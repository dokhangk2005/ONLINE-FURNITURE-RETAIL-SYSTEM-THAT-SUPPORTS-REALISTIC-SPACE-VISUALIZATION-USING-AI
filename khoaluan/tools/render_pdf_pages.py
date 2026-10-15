from pathlib import Path

import fitz


pdf_path = Path(r"D:\KLTN\khoaluan\artifacts\Tai_lieu_phan_bien_web_noi_that.pdf")
out_dir = Path(r"D:\KLTN\khoaluan\artifacts\rendered")
out_dir.mkdir(parents=True, exist_ok=True)
for old in out_dir.glob("page-*.png"):
    old.unlink()

document = fitz.open(pdf_path)
matrix = fitz.Matrix(1.6, 1.6)
for index, page in enumerate(document):
    pixmap = page.get_pixmap(matrix=matrix, alpha=False)
    pixmap.save(out_dir / f"page-{index + 1:02d}.png")
print(f"pages={document.page_count}")
