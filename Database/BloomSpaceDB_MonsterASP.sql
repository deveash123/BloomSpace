/* =====================================================================
   BLOOM SPACE - BloomSpaceDB_MonsterASP.sql
   Compatible with MonsterASP.net Free MSSQL (db82285) / SQL Server 2025.
   Executes directly in the hosted database without master permissions.
   ===================================================================== */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* ---------- Clean reset (children first) ---------- */
IF OBJECT_ID(N'dbo.OrderDetails',   N'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID(N'dbo.Orders',         N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Cart',           N'U') IS NOT NULL DROP TABLE dbo.Cart;
IF OBJECT_ID(N'dbo.ContactMessages',N'U') IS NOT NULL DROP TABLE dbo.ContactMessages;
IF OBJECT_ID(N'dbo.Ribbons',        N'U') IS NOT NULL DROP TABLE dbo.Ribbons;
IF OBJECT_ID(N'dbo.WrappingSheets', N'U') IS NOT NULL DROP TABLE dbo.WrappingSheets;
IF OBJECT_ID(N'dbo.Flowers',        N'U') IS NOT NULL DROP TABLE dbo.Flowers;
IF OBJECT_ID(N'dbo.Users',          N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

/* ---------- 1. Users ---------- */
CREATE TABLE dbo.Users
(
    UserId        INT IDENTITY(1,1) NOT NULL,
    FullName      NVARCHAR(100)     NOT NULL,
    Email         NVARCHAR(256)     NOT NULL,
    Phone         VARCHAR(15)       NOT NULL,
    PasswordHash  VARCHAR(128)      NOT NULL,
    PasswordSalt  VARCHAR(64)       NOT NULL,
    Iterations    INT               NOT NULL CONSTRAINT DF_Users_Iterations DEFAULT (100000),
    CreatedAt     DATETIME2(0)      NOT NULL CONSTRAINT DF_Users_CreatedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Users PRIMARY KEY (UserId),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);
GO

/* ---------- 2. Flowers ---------- */
CREATE TABLE dbo.Flowers
(
    FlowerId     INT IDENTITY(1,1) NOT NULL,
    Name         NVARCHAR(100)     NOT NULL,
    Category     NVARCHAR(20)      NOT NULL,
    Description  NVARCHAR(300)     NOT NULL,
    UnitPrice    DECIMAL(10,2)     NOT NULL,   -- price per stem, INR
    ImageUrl     NVARCHAR(200)     NOT NULL,
    IsFeatured   BIT               NOT NULL CONSTRAINT DF_Flowers_IsFeatured DEFAULT (0),
    IsActive     BIT               NOT NULL CONSTRAINT DF_Flowers_IsActive   DEFAULT (1),
    CONSTRAINT PK_Flowers PRIMARY KEY (FlowerId),
    CONSTRAINT UQ_Flowers_Name UNIQUE (Name),
    CONSTRAINT CK_Flowers_Price CHECK (UnitPrice > 0),
    CONSTRAINT CK_Flowers_Category CHECK (Category IN (N'Roses', N'Tulips', N'Lilies', N'Sunflowers'))
);
GO

/* ---------- 3. WrappingSheets ---------- */
CREATE TABLE dbo.WrappingSheets
(
    WrappingId  INT IDENTITY(1,1) NOT NULL,
    Name        NVARCHAR(100)     NOT NULL,
    Price       DECIMAL(10,2)     NOT NULL,
    ColorHex    CHAR(7)           NOT NULL,   -- paper colour used by the live bouquet preview
    ImageUrl    NVARCHAR(200)     NOT NULL,
    IsActive    BIT               NOT NULL CONSTRAINT DF_Wrapping_IsActive DEFAULT (1),
    CONSTRAINT PK_WrappingSheets PRIMARY KEY (WrappingId),
    CONSTRAINT UQ_WrappingSheets_Name UNIQUE (Name),
    CONSTRAINT CK_WrappingSheets_Price CHECK (Price >= 0)
);
GO

/* ---------- 4. Ribbons ---------- */
CREATE TABLE dbo.Ribbons
(
    RibbonId   INT IDENTITY(1,1) NOT NULL,
    Name       NVARCHAR(100)     NOT NULL,
    Price      DECIMAL(10,2)     NOT NULL,
    ColorHex   CHAR(7)           NOT NULL,   -- ribbon colour used by the live bouquet preview
    ImageUrl   NVARCHAR(200)     NOT NULL,
    IsActive   BIT               NOT NULL CONSTRAINT DF_Ribbons_IsActive DEFAULT (1),
    CONSTRAINT PK_Ribbons PRIMARY KEY (RibbonId),
    CONSTRAINT UQ_Ribbons_Name UNIQUE (Name),
    CONSTRAINT CK_Ribbons_Price CHECK (Price >= 0)
);
GO

/* ---------- 5. Cart ---------- */
CREATE TABLE dbo.Cart
(
    CartId      INT IDENTITY(1,1)  NOT NULL,
    UserId      INT                NOT NULL,
    FlowerId    INT                NOT NULL,
    Quantity    INT                NOT NULL,
    BouquetId   UNIQUEIDENTIFIER   NULL,
    WrappingId  INT                NULL,
    RibbonId    INT                NULL,
    AddedAt     DATETIME2(0)       NOT NULL CONSTRAINT DF_Cart_AddedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Cart PRIMARY KEY (CartId),
    CONSTRAINT FK_Cart_Users     FOREIGN KEY (UserId)     REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    CONSTRAINT FK_Cart_Flowers   FOREIGN KEY (FlowerId)   REFERENCES dbo.Flowers(FlowerId),
    CONSTRAINT FK_Cart_Wrapping  FOREIGN KEY (WrappingId) REFERENCES dbo.WrappingSheets(WrappingId),
    CONSTRAINT FK_Cart_Ribbons   FOREIGN KEY (RibbonId)   REFERENCES dbo.Ribbons(RibbonId),
    CONSTRAINT CK_Cart_Quantity  CHECK (Quantity BETWEEN 1 AND 50),
    CONSTRAINT CK_Cart_BouquetShape CHECK
    (
        (BouquetId IS NULL     AND WrappingId IS NULL     AND RibbonId IS NULL) OR
        (BouquetId IS NOT NULL AND WrappingId IS NOT NULL AND RibbonId IS NOT NULL)
    )
);
GO

CREATE UNIQUE INDEX UX_Cart_Single  ON dbo.Cart (UserId, FlowerId)    WHERE BouquetId IS NULL;
CREATE UNIQUE INDEX UX_Cart_Bouquet ON dbo.Cart (BouquetId, FlowerId) WHERE BouquetId IS NOT NULL;
CREATE INDEX IX_Cart_UserId ON dbo.Cart (UserId);
GO

/* ---------- 6. Orders ---------- */
CREATE TABLE dbo.Orders
(
    OrderId          INT IDENTITY(1,1) NOT NULL,
    UserId           INT               NOT NULL,
    CustomerName     NVARCHAR(100)     NOT NULL,
    Phone            VARCHAR(15)       NOT NULL,
    DeliveryAddress  NVARCHAR(500)     NOT NULL,
    DeliveryDate     DATE              NOT NULL,
    Subtotal         DECIMAL(10,2)     NOT NULL,
    DeliveryFee      DECIMAL(10,2)     NOT NULL,
    TotalAmount      DECIMAL(10,2)     NOT NULL,
    Status           NVARCHAR(20)      NOT NULL CONSTRAINT DF_Orders_Status DEFAULT (N'Placed'),
    OrderedAt        DATETIME2(0)      NOT NULL CONSTRAINT DF_Orders_OrderedAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Orders PRIMARY KEY (OrderId),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId),
    CONSTRAINT CK_Orders_Amounts CHECK (Subtotal >= 0 AND DeliveryFee >= 0 AND TotalAmount = Subtotal + DeliveryFee)
);
GO
CREATE INDEX IX_Orders_UserId ON dbo.Orders (UserId);
GO

