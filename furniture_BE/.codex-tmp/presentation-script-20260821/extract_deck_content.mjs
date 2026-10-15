import fs from "node:fs/promises";
import { FileBlob, PresentationFile } from "@oai/artifact-tool";

const source = "D:/KLTN/furniture_BE/BaoCao_BaoVe_KhoaLuan_MyFurnitureStore_TrangDau_ToiGian.pptx";
const out = "D:/KLTN/furniture_BE/.codex-tmp/presentation-script-20260821/deck-content.ndjson";

const presentation = await PresentationFile.importPptx(await FileBlob.load(source));
const snapshot = await presentation.inspect({
  kind: "slide,textbox,notes",
  include: "id,slide,title,name,text,textPreview",
  maxChars: 120000,
});
await fs.writeFile(out, snapshot.ndjson);
console.log(JSON.stringify({ slides: presentation.slides.items.length, out }, null, 2));
