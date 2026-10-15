import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const source = "D:\\KLTN\\furniture_BE\\BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx";
const outDir = "D:\\KLTN\\furniture_BE\\.codex-tmp\\font-update-20260823\\source-inspect";

async function writeBlob(filePath, blob) {
  await fs.writeFile(filePath, new Uint8Array(await blob.arrayBuffer()));
}

await fs.mkdir(outDir, { recursive: true });
const presentation = await PresentationFile.importPptx(await FileBlob.load(source));
const snapshot = await presentation.inspect({
  kind: "slide,textbox,shape,image,table,chart,notes,layout",
  include: "id,slide,name,title,text,textPreview,textChars,textLines,bbox,bboxUnit,isPlaceholder,placeholders,alt",
  maxChars: 200000,
});
await fs.writeFile(path.join(outDir, "source-inspect.ndjson"), snapshot.ndjson, "utf8");

const records = snapshot.ndjson.split(/\r?\n/).filter(Boolean).map((line) => JSON.parse(line));
const styles = [];
for (const record of records.filter((item) => item.kind === "textbox" || item.kind === "shape")) {
  try {
    const target = presentation.resolve(record.id);
    if (!target?.text || !String(target.text).trim()) continue;
    styles.push({
      id: record.id,
      slide: record.slide,
      name: record.name,
      textPreview: record.textPreview,
      style: target.text.style,
      position: target.position,
    });
  } catch {}
}
await fs.writeFile(path.join(outDir, "text-styles.json"), JSON.stringify(styles, null, 2), "utf8");

for (let index = 0; index < presentation.slides.items.length; index += 1) {
  const slide = presentation.slides.items[index];
  const stem = `slide-${String(index + 1).padStart(2, "0")}`;
  await writeBlob(path.join(outDir, `${stem}.png`), await presentation.export({ slide, format: "png", scale: 1 }));
  const layout = await slide.export({ format: "layout" });
  await fs.writeFile(path.join(outDir, `${stem}.layout.json`), await layout.text(), "utf8");
}

await writeBlob(path.join(outDir, "source-montage.webp"), await presentation.export({ format: "webp", montage: true, scale: 1 }));
await fs.writeFile(path.join(outDir, "summary.json"), JSON.stringify({ slides: presentation.slides.items.length, textObjects: styles.length }, null, 2), "utf8");
console.log(JSON.stringify({ slides: presentation.slides.items.length, textObjects: styles.length, outDir }));
