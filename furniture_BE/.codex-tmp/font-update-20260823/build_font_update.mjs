import fs from "node:fs/promises";
import path from "node:path";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const sourcePath = String.raw`D:\KLTN\furniture_BE\BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx`;
const outputPath = String.raw`D:\KLTN\furniture_BE\BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TimesNewRoman.pptx`;
const workDir = String.raw`D:\KLTN\furniture_BE\.codex-tmp\font-update-20260823`;
const renderDir = path.join(workDir, "final-render");
const fontName = "Times New Roman";
const sizeIncrease = 2; // artifact pixels = approximately 1.5 PowerPoint points

async function writeBlob(filePath, blob) {
  await fs.writeFile(filePath, new Uint8Array(await blob.arrayBuffer()));
}

await fs.rm(renderDir, { recursive: true, force: true });
await fs.mkdir(renderDir, { recursive: true });

const presentation = await PresentationFile.importPptx(await FileBlob.load(sourcePath));
const sourceInspection = await presentation.inspect({
  kind: "slide,textbox,shape,image,table,chart,notes,layout",
  include: "id,slide,name,title,text,textPreview,textChars,textLines,bbox,bboxUnit,isPlaceholder,placeholders,alt",
  maxChars: 200000,
});
const sourceRecords = sourceInspection.ndjson
  .split(/\r?\n/)
  .filter(Boolean)
  .map((line) => JSON.parse(line));

const textRecords = sourceRecords.filter(
  (record) => record.kind === "textbox" && record.id && record.text !== undefined,
);

const editPlan = [];
for (const record of textRecords) {
  const target = presentation.resolve(record.id);
  if (!target?.text) continue;

  const beforeTypeface = target.text.typeface;
  const beforeSize = target.text.fontSize;
  if (!Number.isFinite(beforeSize)) {
    throw new Error(`Missing uniform font size for ${record.id}`);
  }

  target.text.typeface = fontName;
  target.text.fontSize = beforeSize + sizeIncrease;

  editPlan.push({
    slide: record.slide,
    sourceElementId: record.id,
    textPreview: String(record.text).replace(/\s+/g, " ").trim().slice(0, 90),
    beforeTypeface,
    afterTypeface: fontName,
    beforeSize,
    afterSize: beforeSize + sizeIncrease,
  });
}

const frameMap = {
  template: path.basename(sourcePath),
  output: path.basename(outputPath),
  policy: "Preserve all 20 original slides and edit only global typography.",
  slides: Array.from({ length: presentation.slides.items.length }, (_, index) => ({
    outputSlide: index + 1,
    sourceSlide: index + 1,
    narrativeRole: `Preserve original slide ${index + 1}`,
    reuseMode: "duplicate-slide",
    editTargets: editPlan
      .filter((item) => item.slide === index + 1)
      .map((item) => ({
        sourceElementId: item.sourceElementId,
        action: "rewrite",
        reason: "Change typeface to Times New Roman and increase size by 2 artifact pixels.",
      })),
  })),
};

await fs.writeFile(
  path.join(workDir, "template-frame-map.json"),
  JSON.stringify(frameMap, null, 2),
  "utf8",
);
await fs.writeFile(
  path.join(workDir, "typography-edit-plan.json"),
  JSON.stringify(editPlan, null, 2),
  "utf8",
);

const blob = await PresentationFile.exportPptx(presentation);
await blob.save(outputPath);

const finalPresentation = await PresentationFile.importPptx(await FileBlob.load(outputPath));
const finalInspection = await finalPresentation.inspect({
  kind: "slide,textbox,shape,image,table,chart,notes,layout",
  include: "id,slide,name,title,text,textPreview,textChars,textLines,bbox,bboxUnit,isPlaceholder,placeholders,alt",
  maxChars: 200000,
});
const finalRecords = finalInspection.ndjson
  .split(/\r?\n/)
  .filter(Boolean)
  .map((line) => JSON.parse(line));

const finalTextRecords = finalRecords.filter(
  (record) => record.kind === "textbox" && record.id && record.text !== undefined,
);
const mismatchedTypefaces = [];
for (const record of finalTextRecords) {
  const target = finalPresentation.resolve(record.id);
  if (target?.text?.typeface !== fontName) {
    mismatchedTypefaces.push({ id: record.id, typeface: target?.text?.typeface ?? null });
  }
}
if (mismatchedTypefaces.length) {
  throw new Error(`Typeface verification failed: ${JSON.stringify(mismatchedTypefaces.slice(0, 10))}`);
}

for (let index = 0; index < finalPresentation.slides.items.length; index += 1) {
  const slide = finalPresentation.slides.items[index];
  await writeBlob(
    path.join(renderDir, `slide-${String(index + 1).padStart(2, "0")}.png`),
    await finalPresentation.export({ slide, format: "png", scale: 1.5 }),
  );

  const layout = await slide.export({ format: "layout" });
  await fs.writeFile(
    path.join(renderDir, `slide-${String(index + 1).padStart(2, "0")}-layout.json`),
    await layout.text(),
    "utf8",
  );
}

await writeBlob(
  path.join(renderDir, "montage.webp"),
  await finalPresentation.export({ format: "webp", montage: true, scale: 1 }),
);

const report = {
  sourcePath,
  outputPath,
  slideCount: finalPresentation.slides.items.length,
  editedTextObjectCount: editPlan.length,
  finalTextObjectCount: finalTextRecords.length,
  typeface: fontName,
  sizeIncreaseArtifactPixels: sizeIncrease,
  approximateIncreasePoints: 1.5,
  minBeforeSize: Math.min(...editPlan.map((item) => item.beforeSize)),
  maxBeforeSize: Math.max(...editPlan.map((item) => item.beforeSize)),
  minAfterSize: Math.min(...editPlan.map((item) => item.afterSize)),
  maxAfterSize: Math.max(...editPlan.map((item) => item.afterSize)),
  mismatchedTypefaceCount: mismatchedTypefaces.length,
};
await fs.writeFile(path.join(workDir, "edit-report.json"), JSON.stringify(report, null, 2), "utf8");
process.stdout.write(`${JSON.stringify(report)}\n`);
