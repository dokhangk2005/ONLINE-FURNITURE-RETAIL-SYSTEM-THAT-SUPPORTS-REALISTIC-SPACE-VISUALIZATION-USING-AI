import fs from "node:fs/promises";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const source = "D:\\KLTN\\furniture_BE\\BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx";
const recordsPath = "D:\\KLTN\\furniture_BE\\.codex-tmp\\font-update-20260823\\source-inspect\\source-inspect.ndjson";
const presentation = await PresentationFile.importPptx(await FileBlob.load(source));
const records = (await fs.readFile(recordsPath, "utf8")).split(/\r?\n/).filter(Boolean).map(JSON.parse);
const analysis = [];
for (const record of records.filter((x) => x.kind === "textbox")) {
  const target = presentation.resolve(record.id);
  const fontSizes = new Set();
  const typefaces = new Set();
  let runs = 0;
  for (const paragraph of target.paragraphs.items) {
    const proto = paragraph.toProto();
    for (const run of proto.runs ?? []) {
      runs += 1;
      if (run.textStyle?.fontSize) fontSizes.add(run.textStyle.fontSize);
      if (run.textStyle?.typeface) typefaces.add(run.textStyle.typeface);
    }
  }
  analysis.push({
    id: record.id,
    slide: record.slide,
    name: record.name,
    textPreview: record.textPreview,
    runs,
    fontSizes: [...fontSizes].sort((a, b) => a - b),
    typefaces: [...typefaces].sort(),
    facadeFontSize: target.text.fontSize,
    facadeTypeface: target.text.typeface,
  });
}
const out = "D:\\KLTN\\furniture_BE\\.codex-tmp\\font-update-20260823\\source-inspect\\text-run-analysis.json";
await fs.writeFile(out, JSON.stringify(analysis, null, 2), "utf8");
const mixed = analysis.filter((x) => x.fontSizes.length > 1);
const dist = {};
for (const item of analysis) for (const size of item.fontSizes) dist[size] = (dist[size] ?? 0) + 1;
console.log(JSON.stringify({ total: analysis.length, mixedCount: mixed.length, mixed: mixed.slice(0, 20), sizeDistribution: dist }, null, 2));
