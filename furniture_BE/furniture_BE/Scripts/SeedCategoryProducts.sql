SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @SeededAt datetime2 = SYSDATETIME();

DECLARE @Numbers TABLE (Number int PRIMARY KEY);
INSERT INTO @Numbers (Number)
VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10),
       (11), (12), (13), (14), (15), (16), (17), (18), (19), (20);

/*
  Mỗi danh mục đang hoạt động nhận 20 sản phẩm seed.
  ProductCode là khóa tự nhiên của dữ liệu mẫu để script có thể chạy lại an toàn.
*/
INSERT INTO Products
(
    CategoryId,
    ProductName,
    ProductCode,
    BasePrice,
    Description,
    IsDeleted,
    CreatedAt,
    UpdatedAt,
    AverageRating,
    ReviewCount
)
SELECT
    category.CategoryId,
    CONCAT(category.CategoryName, N' - Mẫu ', FORMAT(number.Number, '00')),
    CONCAT('SEED-C', category.CategoryId, '-', FORMAT(number.Number, '00')),
    CAST(750000 + (category.CategoryId % 10) * 250000 + number.Number * 175000 AS decimal(18, 2)),
    CONCAT(
        N'Sản phẩm mẫu số ', FORMAT(number.Number, '00'),
        N' thuộc danh mục ', category.CategoryName,
        N'. Thiết kế hiện đại, phù hợp cho dữ liệu trình diễn và kiểm thử.'
    ),
    0,
    @SeededAt,
    NULL,
    CAST(0 AS float),
    0
FROM Categories AS category
CROSS JOIN @Numbers AS number
WHERE category.IsDeleted = 0
  AND NOT EXISTS
  (
      SELECT 1
      FROM Products AS existingProduct
      WHERE existingProduct.ProductCode = CONCAT(
          'SEED-C', category.CategoryId, '-', FORMAT(number.Number, '00')
      )
  );

/*
  Chuẩn hóa lại nội dung của các bản ghi seed nếu script đã từng được chạy.
  Phần này cũng giúp script sửa dữ liệu khi nội dung mẫu được cập nhật.
*/
UPDATE product
SET
    product.ProductName = CONCAT(
        category.CategoryName,
        N' - Mẫu ',
        RIGHT(product.ProductCode, 2)
    ),
    product.Description = CONCAT(
        N'Sản phẩm mẫu số ', RIGHT(product.ProductCode, 2),
        N' thuộc danh mục ', category.CategoryName,
        N'. Thiết kế hiện đại, phù hợp cho dữ liệu trình diễn và kiểm thử.'
    )
FROM Products AS product
INNER JOIN Categories AS category
    ON category.CategoryId = product.CategoryId
WHERE product.ProductCode LIKE 'SEED-C%';

UPDATE variant
SET
    variant.Material = N'Gỗ tự nhiên',
    variant.Color = CASE
        WHEN variant.AdditionalPrice = 0 THEN N'Nâu gỗ (Brown)'
        ELSE N'Kem (Beige)'
    END,
    variant.Size = N'Tiêu chuẩn'
FROM ProductVariants AS variant
INNER JOIN Products AS product
    ON product.ProductId = variant.ProductId
WHERE product.ProductCode LIKE 'SEED-C%'
  AND variant.AdditionalPrice IN (0, 150000);

/* Biến thể thứ nhất, đồng thời là màu thứ nhất của mỗi sản phẩm. */
INSERT INTO ProductVariants
(
    ProductId,
    Material,
    Color,
    Size,
    AdditionalPrice,
    StockQuantity,
    IsDeleted,
    CreatedAt,
    UpdatedAt
)
SELECT
    product.ProductId,
    N'Gỗ tự nhiên',
    N'Nâu gỗ (Brown)',
    N'Tiêu chuẩn',
    CAST(0 AS decimal(18, 2)),
    40 + (product.ProductId % 21),
    0,
    @SeededAt,
    NULL
FROM Products AS product
WHERE product.IsDeleted = 0
  AND product.ProductCode LIKE 'SEED-C%'
  AND NOT EXISTS
  (
      SELECT 1
      FROM ProductVariants AS variant
      WHERE variant.ProductId = product.ProductId
        AND variant.Color = N'Nâu gỗ (Brown)'
        AND variant.IsDeleted = 0
  );

/* Biến thể thứ hai, đồng thời là màu thứ hai của mỗi sản phẩm. */
INSERT INTO ProductVariants
(
    ProductId,
    Material,
    Color,
    Size,
    AdditionalPrice,
    StockQuantity,
    IsDeleted,
    CreatedAt,
    UpdatedAt
)
SELECT
    product.ProductId,
    N'Gỗ tự nhiên',
    N'Kem (Beige)',
    N'Tiêu chuẩn',
    CAST(150000 AS decimal(18, 2)),
    30 + (product.ProductId % 21),
    0,
    @SeededAt,
    NULL
FROM Products AS product
WHERE product.IsDeleted = 0
  AND product.ProductCode LIKE 'SEED-C%'
  AND NOT EXISTS
  (
      SELECT 1
      FROM ProductVariants AS variant
      WHERE variant.ProductId = product.ProductId
        AND variant.Color = N'Kem (Beige)'
        AND variant.IsDeleted = 0
  );

COMMIT TRANSACTION;

SELECT
    category.CategoryId,
    category.CategoryName,
    category.ParentCategoryId,
    COUNT(DISTINCT product.ProductId) AS SeedProductCount,
    COUNT(variant.VariantId) AS SeedVariantCount,
    COUNT(DISTINCT variant.Color) AS SeedColorCount
FROM Categories AS category
LEFT JOIN Products AS product
    ON product.CategoryId = category.CategoryId
   AND product.ProductCode LIKE 'SEED-C%'
   AND product.IsDeleted = 0
LEFT JOIN ProductVariants AS variant
    ON variant.ProductId = product.ProductId
   AND variant.IsDeleted = 0
WHERE category.IsDeleted = 0
GROUP BY
    category.CategoryId,
    category.CategoryName,
    category.ParentCategoryId
ORDER BY
    CASE WHEN category.ParentCategoryId IS NULL THEN 0 ELSE 1 END,
    category.ParentCategoryId,
    category.CategoryId;
