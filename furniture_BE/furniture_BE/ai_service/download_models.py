from __future__ import annotations

import shutil
import urllib.request
from pathlib import Path


MODEL_DIR = Path(__file__).resolve().parent / "models"
MODELS = {
    "depth_anything_v2_vits.onnx": (
        "https://github.com/fabio-sim/Depth-Anything-ONNX/releases/download/v2.0.0/"
        "depth_anything_v2_vits.onnx",
        99_373_606,
    ),
    "segformer-b0-ade512.onnx": (
        "https://huggingface.co/Xenova/segformer-b0-finetuned-ade-512-512/resolve/main/"
        "onnx/model.onnx?download=true",
        15_335_446,
    ),
}


def download(name: str, url: str, expected_size: int) -> None:
    destination = MODEL_DIR / name
    if destination.is_file() and destination.stat().st_size == expected_size:
        print(f"[ok] {name} đã tồn tại")
        return

    temporary = destination.with_suffix(destination.suffix + ".part")
    print(f"[download] {name} ({expected_size / 1024 / 1024:.1f} MB)")
    request = urllib.request.Request(url, headers={"User-Agent": "Furniture-AI-Setup/2A"})
    with urllib.request.urlopen(request, timeout=120) as response, temporary.open("wb") as output:
        shutil.copyfileobj(response, output)

    actual_size = temporary.stat().st_size
    if actual_size != expected_size:
        temporary.unlink(missing_ok=True)
        raise RuntimeError(
            f"Sai kích thước {name}: nhận {actual_size}, mong đợi {expected_size}."
        )
    temporary.replace(destination)
    print(f"[ok] {destination}")


def main() -> None:
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    for name, (url, size) in MODELS.items():
        download(name, url, size)


if __name__ == "__main__":
    main()
