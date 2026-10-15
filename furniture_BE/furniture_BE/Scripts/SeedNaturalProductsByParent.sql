SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

DECLARE @CreatedAt datetime2 = SYSDATETIME();

DECLARE @Seed TABLE
(
    ParentName nvarchar(100) NOT NULL,
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
-- Phòng ăn: bàn ăn
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-AURORA', N'Bàn ăn Aurora gỗ sồi thanh lịch', 7850000, N'Gỗ sồi', N'Nâu tự nhiên', N'160 x 80 cm', N'Gỗ sồi', N'Trắng kem', N'180 x 90 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-ELISE', N'Bàn ăn Elise mặt đá vân mây', 12600000, N'Đá ceramic', N'Trắng vân mây', N'160 x 80 cm', N'Đá ceramic', N'Đen vân trắng', N'180 x 90 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-NORDIC', N'Bàn ăn Nordic chân chữ A', 6900000, N'Gỗ cao su', N'Sồi sáng', N'140 x 80 cm', N'Gỗ cao su', N'Nâu óc chó', N'160 x 80 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-MILANO', N'Bàn ăn Milano mặt kính cường lực', 9400000, N'Kính cường lực', N'Trong suốt', N'160 x 85 cm', N'Kính cường lực', N'Khói xám', N'180 x 90 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-HARMONY', N'Bàn ăn Harmony bo góc an toàn', 8200000, N'Gỗ tần bì', N'Nâu mật ong', N'160 x 80 cm', N'Gỗ tần bì', N'Be tự nhiên', N'180 x 85 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-LOTUS', N'Bàn ăn Lotus tròn chân trụ', 7350000, N'Gỗ tự nhiên', N'Nâu hạt dẻ', N'Đường kính 120 cm', N'Gỗ tự nhiên', N'Trắng ngà', N'Đường kính 135 cm'),
(N'Phòng ăn', N'bàn ăn', 'DIN-TBL-IMPERIAL', N'Bàn ăn Imperial gỗ óc chó', 18900000, N'Gỗ óc chó', N'Nâu óc chó', N'180 x 90 cm', N'Gỗ óc chó', N'Nâu trầm', N'200 x 100 cm'),
-- Phòng ăn: ghế ăn
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-LUNA', N'Ghế ăn Luna tựa cong bọc nệm', 2150000, N'Gỗ cao su và vải', N'Kem', N'Tiêu chuẩn', N'Gỗ cao su và da PU', N'Nâu caramel', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-VERONA', N'Ghế ăn Verona lưng đan mây', 2480000, N'Gỗ tần bì và mây', N'Tự nhiên', N'Tiêu chuẩn', N'Gỗ tần bì và mây', N'Nâu cánh gián', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-EMMA', N'Ghế ăn Emma phong cách Bắc Âu', 1850000, N'Gỗ sồi và vải', N'Xám nhạt', N'Tiêu chuẩn', N'Gỗ sồi và vải', N'Xanh rêu', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-OSLO', N'Ghế ăn Oslo chân gỗ nguyên khối', 1980000, N'Gỗ cao su', N'Sồi sáng', N'Tiêu chuẩn', N'Gỗ cao su', N'Nâu óc chó', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-CELESTE', N'Ghế ăn Celeste bọc nhung cao cấp', 2950000, N'Nhung và thép', N'Xanh cổ vịt', N'Tiêu chuẩn', N'Nhung và thép', N'Xám khói', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-MAYA', N'Ghế ăn Maya lưng nan thanh thoát', 1750000, N'Gỗ beech', N'Nâu tự nhiên', N'Tiêu chuẩn', N'Gỗ beech', N'Đen mờ', N'Tiêu chuẩn'),
(N'Phòng ăn', N'ghế ăn', 'DIN-CHR-RUBY', N'Ghế ăn Ruby tay vịn êm ái', 3250000, N'Gỗ và vải bố', N'Be cát', N'Tiêu chuẩn', N'Gỗ và da PU', N'Nâu bò', N'Tiêu chuẩn'),
-- Phòng ăn: bộ bàn ghế ăn
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-SERENA', N'Bộ bàn ghế ăn Serena sáu chỗ', 16900000, N'Gỗ sồi', N'Nâu tự nhiên', N'Bộ 1 bàn 6 ghế', N'Gỗ sồi và nệm', N'Trắng kem', N'Bộ 1 bàn 6 ghế'),
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-PREMIER', N'Bộ bàn ghế ăn Premier mặt đá', 23800000, N'Đá ceramic và thép', N'Trắng vân mây', N'Bộ 1 bàn 6 ghế', N'Đá ceramic và thép', N'Đen vân trắng', N'Bộ 1 bàn 6 ghế'),
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-MOC-NHIEN', N'Bộ bàn ghế ăn Mộc Nhiên bốn chỗ', 11900000, N'Gỗ cao su', N'Sồi sáng', N'Bộ 1 bàn 4 ghế', N'Gỗ cao su', N'Nâu hạt dẻ', N'Bộ 1 bàn 4 ghế'),
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-FLORENCE', N'Bộ bàn ghế ăn Florence tân cổ điển', 28600000, N'Gỗ tự nhiên và vải', N'Trắng ngà', N'Bộ 1 bàn 6 ghế', N'Gỗ tự nhiên và da PU', N'Nâu champagne', N'Bộ 1 bàn 6 ghế'),
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-KYOTO', N'Bộ bàn ghế ăn Kyoto tối giản', 15200000, N'Gỗ tần bì', N'Nâu mật ong', N'Bộ 1 bàn 6 ghế', N'Gỗ tần bì', N'Đen mờ', N'Bộ 1 bàn 6 ghế'),
(N'Phòng ăn', N'Bộ bàn ghế ăn', 'DIN-SET-GRAND', N'Bộ bàn ghế ăn Grand tám chỗ', 32500000, N'Gỗ óc chó và da', N'Nâu óc chó', N'Bộ 1 bàn 8 ghế', N'Gỗ óc chó và vải', N'Xám ghi', N'Bộ 1 bàn 8 ghế'),