/* ---------- 7. OrderDetails ---------- */
CREATE TABLE dbo.OrderDetails
(
    OrderDetailId  INT IDENTITY(1,1) NOT NULL,
    OrderId        INT               NOT NULL,
    FlowerId       INT               NOT NULL,
    BouquetNo      INT               NULL,
    FlowerName     NVARCHAR(100)     NOT NULL,
    UnitPrice      DECIMAL(10,2)     NOT NULL,
    Quantity       INT               NOT NULL,
    WrappingName   NVARCHAR(100)     NULL,
    WrappingPrice  DECIMAL(10,2)     NOT NULL CONSTRAINT DF_OD_WrapPrice DEFAULT (0),
    RibbonName     NVARCHAR(100)     NULL,
    RibbonPrice    DECIMAL(10,2)     NOT NULL CONSTRAINT DF_OD_RibbonPrice DEFAULT (0),
    LineTotal      DECIMAL(10,2)     NOT NULL,
    CONSTRAINT PK_OrderDetails PRIMARY KEY (OrderDetailId),
    CONSTRAINT FK_OD_Orders  FOREIGN KEY (OrderId)  REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OD_Flowers FOREIGN KEY (FlowerId) REFERENCES dbo.Flowers(FlowerId),
    CONSTRAINT CK_OD_Quantity CHECK (Quantity > 0)
);
GO
CREATE INDEX IX_OrderDetails_OrderId ON dbo.OrderDetails (OrderId);
GO

