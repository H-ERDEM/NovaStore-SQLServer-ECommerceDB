/* =========================================
   NovaStore E-Ticaret Veri Yönetim Sistemi
   ========================================= */

-- BÖLÜM 1: Veri Tabanı Oluşturma
CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- A. Categories Tablosu
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);

-- B. Products Tablosu
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- C. Customers Tablosu
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);

-- D. Orders Tablosu
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- E. OrderDetails Tablosu
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

--------------------------------------------------
-- BÖLÜM 2: Veri Girişi
--------------------------------------------------

-- Görev 1: Kategoriler
INSERT INTO Categories (CategoryName) VALUES
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');

-- Görev 2: Ürünler
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
('Laptop', 25000.00, 15, 1),
('Kablosuz Kulaklık', 1500.00, 35, 1),
('Akıllı Telefon', 18000.00, 10, 1),
('Kadın Mont', 2200.00, 18, 2),
('Erkek Tişört', 450.00, 60, 2),
('Spor Ayakkabı', 1800.00, 22, 2),
('Roman Kitabı', 180.00, 40, 3),
('SQL Eğitim Kitabı', 320.00, 12, 3),
('Parfüm', 950.00, 25, 4),
('Cilt Bakım Kremi', 400.00, 8, 4),
('Masa Lambası', 650.00, 30, 5),
('Kahve Makinesi', 3500.00, 14, 5);

-- Görev 3: Müşteriler
INSERT INTO Customers (FullName, City, Email) VALUES
('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@mail.com'),
('Ayşe Demir', 'Ankara', 'ayse.demir@mail.com'),
('Mehmet Kaya', 'İzmir', 'mehmet.kaya@mail.com'),
('Zeynep Çelik', 'Bursa', 'zeynep.celik@mail.com'),
('Elif Arslan', 'Malatya', 'elif.arslan@mail.com'),
('Murat Şahin', 'Antalya', 'murat.sahin@mail.com');

-- Görev 4: Siparişler
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-06-01', 26500.00),
(2, '2026-06-02', 2650.00),
(3, '2026-06-04', 500.00),
(4, '2026-06-06', 3900.00),
(5, '2026-06-08', 2450.00),
(6, '2026-06-10', 18000.00),
(1, '2026-06-12', 1270.00),
(2, '2026-06-14', 3500.00),
(3, '2026-06-16', 2200.00),
(4, '2026-06-18', 950.00);

-- Sipariş Detayları
INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),
(1, 2, 1),

(2, 4, 1),
(2, 5, 1),

(3, 7, 1),
(3, 8, 1),

(4, 12, 1),
(4, 10, 1),

(5, 6, 1),
(5, 11, 1),

(6, 3, 1),

(7, 9, 1),
(7, 8, 1),

(8, 12, 1),

(9, 4, 1),

(10, 9, 1);

--------------------------------------------------
-- BÖLÜM 3: Sorgulama ve Analiz
--------------------------------------------------

-- 1. Temel Listeleme
-- Stok miktarı 20'den az olan ürünleri stok miktarına göre azalan sırada listele
SELECT 
    ProductName,
    Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

-- 2. Veri Birleştirme
-- Hangi müşteri hangi tarihte sipariş vermiş?
SELECT 
    c.FullName AS MusteriAdi,
    c.City AS Sehir,
    o.OrderDate AS SiparisTarihi,
    o.TotalAmount AS ToplamTutar
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;

-- 3. Çoklu Birleştirme ve Detay Raporu
-- Ahmet Yılmaz isimli müşterinin aldığı ürünler
SELECT 
    c.FullName AS MusteriAdi,
    p.ProductName AS UrunAdi,
    p.Price AS Fiyat,
    cat.CategoryName AS Kategori
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';

-- 4. Gruplama ve Aggregate Fonksiyonlar
-- Hangi kategoride toplam kaç adet ürün var?
SELECT 
    cat.CategoryName AS KategoriAdi,
    COUNT(p.ProductID) AS UrunSayisi
FROM Categories cat
LEFT JOIN Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;

-- 5. Ciro Analizi
-- Her müşterinin toplam harcaması
SELECT 
    c.FullName AS MusteriAdi,
    SUM(o.TotalAmount) AS ToplamCiro
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FullName
ORDER BY ToplamCiro DESC;

-- 6. Zaman Analizi
-- Siparişlerin üzerinden kaç gün geçti?
SELECT 
    OrderID,
    OrderDate,
    DATEDIFF(DAY, OrderDate, GETDATE()) AS GecenGunSayisi
FROM Orders;

--------------------------------------------------
-- BÖLÜM 4: İleri Seviye Veri Tabanı Nesneleri
--------------------------------------------------

-- 1. View Oluşturma
GO
CREATE VIEW vw_SiparisOzet AS
SELECT 
    c.FullName AS MusteriAdi,
    o.OrderDate AS SiparisTarihi,
    p.ProductName AS UrunAdi,
    od.Quantity AS Adet
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;
GO

-- View test sorgusu
SELECT * FROM vw_SiparisOzet;

-- 2. Backup Komutu
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak'
WITH FORMAT,
NAME = 'NovaStoreDB Full Backup';
GO