-- Phòng bếp: kệ bếp
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-ALBA', N'Kệ bếp Alba chữ I chống ẩm', 14500000, N'MDF chống ẩm', N'Trắng bóng', N'Dài 240 cm', N'MDF chống ẩm', N'Xám ghi', N'Dài 280 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-MONACO', N'Kệ bếp Monaco chữ L hiện đại', 21800000, N'MDF phủ acrylic', N'Trắng và vân gỗ', N'240 x 180 cm', N'MDF phủ acrylic', N'Đen và vân gỗ', N'280 x 200 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-GIA-NHIEN', N'Kệ bếp Gia Nhiên gỗ sồi', 26500000, N'Gỗ sồi', N'Nâu tự nhiên', N'Dài 260 cm', N'Gỗ sồi', N'Nâu óc chó', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-URBAN', N'Kệ bếp Urban cánh phẳng', 17200000, N'MDF phủ melamine', N'Xám xi măng', N'Dài 240 cm', N'MDF phủ melamine', N'Xanh navy', N'Dài 280 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-OLIVIA', N'Kệ bếp Olivia phong cách đồng quê', 24900000, N'Gỗ tự nhiên', N'Trắng kem', N'Dài 260 cm', N'Gỗ tự nhiên', N'Xanh olive', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-NOVA', N'Kệ bếp Nova tích hợp quầy bar', 29800000, N'MDF chống ẩm và đá', N'Trắng vân đá', N'280 x 180 cm', N'MDF chống ẩm và đá', N'Đen vân mây', N'320 x 200 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-ZEN', N'Kệ bếp Zen vân gỗ tối giản', 18600000, N'Plywood phủ laminate', N'Sồi sáng', N'Dài 250 cm', N'Plywood phủ laminate', N'Nâu hạt dẻ', N'Dài 290 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-ELARA', N'Kệ bếp Elara tay nắm âm', 19500000, N'MDF phủ acrylic', N'Be cát', N'Dài 260 cm', N'MDF phủ acrylic', N'Xám khói', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-TOSCANA', N'Kệ bếp Toscana mặt đá thạch anh', 33500000, N'Gỗ sồi và đá thạch anh', N'Nâu sáng', N'Dài 280 cm', N'Gỗ sồi và đá thạch anh', N'Nâu trầm', N'Dài 320 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-IRIS', N'Kệ bếp Iris nhỏ gọn cho căn hộ', 12800000, N'MDF chống ẩm', N'Trắng ngà', N'Dài 180 cm', N'MDF chống ẩm', N'Xanh pastel', N'Dài 210 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-LUXE', N'Kệ bếp Luxe cánh kính sang trọng', 36800000, N'Kính và nhôm', N'Đen khói', N'Dài 280 cm', N'Kính và nhôm', N'Champagne', N'Dài 320 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-MINORI', N'Kệ bếp Minori kiểu Nhật', 20500000, N'Gỗ tần bì', N'Gỗ sáng', N'Dài 250 cm', N'Gỗ tần bì', N'Nâu trà', N'Dài 290 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-SAPPHIRE', N'Kệ bếp Sapphire xanh thanh lịch', 23200000, N'MDF phủ sơn', N'Xanh sapphire', N'Dài 260 cm', N'MDF phủ sơn', N'Trắng kem', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-HORIZON', N'Kệ bếp Horizon không tay nắm', 22400000, N'Plywood phủ acrylic', N'Xám bạc', N'Dài 260 cm', N'Plywood phủ acrylic', N'Đen mờ', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-LAVIE', N'Kệ bếp Lavie phối màu ấm', 17800000, N'MDF phủ laminate', N'Kem và nâu', N'Dài 240 cm', N'MDF phủ laminate', N'Trắng và sồi', N'Dài 280 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-RIVIERA', N'Kệ bếp Riviera chữ U rộng rãi', 38900000, N'MDF chống ẩm và đá', N'Trắng xám', N'300 x 220 cm', N'MDF chống ẩm và đá', N'Xanh xám', N'340 x 240 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-AN-PHUC', N'Kệ bếp An Phúc gỗ tự nhiên', 27900000, N'Gỗ xoan đào', N'Nâu cánh gián', N'Dài 270 cm', N'Gỗ xoan đào', N'Nâu đỏ', N'Dài 310 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-CLARA', N'Kệ bếp Clara phong cách Scandinavian', 21600000, N'Gỗ và MDF', N'Trắng và sồi', N'Dài 260 cm', N'Gỗ và MDF', N'Xám và sồi', N'Dài 300 cm'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-VISTA', N'Kệ bếp Vista có đảo trung tâm', 42500000, N'MDF acrylic và đá', N'Trắng vân mây', N'Bếp 300 cm kèm đảo', N'MDF acrylic và đá', N'Xám vân đá', N'Bếp 340 cm kèm đảo'),
(N'Phòng bếp', N'kệ bếp', 'KIT-CAB-ECO', N'Kệ bếp Eco module linh hoạt', 15900000, N'Plywood phủ melamine', N'Vân gỗ sáng', N'Dài 220 cm', N'Plywood phủ melamine', N'Vân gỗ nâu', N'Dài 260 cm'),

