import fs from "node:fs/promises";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const source = "D:\\KLTN\\furniture_BE\\BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx";
const presentation = await PresentationFile.importPptx(await FileBlob.load(source));
const recordsText = await fs.readFile("D:\\KLTN\\furniture_BE\\.codex-tmp\\font-update-20260823\\source-inspect\\source-inspect.ndjson", "utf8");
const record = recordsText.split(/\r?\n/).filter(Boolean).map(JSON.parse).find((x) => x.kind === "textbox" && x.textPreview?.length > 20);
const target = presentation.resolve(record.id);

function keysWithProto(value) {
  const result = new Set();
  let cursor = value;
  while (cursor && cursor !== Object.prototype) {
    for (const key of Reflect.ownKeys(cursor)) result.add(String(key));
    cursor = Object.getPrototypeOf(cursor);
  }
  return [...result].sort();
}

console.log(JSON.stringify({
  record,
  targetKeys: keysWithProto(target),
  textKeys: keysWithProto(target.text),
  textValues: {
    typeface: target.text.typeface,
    fontSize: target.text.fontSize,
    style: target.text.style,
    defaultTextStyle: target.text.defaultTextStyle,
    paragraphsType: typeof target.text.paragraphs,
    paragraphsKeys: keysWithProto(target.text.paragraphs),
    targetParagraphsType: typeof target.paragraphs,
    targetParagraphsKeys: keysWithProto(target.paragraphs),
    firstParagraphKeys: keysWithProto(target.paragraphs?.items?.[0]),
    firstParagraphProto: target.paragraphs?.items?.[0]?.toProto?.(),
    firstParagraphRunsType: typeof target.paragraphs?.items?.[0]?.runs,
    firstParagraphRunsKeys: keysWithProto(target.paragraphs?.items?.[0]?.runs),
    firstRunKeys: keysWithProto(target.paragraphs?.items?.[0]?.runs?.items?.[0]),
    firstRunValues: target.paragraphs?.items?.[0]?.runs?.items?.[0] ? {
      text: target.paragraphs.items[0].runs.items[0].text,
      textStyle: target.paragraphs.items[0].runs.items[0].textStyle,
      resolvedTextStyle: target.paragraphs.items[0].runs.items[0].resolvedTextStyle,
    } : null,
  },
}, null, 2));
for (const query of ["text style font family imported rich text", "paragraph run text style", "text format fontSize fontFamily"]) {
  try {
    const help = presentation.help("*", { search: query, include: ["index", "notes", "examples"], maxChars: 10000 });
    console.log(`HELP ${query}\n${help.ndjson ?? help}`);
  } catch (error) {
    console.log(`HELP ERROR ${query}: ${error}`);
  }
}
