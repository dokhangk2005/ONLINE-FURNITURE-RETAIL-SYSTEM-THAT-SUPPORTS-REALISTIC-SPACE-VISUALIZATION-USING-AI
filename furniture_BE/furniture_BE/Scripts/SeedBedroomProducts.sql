SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @CreatedAt datetime2 = SYSDATETIME();
DECLARE @Seed TABLE
(
    ChildName nvarchar(100) NOT NULL,
    ProductCode varchar(50) NOT NULL,
    ProductName nvarchar(200) NOT NULL,
    BasePrice decimal(18,2) NOT NULL,
    Material1 nvarchar(50) NOT NULL,
    Color1 nvarchar(50) NOT NULL,
    Size1 nvarchar(50) NOT NULL,
    Material2 nvarchar(50) NOT NULL,
    Color2 nvarchar(50) NOT NULL,
    Size2 nvarchar(50) NOT NULL
);

INSERT INTO @Seed VALUES
-- Combo phòng ngủ
(N'Combo phòng ngủ', 'BED-COMBO-SERENITY', N'Combo phòng ngủ Serenity thanh lịch', 28900000, N'Gỗ sồi', N'Sồi tự nhiên', N'Giường 1m6 và bộ tủ', N'Gỗ sồi', N'Nâu óc chó', N'Giường 1m8 và bộ tủ'),
(N'Combo phòng ngủ', 'BED-COMBO-AURORA', N'Combo phòng ngủ Aurora hiện đại', 32500000, N'MDF chống ẩm', N'Trắng kem', N'Giường 1m6 và bộ tủ', N'MDF chống ẩm', N'Xám ghi', N'Giường 1m8 và bộ tủ'),
(N'Combo phòng ngủ', 'BED-COMBO-MOC-NHIEN', N'Combo phòng ngủ Mộc Nhiên ấm áp', 34800000, N'Gỗ cao su', N'Nâu mật ong', N'Giường 1m6 và bộ tủ', N'Gỗ cao su', N'Nâu hạt dẻ', N'Giường 1m8 và bộ tủ'),
(N'Combo phòng ngủ', 'BED-COMBO-ELYSIA', N'Combo phòng ngủ Elysia bọc nệm', 38600000, N'Gỗ và vải bố', N'Be cát', N'Giường 1m6 và bộ tủ', N'Gỗ và nhung', N'Xám khói', N'Giường 1m8 và bộ tủ'),
(N'Combo phòng ngủ', 'BED-COMBO-NORDIC', N'Combo phòng ngủ Nordic tối giản', 27600000, N'Gỗ tần bì', N'Gỗ sáng', N'Giường 1m6 và bộ tủ', N'Gỗ tần bì', N'Trắng ngà', N'Giường 1m8 và bộ tủ'),
(N'Combo phòng ngủ', 'BED-COMBO-IMPERIAL', N'Combo phòng ngủ Imperial sang trọng', 52900000, N'Gỗ óc chó và da', N'Nâu óc chó', N'Giường 1m8 và bộ tủ', N'Gỗ óc chó và vải', N'Nâu trầm', N'Giường 2m và bộ tủ'),

-- Giường ngủ
(N'Giường ngủ', 'BED-FRAME-LUNA', N'Giường ngủ Luna đầu giường bo cong', 12800000, N'Gỗ sồi', N'Sồi sáng', N'1m6 x 2m', N'Gỗ sồi', N'Nâu tự nhiên', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-OLIVIA', N'Giường ngủ Olivia bọc nhung êm ái', 15600000, N'Gỗ và nhung', N'Kem', N'1m6 x 2m', N'Gỗ và nhung', N'Xanh rêu', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-KYOTO', N'Giường ngủ Kyoto kiểu Nhật thấp', 10900000, N'Gỗ tần bì', N'Nâu mật ong', N'1m6 x 2m', N'Gỗ tần bì', N'Nâu trà', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-MILANO', N'Giường ngủ Milano đầu giường chần nút', 17400000, N'Gỗ và da PU', N'Nâu caramel', N'1m6 x 2m', N'Gỗ và da PU', N'Xám than', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-HARMONY', N'Giường ngủ Harmony có ngăn kéo', 13900000, N'MDF chống ẩm', N'Trắng và sồi', N'1m6 x 2m', N'MDF chống ẩm', N'Xám và sồi', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-VERONA', N'Giường ngủ Verona gỗ tự nhiên', 19800000, N'Gỗ xoan đào', N'Nâu cánh gián', N'1m6 x 2m', N'Gỗ xoan đào', N'Nâu đỏ', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-CELESTE', N'Giường ngủ Celeste chân ẩn hiện đại', 14800000, N'Gỗ và vải linen', N'Be sáng', N'1m6 x 2m', N'Gỗ và vải linen', N'Xám bạc', N'1m8 x 2m'),
(N'Giường ngủ', 'BED-FRAME-AN-NHIEN', N'Giường ngủ An Nhiên nan gỗ thoáng', 11600000, N'Gỗ cao su', N'Tự nhiên', N'1m6 x 2m', N'Gỗ cao su', N'Nâu hạt dẻ', N'1m8 x 2m'),