-- Ban công: bộ bàn ghế
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-SUNNY', N'Bộ bàn ghế ban công Sunny gấp gọn', 3450000, N'Thép sơn tĩnh điện', N'Trắng', N'Bộ 1 bàn 2 ghế', N'Thép sơn tĩnh điện', N'Xanh lá', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-MAYFAIR', N'Bộ bàn ghế ban công Mayfair đan mây', 6250000, N'Nhựa giả mây', N'Nâu cà phê', N'Bộ 1 bàn 2 ghế', N'Nhựa giả mây', N'Xám tro', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-LAVENDER', N'Bộ bàn ghế ban công Lavender lãng mạn', 4850000, N'Sắt mỹ thuật', N'Trắng kem', N'Bộ 1 bàn 2 ghế', N'Sắt mỹ thuật', N'Tím pastel', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-TROPICAL', N'Bộ bàn ghế ban công Tropical thư giãn', 7900000, N'Gỗ teak', N'Nâu teak', N'Bộ 1 bàn 2 ghế', N'Gỗ teak và nệm', N'Be cát', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-BREEZE', N'Bộ bàn ghế ban công Breeze thanh mảnh', 3950000, N'Nhôm sơn tĩnh điện', N'Xám nhạt', N'Bộ 1 bàn 2 ghế', N'Nhôm sơn tĩnh điện', N'Đen mờ', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-MOSAIC', N'Bộ bàn ghế ban công Mosaic nghệ thuật', 5750000, N'Gốm và sắt', N'Xanh biển', N'Bộ 1 bàn 2 ghế', N'Gốm và sắt', N'Vàng đất', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-CAPRI', N'Bộ bàn ghế ban công Capri phong cách Ý', 8650000, N'Nhôm và dây rope', N'Be sáng', N'Bộ 1 bàn 2 ghế', N'Nhôm và dây rope', N'Xám than', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-GARDENIA', N'Bộ bàn ghế ban công Gardenia xanh mát', 5350000, N'Thép và lưới textilene', N'Xanh rêu', N'Bộ 1 bàn 2 ghế', N'Thép và lưới textilene', N'Kem', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-MORNING', N'Bộ bàn ghế ban công Morning Coffee', 4550000, N'Gỗ keo', N'Nâu mật ong', N'Bộ 1 bàn 2 ghế', N'Gỗ keo', N'Nâu trầm', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-PEARL', N'Bộ bàn ghế ban công Pearl màu sáng', 6100000, N'Nhựa giả mây và kính', N'Trắng ngọc trai', N'Bộ 1 bàn 2 ghế', N'Nhựa giả mây và kính', N'Be champagne', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-NEST', N'Bộ bàn ghế ban công Nest ôm lưng', 7250000, N'Dây rope và nhôm', N'Xám ghi', N'Bộ 1 bàn 2 ghế', N'Dây rope và nhôm', N'Nâu đất', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-DAISY', N'Bộ bàn ghế ban công Daisy nhỏ xinh', 3650000, N'Thép sơn tĩnh điện', N'Vàng nhạt', N'Bộ 1 bàn 2 ghế', N'Thép sơn tĩnh điện', N'Trắng sữa', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-OASIS', N'Bộ bàn ghế ban công Oasis có nệm', 8950000, N'Nhựa giả mây và nệm', N'Nâu chocolate', N'Bộ 1 bàn 2 ghế', N'Nhựa giả mây và nệm', N'Xám lông chuột', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-MARINA', N'Bộ bàn ghế ban công Marina chống nước', 6850000, N'Nhôm và textilene', N'Xanh navy', N'Bộ 1 bàn 2 ghế', N'Nhôm và textilene', N'Xám bạc', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-WILLOW', N'Bộ bàn ghế ban công Willow nan gỗ', 5850000, N'Gỗ keo ngoài trời', N'Nâu tự nhiên', N'Bộ 1 bàn 2 ghế', N'Gỗ keo ngoài trời', N'Xám weathered', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-MINT', N'Bộ bàn ghế ban công Mint trẻ trung', 4150000, N'Thép và gỗ', N'Xanh mint', N'Bộ 1 bàn 2 ghế', N'Thép và gỗ', N'Trắng', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-ROOFTOP', N'Bộ bàn ghế ban công Rooftop hiện đại', 9650000, N'Nhôm đúc', N'Đen mờ', N'Bộ 1 bàn 4 ghế', N'Nhôm đúc', N'Xám đá', N'Bộ 1 bàn 4 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-SANTORINI', N'Bộ bàn ghế ban công Santorini xanh trắng', 7550000, N'Nhôm và dây rope', N'Trắng xanh', N'Bộ 1 bàn 2 ghế', N'Nhôm và dây rope', N'Trắng be', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-ZENITH', N'Bộ bàn ghế ban công Zenith tối giản', 6450000, N'Nhôm sơn tĩnh điện', N'Xám than', N'Bộ 1 bàn 2 ghế', N'Nhôm sơn tĩnh điện', N'Be cát', N'Bộ 1 bàn 2 ghế'),
(N'ban công', N'Bộ bàn ghế', 'BAL-SET-HONEY', N'Bộ bàn ghế ban công Honey ấm áp', 5250000, N'Gỗ keo và thép', N'Nâu mật ong', N'Bộ 1 bàn 2 ghế', N'Gỗ keo và thép', N'Nâu caramel', N'Bộ 1 bàn 2 ghế');

