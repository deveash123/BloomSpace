/* ============================================================
   BLOOM SPACE - ONLINE FLOWER SHOPPING WEBSITE
   MonsterASP / Hosted SQL Server Database Script
   Target Database: Hosted Database (e.g., db82285)
   Compatibility: SQL Server 2016 through SQL Server 2025

   IMPORTANT HOSTING NOTES:
   1. DO NOT add CREATE DATABASE or USE statements.
      MonsterASP provisions your database name (e.g., db82285).
      Hosted user accounts do not have permission to create databases
      or access the master database. This script executes directly
      inside the currently selected database.
   2. RE-EXECUTION / CLEAN RESET:
      This script drops existing child and parent tables in correct
      dependency order to cleanly recover from any partial imports.
      Running this script will reset existing cart, order, and user
      test records.
   ============================================================ */

/* ---------- STEP 1: Drop old tables (child tables first) ---------- */
IF OBJECT_ID('dbo.OrderDetails', 'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.Cart', 'U') IS NOT NULL DROP TABLE dbo.Cart;
IF OBJECT_ID('dbo.ContactMessages', 'U') IS NOT NULL DROP TABLE dbo.ContactMessages;
IF OBJECT_ID('dbo.Ribbons', 'U') IS NOT NULL DROP TABLE dbo.Ribbons;
IF OBJECT_ID('dbo.WrappingSheets', 'U') IS NOT NULL DROP TABLE dbo.WrappingSheets;
IF OBJECT_ID('dbo.Flowers', 'U') IS NOT NULL DROP TABLE dbo.Flowers;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* ============================================================
   TABLE 1: USERS
   Passwords are encrypted using PBKDF2-SHA256 with 100,000 iterations
   and a cryptographically secure random salt. Plain-text passwords
   are NEVER stored.
   ============================================================ */
CREATE TABLE dbo.Users
(
    UserId             INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Users PRIMARY KEY,
    FullName           NVARCHAR(100)  NOT NULL,
    Email              NVARCHAR(150)  NOT NULL,
    Phone              NVARCHAR(20)   NOT NULL,
    PasswordHash       NVARCHAR(200)  NOT NULL,
    PasswordSalt       NVARCHAR(100)  NOT NULL,
    PasswordIterations INT            NOT NULL CONSTRAINT DF_Users_Iterations DEFAULT (100000),
    CreatedAt          DATETIME2(0)   NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT UQ_Users_Email UNIQUE (Email),
    CONSTRAINT CK_Users_Email CHECK (Email LIKE '%_@_%._%')
);
GO

/* ============================================================
   TABLE 2: FLOWERS
   ShowInShop    = 1 -> Appears as ready-made bouquet in Shop.aspx
   ShowInBuilder = 1 -> Appears as per-stem stem in CustomBouquet.aspx
   ============================================================ */
CREATE TABLE dbo.Flowers
(
    FlowerId      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Flowers PRIMARY KEY,
    Name          NVARCHAR(100)  NOT NULL,
    Category      NVARCHAR(50)   NOT NULL,
    Description   NVARCHAR(300)  NULL,
    Price         DECIMAL(10,2)  NOT NULL CONSTRAINT DF_Flowers_Price DEFAULT (0),
    PricePerStem  DECIMAL(10,2)  NOT NULL CONSTRAINT DF_Flowers_StemPrice DEFAULT (0),
    ImagePath     NVARCHAR(200)  NOT NULL,
    Badge         NVARCHAR(50)   NULL,
    ShowInShop    BIT            NOT NULL CONSTRAINT DF_Flowers_ShowInShop DEFAULT (1),
    ShowInBuilder BIT            NOT NULL CONSTRAINT DF_Flowers_ShowInBuilder DEFAULT (0),
    IsActive      BIT            NOT NULL CONSTRAINT DF_Flowers_IsActive DEFAULT (1),
    CreatedAt     DATETIME2(0)   NOT NULL CONSTRAINT DF_Flowers_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Flowers_Price CHECK (Price >= 0),
    CONSTRAINT CK_Flowers_StemPrice CHECK (PricePerStem >= 0)
);
GO
CREATE INDEX IX_Flowers_Category ON dbo.Flowers (Category) INCLUDE (Name, Price, IsActive);
GO

/* ============================================================
   TABLE 3: WRAPPING SHEETS
   Wrapping paper options for the Custom Bouquet Studio.
   ============================================================ */
CREATE TABLE dbo.WrappingSheets
(
    WrappingId  INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_WrappingSheets PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200) NULL,
    Price       DECIMAL(10,2) NOT NULL CONSTRAINT DF_Wrapping_Price DEFAULT (0),
    ImagePath   NVARCHAR(200) NOT NULL,
    IsActive    BIT           NOT NULL CONSTRAINT DF_Wrapping_IsActive DEFAULT (1),
    CONSTRAINT CK_Wrapping_Price CHECK (Price >= 0)
);
GO