-- Tủ đầu giường
(N'Tủ đầu giường', 'BED-NIGHTSTAND-IRIS', N'Tủ đầu giường Iris hai ngăn kéo', 2850000, N'MDF phủ melamine', N'Trắng ngà', N'45 x 40 x 50 cm', N'MDF phủ melamine', N'Xám nhạt', N'50 x 42 x 52 cm'),
(N'Tủ đầu giường', 'BED-NIGHTSTAND-OSLO', N'Tủ đầu giường Oslo chân gỗ cao', 3250000, N'Gỗ sồi', N'Sồi sáng', N'45 x 40 x 55 cm', N'Gỗ sồi', N'Nâu óc chó', N'50 x 42 x 55 cm'),
(N'Tủ đầu giường', 'BED-NIGHTSTAND-PEARL', N'Tủ đầu giường Pearl mặt đá', 4650000, N'Gỗ và đá ceramic', N'Trắng vân mây', N'45 x 40 x 50 cm', N'Gỗ và đá ceramic', N'Đen vân trắng', N'50 x 42 x 52 cm'),
(N'Tủ đầu giường', 'BED-NIGHTSTAND-MAYA', N'Tủ đầu giường Maya đan mây', 3480000, N'Gỗ và mây tự nhiên', N'Nâu sáng', N'45 x 40 x 52 cm', N'Gỗ và mây tự nhiên', N'Nâu cánh gián', N'50 x 42 x 54 cm'),
(N'Tủ đầu giường', 'BED-NIGHTSTAND-NOVA', N'Tủ đầu giường Nova tay nắm âm', 3050000, N'MDF phủ acrylic', N'Be cát', N'45 x 40 x 50 cm', N'MDF phủ acrylic', N'Xám khói', N'50 x 42 x 52 cm'),
(N'Tủ đầu giường', 'BED-NIGHTSTAND-FLORENCE', N'Tủ đầu giường Florence tân cổ điển', 5200000, N'Gỗ tự nhiên', N'Trắng kem', N'48 x 42 x 55 cm', N'Gỗ tự nhiên', N'Nâu champagne', N'52 x 45 x 58 cm');

IF (SELECT COUNT(*) FROM @Seed) <> 20
    THROW 51100, N'Danh sách seed phòng ngủ phải có đúng 20 sản phẩm.', 1;

IF EXISTS
(
    SELECT 1 FROM @Seed seed
    WHERE NOT EXISTS
    (
        SELECT 1 FROM Categories child
        INNER JOIN Categories parent ON parent.CategoryId = child.ParentCategoryId
        WHERE parent.CategoryName = N'Phòng ngủ'
          AND child.CategoryName = seed.ChildName
          AND parent.IsDeleted = 0 AND child.IsDeleted = 0
    )
)
    THROW 51101, N'Không tìm thấy đầy đủ danh mục con của Phòng ngủ.', 1;

INSERT INTO Products
(
    CategoryId, ProductName, ProductCode, BasePrice, Description,
    IsDeleted, CreatedAt, UpdatedAt, AverageRating, ReviewCount
)
SELECT child.CategoryId, seed.ProductName, seed.ProductCode, seed.BasePrice,
       CONCAT(N'Sản phẩm ', seed.ProductName,
              N' thuộc bộ sưu tập Phòng ngủ, có hai biến thể để lựa chọn.'),
       0, @CreatedAt, NULL, 0, 0
FROM @Seed seed
INNER JOIN Categories parent
    ON parent.CategoryName = N'Phòng ngủ'
   AND parent.ParentCategoryId IS NULL AND parent.IsDeleted = 0
INNER JOIN Categories child
    ON child.ParentCategoryId = parent.CategoryId
   AND child.CategoryName = seed.ChildName AND child.IsDeleted = 0
WHERE NOT EXISTS
(
    SELECT 1 FROM Products product WHERE product.ProductCode = seed.ProductCode
);

INSERT INTO ProductVariants
(
    ProductId, Material, Color, Size, AdditionalPrice, StockQuantity,
    IsDeleted, CreatedAt, UpdatedAt
)
SELECT product.ProductId, seed.Material1, seed.Color1, seed.Size1,
       0, 25 + (product.ProductId % 16), 0, @CreatedAt, NULL
FROM @Seed seed
INNER JOIN Products product ON product.ProductCode = seed.ProductCode
WHERE NOT EXISTS
(
    SELECT 1 FROM ProductVariants variant WHERE variant.ProductId = product.ProductId
);

INSERT INTO ProductVariants
(
    ProductId, Material, Color, Size, AdditionalPrice, StockQuantity,
    IsDeleted, CreatedAt, UpdatedAt
)
SELECT product.ProductId, seed.Material2, seed.Color2, seed.Size2,
       CAST(350000 + (product.ProductId % 5) * 150000 AS decimal(18,2)),
       18 + (product.ProductId % 14), 0, @CreatedAt, NULL
FROM @Seed seed
INNER JOIN Products product ON product.ProductCode = seed.ProductCode
WHERE (SELECT COUNT(*) FROM ProductVariants variant WHERE variant.ProductId = product.ProductId) = 1;

IF EXISTS
(
    SELECT product.ProductId
    FROM Products product
    INNER JOIN @Seed seed ON seed.ProductCode = product.ProductCode
    LEFT JOIN ProductVariants variant ON variant.ProductId = product.ProductId
    GROUP BY product.ProductId
    HAVING COUNT(variant.VariantId) <> 2
)
    THROW 51102, N'Một hoặc nhiều sản phẩm phòng ngủ không có đúng hai biến thể.', 1;

COMMIT TRANSACTION;

SELECT child.CategoryName AS ChildCategory,
       COUNT(DISTINCT product.ProductId) AS ProductCount,
       COUNT(variant.VariantId) AS VariantCount,
       COUNT(DISTINCT product.ProductName) AS UniqueNames
FROM @Seed seed
INNER JOIN Products product ON product.ProductCode = seed.ProductCode
INNER JOIN ProductVariants variant ON variant.ProductId = product.ProductId
INNER JOIN Categories child ON child.CategoryId = product.CategoryId
GROUP BY child.CategoryName
ORDER BY child.CategoryName;
