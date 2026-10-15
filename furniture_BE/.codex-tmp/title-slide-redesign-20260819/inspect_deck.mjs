import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const source = "D:/KLTN/furniture_BE/BaoCao_BaoVe_KhoaLuan_MyFurnitureStore.pptx";
const outDir = "D:/KLTN/furniture_BE/.codex-tmp/title-slide-redesign-20260819/source-inspect";

async function writeBlob(filePath, blob) {
  await fs.writeFile(filePath, new Uint8Array(await blob.arrayBuffer()));
}

await fs.mkdir(outDir, { recursive: true });
const presentation = await PresentationFile.importPptx(await FileBlob.load(source));
const snapshot = await presentation.inspect({
  kind: "slide,textbox,shape,image,chart,table,notes,layout",
  include: "id,slide,name,title,textPreview,bbox,isPlaceholder,placeholders,alt",
  maxChars: 40000,
});
await fs.writeFile(path.join(outDir, "template-inspect.ndjson"), snapshot.ndjson);

for (const [index, slide] of presentation.slides.items.entries()) {
  const stem = `slide-${String(index + 1).padStart(2, "0")}`;
  await writeBlob(path.join(outDir, `${stem}.png`), await presentation.export({ slide, format: "png", scale: 1 }));
  const layout = await slide.export({ format: "layout" });
  await fs.writeFile(path.join(outDir, `${stem}.layout.json`), await layout.text());
}

const montage = await presentation.export({ format: "webp", montage: true, scale: 1 });
await writeBlob(path.join(outDir, "source-montage.webp"), montage);

const masterSummary = presentation.masters.items.map((master) => ({
  id: master.id,
  name: master.name,
  placeholders: master.placeholders?.summary?.() ?? null,
}));
const layoutSummary = presentation.layouts.items.map((layout) => ({
  id: layout.id,
  name: layout.name,
  parentLayoutId: layout.parentLayoutId,
  placeholders: layout.placeholders?.summary?.() ?? null,
}));
await fs.writeFile(path.join(outDir, "hierarchy.json"), JSON.stringify({ masters: masterSummary, layouts: layoutSummary }, null, 2));
console.log(JSON.stringify({ slides: presentation.slides.items.length, outDir }, null, 2));
