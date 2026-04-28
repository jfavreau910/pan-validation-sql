---PAN Number Validation Project using SQL---

-- Create a table
CREATE TABLE stg_pan_numbers_dataset
(
	pan_number NVARCHAR(MAX)
);

-- View all records
SELECT * 
FROM stg_pan_numbers_dataset;

---Identify and manage missing data:
SELECT * 
FROM stg_pan_numbers_dataset 
WHERE pan_number IS NULL;

---Check for duplicates:
SELECT pan_number, COUNT(*) AS record_count
FROM stg_pan_numbers_dataset 
GROUP BY pan_number
HAVING COUNT(*) > 1;

---Manage leading/trailing spaces:
SELECT * 
FROM stg_pan_numbers_dataset 
WHERE pan_number <> TRIM(pan_number);

---Correct the letter case:
SELECT * 
FROM stg_pan_numbers_dataset 
WHERE pan_number <> UPPER(pan_number);


---CLEANED PAN NUMBERS---

---Return cleaned PAN numbers (all validation steps combined):
SELECT DISTINCT UPPER(TRIM(pan_number)) AS pan_number
FROM stg_pan_numbers_dataset
WHERE pan_number IS NOT NULL 
AND TRIM(pan_number) <> '';


---VALIDATION FUNCTIONS---

---Function to check if adjacent characters are the same:
DROP FUNCTION IF EXISTS fn_check_adjacent_characters;
GO

CREATE FUNCTION fn_check_adjacent_characters(@p_str NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @i INT = 1;
	DECLARE @len INT = LEN(@p_str);
	
	WHILE @i < @len
	BEGIN
		IF SUBSTRING(@p_str, @i, 1) = SUBSTRING(@p_str, @i + 1, 1)
		BEGIN
			RETURN 1; -- Adjacent characters found
		END
		SET @i = @i + 1;
	END
	
	RETURN 0; -- No adjacent characters
END;
GO

---Test the function:
SELECT dbo.fn_check_adjacent_characters('AABCD') AS result; -- Returns 1
SELECT dbo.fn_check_adjacent_characters('AXBCD') AS result; -- Returns 0


---Check if sequential characters are used:
DROP FUNCTION IF EXISTS fn_check_sequential_characters;
GO

CREATE FUNCTION fn_check_sequential_characters(@p_str NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @i INT = 1;
	DECLARE @len INT = LEN(@p_str);
	
	WHILE @i < @len
	BEGIN
		-- Check if ASCII difference between consecutive characters is exactly 1
		IF ABS(ASCII(SUBSTRING(@p_str, @i + 1, 1)) - ASCII(SUBSTRING(@p_str, @i, 1))) <> 1
		BEGIN
			RETURN 0; -- String does not form a sequence
		END
		SET @i = @i + 1;
	END
	
	RETURN 1; -- String forms a sequence
END;
GO

---Test the function:
SELECT ASCII('X') AS ascii_value; -- Returns 88

SELECT dbo.fn_check_sequential_characters('ABCDE') AS result; -- Returns 1
SELECT dbo.fn_check_sequential_characters('BCDEF') AS result; -- Returns 1
SELECT dbo.fn_check_sequential_characters('ABCDX') AS result; -- Returns 0


---Pattern validation using LIKE (SQL Server equivalent for regex):
SELECT * 
FROM stg_pan_numbers_dataset
WHERE pan_number LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]';

---Alternative using PATINDEX for more complex patterns:
SELECT * 
FROM stg_pan_numbers_dataset
WHERE PATINDEX('[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]', UPPER(TRIM(pan_number))) > 0;


---VALID/INVALID PAN CATEGORIZATION---

---Create view to categorize valid and invalid PANs:
DROP VIEW IF EXISTS vw_valid_invalid_pans;
GO

CREATE VIEW vw_valid_invalid_pans
AS 
WITH cte_cleaned_pans AS
	(
		SELECT DISTINCT UPPER(TRIM(pan_number)) AS pan_number
		FROM stg_pan_numbers_dataset
		WHERE pan_number IS NOT NULL 
		AND TRIM(pan_number) <> ''
	),
cte_valid_pans AS
	(
		SELECT *
		FROM cte_cleaned_pans
		WHERE dbo.fn_check_adjacent_characters(pan_number) = 0
		AND dbo.fn_check_sequential_characters(SUBSTRING(pan_number, 1, 5)) = 0
		AND dbo.fn_check_sequential_characters(SUBSTRING(pan_number, 6, 4)) = 0
		AND pan_number LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][A-Z]'
	)
SELECT 
	cln.pan_number,
	CASE WHEN vld.pan_number IS NOT NULL 
		THEN 'Valid PAN' 
		ELSE 'Invalid PAN' 
	END AS status
FROM cte_cleaned_pans cln
LEFT JOIN cte_valid_pans vld ON vld.pan_number = cln.pan_number;
GO


---SUMMARY REPORT---

---Create the total summary report:
WITH cte_summary AS
	(
		SELECT
			(SELECT COUNT(*) FROM stg_pan_numbers_dataset) AS total_processed_records,
			SUM(CASE WHEN status = 'Valid PAN' THEN 1 ELSE 0 END) AS total_valid_pans,
			SUM(CASE WHEN status = 'Invalid PAN' THEN 1 ELSE 0 END) AS total_invalid_pans
		FROM vw_valid_invalid_pans
	)
SELECT 
	total_processed_records,
	total_valid_pans,
	total_invalid_pans,
	(total_processed_records - (total_valid_pans + total_invalid_pans)) AS total_missing_or_cleaned_pans
FROM cte_summary;
