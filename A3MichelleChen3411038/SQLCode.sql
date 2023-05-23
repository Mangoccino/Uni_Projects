use test 
go 

--CREATE TABLES
CREATE TABLE Customer(
	customerId CHAR(10) PRIMARY KEY,
	firstName VARCHAR(15) NOT NULL,
	lastName VARCHAR(15) NOT NULL,
	Address VARCHAR(200) NOT NULL,
	Phone VARCHAR(10) NOT NULL,
	isHoax VARCHAR(10) DEFAULT 'unverified',
	CHECK(isHoax IN ('verified', 'unverified'))
	--checking isHoax to be either verified or unverified.
);

CREATE TABLE MenuItem(
	ItemCode CHAR(10) PRIMARY KEY NOT NULL,
	Name VARCHAR(20),
	Size FLOAT,
	Price FLOAT,
	Description VARCHAR(100)
);

CREATE TABLE Ingredient(
	IngredientCode CHAR(10) PRIMARY KEY NOT NULL,
	Name VARCHAR(15),
	StockUnit FLOAT,
	Description VARCHAR(50),
	DateOfLastStockTake DATE,
	StockLevelAtLastStockTake FLOAT,
	SuggetedStockLevel FLOAT,
	StockLevelAtCurrentPeriod FLOAT,
	Type VARCHAR(10)
);

