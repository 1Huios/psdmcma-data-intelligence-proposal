-- ===============================
-- PSDMCMA DATA AUTOMATION SCRIPT
-- ===============================
CREATE DATABASE PSDMCMA_DB;

USE PSDMCMA_DB;

-- 1. Facilities Table (Enhanced)
CREATE TABLE Facilities (
    FacilityID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    FacilityCode VARCHAR(20) UNIQUE,
    Location VARCHAR(100) NOT NULL,
    LGA VARCHAR(50) NOT NULL,
    Type ENUM('Primary', 'Secondary', 'Tertiary', 'Warehouse', 'Other') NOT NULL,
    ContactPerson VARCHAR(100),
    ContactPhone VARCHAR(20),
    Email VARCHAR(100),
    Address TEXT,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Phone VARCHAR(20) NOT NULL,
    Email VARCHAR(100),
    Address TEXT,
    TaxID VARCHAR(50),
    BankAccount VARCHAR(50),
    BankName VARCHAR(100),
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 3. Products Table (Enhanced)
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductCode VARCHAR(20) UNIQUE,
    Name VARCHAR(100) NOT NULL,
    GenericName VARCHAR(100),
    Description TEXT,
    Category ENUM('Drug', 'Consumable', 'Equipment', 'Vaccine', 'Other') NOT NULL,
    UnitOfMeasure ENUM('tablet', 'capsule', 'bottle', 'box', 'pack', 'unit', 'pair', 'vial', 'ampoule') NOT NULL,
    PackSize INT NOT NULL COMMENT 'Quantity in the smallest package unit',
    BatchNumber VARCHAR(50),
    ExpiryDate DATE,
    UnitPrice DECIMAL(10,2),
    Manufacturer VARCHAR(100),
    SupplierID INT,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- 4. Staff Table (Enhanced)
CREATE TABLE Staff (
    StaffID INT PRIMARY KEY AUTO_INCREMENT,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Role ENUM('Admin', 'Pharmacist', 'Storekeeper', 'Driver', 'Supervisor', 'Support', 'Procurement_Officer', 'Finance_Officer') NOT NULL,
    FacilityID INT,
    HireDate DATE,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID)
);

-- 5. Inventory Table (Enhanced)
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY AUTO_INCREMENT,
    FacilityID INT NOT NULL,
    ProductID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    ExpiryDate DATE NOT NULL,
    QuantityAvailable INT NOT NULL,
    QuantityAllocated INT DEFAULT 0,
    ReorderLevel INT,
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ShelfLocation VARCHAR(50),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    INDEX (FacilityID, ProductID)
);

