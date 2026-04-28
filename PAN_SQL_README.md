# PAN Number Cleaning and Validation - SQL 

A comprehensive data cleaning and validation system for Indian Permanent Account Numbers (PAN) implemented in **SQL Server Express 2022 (T-SQL)**. This project processes, cleans, and validates a dataset of PAN numbers, categorizing them as "Valid" or "Invalid" based on official format requirements. (See the included "PAN_Validation_Instructions.txt" file for the format requirements).

## Overview

This implementation includes:
- **Data Cleaning**: Remove duplicates, handle missing values, trim spaces, standardize case
- **Custom Functions**: User-defined functions for character pattern validation
- **Format Validation**: Verify PAN structure using regex and pattern matching
- **Views**: SQL views for categorization and reporting
- **Summary Reports**: T-SQL queries for comprehensive statistics

---

## PAN Format Requirements

A **Valid PAN number** follows this exact format:

### Structure: `AAAAA1234A`

| Position | Count | Type | Rules |
|----------|-------|------|-------|
| Characters 1-5 | 5 | Uppercase Letters | No adjacent identical characters; Cannot form a sequence |
| Characters 6-9 | 4 | Numeric Digits | No adjacent identical characters; Cannot form a sequence |
| Character 10 | 1 | Uppercase Letter | Single character (no additional rules) |

### Detailed Validation Rules

#### First 5 Characters (Alphabetic)
- **Rule 1**: Adjacent characters cannot be the same
  - ❌ Invalid: `AABCD` (A and A are adjacent)
  - ✅ Valid: `ABCDX` (no adjacent duplicates)

- **Rule 2**: All five characters cannot form a sequential pattern
  - ❌ Invalid: `ABCDE`, `BCDEF` (consecutive sequences)
  - ✅ Valid: `AXBCD`, `XYZAB` (no sequential pattern)

#### Middle 4 Characters (Numeric)
- **Rule 1**: Adjacent characters cannot be the same
  - ❌ Invalid: `1123` (1 and 1 are adjacent)
  - ✅ Valid: `1923` (no adjacent duplicates)

- **Rule 2**: All four characters cannot form a sequential pattern
  - ❌ Invalid: `1234`, `2345`, `5678` (consecutive sequences)
  - ✅ Valid: `1926`, `5739` (no sequential pattern)

#### Last Character (Alphabetic)
- Single uppercase letter
- No additional validation rules

### Valid PAN Examples

AHGVE1276F  ✅ Valid
XYZAB1234C  ✅ Valid
PQRST5678M  ✅ Valid


### Invalid PAN Examples

AAAAA0000A  ❌ First char repeated (A-A-A-A-A)
ABCDE0000X  ❌ First 5 chars form sequence (A-B-C-D-E)
XYZAB1234X  ❌ Middle 4 chars form sequence (1-2-3-4)
AABBC0000Z  ❌ Adjacent chars same (A-A, B-B)
AAAA00000A  ❌ Wrong format (9 digits instead of 4)


## Installation & Setup

### Prerequisites
- **SQL Server Express 2022** (or later)
- **SQL Server Management Studio (SSMS)** or SQL Server client tools
- **Git** (for version control via GitHub Desktop)

### SQL Server Express 2022 Installation

1. Download from: [SQL Server Express 2022](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
2. Install with default settings
3. Ensure **Database Engine** and **Tools** are selected during installation

### Execute the Script

#### Method 1: Using SQL Server Management Studio (SSMS)
1. Open **SQL Server Management Studio**
2. Connect to your SQL Server instance
3. Select **File** → **Open** → **File**
4. Navigate to `pan_validation.sql`
5. Click **Execute** (or press **F5**)


#### Author: J. Favreau



