SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

/*
  Gắn một ảnh catalog cho từng biến thể của dữ liệu mẫu.
  Hai màu của cùng danh mục dùng hai ảnh riêng, cùng thiết kế và khác lớp hoàn thiện màu.
*/
INSERT INTO ProductImages
(
    VariantId,
    ImageUrl,
    IsThumbnail,
    CreatedAt
)
SELECT
    variant.VariantId,
    CONCAT(
        '/uploads/products/seed-category-',
        product.CategoryId,
        CASE
            WHEN variant.Color = N'Nâu gỗ (Brown)' THEN '-brown.png'
            WHEN variant.Color = N'Kem (Beige)' THEN '-beige.png'
        END
    ),
    1,
    SYSDATETIME()
FROM ProductVariants AS variant
INNER JOIN Products AS product
    ON product.ProductId = variant.ProductId
WHERE product.IsDeleted = 0
  AND variant.IsDeleted = 0
  AND product.ProductCode LIKE 'SEED-C%'
  AND variant.Color IN (N'Nâu gỗ (Brown)', N'Kem (Beige)')
  AND NOT EXISTS
  (
      SELECT 1
      FROM ProductImages AS existingImage
      WHERE existingImage.VariantId = variant.VariantId
  );

COMMIT TRANSACTION;

SELECT
    category.CategoryId,
    category.CategoryName,
    COUNT(DISTINCT product.ProductId) AS SeedProductCount,
    COUNT(DISTINCT variant.VariantId) AS SeedVariantCount,
    COUNT(image.ImageId) AS SeedImageCount
FROM Categories AS category
LEFT JOIN Products AS product
    ON product.CategoryId = category.CategoryId
   AND product.IsDeleted = 0
   AND product.ProductCode LIKE 'SEED-C%'
LEFT JOIN ProductVariants AS variant
    ON variant.ProductId = product.ProductId
   AND variant.IsDeleted = 0
LEFT JOIN ProductImages AS image
    ON image.VariantId = variant.VariantId
WHERE category.IsDeleted = 0
GROUP BY
    category.CategoryId,
    category.CategoryName,
    category.ParentCategoryId
ORDER BY
    CASE WHEN category.ParentCategoryId IS NULL THEN 0 ELSE 1 END,
    category.ParentCategoryId,
    category.CategoryId;
