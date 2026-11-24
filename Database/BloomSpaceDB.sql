/* ============================================================
   BLOOM SPACE - ONLINE FLOWER SHOPPING WEBSITE
   SQL Server database script (.NET Framework 4.8 / ADO.NET)

   HOW TO USE
   1. Open this file in SQL Server Management Studio (or Visual
      Studio SQL Server Object Explorer).
   2. Connect to your SQL Server instance:
          .\SQLEXPRESS        (SQL Server Express)
          (LocalDB)\MSSQLLocalDB  (LocalDB that ships with VS 2022)
   3. Run the whole script once. It creates BloomSpaceDB, all
      tables and sample catalogue data.

   NOTE: Re-running the script resets the catalogue tables and
   deletes any accounts/orders created during testing. This is
   intentional so the project can always be demonstrated from a
   clean state.
   ============================================================ */

IF DB_ID('BloomSpaceDB') IS NULL
BEGIN
    CREATE DATABASE BloomSpaceDB;
END
GO

USE BloomSpaceDB;
GO

/* ---------- Drop old tables (child tables first) ---------- */
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
   1. USERS
   Passwords are NEVER stored in plain text. The application
   stores a PBKDF2-SHA256 hash together with a random salt and
   the iteration count used to create it.
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
   2. FLOWERS
   ShowInShop   = 1 -> appears as a ready-made bouquet in Shop
   ShowInBuilder= 1 -> appears as a per-stem choice in the
                       Custom Bouquet builder
   ============================================================ */
CREATE TABLE dbo.Flowers
(
    FlowerId     INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Flowers PRIMARY KEY,
    Name         NVARCHAR(100)  NOT NULL,
    Category     NVARCHAR(50)   NOT NULL,
    Description  NVARCHAR(300)  NULL,
    Price        DECIMAL(10,2)  NOT NULL CONSTRAINT DF_Flowers_Price DEFAULT (0),
    PricePerStem DECIMAL(10,2)  NOT NULL CONSTRAINT DF_Flowers_StemPrice DEFAULT (0),
    ImagePath    NVARCHAR(200)  NOT NULL,
    Badge        NVARCHAR(50)   NULL,
    ShowInShop   BIT            NOT NULL CONSTRAINT DF_Flowers_ShowInShop DEFAULT (1),
    ShowInBuilder BIT           NOT NULL CONSTRAINT DF_Flowers_ShowInBuilder DEFAULT (0),
    IsActive     BIT            NOT NULL CONSTRAINT DF_Flowers_IsActive DEFAULT (1),
    CreatedAt    DATETIME2(0)   NOT NULL CONSTRAINT DF_Flowers_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT CK_Flowers_Price CHECK (Price >= 0),
    CONSTRAINT CK_Flowers_StemPrice CHECK (PricePerStem >= 0)
);
GO
CREATE INDEX IX_Flowers_Category ON dbo.Flowers (Category) INCLUDE (Name, Price, IsActive);
GO

/* ============================================================
   3. WRAPPING SHEETS
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
   4. RIBBONS
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
   5. CART
   A single cart line can be:
     * a ready-made bouquet : FlowerId + Quantity
     * a custom bouquet      : IsCustom = 1, CustomData holds a
       small JSON array of {flowerId, quantity} pairs and
       WrappingId / RibbonId hold the selected finishes.
   Quantity is the number of bouquets for that line.
   Prices are NOT stored here: they are always recalculated
   from the catalogue so a stale client can never set a price.
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
   6. ORDERS
   Totals are snapshots taken when the order is placed.
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
   7. ORDER DETAILS
   ItemName, UnitPrice, WrappingName/Price and RibbonName/Price
   are historical snapshots. Changing a catalogue price later
   must never change an old invoice.
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
   8. CONTACT MESSAGES (contact form inbox)
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
   SAMPLE DATA - READY-MADE BOUQUETS (Shop)
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
   SAMPLE DATA - WRAPPING
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
   SAMPLE DATA - RIBBONS
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
   Quick sanity check
   ============================================================ */
SELECT 'Flowers' AS TableName, COUNT(*) AS Records FROM dbo.Flowers
UNION ALL SELECT 'WrappingSheets', COUNT(*) FROM dbo.WrappingSheets
UNION ALL SELECT 'Ribbons', COUNT(*) FROM dbo.Ribbons;
GO
