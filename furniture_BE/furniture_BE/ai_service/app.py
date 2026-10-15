from __future__ import annotations

import io
import json
import threading
import time
import zipfile
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

import numpy as np
import onnxruntime as ort
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.responses import Response
from PIL import Image, ImageFilter, ImageOps, UnidentifiedImageError
from rembg import new_session, remove


MAX_IMAGE_BYTES = 15 * 1024 * 1024
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/gif"}
MODEL_DIR = Path(__file__).resolve().parent / "models"
DEPTH_MODEL_PATH = MODEL_DIR / "depth_anything_v2_vits.onnx"
SEGMENTATION_MODEL_PATH = MODEL_DIR / "segformer-b0-ade512.onnx"
SCENE_MODEL_VERSION = (
    "depth-anything-v2-vits+segformer-b0-ade20k+placement-v2b+lighting-v2c+occlusion-v2d+floor-envelope-v2e1"
)

app = FastAPI(title="Furniture AI Service", version="2.0.0")
_background_session = None
_depth_session: ort.InferenceSession | None = None
_segmentation_session: ort.InferenceSession | None = None
_background_lock = threading.Lock()
_scene_session_lock = threading.Lock()
_analysis_lock = threading.Lock()


def get_background_session():
    global _background_session
    if _background_session is None:
        with _background_lock:
            if _background_session is None:
                # u2netp is intentionally small enough for CPU background removal.
                _background_session = new_session("u2netp")
    return _background_session


def _new_onnx_session(model_path: Path) -> ort.InferenceSession:
    options = ort.SessionOptions()
    options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
    options.intra_op_num_threads = 0
    return ort.InferenceSession(
        str(model_path), sess_options=options, providers=["CPUExecutionProvider"]
    )


def get_scene_sessions() -> tuple[ort.InferenceSession, ort.InferenceSession]:
    global _depth_session, _segmentation_session
    missing = [
        path.name
        for path in (DEPTH_MODEL_PATH, SEGMENTATION_MODEL_PATH)
        if not path.is_file()
    ]
    if missing:
        raise HTTPException(
            status_code=503,
            detail=(
                "Thiếu model phân tích phòng: "
                + ", ".join(missing)
                + ". Hãy chạy download_models.py."
            ),
        )

    if _depth_session is None or _segmentation_session is None:
        with _scene_session_lock:
            if _depth_session is None:
                _depth_session = _new_onnx_session(DEPTH_MODEL_PATH)
            if _segmentation_session is None:
                _segmentation_session = _new_onnx_session(SEGMENTATION_MODEL_PATH)
    return _depth_session, _segmentation_session


def _read_and_validate_image(source: bytes) -> Image.Image:
    try:
        with Image.open(io.BytesIO(source)) as opened:
            image = ImageOps.exif_transpose(opened).convert("RGB")
            image.load()
        return image
    except (UnidentifiedImageError, OSError) as exc:
        raise HTTPException(status_code=400, detail="File không phải ảnh hợp lệ.") from exc


