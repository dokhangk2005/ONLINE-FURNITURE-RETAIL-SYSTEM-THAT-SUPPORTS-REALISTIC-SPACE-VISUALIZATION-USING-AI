import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const SOURCE_PPTX = "D:/KLTN/furniture_BE/.codex-tmp/title-slide-redesign-20260819/template-starter.pptx";
const REFERENCE_IMAGE = "D:/KLTN/furniture_BE/.codex-tmp/title-slide-redesign-20260819/huflit-logo-white.png";
const TMP_DIR = "D:/KLTN/furniture_BE/.codex-tmp/title-slide-redesign-20260819";
const FINAL_PPTX = "D:/KLTN/furniture_BE/BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx";
const FINAL_INSPECT = path.join(TMP_DIR, "final-inspect");

async function writeBlob(filePath, blob) {
  await fs.writeFile(filePath, new Uint8Array(await blob.arrayBuffer()));
}

function styleText(shape, text, frame, fontSize, options = {}) {
  shape.text = text;
  shape.frame = frame;
  shape.text.style = {
    fontSize,
    typeface: "Arial",
    color: options.color ?? "#101828",
    bold: options.bold ?? false,
    alignment: options.alignment ?? "left",
    verticalAlignment: options.verticalAlignment ?? "top",
    autoFit: "none",
    wrap: "square",
  };
}

await fs.mkdir(FINAL_INSPECT, { recursive: true });
const presentation = await PresentationFile.importPptx(await FileBlob.load(SOURCE_PPTX));
const slide = presentation.resolve("sl/y90nupkv");

const school = presentation.resolve("sh/547294r6");
styleText(
  school,
  "BỘ GIÁO DỤC VÀ ĐÀO TẠO · TRƯỜNG ĐẠI HỌC NGOẠI NGỮ – TIN HỌC TP. HỒ CHÍ MINH\nKHOA CÔNG NGHỆ THÔNG TIN",
  { left: 100, top: 28, width: 1080, height: 58 },
  16,
  { bold: true, alignment: "center", color: "#344054" },
);

const defenseLabel = presentation.resolve("sh/7qp4be9c");
styleText(
  defenseLabel,
  "BẢO VỆ ĐỒ ÁN KHÓA LUẬN TỐT NGHIỆP",
  { left: 220, top: 224, width: 840, height: 38 },
  24,
  { bold: true, alignment: "center", color: "#3D8DFF" },
);

const title = presentation.resolve("sh/k3yl0zql");
styleText(
  title,
  "Hệ thống bán lẻ nội thất trực tuyến\nhỗ trợ phối cảnh không gian thực bằng AI",
  { left: 105, top: 292, width: 1070, height: 126 },
  43,
  { bold: true, alignment: "center", verticalAlignment: "middle" },
);

const students = presentation.resolve("sh/65g3298r");
styleText(
  students,
  "SINH VIÊN THỰC HIỆN\nĐỗ Minh Vĩ Khang — 23DH114848\nTrần Ngọc Nhật Duy — 23DH110529",
  { left: 170, top: 492, width: 460, height: 112 },
  18,
  { color: "#344054" },
);

const advisor = presentation.resolve("sh/ts7md4r2");
styleText(
  advisor,
  "GIẢNG VIÊN HƯỚNG DẪN\nThS. Lương Văn Minh\nTP.HCM · 08/2026",
  { left: 715, top: 492, width: 395, height: 112 },
  18,
  { color: "#344054" },
);

const logo = presentation.resolve("im/dkb2xcfy");
const logoBytes = await fs.readFile(REFERENCE_IMAGE);
logo.replace({
  blob: logoBytes,
  contentType: "image/png",
  alt: "Logo HUFLIT từ ảnh tham chiếu do người dùng cung cấp",
  fit: "cover",
});
logo.frame = { left: 560, top: 104, width: 160, height: 104 };
logo.crop = { left: 0, top: 0, right: 0, bottom: 0 };
logo.fit = "contain";
logo.geometry = "rect";
logo.borderRadius = 0;
logo.lockAspectRatio = true;

slide.speakerNotes.append(
  "\n[Sources]\n- Ảnh tham chiếu và logo HUFLIT: tệp do người dùng cung cấp (codex-clipboard-746ead6d-41b2-4f75-b4b2-bf0af0ead1a5.png).",
);

const beforeAfter = await presentation.inspect({
  target: { id: "sl/y90nupkv", beforeLines: 0, afterLines: 12 },
  kind: "slide,textbox,shape,image,notes",
  maxChars: 12000,
});
await fs.writeFile(path.join(FINAL_INSPECT, "slide-01-inspect.ndjson"), beforeAfter.ndjson);

for (const [index, currentSlide] of presentation.slides.items.entries()) {
  const stem = `slide-${String(index + 1).padStart(2, "0")}`;
  await writeBlob(path.join(FINAL_INSPECT, `${stem}.png`), await presentation.export({ slide: currentSlide, format: "png", scale: 1 }));
  const layout = await currentSlide.export({ format: "layout" });
  await fs.writeFile(path.join(FINAL_INSPECT, `${stem}.layout.json`), await layout.text());
}

const pptx = await PresentationFile.exportPptx(presentation);
await pptx.save(FINAL_PPTX);
console.log(JSON.stringify({ finalPptx: FINAL_PPTX, slides: presentation.slides.items.length }, null, 2));