IF EXISTS
(
    SELECT 1
    FROM @Seed seed
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Categories child
        INNER JOIN Categories parent ON parent.CategoryId = child.ParentCategoryId
        WHERE child.CategoryName = seed.ChildName
          AND parent.CategoryName = seed.ParentName
          AND child.IsDeleted = 0
          AND parent.IsDeleted = 0
    )
)
    THROW 51000, N'Không tìm thấy đầy đủ danh mục cha/con cần thiết.', 1;

IF EXISTS (SELECT ProductCode FROM @Seed GROUP BY ProductCode HAVING COUNT(*) > 1)
    THROW 51001, N'Mã sản phẩm seed bị trùng.', 1;

INSERT INTO Products
(
    CategoryId, ProductName, ProductCode, BasePrice, Description,
    IsDeleted, CreatedAt, UpdatedAt, AverageRating, ReviewCount
)
SELECT
    child.CategoryId,
    seed.ProductName,
    seed.ProductCode,
    seed.BasePrice,
    CONCAT(N'Sản phẩm ', seed.ProductName, N' thuộc bộ sưu tập ', seed.ParentName,
           N'. Có hai biến thể để khách hàng lựa chọn theo không gian sử dụng.'),
    0, @CreatedAt, NULL, 0, 0
FROM @Seed seed
INNER JOIN Categories parent
    ON parent.CategoryName = seed.ParentName
   AND parent.ParentCategoryId IS NULL
   AND parent.IsDeleted = 0