/* ============================================================
   TABLE 4: RIBBONS
   Ribbon tie options for the Custom Bouquet Studio.
   ============================================================ */
CREATE TABLE dbo.Ribbons
(
    RibbonId    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ribbons PRIMARY KEY,
    Name        NVARCHAR(100) NOT NULL,
    Description NVARCHAR(200) NULL,
    Price       DECIMAL(10,2) NOT NULL CONSTRAINT DF_Ribbons_Price DEFAULT (0),
    ColorHex    CHAR(7)       NOT NULL CONSTRAINT DF_Ribbons_Color DEFAULT ('#C77F91'),
    IsActive    BIT           NOT NULL CONSTRAINT DF_Ribbons_IsActive DEFAULT (1),
    CONSTRAINT CK_Ribbons_Price CHECK (Price >= 0)
);
GO

/* ============================================================
   TABLE 5: CART
   Shopping bag supporting both ready-made and custom bouquets.
   Prices are NOT stored in the cart table; they are always
   recalculated dynamically from the catalogue on the server.
   ============================================================ */
CREATE TABLE dbo.Cart
(
    CartId     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Cart PRIMARY KEY,
    UserId     INT           NOT NULL,
    FlowerId   INT           NULL,
    Quantity   INT           NOT NULL CONSTRAINT DF_Cart_Qty DEFAULT (1),
    WrappingId INT           NULL,
    RibbonId   INT           NULL,
    IsCustom   BIT           NOT NULL CONSTRAINT DF_Cart_IsCustom DEFAULT (0),
    CustomData NVARCHAR(MAX) NULL,
    AddedAt    DATETIME2(0)  NOT NULL CONSTRAINT DF_Cart_AddedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Cart_Users FOREIGN KEY (UserId) REFERENCES dbo.Users (UserId) ON DELETE CASCADE,
    CONSTRAINT FK_Cart_Flowers FOREIGN KEY (FlowerId) REFERENCES dbo.Flowers (FlowerId),
    CONSTRAINT FK_Cart_Wrapping FOREIGN KEY (WrappingId) REFERENCES dbo.WrappingSheets (WrappingId),
    CONSTRAINT FK_Cart_Ribbons FOREIGN KEY (RibbonId) REFERENCES dbo.Ribbons (RibbonId),
    CONSTRAINT CK_Cart_Quantity CHECK (Quantity BETWEEN 1 AND 99),
    CONSTRAINT CK_Cart_Shape CHECK
    (
        (IsCustom = 0 AND FlowerId IS NOT NULL AND CustomData IS NULL)
        OR
        (IsCustom = 1 AND FlowerId IS NULL AND CustomData IS NOT NULL)
    )
);
GO
CREATE INDEX IX_Cart_UserId ON dbo.Cart (UserId);
GO

/* ============================================================
   TABLE 6: ORDERS
   Order headers placed through checkout. Financial totals are
   persisted as immutable snapshots at order creation time.
   ============================================================ */
CREATE TABLE dbo.Orders
(
    OrderId         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    UserId          INT           NOT NULL,
    CustomerName    NVARCHAR(100) NOT NULL,
    Phone           NVARCHAR(20)  NOT NULL,
    DeliveryAddress NVARCHAR(500) NOT NULL,
    DeliveryDate    DATE          NOT NULL,
    FlowerSubtotal  DECIMAL(10,2) NOT NULL,
    DeliveryFee     DECIMAL(10,2) NOT NULL,
    GrandTotal      DECIMAL(10,2) NOT NULL,
    Status          NVARCHAR(30)  NOT NULL CONSTRAINT DF_Orders_Status DEFAULT ('Confirmed'),
    OrderDate       DATETIME2(0)  NOT NULL CONSTRAINT DF_Orders_OrderDate DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES dbo.Users (UserId),
    CONSTRAINT CK_Orders_Subtotal CHECK (FlowerSubtotal >= 0),
    CONSTRAINT CK_Orders_Delivery CHECK (DeliveryFee >= 0),
    CONSTRAINT CK_Orders_Total CHECK (GrandTotal >= 0)
);
GO
CREATE INDEX IX_Orders_UserId ON dbo.Orders (UserId, OrderDate DESC);
GO

/* ============================================================
   TABLE 7: ORDER DETAILS
   Order line items with immutable price, wrapping, and ribbon snapshots.
   Subsequent catalogue price updates never alter historical orders.
   ============================================================ */
