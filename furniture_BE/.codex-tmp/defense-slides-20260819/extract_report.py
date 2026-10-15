from __future__ import annotations

import json
import shutil
import sys
import zipfile
from pathlib import Path

from docx import Document
from docx.table import Table
from docx.text.paragraph import Paragraph


def iter_block_items(document: Document):
    for child in document.element.body.iterchildren():
        if child.tag.endswith("}p"):
            yield Paragraph(child, document)
        elif child.tag.endswith("}tbl"):
            yield Table(child, document)


def main() -> None:
    source = Path(sys.argv[1])
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)
    media_dir = out_dir / "report_media"
    media_dir.mkdir(parents=True, exist_ok=True)

    doc = Document(source)
    lines: list[str] = []
    headings: list[dict[str, object]] = []
    table_count = 0
    paragraph_count = 0

    for block in iter_block_items(doc):
        if isinstance(block, Paragraph):
            paragraph_count += 1
            text = block.text.strip()
            if not text:
                continue
            style = block.style.name if block.style is not None else ""
            lines.append(f"[P][{style}] {text}")
            if style.lower().startswith("heading") or style.lower().startswith("tiêu đề"):
                headings.append({"style": style, "text": text})
        else:
            table_count += 1
            lines.append(f"[TABLE {table_count}]")
            for row in block.rows:
                cells = [" ".join(cell.text.split()) for cell in row.cells]
                lines.append(" | ".join(cells))
            lines.append(f"[/TABLE {table_count}]")

    (out_dir / "report_text.txt").write_text("\n".join(lines), encoding="utf-8")
    (out_dir / "report_headings.json").write_text(
        json.dumps(headings, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    media: list[dict[str, object]] = []
    with zipfile.ZipFile(source) as archive:
        for name in archive.namelist():
            if not name.startswith("word/media/") or name.endswith("/"):
                continue
            target = media_dir / Path(name).name
            with archive.open(name) as src, target.open("wb") as dst:
                shutil.copyfileobj(src, dst)
            media.append({"name": target.name, "bytes": target.stat().st_size})

    summary = {
        "source": str(source),
        "paragraphs": paragraph_count,
        "tables": table_count,
        "headings": len(headings),
        "inline_shapes": len(doc.inline_shapes),
        "media": sorted(media, key=lambda item: item["name"]),
        "sections": len(doc.sections),
    }
    (out_dir / "report_summary.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