/* ---------- Extra: ContactMessages ---------- */
CREATE TABLE dbo.ContactMessages
(
    MessageId  INT IDENTITY(1,1) NOT NULL,
    FullName   NVARCHAR(100)     NOT NULL,
    Email      NVARCHAR(256)     NOT NULL,
    Subject    NVARCHAR(150)     NOT NULL,
    Message    NVARCHAR(2000)    NOT NULL,
    SentAt     DATETIME2(0)      NOT NULL CONSTRAINT DF_Contact_SentAt DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_ContactMessages PRIMARY KEY (MessageId)
);
GO

/* =====================================================================
   SAMPLE DATA
   ===================================================================== */

INSERT INTO dbo.Flowers (Name, Category, Description, UnitPrice, ImageUrl, IsFeatured) VALUES
(N'Classic Red Rose',  N'Roses',      N'Deep red, velvety petals. The timeless symbol of love.',          50.00, N'~/Images/Flowers/rose-red.jpg',       1),
(N'Blush Pink Rose',   N'Roses',      N'Soft pink petals with a delicate, romantic fragrance.',           45.00, N'~/Images/Flowers/rose-pink.jpg',      0),
(N'Pink Tulip',        N'Tulips',     N'Smooth, cup-shaped blooms that say spring has arrived.',          60.00, N'~/Images/Flowers/tulip-pink.jpg',     1),
(N'White Tulip',       N'Tulips',     N'Pure white tulips for calm, elegant arrangements.',               55.00, N'~/Images/Flowers/tulip-white.jpg',    0),
(N'White Lily',        N'Lilies',     N'Large, fragrant white blooms with graceful curved petals.',       95.00, N'~/Images/Flowers/lily-white.jpg',     1),
(N'Pink Lily',         N'Lilies',     N'Star-shaped pink lilies with a sweet, lingering scent.',          90.00, N'~/Images/Flowers/lily-pink.jpg',      0),
(N'Sunflower',         N'Sunflowers', N'Bright, sun-loving blooms that bring instant cheer.',             50.00, N'~/Images/Flowers/sunflower.jpg',      1),
(N'Mini Sunflower',    N'Sunflowers', N'Petite sunflowers, perfect for cheerful, compact bouquets.',      40.00, N'~/Images/Flowers/sunflower-mini.jpg', 0);
GO

INSERT INTO dbo.WrappingSheets (Name, Price, ColorHex, ImageUrl) VALUES
(N'Pink Floral Paper',  60.00, '#F2C6D0', N'~/Images/Wrapping/wrap-pink.jpg'),
(N'White Premium Paper',80.00, '#FFFFFF', N'~/Images/Wrapping/wrap-white.svg'),
(N'Brown Kraft Paper',  50.00, '#C9A27A', N'~/Images/Wrapping/wrap-kraft.jpg');
GO

INSERT INTO dbo.Ribbons (Name, Price, ColorHex, ImageUrl) VALUES
(N'Satin Pink',  30.00, '#E39AAE', N'~/Images/Ribbons/ribbon-pink.svg'),
(N'Classic Red', 30.00, '#B5252F', N'~/Images/Ribbons/ribbon-red.svg'),
(N'Soft White',  25.00, '#F4EFE8', N'~/Images/Ribbons/ribbon-white.svg');
GO