CREATE TABLE dbo.OrderDetails
(
    OrderDetailId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_OrderDetails PRIMARY KEY,
    OrderId       INT           NOT NULL,
    FlowerId      INT           NULL,
    ItemName      NVARCHAR(300) NOT NULL,
    Quantity      INT           NOT NULL,
    UnitPrice     DECIMAL(10,2) NOT NULL,
    WrappingName  NVARCHAR(100) NULL,
    WrappingPrice DECIMAL(10,2) NOT NULL CONSTRAINT DF_OrderDetails_WrapPrice DEFAULT (0),
    RibbonName    NVARCHAR(100) NULL,
    RibbonPrice   DECIMAL(10,2) NOT NULL CONSTRAINT DF_OrderDetails_RibbonPrice DEFAULT (0),
    LineTotal     DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId) REFERENCES dbo.Orders (OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_Flowers FOREIGN KEY (FlowerId) REFERENCES dbo.Flowers (FlowerId),
    CONSTRAINT CK_OrderDetails_Qty CHECK (Quantity BETWEEN 1 AND 99),
    CONSTRAINT CK_OrderDetails_Unit CHECK (UnitPrice >= 0),
    CONSTRAINT CK_OrderDetails_Line CHECK (LineTotal >= 0)
);
GO
CREATE INDEX IX_OrderDetails_OrderId ON dbo.OrderDetails (OrderId);
GO

/* ============================================================
   TABLE 8: CONTACT MESSAGES
   Inquiries submitted through Contact.aspx.
   ============================================================ */
CREATE TABLE dbo.ContactMessages
(
    MessageId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ContactMessages PRIMARY KEY,
    FullName  NVARCHAR(100)  NOT NULL,
    Email     NVARCHAR(150)  NOT NULL,
    Subject   NVARCHAR(150)  NOT NULL,
    Message   NVARCHAR(2000) NOT NULL,
    CreatedAt DATETIME2(0)   NOT NULL CONSTRAINT DF_Contact_CreatedAt DEFAULT (SYSUTCDATETIME())
);
GO

/* ============================================================
   SAMPLE DATA - FLOWERS (12 Records)
   FlowerId 1-8:  Ready-made bouquets shown in Shop.aspx
   FlowerId 9-12: Single stems shown in CustomBouquet.aspx
   ============================================================ */
SET IDENTITY_INSERT dbo.Flowers ON;

INSERT INTO dbo.Flowers
    (FlowerId, Name, Category, Description, Price, PricePerStem, ImagePath, Badge, ShowInShop, ShowInBuilder, IsActive)
VALUES
(1, N'The Ros' + NCHAR(233) + N' Edit',        N'Roses',      N'Twelve blush garden roses, hand-tied with eucalyptus and finished in signature paper.', 1499.00, 45.00, N'~/Images/Flowers/rose.svg',      N'BESTSELLER', 1, 0, 1),
(2, N'Crimson Romance',      N'Roses',      N'Fifteen deep red roses for grand declarations and unforgettable evenings.',             1699.00, 45.00, N'~/Images/Flowers/rose.svg',      NULL,          1, 0, 1),
(3, N'Sunday in Bloom',      N'Tulips',     N'Twenty fresh seasonal tulips in soft pastel shades, wrapped in ivory paper.',           1899.00, 60.00, N'~/Images/Flowers/tulip.svg',     N'SEASONAL',   1, 0, 1),
(4, N'Peach Petal Whisper',  N'Tulips',     N'A dozen peach tulips with a gentle, romantic silhouette for everyday joy.',             1299.00, 60.00, N'~/Images/Flowers/tulip.svg',     NULL,          1, 0, 1),
(5, N'Pure Elegance',        N'Lilies',     N'Ten Casablanca lilies arranged with sage foliage in premium white paper.',               2199.00, 75.00, N'~/Images/Flowers/lily.svg',      N'NEW ARRIVAL',1, 0, 1),
(6, N'White Garden',         N'Lilies',     N'Eight ivory lilies with delicate greenery, quietly luxurious.',                         1799.00, 75.00, N'~/Images/Flowers/lily.svg',      NULL,          1, 0, 1),
(7, N'Golden Hour',          N'Sunflowers', N'Nine sunflowers gathered with wild grasses for warmth in every petal.',                 1599.00, 55.00, N'~/Images/Flowers/sunflower.svg', N'LIMITED',    1, 0, 1),
(8, N'Sunshine Symphony',    N'Sunflowers', N'Twelve sunflowers and eucalyptus, a celebration in a bouquet.',                         1899.00, 55.00, N'~/Images/Flowers/sunflower.svg', NULL,          1, 0, 1),