-- 6. Procurements Table (Enhanced)
CREATE TABLE Procurements (
    ProcurementID INT PRIMARY KEY AUTO_INCREMENT,
    PONumber VARCHAR(20) UNIQUE,
    SupplierID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ExpectedDeliveryDate DATE,
    Status ENUM('Draft', 'Submitted', 'Approved', 'Rejected', 'Partially_Received', 'Fully_Received') DEFAULT 'Draft',
    TotalAmount DECIMAL(12,2),
    PreparedBy INT NOT NULL,
    ApprovedBy INT,
    ApprovalDate DATETIME,
    Notes TEXT,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (PreparedBy) REFERENCES Staff(StaffID),
    FOREIGN KEY (ApprovedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 7. Procurement Items Table
CREATE TABLE ProcurementItems (
    ProcurementItemID INT PRIMARY KEY AUTO_INCREMENT,
    ProcurementID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    ReceivedQuantity INT DEFAULT 0,
    FOREIGN KEY (ProcurementID) REFERENCES Procurements(ProcurementID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 8. Receivings Table
CREATE TABLE Receivings (
    ReceivingID INT PRIMARY KEY AUTO_INCREMENT,
    ReceivingNumber VARCHAR(20) UNIQUE,
    ProcurementID INT,
    ReceivedDate DATE NOT NULL,
    ReceivedBy INT NOT NULL,
    SupplierID INT NOT NULL,
    InvoiceNumber VARCHAR(50),
    InvoiceDate DATE,
    InvoiceAmount DECIMAL(12,2),
    Notes TEXT,
    FOREIGN KEY (ProcurementID) REFERENCES Procurements(ProcurementID),
    FOREIGN KEY (ReceivedBy) REFERENCES Staff(StaffID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 9. Receiving Items Table
CREATE TABLE ReceivingItems (
    ReceivingItemID INT PRIMARY KEY AUTO_INCREMENT,
    ReceivingID INT NOT NULL,
    ProcurementItemID INT,
    ProductID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    ExpiryDate DATE NOT NULL,
    QuantityReceived INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (ReceivingID) REFERENCES Receivings(ReceivingID),
    FOREIGN KEY (ProcurementItemID) REFERENCES ProcurementItems(ProcurementItemID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 10. Requisitions Table
CREATE TABLE Requisitions (
    RequisitionID INT PRIfacilitiesFacilityIDMARY KEY AUTO_INCREMENT,
    RequisitionNumber VARCHAR(20) UNIQUE,
    RequestingFacilityID INT NOT NULL,
    SupplyingFacilityID INT NOT NULL,
    RequisitionDate DATE NOT NULL,
    Status ENUM('Draft', 'Submitted', 'Approved', 'Rejected', 'Partially_Fulfilled', 'Fully_Fulfilled') DEFAULT 'Draft',
    PreparedBy INT NOT NULL,
    ApprovedBy INT,
    ApprovalDate DATETIME,
    Notes TEXT,
    FOREIGN KEY (RequestingFacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (SupplyingFacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (PreparedBy) REFERENCES Staff(StaffID),
    FOREIGN KEY (ApprovedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 11. Requisition Items Table
CREATE TABLE RequisitionItems (
    RequisitionItemID INT PRIMARY KEY AUTO_INCREMENT,
    RequisitionID INT NOT NULL,
    ProductID INT NOT NULL,
    QuantityRequested INT NOT NULL,
    QuantityApproved INT,
    QuantityIssued INT DEFAULT 0,
    FOREIGN KEY (RequisitionID) REFERENCES Requisitions(RequisitionID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 12. Disbursements Table (Enhanced)
CREATE TABLE Disbursements (
    DisbursementID INT PRIMARY KEY AUTO_INCREMENT,
    DisbursementNumber VARCHAR(20) UNIQUE,
    RequisitionID INT NOT NULL,
    DisbursementDate DATE NOT NULL,
    IssuedBy INT NOT NULL,
    ReceivedBy INT,
    Notes TEXT,
    FOREIGN KEY (RequisitionID) REFERENCES Requisitions(RequisitionID),
    FOREIGN KEY (IssuedBy) REFERENCES Staff(StaffID),
    FOREIGN KEY (ReceivedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 13. Disbursement Items Table
CREATE TABLE DisbursementItems (
    DisbursementItemID INT PRIMARY KEY AUTO_INCREMENT,
    DisbursementID INT NOT NULL,
    RequisitionItemID INT NOT NULL,
    ProductID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    ExpiryDate DATE NOT NULL,
    QuantityDisbursed INT NOT NULL,
    FOREIGN KEY (DisbursementID) REFERENCES Disbursements(DisbursementID),
    FOREIGN KEY (RequisitionItemID) REFERENCES RequisitionItems(RequisitionItemID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 14. Stock Movements Table (for tracking all inventory transactions)
CREATE TABLE StockMovements (
    MovementID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    FacilityID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    MovementType ENUM('Purchase', 'Receiving', 'Requisition', 'Disbursement', 'Adjustment', 'Return', 'Loss') NOT NULL,
    ReferenceID INT COMMENT 'ID of the related transaction',
    ReferenceNumber VARCHAR(20) COMMENT 'Reference number of the related transaction',
    QuantityBefore INT NOT NULL,
    QuantityChange INT NOT NULL COMMENT 'Positive for additions, negative for deductions',
    QuantityAfter INT NOT NULL,
    MovementDate DATETIME NOT NULL,
    PerformedBy INT NOT NULL,
    Notes TEXT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (PerformedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. Alerts Table (Enhanced)
CREATE TABLE Alerts (
    AlertID INT PRIMARY KEY AUTO_INCREMENT,
    AlertType ENUM('Expiry', 'LowStock', 'Reorder', 'System', 'Other') NOT NULL,
    Message VARCHAR(255) NOT NULL,
    RelatedEntityType ENUM('Product', 'Facility', 'Procurement', 'Requisition', 'Disbursement') NOT NULL,
    RelatedEntityID INT NOT NULL,
    AlertDate DATETIME NOT NULL,
    IsRead BOOLEAN DEFAULT FALSE,
    ReadBy INT,
    ReadDate DATETIME,
    Priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    FOREIGN KEY (ReadBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16. Attendance Log Table
CREATE TABLE AttendanceLog (
    AttendanceID INT PRIMARY KEY AUTO_INCREMENT,
    StaffID INT NOT NULL,
    CheckInTime DATETIME,
    CheckOutTime DATETIME,
    WorkDate DATE,
    Remarks VARCHAR(255),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Training Records Table
CREATE TABLE TrainingRecords (
    TrainingID INT PRIMARY KEY AUTO_INCREMENT,
    StaffID INT NOT NULL,
    TrainingTitle VARCHAR(100) NOT NULL,
    Provider VARCHAR(100) NOT NULL,
    DateAttended DATE NOT NULL,
    CertificateIssued BOOLEAN DEFAULT FALSE,
    ExpirationDate DATE,
    Notes TEXT,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 18. Access Control Table
CREATE TABLE AccessControl (
    AccessID INT PRIMARY KEY AUTO_INCREMENT,
    StaffID INT NOT NULL,
    ModuleName VARCHAR(100) NOT NULL,
    PermissionLevel ENUM('Read', 'Write', 'Approve', 'Admin') NOT NULL,
    GrantedOn DATE NOT NULL,
    RevokedOn DATE,
    GrantedBy INT NOT NULL,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID),
    FOREIGN KEY (GrantedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 19. Stock Takes Table (for inventory counts)
CREATE TABLE StockTakes (
    StockTakeID INT PRIMARY KEY AUTO_INCREMENT,
    FacilityID INT NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME,
    Status ENUM('In_Progress', 'Completed', 'Cancelled') DEFAULT 'In_Progress',
    ConductedBy INT NOT NULL,
    VerifiedBy INT,
    Notes TEXT,
    FOREIGN KEY (FacilityID) REFERENCES Facilities(FacilityID),
    FOREIGN KEY (ConductedBy) REFERENCES Staff(StaffID),
    FOREIGN KEY (VerifiedBy) REFERENCES Staff(StaffID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 20. Stock Take Items Table
CREATE TABLE StockTakeItems (
    StockTakeItemID INT PRIMARY KEY AUTO_INCREMENT,
    StockTakeID INT NOT NULL,
    ProductID INT NOT NULL,
    BatchNumber VARCHAR(50) NOT NULL,
    SystemQuantity INT NOT NULL COMMENT 'Quantity according to system records',
    CountedQuantity INT NOT NULL COMMENT 'Actual counted quantity',
    Variance INT GENERATED ALWAYS AS (CountedQuantity - SystemQuantity) STORED,
    Notes TEXT,
    FOREIGN KEY (StockTakeID) REFERENCES StockTakes(StockTakeID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ====================================
-- AUTOMATION SECTION
-- ====================================

-- A. Trigger to auto-update inventory after disbursement
DELIMITER //
CREATE TRIGGER UpdateInventoryAfterDisbursement
AFTER INSERT ON DisbursementItems
FOR EACH ROW
BEGIN
  -- Update inventory at supplying facility
  UPDATE Inventory
  SET QuantityAvailable = QuantityAvailable - NEW.QuantityDisbursed,
      LastUpdated = CURRENT_TIMESTAMP
  WHERE FacilityID = (SELECT SupplyingFacilityID FROM Disbursements d JOIN Requisitions r ON d.RequisitionID = r.RequisitionID WHERE d.DisbursementID = NEW.DisbursementID)
  AND ProductID = NEW.ProductID
  AND BatchNumber = NEW.BatchNumber;
  
  -- Record stock movement
  INSERT INTO StockMovements (
    ProductID, FacilityID, BatchNumber, MovementType, 
    ReferenceID, ReferenceNumber, QuantityBefore, 
    QuantityChange, QuantityAfter, MovementDate, PerformedBy
  )
  SELECT 
    NEW.ProductID, 
    r.SupplyingFacilityID,
    NEW.BatchNumber,
    'Disbursement',
    NEW.DisbursementID,
    d.DisbursementNumber,
    i.QuantityAvailable,
    -NEW.QuantityDisbursed,
    i.QuantityAvailable - NEW.QuantityDisbursed,
    CURRENT_TIMESTAMP,
    d.IssuedBy
  FROM Disbursements d
  JOIN Requisitions r ON d.RequisitionID = r.RequisitionID
  JOIN Inventory i ON i.FacilityID = r.SupplyingFacilityID AND i.ProductID = NEW.ProductID AND i.BatchNumber = NEW.BatchNumber
  WHERE d.DisbursementID = NEW.DisbursementID;
END;
//
DELIMITER ;

-- B. Trigger to update inventory after receiving
DELIMITER //
CREATE TRIGGER UpdateInventoryAfterReceiving
AFTER INSERT ON ReceivingItems
FOR EACH ROW
BEGIN
  -- Check if inventory record exists for this product/batch
  IF EXISTS (
    SELECT 1 FROM Inventory 
    WHERE FacilityID = (SELECT FacilityID FROM Receivings WHERE ReceivingID = NEW.ReceivingID)
    AND ProductID = NEW.ProductID
    AND BatchNumber = NEW.BatchNumber
  ) THEN
    -- Update existing inventory
    UPDATE Inventory
    SET QuantityAvailable = QuantityAvailable + NEW.QuantityReceived,
        LastUpdated = CURRENT_TIMESTAMP
    WHERE FacilityID = (SELECT FacilityID FROM Receivings WHERE ReceivingID = NEW.ReceivingID)
    AND ProductID = NEW.ProductID
    AND BatchNumber = NEW.BatchNumber;
  ELSE
    -- Insert new inventory record
    INSERT INTO Inventory (
      FacilityID, ProductID, BatchNumber, ExpiryDate,
      QuantityAvailable, LastUpdated
    )
    SELECT 
      r.FacilityID, NEW.ProductID, NEW.BatchNumber, NEW.ExpiryDate,
      NEW.QuantityReceived, CURRENT_TIMESTAMP
    FROM Receivings r
    WHERE r.ReceivingID = NEW.ReceivingID;
  END IF;
  
  -- Record stock movement
  INSERT INTO StockMovements (
    ProductID, FacilityID, BatchNumber, MovementType, 
    ReferenceID, ReferenceNumber, QuantityBefore, 
    QuantityChange, QuantityAfter, MovementDate, PerformedBy
  )
  SELECT 
    NEW.ProductID, 
    r.FacilityID,
    NEW.BatchNumber,
    'Receiving',
    NEW.ReceivingID,
    r.ReceivingNumber,
    COALESCE(i.QuantityAvailable, 0),
    NEW.QuantityReceived,
    COALESCE(i.QuantityAvailable, 0) + NEW.QuantityReceived,
    CURRENT_TIMESTAMP,
    r.ReceivedBy
  FROM Receivings r
  LEFT JOIN Inventory i ON i.FacilityID = r.FacilityID AND i.ProductID = NEW.ProductID AND i.BatchNumber = NEW.BatchNumber
  WHERE r.ReceivingID = NEW.ReceivingID;
END;
//
DELIMITER ;

-- C. Stored Procedure to check low stock
DELIMITER //
CREATE PROCEDURE CheckLowStock(IN threshold INT)
BEGIN
  SELECT 
    f.Name AS Facility, 
    p.Name AS Product, 
    p.ProductCode,
    i.QuantityAvailable,
    i.ReorderLevel,
    CASE 
      WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
      WHEN i.QuantityAvailable < i.ReorderLevel THEN 'Below Reorder Level'
      WHEN i.QuantityAvailable < threshold THEN 'Low Stock'
      ELSE 'Adequate'
    END AS StockStatus
  FROM Inventory i
  JOIN Facilities f ON i.FacilityID = f.FacilityID
  JOIN Products p ON i.ProductID = p.ProductID
  WHERE i.QuantityAvailable < threshold OR i.QuantityAvailable < i.ReorderLevel
  ORDER BY StockStatus, f.Name, p.Name;
END;
//
DELIMITER ;

-- D. Stored Procedure to generate expiry alerts
DELIMITER //
CREATE PROCEDURE GenerateExpiryAlerts(IN daysThreshold INT)
BEGIN
  -- Delete old unread expiry alerts for the same products
  DELETE FROM Alerts 
  WHERE AlertType = 'Expiry' 
  AND IsRead = FALSE
  AND RelatedEntityID IN (
    SELECT ProductID FROM Products 
    WHERE DATEDIFF(ExpiryDate, CURDATE()) <= daysThreshold
  );
  
  -- Insert new expiry alerts
  INSERT INTO Alerts (
    AlertType, Message, RelatedEntityType, 
    RelatedEntityID, AlertDate, Priority
  )
  SELECT 
    'Expiry',
    CONCAT('Product ', p.Name, ' (Batch: ', p.BatchNumber, ') is expiring in ', DATEDIFF(p.ExpiryDate, CURDATE()), ' days'),
    'Product',
    p.ProductID,
    CURRENT_TIMESTAMP,
    CASE 
      WHEN DATEDIFF(p.ExpiryDate, CURDATE()) <= 30 THEN 'High'
      WHEN DATEDIFF(p.ExpiryDate, CURDATE()) <= 60 THEN 'Medium'
      ELSE 'Low'
    END
  FROM Products p
  WHERE DATEDIFF(p.ExpiryDate, CURDATE()) <= daysThreshold
  AND p.ExpiryDate > CURDATE();
END;
//
DELIMITER ;

-- E. Daily Event to monitor expiries and low stock
SET GLOBAL event_scheduler = ON;

DELIMITER //
CREATE EVENT InventoryMonitor
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
  -- Check for expiring products (within 60 days)
  CALL GenerateExpiryAlerts(60);
  
  -- Check for low stock (below reorder level)
  INSERT INTO Alerts (
    AlertType, Message, RelatedEntityType, 
    RelatedEntityID, AlertDate, Priority
  )
  SELECT 
    'LowStock',
    CONCAT('Low stock alert for ', p.Name, ' at ', f.Name, '. Current stock: ', i.QuantityAvailable),
    'Product',
    i.ProductID,
    CURRENT_TIMESTAMP,
    CASE 
      WHEN i.QuantityAvailable <= 0 THEN 'Critical'
      WHEN i.QuantityAvailable < i.ReorderLevel THEN 'High'
      ELSE 'Medium'
    END
  FROM Inventory i
  JOIN Products p ON i.ProductID = p.ProductID
  JOIN Facilities f ON i.FacilityID = f.FacilityID
  WHERE i.QuantityAvailable < i.ReorderLevel OR i.QuantityAvailable <= 0;
END;
//
DELIMITER ;

-- F. View for Monthly Consumption Trends
CREATE VIEW MonthlyConsumption AS
SELECT 
  r.RequestingFacilityID AS FacilityID,
  di.ProductID,
  MONTH(d.DisbursementDate) AS Month,
  YEAR(d.DisbursementDate) AS Year,
  SUM(di.QuantityDisbursed) AS TotalUsed
FROM DisbursementItems di
JOIN Disbursements d ON di.DisbursementID = d.DisbursementID
JOIN Requisitions r ON d.RequisitionID = r.RequisitionID
GROUP BY r.RequestingFacilityID, di.ProductID, Year, Month;

-- G. Comprehensive Dashboard View
CREATE VIEW DashboardOverview AS
SELECT 
    f.FacilityID,
    f.Name AS FacilityName,
    f.Location,
    f.LGA,
    f.Type AS FacilityType,
    
    p.ProductID,
    p.Name AS ProductName,
    p.ProductCode,
    p.Category,
    p.UnitOfMeasure,
    
    i.BatchNumber,
    i.ExpiryDate,
    i.QuantityAvailable,
    i.ReorderLevel,
    i.LastUpdated,

    -- Days to expiry
    DATEDIFf(i.ExpiryDate, CURDATE()) AS DaysUntilExpiry,

    -- Monthly consumption trend
    IFNULL(mc.TotalUsed, 0) AS LastMonthUsed,

    -- Stock status
    CASE 
        WHEN i.QuantityAvailable <= 0 THEN 'Out of Stock'
        WHEN i.QuantityAvailable < i.ReorderLevel THEN 'Below Reorder'
        WHEN i.QuantityAvailable < (i.ReorderLevel * 1.5) THEN 'Low Stock'
        ELSE 'Adequate'
    END AS StockStatus,

    -- Expiry status
    CASE 
        WHEN i.ExpiryDate <= CURDATE() THEN 'Expired'
        WHEN DATEDIFF(i.ExpiryDate, CURDATE()) <= 30 THEN 'Expiring Soon'
        WHEN DATEDIFF(i.ExpiryDate, CURDATE()) <= 90 THEN 'Near Expiry'
        ELSE 'Valid'
    END AS ExpiryStatus,

    -- Supplier info
    s.SupplierName,
    s.ContactPerson AS SupplierContact,
    s.Phone AS SupplierPhone

FROM 
    Inventory i
JOIN 
    Facilities f ON i.FacilityID = f.FacilityID
JOIN 
    Products p ON i.ProductID = p.ProductID
LEFT JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
LEFT JOIN 
    (SELECT FacilityID, ProductID, TotalUsed 
     FROM MonthlyConsumption 
     WHERE Month = MONTH(CURDATE()) - 1 AND Year = YEAR(CURDATE())) mc 
    ON mc.FacilityID = i.FacilityID AND mc.ProductID = i.ProductID
WHERE
    f.IsActive = TRUE AND p.IsActive = TRUE;
    
    
    
    
    
    
    
    
    
    select *
    from products;