def _prepare_tensor(image: Image.Image, size: int) -> np.ndarray:
    resized = image.resize((size, size), Image.Resampling.BICUBIC)
    array = np.asarray(resized, dtype=np.float32) / 255.0
    mean = np.asarray([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.asarray([0.229, 0.224, 0.225], dtype=np.float32)
    array = (array - mean) / std
    return np.ascontiguousarray(array.transpose(2, 0, 1)[None, ...])


def _run_depth(image: Image.Image, session: ort.InferenceSession) -> np.ndarray:
    input_info = session.get_inputs()[0]
    tensor = _prepare_tensor(image, 518)
    depth = np.asarray(session.run(None, {input_info.name: tensor})[0]).squeeze()
    if depth.ndim != 2:
        raise RuntimeError(f"Kích thước đầu ra depth không hợp lệ: {depth.shape}")

    finite = depth[np.isfinite(depth)]
    if finite.size == 0:
        raise RuntimeError("Model depth không trả về giá trị hợp lệ.")
    low, high = np.percentile(finite, [2.0, 98.0])
    if high - low < 1e-6:
        normalized = np.zeros_like(depth, dtype=np.float32)
    else:
        normalized = np.clip((depth - low) / (high - low), 0.0, 1.0)

    depth_image = Image.fromarray(normalized.astype(np.float32), mode="F")
    depth_image = depth_image.resize(image.size, Image.Resampling.BICUBIC)
    return np.clip(np.asarray(depth_image), 0.0, 1.0)


def _run_segmentation(
    image: Image.Image, session: ort.InferenceSession
) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    input_info = session.get_inputs()[0]
    tensor = _prepare_tensor(image, 512)
    logits = np.asarray(session.run(None, {input_info.name: tensor})[0]).squeeze(0)
    if logits.ndim != 3:
        raise RuntimeError(f"Kích thước đầu ra segmentation không hợp lệ: {logits.shape}")

    labels = np.argmax(logits, axis=0).astype(np.uint8)
    labels_image = Image.fromarray(labels, mode="L").resize(
        image.size, Image.Resampling.NEAREST
    )
    labels = np.asarray(labels_image)

    # ADE20K: wall=0, floor=3, rug=28. Rug is included as a usable floor area.
    floor_mask = np.isin(labels, [3, 28])
    wall_mask = labels == 0
    return floor_mask, wall_mask, labels


def _mask_png(mask: np.ndarray) -> bytes:
    mask_image = Image.fromarray((mask.astype(np.uint8) * 255), mode="L")
    mask_image = mask_image.filter(ImageFilter.MedianFilter(size=3))
    buffer = io.BytesIO()
    mask_image.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def _occlusion_mask(labels: np.ndarray) -> np.ndarray:
    # Indoor objects that should normally be drawn in front of a newly placed item.
    object_labels = np.asarray(
        [
            7, 10, 12, 15, 17, 18, 19, 22, 23, 24, 30, 31, 33, 35, 36,
            37, 38, 39, 40, 41, 42, 44, 45, 47, 49, 50, 53, 55, 56, 57,
            59, 62, 63, 64, 65, 66, 67, 69, 70, 71, 73, 74, 75, 77, 81,
            82, 85, 89, 92, 95, 97, 98, 99, 100, 101, 107, 108, 110,
            112, 115, 117, 118, 120, 121, 124, 125, 130, 131, 132, 133,
            134, 135, 137, 138, 139, 141, 142, 143, 145, 146, 147, 148,
        ],
        dtype=np.uint8,
    )
    raw = np.isin(labels, object_labels)
    cleaned_image = Image.fromarray((raw.astype(np.uint8) * 255), mode="L")
    cleaned_image = cleaned_image.filter(ImageFilter.MedianFilter(size=5))
    cleaned_image = cleaned_image.filter(ImageFilter.MaxFilter(size=3))
    return np.asarray(cleaned_image) >= 128


def _foreground_png(image: Image.Image, mask: np.ndarray) -> bytes:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgba[..., 3] = mask.astype(np.uint8) * 255
    foreground = Image.fromarray(rgba, mode="RGBA")
    buffer = io.BytesIO()
    foreground.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def _depth_png(depth: np.ndarray) -> bytes:
    # Dark pixels are farther away; bright pixels are nearer to the camera.
    gray = (depth * 255.0).round().astype(np.uint8)
    # Lightweight blue -> cyan -> yellow heatmap without an OpenCV dependency.
    value = gray.astype(np.float32) / 255.0
    red = np.clip(2.2 * value - 0.6, 0.0, 1.0)
    green = np.clip(2.0 - np.abs(value - 0.55) * 3.0, 0.0, 1.0)
    blue = np.clip(1.4 - 2.0 * value, 0.0, 1.0)
    heatmap = np.stack([red, green, blue], axis=-1)
    image = Image.fromarray((heatmap * 255.0).astype(np.uint8), mode="RGB")
    buffer = io.BytesIO()
    image.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def _overlay_png(
    image: Image.Image, floor_mask: np.ndarray, wall_mask: np.ndarray
) -> bytes:
    base = np.asarray(image, dtype=np.float32)
    color = base.copy()
    color[floor_mask] = [30.0, 210.0, 125.0]
    color[wall_mask] = [55.0, 125.0, 255.0]
    active = floor_mask | wall_mask
    output = base.copy()
    output[active] = base[active] * 0.55 + color[active] * 0.45
    overlay = Image.fromarray(np.clip(output, 0, 255).astype(np.uint8), mode="RGB")
    buffer = io.BytesIO()
    overlay.save(buffer, format="PNG", optimize=True)
    return buffer.getvalue()


def _largest_component(mask: np.ndarray, max_side: int = 160) -> np.ndarray:
    height, width = mask.shape
    scale = min(1.0, max_side / max(height, width))
    grid_width = max(24, round(width * scale))
    grid_height = max(24, round(height * scale))
    small = np.asarray(
        Image.fromarray((mask.astype(np.uint8) * 255), mode="L").resize(
            (grid_width, grid_height), Image.Resampling.NEAREST
        )
    ) > 0
    visited = np.zeros_like(small, dtype=bool)
    largest: list[tuple[int, int]] = []

    for start_y, start_x in zip(*np.nonzero(small & ~visited)):
        if visited[start_y, start_x]:
            continue
        stack = [(int(start_y), int(start_x))]
        visited[start_y, start_x] = True
        component: list[tuple[int, int]] = []
        while stack:
            y, x = stack.pop()
            component.append((y, x))
            for next_y, next_x in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                if (
                    0 <= next_y < grid_height
                    and 0 <= next_x < grid_width
                    and small[next_y, next_x]
                    and not visited[next_y, next_x]
                ):
                    visited[next_y, next_x] = True
                    stack.append((next_y, next_x))
        if len(component) > len(largest):
            largest = component

    output = np.zeros_like(small, dtype=bool)
    if largest:
        ys, xs = zip(*largest)
        output[np.asarray(ys), np.asarray(xs)] = True
    return output


def _row_span(mask: np.ndarray, row: int, radius: int = 2) -> tuple[int, int] | None:
    start = max(0, row - radius)
    end = min(mask.shape[0], row + radius + 1)
    active = np.any(mask[start:end], axis=0)
    indexes = np.flatnonzero(active)
    if indexes.size == 0:
        return None

    splits = np.where(np.diff(indexes) > 1)[0] + 1
    groups = np.split(indexes, splits)
    longest = max(groups, key=len)
    return int(longest[0]), int(longest[-1])


def _estimate_plane(mask: np.ndarray, kind: str) -> dict | None:
    component = _largest_component(mask)
    if not component.any():
        return None

    row_counts = component.sum(axis=1)
    minimum_width = max(3, round(float(row_counts.max()) * 0.12))
    valid_rows = np.flatnonzero(row_counts >= minimum_width)
    if valid_rows.size < 4:
        return None

    grid_height, grid_width = component.shape
    top_row = int(valid_rows[0])
    bottom_row = int(valid_rows[-1])
    if bottom_row - top_row < grid_height * 0.08:
        return None

    top_span = _row_span(component, top_row, radius=3)
    bottom_span = _row_span(component, bottom_row, radius=3)
    if top_span is None or bottom_span is None:
        return None

    top_left, top_right = top_span
    bottom_left, bottom_right = bottom_span
    if kind == "floor":
        # Semantic segmentation commonly misses bright/low-contrast strips along
        # the side walls. A visible floor nevertheless continues towards the
        # lower image edge, so turn the detected component into a conservative
        # placement envelope instead of treating its exact pixels as a hard box.
        side_expansion = max(2, round(grid_width * 0.08))
        top_left = max(0, top_left - side_expansion)
        top_right = min(grid_width - 1, top_right + side_expansion)

        # A tiny first floor row is often only the most confident centre patch,
        # not the true room width. Preserve its centre but give the placement
        # envelope a useful minimum span so the visualization does not imply
        # that valid side-floor areas are forbidden.
        target_top_width = min(
            grid_width - 1,
            max(top_right - top_left, round((grid_width - 1) * 0.82)),
        )
        top_center = (top_left + top_right) / 2.0
        top_left = round(top_center - target_top_width / 2.0)
        top_right = top_left + target_top_width
        if top_left < 0:
            top_right -= top_left
            top_left = 0
        if top_right >= grid_width:
            top_left -= top_right - (grid_width - 1)
            top_right = grid_width - 1
        top_left = max(0, top_left)
        bottom_row = grid_height - 1
        bottom_left = 0
        bottom_right = grid_width - 1
    elif kind == "wall":
        # A wall plane should remain useful when furniture/windows split its mask.
        all_y, all_x = np.nonzero(component)
        left = int(np.percentile(all_x, 2))
        right = int(np.percentile(all_x, 98))
        top_left = max(left, min(top_left, right))
        top_right = min(right, max(top_right, left))
        bottom_left = max(left, min(bottom_left, right))
        bottom_right = min(right, max(bottom_right, left))

    def point(x: int, y: int) -> dict[str, float]:
        return {
            "x": round(float(x / max(1, grid_width - 1)), 5),
            "y": round(float(y / max(1, grid_height - 1)), 5),
        }

    component_area = float(component.mean())
    original_coverage = max(float(mask.mean()), 1e-6)
    retained_ratio = min(1.0, component_area / original_coverage)
    confidence = min(1.0, retained_ratio * 0.65 + min(component_area * 4.0, 0.35))
    return {
        "kind": kind,
        "points": [
            point(top_left, top_row),
            point(top_right, top_row),
            point(bottom_right, bottom_row),
            point(bottom_left, bottom_row),
        ],
        "confidence": round(confidence, 4),
    }


def _make_depth_grid(depth: np.ndarray, width: int = 32, height: int = 24) -> dict:
    grid_image = Image.fromarray(depth.astype(np.float32), mode="F").resize(
        (width, height), Image.Resampling.BILINEAR
    )
    values = np.clip(np.asarray(grid_image), 0.0, 1.0)
    return {
        "width": width,
        "height": height,
        "values": (values * 255.0).round().astype(np.uint8).ravel().tolist(),
    }


def _analyze_lighting(image: Image.Image, grid_width: int = 16, grid_height: int = 12) -> dict:
    rgb = np.asarray(image, dtype=np.float32) / 255.0
    luminance = (
        rgb[..., 0] * 0.2126 + rgb[..., 1] * 0.7152 + rgb[..., 2] * 0.0722
    )
    ambient = float(np.median(luminance))
    contrast = float(np.std(luminance) / max(float(np.mean(luminance)), 0.05))
    channel_means = rgb.reshape(-1, 3).mean(axis=0)
    temperature = float(
        np.clip(
            (channel_means[0] - channel_means[2])
            / max(float(channel_means[0] + channel_means[2]), 0.05)
            * 2.2,
            -1.0,
            1.0,
        )
    )

    threshold = float(np.percentile(luminance, 85))
    weights = np.clip(luminance - threshold, 0.0, None)
    weight_sum = float(weights.sum())
    if weight_sum > 1e-6:
        column_weights = weights.sum(axis=0)
        row_weights = weights.sum(axis=1)
        light_x = float(
            np.dot(column_weights, np.arange(image.width))
            / weight_sum
            / max(1, image.width - 1)
        )
        light_y = float(
            np.dot(row_weights, np.arange(image.height))
            / weight_sum
            / max(1, image.height - 1)
        )
    else:
        light_x, light_y = 0.35, 0.15

    direction_x = 0.5 - light_x
    direction_y = 0.65 - light_y
    direction_length = max((direction_x**2 + direction_y**2) ** 0.5, 1e-6)
    direction_x /= direction_length
    direction_y /= direction_length

    grid_image = Image.fromarray(luminance.astype(np.float32), mode="F").resize(
        (grid_width, grid_height), Image.Resampling.BILINEAR
    )
    grid_values = np.clip(np.asarray(grid_image), 0.0, 1.0)
    softness = float(np.clip(1.0 - contrast * 0.75, 0.25, 0.9))
    confidence = float(np.clip(weight_sum / max(luminance.size * 0.035, 1.0), 0.2, 1.0))
    return {
        "ambientBrightness": round(ambient, 5),
        "colorTemperature": round(temperature, 5),
        "contrast": round(contrast, 5),
        "lightPosition": {"x": round(light_x, 5), "y": round(light_y, 5)},
        "shadowDirection": {
            "x": round(direction_x, 5),
            "y": round(direction_y, 5),
        },
        "shadowSoftness": round(softness, 5),
        "confidence": round(confidence, 5),
        "grid": {
            "width": grid_width,
            "height": grid_height,
            "values": (grid_values * 255.0).round().astype(np.uint8).ravel().tolist(),
        },
    }


def _analyze_scene(image: Image.Image) -> tuple[dict, dict[str, bytes]]:
    depth_session, segmentation_session = get_scene_sessions()
    started = time.perf_counter()
    with _analysis_lock:
        depth_started = time.perf_counter()
        depth = _run_depth(image, depth_session)
        depth_ms = round((time.perf_counter() - depth_started) * 1000)

        segmentation_started = time.perf_counter()
        floor_mask, wall_mask, labels = _run_segmentation(image, segmentation_session)
        segmentation_ms = round((time.perf_counter() - segmentation_started) * 1000)

    occlusion_mask = _occlusion_mask(labels)
    metadata = {
        "modelVersion": SCENE_MODEL_VERSION,
        "width": image.width,
        "height": image.height,
        "floorCoverage": round(float(floor_mask.mean()), 5),
        "wallCoverage": round(float(wall_mask.mean()), 5),
        "depthMeaning": "0=far,1=near",
        "depthInferenceMs": depth_ms,
        "segmentationInferenceMs": segmentation_ms,
        "floorPlane": _estimate_plane(floor_mask, "floor"),
        "wallPlane": _estimate_plane(wall_mask, "wall"),
        "depthGrid": _make_depth_grid(depth),
        "lighting": _analyze_lighting(image),
        "occlusionCoverage": round(float(occlusion_mask.mean()), 5),
    }
    builders = {
        "depth.png": lambda: _depth_png(depth),
        "floor-mask.png": lambda: _mask_png(floor_mask),
        "wall-mask.png": lambda: _mask_png(wall_mask),
        "overlay.png": lambda: _overlay_png(image, floor_mask, wall_mask),
        "occlusion-mask.png": lambda: _mask_png(occlusion_mask),
        "foreground.png": lambda: _foreground_png(image, occlusion_mask),
    }
    with ThreadPoolExecutor(max_workers=4, thread_name_prefix="scene-encode") as pool:
        futures = {name: pool.submit(builder) for name, builder in builders.items()}
        files = {name: future.result() for name, future in futures.items()}
    metadata["processingMs"] = round((time.perf_counter() - started) * 1000)
    return metadata, files


@app.get("/health")
def health():
    scene_models_available = DEPTH_MODEL_PATH.is_file() and SEGMENTATION_MODEL_PATH.is_file()
    return {
        "available": True,
        "modelLoaded": _background_session is not None,
        "sceneAnalysis": {
            "available": scene_models_available,
            "depthLoaded": _depth_session is not None,
            "segmentationLoaded": _segmentation_session is not None,
            "modelVersion": SCENE_MODEL_VERSION,
        },
    }


@app.post("/remove-background")
async def remove_background(file: UploadFile = File(...)):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=400, detail="Chỉ chấp nhận ảnh JPG, PNG, WEBP hoặc GIF.")

    source = await file.read(MAX_IMAGE_BYTES + 1)
    if not source:
        raise HTTPException(status_code=400, detail="Ảnh rỗng.")
    if len(source) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Ảnh vượt quá 15 MB.")

    _read_and_validate_image(source)
    try:
        result = remove(source, session=get_background_session(), force_return_bytes=True)
        with Image.open(io.BytesIO(result)) as output:
            rgba = output.convert("RGBA")
            buffer = io.BytesIO()
            rgba.save(buffer, format="PNG", optimize=True)
        return Response(content=buffer.getvalue(), media_type="image/png")
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Không thể xóa nền: {exc}") from exc


@app.post("/analyze-room")
async def analyze_room(file: UploadFile = File(...)):
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(status_code=400, detail="Chỉ chấp nhận ảnh JPG, PNG, WEBP hoặc GIF.")

    source = await file.read(MAX_IMAGE_BYTES + 1)
    if not source:
        raise HTTPException(status_code=400, detail="Ảnh rỗng.")
    if len(source) > MAX_IMAGE_BYTES:
        raise HTTPException(status_code=413, detail="Ảnh vượt quá 15 MB.")

    image = _read_and_validate_image(source)
    # Keep the saved analysis practical for web delivery while preserving aspect ratio.
    if max(image.size) > 1600:
        image.thumbnail((1600, 1600), Image.Resampling.LANCZOS)

    try:
        metadata, files = _analyze_scene(image)
        archive_buffer = io.BytesIO()
        with zipfile.ZipFile(archive_buffer, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            archive.writestr(
                "metadata.json",
                json.dumps(metadata, ensure_ascii=False, separators=(",", ":")),
            )
            for name, content in files.items():
                archive.writestr(name, content)
        return Response(
            content=archive_buffer.getvalue(),
            media_type="application/zip",
            headers={"X-Scene-Model-Version": SCENE_MODEL_VERSION},
        )
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Không thể phân tích phòng: {exc}") from exc