INNER JOIN Categories child
    ON child.CategoryName = seed.ChildName
   AND child.ParentCategoryId = parent.CategoryId
   AND child.IsDeleted = 0
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
       0, 30 + (product.ProductId % 21), 0, @CreatedAt, NULL
FROM @Seed seed
INNER JOIN Products product ON product.ProductCode = seed.ProductCode
WHERE NOT EXISTS (SELECT 1 FROM ProductVariants variant WHERE variant.ProductId = product.ProductId);

INSERT INTO ProductVariants
(
    ProductId, Material, Color, Size, AdditionalPrice, StockQuantity,
    IsDeleted, CreatedAt, UpdatedAt
)
SELECT product.ProductId, seed.Material2, seed.Color2, seed.Size2,
       CAST(250000 + (product.ProductId % 5) * 100000 AS decimal(18,2)),
       20 + (product.ProductId % 16), 0, @CreatedAt, NULL
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
    THROW 51002, N'Một hoặc nhiều sản phẩm không có đúng hai biến thể.', 1;

COMMIT TRANSACTION;

SELECT
    parent.CategoryName AS ParentCategory,
    COUNT(DISTINCT product.ProductId) AS ProductCount,
    COUNT(variant.VariantId) AS VariantCount,
    COUNT(DISTINCT product.ProductName) AS UniqueProductNames
FROM @Seed seed
INNER JOIN Products product ON product.ProductCode = seed.ProductCode
INNER JOIN ProductVariants variant ON variant.ProductId = product.ProductId
INNER JOIN Categories child ON child.CategoryId = product.CategoryId
INNER JOIN Categories parent ON parent.CategoryId = child.ParentCategoryId
GROUP BY parent.CategoryName
ORDER BY parent.CategoryName;
