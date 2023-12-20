select * FROM Bookings;

-- creating first procedure Checkbooking (to see if the table and date is available for new booking)
DELIMITER //
CREATE PROCEDURE CheckBooking(IN booking_date DATE, IN table_number INT)
BEGIN
    DECLARE isBooked VARCHAR(10);

    SELECT IF(COUNT(*) > 0, ' is Booked', ' is Available') INTO isBooked
    FROM bookings
    WHERE TableNumber = table_number
    AND Date = booking_date;

    SELECT CONCAT("Table ", table_number, isBooked) AS Status;
END //

DELIMITER ;

DROP PROCEDURE AddValidBooking;
Call CheckBooking('2023-12-01','3');

-- creating procedure AddValidbooking (to see if the table and date is available for new booking and if not add a transaction to insert new booking)

DELIMITER //
CREATE PROCEDURE AddValidBooking(IN booking_date DATE, IN table_number INT, IN customer_id INT, IN staff_id INT)
BEGIN
    -- Declare a variable to check if the table is already booked
    DECLARE isAlreadyBooked INT;

    -- Start the transaction
    START TRANSACTION;

    -- Check if the table is already booked on the given date
    SELECT COUNT(*) INTO isAlreadyBooked
    FROM bookings
    WHERE TableNumber = table_number AND Date = booking_date;

    -- If the table is already booked, rollback the transaction
    IF isAlreadyBooked > 0 THEN
		SELECT CONCAT("Table ",table_number," is already booked, booking cancelled") AS Status;
        ROLLBACK;
    ELSE
        -- Otherwise, add the booking and commit the transaction
        INSERT INTO bookings (Date, TableNumber, CustomerID, StaffID)
        VALUES (booking_date, table_number, customer_id, staff_id);
        COMMIT;
    END IF;
END //

DELIMITER ;

CALL AddValidBooking('2023-12-03','4','4','1');

-- procedure to add booking

DELIMITER //
CREATE PROCEDURE AddBooking (IN input_date DATE, IN input_table INT, IN input_customer INT, IN input_staff INT)
BEGIN 
INSERT INTO bookings (Date, TableNumber, CustomerID, StaffID)
VALUES (input_date, input_table, input_customer, input_staff);
SELECT "New Booking Added" AS Confirmation;
END //
DELIMITER ;

CALL AddBooking ('2023-12-06','6','3','1');

-- procedure to update booking

DELIMITER //
CREATE PROCEDURE UpdateBooking (IN input_ID INT, IN input_date DATE)
BEGIN 
UPDATE Bookings SET Date = input_date WHERE BookingID = input_ID;
SELECT CONCAT("Booking ",input_ID, " Updated") AS Confirmation;
END //
DELIMITER ;

CALL UpdateBooking ('3','2023-12-03');

DELIMITER //
CREATE PROCEDURE CancelBooking (IN input_ID INT)
BEGIN 
DELETE FROM Bookings WHERE BookingID = input_ID;
SELECT CONCAT("Booking ",input_ID, " Cancelled") AS Confirmation;
END //
DELIMITER ;

CALL CancelBooking ('8');