CREATE TABLE Orders(
	OrderId CHAR(10) PRIMARY KEY NOT NULL,
	OrderDateTime DATETIME2,
	TotalAmountDue FLOAT DEFAULT 0,
	PaymentMethod VARCHAR(10),
	PaymentApprovalNo VARCHAR(20),
	CHECK (PaymentMethod IN ('Cash', 'Card')),
	CHECK ((PaymentMethod = 'Cash' AND PaymentApprovalNo IS NULL) OR (PaymentMethod = 'Card' AND PaymentApprovalNo IS NOT NULL)),
	-- checks for payment method to be cash or card, and approval number only required when its card.
	OrderStatus VARCHAR(20) DEFAULT 'Cooking',
	customerId CHAR(10) NOT NULL,
	FOREIGN KEY(customerId ) REFERENCES Customer(customerId ) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Orders and Menuitems must be above.
CREATE TABLE QOrderMenuItem(
	OrderId CHAR(10) NOT NULL,
	ItemCode CHAR(10) NOT NULL,
	Quantity INT NOT NULL DEFAULT 1,
	PRIMARY KEY (ItemCode, OrderId),
	FOREIGN KEY(OrderId) REFERENCES Orders(OrderId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(ItemCode) REFERENCES MenuItem(ItemCode) ON UPDATE CASCADE ON DELETE CASCADE 

);

--Ingredient and MenuItem must be above.
CREATE TABLE QMenuItemIngredient(
	ItemCode CHAR(10) NOT NULL,
	IngredientCode CHAR(10) NOT NULL,
	Quantity INT,
	PRIMARY KEY (ItemCode, IngredientCode),
	FOREIGN KEY(ItemCode) REFERENCES MenuItem(ItemCode) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(IngredientCode) REFERENCES Ingredient(IngredientCode) ON UPDATE CASCADE ON DELETE CASCADE 
);


CREATE TABLE Staff(
	StaffId CHAR (10) PRIMARY KEY NOT NULL,
	TaxFileNo CHAR(9) UNIQUE NOT NULL,
	Type VARCHAR(8),
	firstName VARCHAR(20) NOT NULL,
	lastName VARCHAR(20) NOT NULL,
	Phone VARCHAR(10),
	Address VARCHAR(200),
	Description VARCHAR(50),
	AcName VARCHAR(20) NOT NULL,
	BSB CHAR(6) NOT NULL,
	AcNo VARCHAR(10) NOT NULL
);

CREATE TABLE InStoreStaff(
	StaffId CHAR(10) PRIMARY KEY NOT NULL,
	TaxFileNo CHAR(9) UNIQUE NOT NULL,
	HourlyRate FLOAT,
	FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY (TaxFileNo) REFERENCES Staff(TaxFileNo) ON UPDATE NO ACTION ON DELETE NO ACTION 
);

CREATE TABLE DriverStaff(
	StaffId CHAR(10) PRIMARY KEY NOT NULL,
	TaxFileNo CHAR(9) UNIQUE NOT NULL,
	driverLicNo CHAR(6) UNIQUE NOT NULL,
	RatePerDelivery FLOAT,
	FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY (TaxFileNo) REFERENCES Staff(TaxFileNo) ON UPDATE NO ACTION ON DELETE NO ACTION 
);

CREATE TABLE StaffPayment(
	RecordId CHAR(10) PRIMARY KEY NOT NULL,
	GrossPay FLOAT NOT NULL,
	PaymentDate DATE NOT NULL,
	TaxWithheld FLOAT DEFAULT 0,
	TotalAmountPaid FLOAT DEFAULT 0,
	PayPeriodStartDate DATE,
	PayPeriodEndDate DATE,
);

CREATE TABLE InStorePay(
	RecordId CHAR(10) PRIMARY KEY NOT NULL,
	PaidHourlyRate FLOAT,
	HoursPaid FLOAT,
	StaffId CHAR(10),
	FOREIGN KEY (RecordId) REFERENCES StaffPayment(RecordId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (StaffId) REFERENCES InStoreStaff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE DriverPay(
	RecordId CHAR(10) PRIMARY KEY NOT NULL,
	PaidDeliveryRate FLOAT,
	DeliveriesPaid INT DEFAULT 0,
	StaffId CHAR(10),
	FOREIGN KEY (RecordId) REFERENCES StaffPayment(RecordId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (StaffId) REFERENCES DriverStaff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Shift(
	ShiftNo CHAR(10) PRIMARY KEY NOT NULL,
	StartDateTime DATETIME2,
	EndDateTime DATETIME2,
	StaffId CHAR(10) NOT NULL,
	RecordId CHAR(10) NOT NULL,
	FOREIGN KEY (StaffId) REFERENCES Staff(StaffId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (RecordId) REFERENCES StaffPayment(RecordId) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE InShopShift(
	ShiftNo CHAR(10) PRIMARY KEY NOT NULL,
	NoOfHours FLOAT DEFAULT 0,
	Others VARCHAR(20) DEFAULT null,
	StaffId CHAR(10) NOT NULL,
	RecordId CHAR(10) NOT NULL,
	FOREIGN KEY (ShiftNo) REFERENCES Shift(ShiftNo) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (StaffId) REFERENCES InStoreStaff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY (RecordId) REFERENCES InStorePay(RecordId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE DriverShift(
	ShiftNo CHAR(10) PRIMARY KEY NOT NULL,
	NoOfDeliveries INT DEFAULT 0,
	Others VARCHAR (20) DEFAULT null,
	StaffId CHAR(10) NOT NULL,
	RecordId CHAR(10) NOT NULL,
	FOREIGN KEY (ShiftNo) REFERENCES Shift(ShiftNo) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (StaffId) REFERENCES DriverStaff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY (RecordId) REFERENCES DriverPay(RecordId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE WalkInOrder(
	OrderId CHAR(10) PRIMARY KEY NOT NULL,
	WalkInTime DATETIME2,
	StaffId CHAR(10) NOT NULL,
	customerId CHAR (10) NOT NULL,
	FOREIGN KEY(OrderId) REFERENCES Orders(OrderId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(StaffId) REFERENCES InStoreStaff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY(customerId) REFERENCES Customer(customerId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE PhoneOrder(
	OrderId CHAR(10) PRIMARY KEY,
	timeCallAnswered DATETIME2,
	timeCallTerminated DATETIME2,
	StaffId CHAR(10) NOT NULL,
	customerId CHAR(10) NOT NULL,
	FOREIGN KEY(OrderId) REFERENCES Orders(OrderId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(StaffId) REFERENCES InStoreStaff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY(customerId) REFERENCES Customer(customerId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE PickupOrder(
	OrderId CHAR(10) PRIMARY KEY,
	PickupTime DATETIME2,
	StaffId CHAR(10) NOT NULL,
	customerId CHAR(10) NOT NULL,
	FOREIGN KEY(OrderId) REFERENCES PhoneOrder(OrderId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(StaffId) REFERENCES InStoreStaff(StaffId) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY(customerId) REFERENCES Customer(customerId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE DeliveryOrder(
	OrderId CHAR(10) PRIMARY KEY,
	Address VARCHAR(200) NOT NULL,
	DeliveryTime DATETIME2,
	ShiftNo CHAR(10) NOT NULL,
	CustomerId CHAR(10) NOT NULL,
	FOREIGN KEY(OrderId) REFERENCES PhoneOrder(OrderId) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(ShiftNo) REFERENCES DriverShift(ShiftNo) ON UPDATE NO ACTION ON DELETE NO ACTION,
	FOREIGN KEY(customerId) REFERENCES Customer(customerId) ON UPDATE NO ACTION ON DELETE NO ACTION
);

--INSERT DATA
--Insert data

--Customer table
--INSERT INTO Customer VALUES ('customerId', 'firstName', 'lastname','Address', 'Phone', 'verified or unverified')
INSERT INTO Customer VALUES ('1457896320', 'Alice', 'Brown','123 George St, Sydney NSW 2000', '0432698745', 'verified')
INSERT INTO Customer VALUES ('1457896321', 'Brandon','Carter','456 Pitt St, Sydney NSW 2000', '0405876932', 'verified')
INSERT INTO Customer VALUES ('1457896322', 'Claire', 'Davis','789 Kent St, Sydney NSW 2000', '0412365987', 'verified')
INSERT INTO Customer VALUES ('1457896323', 'David', 'Anderson','101 York St, Sydney NSW 2000', '0421658749', 'unverified')
INSERT INTO Customer VALUES ('1457896324', 'Ethan', 'Cole','234 Castlereagh St, Sydney NSW 2000', '0478963215', 'verified')
INSERT INTO Customer VALUES ('1457896325', 'Lucas', 'Nguyen', '14 Mary St, Surry Hills NSW 2010', '0412765432', 'unverified')
INSERT INTO Customer VALUES ('1457896326', 'Ava', 'Johnson', '19 Bridge St, Sydney NSW 2000', '0432876543', 'verified')
INSERT INTO Customer VALUES ('1457896327', 'Oliver', 'Louis', '32 George St, The Rocks NSW 2000', '0409012345', 'verified')

--MenuItem table
--INSERT INTO MenuItem VALUES ('itemcode', 'name', 'size', 'price', 'description')
INSERT INTO MenuItem VALUES ('3654781209', 'Peri Chicken', '14', '24.50', 'Seasoned chicken, cherry tomatoes, sliced red onion & baby spinach')
INSERT INTO MenuItem VALUES ('3654781210', 'Supreme', '14', '25.50', 'Bacon, mushroom, pepperoni, sausage, ham')
INSERT INTO MenuItem VALUES ('3654781211', 'Garlic Prawn', '14', '29.50', 'Prawns, baby spinach and diced tomato')
INSERT INTO MenuItem VALUES ('3654781212', 'Meatlovers', '14', '25.50', 'Pepperoni, ground beef, ham, sausage and BBQ sauce')
INSERT INTO MenuItem VALUES ('3654781213', 'Simply Cheese', '14', '20', 'Melted mozzarella ')
INSERT INTO MenuItem VALUES ('3654781214', 'Ham and Cheese', '14', '21', 'Strips of smoky leg ham & creamy mozzarella')

-- Ingredient table
--INSERT INTO Ingredient VALUES ('Ingredientcode', 'name', 'stockunit', 'description', 'dateoflaststocktake', 'stock level(last)', 'suggested level', 'stocklevel now', 'type')
INSERT INTO Ingredient VALUES ('1234567890', 'Ham', '1', 'Pork meat', '2023-03-01', '50', '60', '50', 'Meat')
INSERT INTO Ingredient VALUES ('1234567891', 'Mozzarella', '1', 'Melted cheese', '2023-03-01', '80', '80', '75', 'Dairy')
INSERT INTO Ingredient VALUES ('1234567892', 'Prawn', '1', 'Fresh prawns', '2023-03-01', '40', '50', '35', 'Seafood')
INSERT INTO Ingredient VALUES ('1234567893', 'Garlic Sauce', '0.5', 'Cremy garlic sauce', '2023-03-01', '10', '12', '7', 'Sauce')
INSERT INTO Ingredient VALUES ('1234567894', 'BBQ Sauce', '0.5', 'Homemade BBQ sauce', '2023-03-01', '10', '12', '8', 'Sauce')
INSERT INTO Ingredient VALUES ('1234567895', 'Pepperoni', '1', 'Pepperoni', '2023-03-01', '50', '60', '50', 'Meat')
INSERT INTO Ingredient VALUES ('1234567896', 'Chicken', '1', 'Smoked Chicken', '2023-03-01', '50', '60', '50', 'Meat')
INSERT INTO Ingredient VALUES ('1234567897', 'Spinach', '1', 'Baby spinach', '2023-03-01', '70', '80', '65', 'Fresh')

--Orders table
--Note: customerId must exist, and match Customers table
-- INSERT INTO Orders VALUES ('orderId', 'datetime', 'totalamountdue', 'paymentmethod', 'payment approval','status', 'customerid')
INSERT INTO Orders VALUES ('0000000001', '2023-01-10 19:28:43', '49', 'Card', '6895237410','Cooking', '1457896320')
INSERT INTO Orders VALUES ('0000000002', '2023-01-11 18:31:20', '29.5', 'Cash', NULL,'Completed', '1457896321')
INSERT INTO Orders VALUES ('0000000003', '2023-01-12 19:26:35', '25.5', 'Card', '1234567890','Preparing', '1457896322')
INSERT INTO Orders VALUES ('0000000004', '2023-01-13 20:35:50', '88.5', 'Card', '8742365190','Waiting for pickup', '1457896323')
INSERT INTO Orders VALUES ('0000000005', '2023-01-10 19:40:39', '21', 'Cash', NULL,'Cooking', '1457896324')
INSERT INTO Orders VALUES ('0000000006', '2023-01-12 16:25:59', '25.50', 'Card', '2076894315','Completed', '1457896325')
INSERT INTO Orders VALUES ('0000000007', '2023-01-12 19:40:30', '20', 'Card', '5721098346','Cooking', '1457896326')
INSERT INTO Orders VALUES ('0000000008', '2023-01-13 21:32:42', '21', 'Card', '9467120358','Completed', '1457896327')


--QOrderMenuItem table
--OrderId needs to match existing order 
--ItemCode needs to match existing menu items
--INSERT INTO QOrderMenuItem VALUES ('orderid','itemcode', 'quantity of pizza')
INSERT INTO QOrderMenuItem VALUES ('0000000001','3654781209', '2')
INSERT INTO QOrderMenuItem VALUES ('0000000002','3654781211', '1')
INSERT INTO QOrderMenuItem VALUES ('0000000003','3654781212', '1')
INSERT INTO QOrderMenuItem VALUES ('0000000004','3654781211', '3')
INSERT INTO QOrderMenuItem VALUES ('0000000005','3654781214', '1')
INSERT INTO QOrderMenuItem VALUES ('0000000006','3654781212', '1')
INSERT INTO QOrderMenuItem VALUES ('0000000007','3654781213', '1')
INSERT INTO QOrderMenuItem VALUES ('0000000008','3654781214', '2')

--QMenuItemIngredient
--INSERT INTO QMenuItemIngredient VALUES('itemcode', 'ingredientcode', 'quantity')

--MenuItem: Peri Chicken
INSERT INTO QMenuItemIngredient VALUES('3654781209', '1234567896', '15')
INSERT INTO QMenuItemIngredient VALUES('3654781209', '1234567891', '20')

--MenuItem: Supreme
INSERT INTO QMenuItemIngredient VALUES('3654781210', '1234567895', '15')
INSERT INTO QMenuItemIngredient VALUES('3654781210', '1234567891', '20')

--MenuItem: Garlic Prawn
INSERT INTO QMenuItemIngredient VALUES('3654781211', '1234567892', '10')
INSERT INTO QMenuItemIngredient VALUES('3654781211', '1234567891', '20')
INSERT INTO QMenuItemIngredient VALUES('3654781211', '1234567893', '10')
INSERT INTO QMenuItemIngredient VALUES('3654781211', '1234567897', '15')

--MenuItem: Meatlovers
INSERT INTO QMenuItemIngredient VALUES('3654781212', '1234567890', '10')
INSERT INTO QMenuItemIngredient VALUES('3654781212', '1234567895', '10')
INSERT INTO QMenuItemIngredient VALUES('3654781212', '1234567891', '20')


--MenuItem: Simply Cheese
INSERT INTO QMenuItemIngredient VALUES('3654781213', '1234567891', '30')

--MenuItem: Ham and Cheese
INSERT INTO QMenuItemIngredient VALUES('3654781214', '1234567890', '15')
INSERT INTO QMenuItemIngredient VALUES('3654781214', '1234567891', '20')

--Staff table
-- INSERT INTO Staff VALUES ('staffId', 'taxfileno', 'status', 'fname', 'lname', 'phone', 'address', 'description', 'acname','BSB', 'acNo')
INSERT INTO Staff VALUES ('0000000001', '123456789', 'PT', 'Samantha', 'Patel', '0412987654', '23 Rose Street, Parramatta NSW 2150', 'n/a', 'Samantha Patel', '723409', '90765423')
INSERT INTO Staff VALUES ('0000000002', '987654321', 'FT', 'Tyler', 'Nguyen', '0431768921', '7 Beach Road, Bondi NSW 2026', 'n/a', 'Tyler Nguyen', '835761', '18257936')
INSERT INTO Staff VALUES ('0000000003', '123459876', 'PT', 'Olivia', 'Walker', '0408654321', '49 Collins Street, Tamworth NSW 2340', 'n/a', 'Olivia Walker', '195032', '34906571')
INSERT INTO Staff VALUES ('0000000004', '123789456', 'PT', 'Sophia', 'Thompson', '0435876542', '28 Lawson Street, Parramatta NSW 2150', 'n/a', 'Sophia Thompson', '489731', '73490568')
INSERT INTO Staff VALUES ('0000000005', '987321654', 'PT', 'Ethan', 'Lee', '0421983710', '47 Wollongong Road, Arncliffe NSW 2205', 'n/a', 'Ethan Lee', '903205', '14860273')
INSERT INTO Staff VALUES ('0000000006', '135790246', 'FT', 'Charlotte', 'Cooper', '0456324891', '17 Ocean Street, Bondi Beach NSW 2026', 'n/a', 'Charlotte Cooper', '629416', '98273516')
INSERT INTO Staff VALUES ('0000000007', '246801357', 'PT', 'William', 'Hanson', '0403708925', '12 Spring Street, Chatswood NSW 2067', 'n/a', 'William Hanson', '815072', '57291480')
INSERT INTO Staff VALUES ('0000000008', '134579013', 'PT', 'Lily', 'Campbell', '0412569437', '3 Kent Street, Epping NSW 2121', 'n/a', 'Lily Campbell', '347589', '62740853')

--InStoreStaff (must match StaffId and TFN to existing Staff)
-- INSERT INTO InStoreStaff VALUES ('staffId', 'taxfileno', 'hourly rate')
INSERT INTO InStoreStaff VALUES ('0000000001', '123456789', '25.25')
INSERT INTO InStoreStaff VALUES ('0000000002', '987654321', '26.70')
INSERT INTO InStoreStaff VALUES ('0000000003', '123459876', '25.25')
INSERT INTO InStoreStaff VALUES ('0000000004', '123789456', '25.25')

--DriverStaff (must match StaffId and TFN to existing Staff)
-- INSERT INTO DriverStaff VALUES ('staffid', 'taxfileno', 'drivers license no', 'pay per delivery')
INSERT INTO DriverStaff VALUES ('0000000005', '987321654', 'LA2345', '12')
INSERT INTO DriverStaff VALUES ('0000000006', '135790246', 'LA3456', '12')
INSERT INTO DriverStaff VALUES ('0000000007', '246801357', 'LA7893', '12')
INSERT INTO DriverStaff VALUES ('0000000008', '134579013', 'LA7935', '12')

--InStore StaffPayment
--INSERT INTO StaffPayment VALUES ('recordId', 'grosspay', 'paymentdate', 'taxwithheld', 'totalamountpaid', 'startperiod', 'endperiod')
INSERT INTO StaffPayment VALUES ('0000000020', '1767.50', '2023-04-11', '401.25', '1366.25', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000021', '942.87', '2023-04-11', '208.75', '734.12', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000022', '930.90', '2023-04-11', '212.38', '718.52', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000023', '766.56', '2023-04-11', '171.63', '594.93', '2023-01-09', '2023-01-23')

--Delivery staffpayment
INSERT INTO StaffPayment VALUES ('0000000024', '192', '2023-04-11', '38.40', '153.60', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000025', '444', '2023-04-11', '88.80', '355.20', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000026', '528', '2023-04-11', '105.60', '422.40', '2023-01-09', '2023-01-23')
INSERT INTO StaffPayment VALUES ('0000000027', '36', '2023-04-11', '7.20', '28.80', '2023-01-09', '2023-01-23')

--InStorePay table
--INSERT INTO InStorePay VALUES ('recordId', 'hourlyrate', 'hourspaid', 'staffId')
INSERT INTO InStorePay VALUES ('0000000020', '25.25', '70.0', '0000000001')
INSERT INTO InStorePay VALUES ('0000000021', '25.25', '29.7', '0000000002')
INSERT INTO InStorePay VALUES ('0000000022', '26.70', '34.8', '0000000003')
INSERT INTO InStorePay VALUES ('0000000023', '25.25', '30.4', '0000000004')

--DriverPay table
--INSERT INTO DriverPay VALUES ('recordId', 'paid delivery rate', 'deliveries paid', 'staffId')
INSERT INTO DriverPay VALUES ('0000000024', '12', '16', '0000000005')
INSERT INTO DriverPay VALUES ('0000000025', '12', '37', '0000000006')
INSERT INTO DriverPay VALUES ('0000000026', '12', '44', '0000000007')
INSERT INTO DriverPay VALUES ('0000000027', '12', '3', '0000000008')

--Shift table
--INSERT INTO Shift VALUES ('shiftno','startdatetime','enddatetime','staffid','recordid')
INSERT INTO Shift VALUES ('0000000040','2023-01-09 08:00:00', '2023-01-09 16:00:00','0000000001','0000000020')
INSERT INTO Shift VALUES ('0000000041','2023-01-10 08:00:00', '2023-01-10 16:00:00','0000000002','0000000021')
INSERT INTO Shift VALUES ('0000000042','2023-01-09 14:00:00', '2023-01-09 22:00:00','0000000003','0000000022')
INSERT INTO Shift VALUES ('0000000043','2023-01-10 14:00:00', '2023-01-10 22:00:00','0000000004','0000000023')
INSERT INTO Shift VALUES ('0000000044','2023-01-09 08:00:00', '2023-01-09 16:00:00','0000000005','0000000024')
INSERT INTO Shift VALUES ('0000000045','2023-01-10 08:00:00', '2023-01-10 16:00:00','0000000006','0000000025')
INSERT INTO Shift VALUES ('0000000046','2023-01-09 14:00:00', '2023-01-09 22:00:00','0000000007','0000000026')
INSERT INTO Shift VALUES ('0000000047','2023-01-10 14:00:00', '2023-01-10 22:00:00','0000000008','0000000027')

-- InShopShift table
--INSERT INTO InShopShift VALUES ('shiftno','noofhours','others', 'staffid', 'recordid')
INSERT INTO InShopShift VALUES ('0000000040','70','0','0000000001','0000000020')
INSERT INTO InShopShift VALUES ('0000000041','29.7','0','0000000002','0000000021')
INSERT INTO InShopShift VALUES ('0000000042','34.8','0','0000000003','0000000022')
INSERT INTO InShopShift VALUES ('0000000043','30.4','0','0000000004','0000000023')

--DriverShift table
--INSERT INTO DriverShift VALUES ('shiftno','noofdeliveries','others', 'staffid', 'recordid')
INSERT INTO DriverShift VALUES ('0000000044','16','0','0000000005','0000000024')
INSERT INTO DriverShift VALUES ('0000000045','37','0','0000000006','0000000025')
INSERT INTO DriverShift VALUES ('0000000046','44','0','0000000007','0000000026')
INSERT INTO DriverShift VALUES ('0000000047','3','0','0000000008','0000000027')

-- WalkInOrder table
--INSERT INTO WalkInOrder VALUES(orderId, walkintime, staffid, customerid)
INSERT INTO WalkInOrder VALUES('0000000001','2023-01-10 19:10:00','0000000001', '1457896320')
INSERT INTO WalkInOrder VALUES('0000000002','2023-01-11 18:15:00','0000000002', '1457896321')
INSERT INTO WalkInOrder VALUES('0000000007','2023-01-12 19:20:45','0000000003', '1457896326')
INSERT INTO WalkInOrder VALUES('0000000008','2023-01-13 21:16:40','0000000004', '1457896327')

--PhoneOrder table 
--INSERT INTO PhoneOrder VALUES ('orderid','timecallans','timecallend','staffid','customerid')
INSERT INTO PhoneOrder VALUES ('0000000003','2023-01-12 19:00:20','2023-01-12 19:02:40','0000000003','1457896322')
INSERT INTO PhoneOrder VALUES ('0000000004','2023-01-13 20:05:20','2023-01-13 20:10:30','0000000004','1457896323')
INSERT INTO PhoneOrder VALUES ('0000000005','2023-01-10 19:20:20','2023-01-10 19:23:50','0000000001','1457896324')
INSERT INTO PhoneOrder VALUES ('0000000006','2023-01-12 16:15:00','2023-01-12 16:17:45','0000000003','1457896325')

-- PickupOrder table
--INSERT INTO PickupOrder VALUES('orderid','pickuptime','staffid','customerid')
INSERT INTO PickupOrder VALUES ('0000000003', '2023-01-12 19:05:00', '0000000003','1457896322')
INSERT INTO PickupOrder VALUES ('0000000004', '2023-01-13 20:40:00', '0000000004','1457896323')

--Deliveryorder table
--INSERT INTO DeliveryOrder VALUES ('orderid','address','deliverytime','shiftno','customerid')
INSERT INTO DeliveryOrder VALUES ('0000000005', '234 Castlereagh St, Sydney NSW 2000','2023-01-10 20:00:00', '0000000045','1457896324')
INSERT INTO DeliveryOrder VALUES ('0000000006', '14 Mary St, Surry Hills NSW 2010','2023-01-12 16:50:00', '0000000046','1457896325')

--Query for month
--SELECT * FROM StaffPayment
--WHERE MONTH(PayPeriodStartDate) = 5;


-- Requirement Transactions

--2.2.1 Input proper data at least 4 rows for every table

--2.2.2 Implement queries:
--Q1 For in store staff with id number xxx, print his/her firstname, lastname and hourly payement rate.
--Using StaffId = 0000000001 for example.

SELECT s.firstName, s.lastName, i.HourlyRate 
FROM Staff s
JOIN InStoreStaff i ON s.StaffId = i.StaffId
WHERE s.StaffId = '0000000001';

--Q2 list all shift details of a delivery staff with first name xxx and last name ttt between date y and z.
--Using Staff Ethan Lee for example, shift on the 01-09
SELECT t.*
FROM Staff s
JOIN Shift t ON s.StaffId = t.StaffId
WHERE (s.firstName = 'Ethan' AND s.lastName = 'Lee') 
AND (t.StartDateTime >= '2023-01-09 07:00:00' AND t.EndDateTime <= '2023-01-09 23:59:00');

--after the 9th it does not show, code below
SELECT t.*
FROM Staff s
JOIN Shift t ON s.StaffId = t.StaffId
WHERE (s.firstName = 'Ethan' AND s.lastName = 'Lee') 
AND (t.StartDateTime >= '2023-01-10 07:00:00' AND t.EndDateTime <= '2023-01-10 23:59:00');

--Q3 list all the order detals of the orders that are made by a walk-in customer with firstname xxx and last name yyy between date y and z.
SELECT o.*
FROM Orders o
JOIN WalkInOrder w ON w.customerId = o.customerId
JOIN Customer c ON c.customerId = o.customerId
WHERE (c.firstName = 'Alice' AND c.lastName = 'Brown')
AND MONTH(WalkInTime) = 1;

--Q4 list name of the menuitems that are ordered in the current year. current year decided by the system.
SELECT m.Name
FROM Orders o
JOIN QOrderMenuItem q ON o.OrderId = q.OrderId
JOIN MenuItem m ON q.ItemCode = m.ItemCode
WHERE YEAR(o.OrderDateTime) = YEAR(GETDATE())
GROUP BY m.Name