/* Per-stem choices used by the Custom Bouquet builder */
(9,  N'Garden Rose Stem',     N'Roses',      N'Blush garden rose, sold per stem.',        45.00, 45.00, N'~/Images/Flowers/rose.svg',      NULL, 0, 1, 1),
(10, N'French Tulip Stem',    N'Tulips',     N'Fresh French tulip, sold per stem.',       60.00, 60.00, N'~/Images/Flowers/tulip.svg',     NULL, 0, 1, 1),
(11, N'Casablanca Lily Stem', N'Lilies',     N'Fragrant ivory lily, sold per stem.',      75.00, 75.00, N'~/Images/Flowers/lily.svg',      NULL, 0, 1, 1),
(12, N'Sunflower Stem',       N'Sunflowers', N'Bright sunflower, sold per stem.',         55.00, 55.00, N'~/Images/Flowers/sunflower.svg', NULL, 0, 1, 1);

SET IDENTITY_INSERT dbo.Flowers OFF;
GO

/* ============================================================
   SAMPLE DATA - WRAPPING SHEETS (3 Records)
   ============================================================ */
SET IDENTITY_INSERT dbo.WrappingSheets ON;
INSERT INTO dbo.WrappingSheets (WrappingId, Name, Description, Price, ImagePath, IsActive)
VALUES
(1, N'Pink Floral Paper',   N'Soft blush paper with a hand-pressed floral motif.',      120.00, N'~/Images/Wrapping/pink-floral.svg',   1),
(2, N'White Premium Paper', N'Matte ivory paper with a subtle pearl finish.',           150.00, N'~/Images/Wrapping/white-premium.svg', 1),
(3, N'Brown Kraft Paper',   N'Natural kraft paper for an understated, rustic look.',      90.00, N'~/Images/Wrapping/brown-kraft.svg',   1);
SET IDENTITY_INSERT dbo.WrappingSheets OFF;
GO

/* ============================================================
   SAMPLE DATA - RIBBONS (3 Records)
   ============================================================ */
SET IDENTITY_INSERT dbo.Ribbons ON;
INSERT INTO dbo.Ribbons (RibbonId, Name, Description, Price, ColorHex, IsActive)
VALUES
(1, N'Satin Pink',  N'Soft satin ribbon in signature rose pink.',   40.00, '#C77F91', 1),
(2, N'Classic Red', N'Rich satin ribbon in classic red.',          40.00, '#A8434F', 1),
(3, N'Soft White',  N'Delicate ivory ribbon with a satin sheen.',  35.00, '#FFF9F2', 1);
SET IDENTITY_INSERT dbo.Ribbons OFF;
GO

/* ============================================================
   VERIFICATION QUERIES
   Confirms table creation, catalogue record counts, foreign keys,
   and identity settings.
   ============================================================ */

-- 1. Verify All 8 Tables Exist
SELECT 
    expected.name AS ExpectedTable,
    CASE WHEN t.object_id IS NOT NULL THEN 'EXISTS (OK)' ELSE 'MISSING (ERROR)' END AS TableStatus
FROM (VALUES 
    ('Users'), ('Flowers'), ('WrappingSheets'), ('Ribbons'), 
    ('Cart'), ('Orders'), ('OrderDetails'), ('ContactMessages')
) AS expected(name)
LEFT JOIN sys.tables t ON t.name = expected.name AND SCHEMA_NAME(t.schema_id) = 'dbo'
ORDER BY expected.name;

-- 2. Verify Catalogue Seed Data Counts
SELECT 'Flowers' AS TableName, COUNT(*) AS ActualCount, 12 AS ExpectedCount,
       CASE WHEN COUNT(*) = 12 THEN 'PASSED' ELSE 'FAILED' END AS Result
FROM dbo.Flowers
UNION ALL
SELECT 'WrappingSheets', COUNT(*), 3,
       CASE WHEN COUNT(*) = 3 THEN 'PASSED' ELSE 'FAILED' END
FROM dbo.WrappingSheets
UNION ALL
SELECT 'Ribbons', COUNT(*), 3,
       CASE WHEN COUNT(*) = 3 THEN 'PASSED' ELSE 'FAILED' END
FROM dbo.Ribbons;

-- 3. Verify Foreign Key Relationships
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc 
    ON fk.object_id = fkc.constraint_object_id
ORDER BY ChildTable, ForeignKeyName;

-- 4. Verify Identity Seed and Status
SELECT 
    t.name AS TableName,
    c.name AS IdentityColumn,
    IDENT_CURRENT('dbo.' + t.name) AS CurrentIdentityValue
FROM sys.tables t
INNER JOIN sys.identity_columns c ON t.object_id = c.object_id
WHERE SCHEMA_NAME(t.schema_id) = 'dbo'
ORDER BY t.name;
GO
