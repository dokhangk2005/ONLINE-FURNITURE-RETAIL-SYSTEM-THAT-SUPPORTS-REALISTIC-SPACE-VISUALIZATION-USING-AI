from __future__ import annotations

import json
import sys
from pathlib import Path

from docx import Document
from docx.oxml.ns import qn


def clean(text: str) -> str:
    return " ".join(text.split())


def main() -> None:
    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    doc = Document(source)
    paragraphs = list(doc.paragraphs)
    records: list[dict[str, object]] = []

    for index, paragraph in enumerate(paragraphs):
        blips = paragraph._p.xpath(".//a:blip")
        if not blips:
            continue
        for blip in blips:
            rid = blip.get(qn("r:embed")) or blip.get(qn("r:link"))
            target = None
            if rid and rid in doc.part.rels:
                rel = doc.part.rels[rid]
                target = Path(str(rel.target_part.partname)).name
            before = [clean(p.text) for p in paragraphs[max(0, index - 3):index] if clean(p.text)]
            after = [clean(p.text) for p in paragraphs[index + 1:index + 4] if clean(p.text)]
            records.append(
                {
                    "paragraph_index": index,
                    "relationship_id": rid,
                    "media_name": target,
                    "paragraph_text": clean(paragraph.text),
                    "before": before,
                    "after": after,
                }
            )

    output.write_text(json.dumps(records, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(records, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
