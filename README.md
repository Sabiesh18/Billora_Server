# Billora Server - Professional Offline Restaurant & Hotel Billing Backend

Enterprise-grade offline restaurant billing backend built with **Java 17**, **Spring Boot 3**, and **PostgreSQL 12+** (managed locally via pgAdmin 4), adapted from the reference C# `.NET` enterprise architecture.

---

## 1. Architectural Highlights & C# Mapping
- **Standardized Response Envelope (`ApiResponse<T>`)**:
  Matches C# `ApiResponse<T>` with `isSuccessful`, `responseCode`, `resultMessage`, `data`, and structured `errorMessage` list.
- **Two-Phase DB Result Protocol (`DbExecutionResult`)**:
  Matches C# `DbExecutionResult` (`isSuccessful`, `resCode`, `resMsg`, `createdId`, `pageInfo`).
- **PostgreSQL Function Only Protocol (`fn_*`)**:
  All application queries and mutations execute **exclusively** through PostgreSQL stored functions. Direct CRUD SQL execution is disallowed.
- **Zero Database Constraints**:
  As per architectural requirements, tables do not define explicit `FOREIGN KEY`, `UNIQUE`, or `CHECK` constraints in DDL. All referential integrity, validations, and rules are enforced programmatically in application logic and functions.
- **Unified Activity History (`tbl_ActivityHistory`)**:
  Captures all system events (login/logout attempts, bill creation, settlement, cancellations, menu changes, user management) with metadata and key before/after values.
- **Regional Timezone & Formatter**:
  Normalized to `Asia/Kolkata` (India Standard Time) with `dd MMM, yyyy h:mm a` formatting matching the C# `ResponseManager.cs`.

---

## 2. Technology Stack
- **Language**: Java 17 LTS
- **Framework**: Spring Boot 3.3.4 (Spring Web, Spring Security, Spring Validation, Spring JDBC)
- **Database**: PostgreSQL 12+
- **Authentication**: Stateless HMAC-SHA256 JWT + BCrypt Password Encoding
- **IDE**: IntelliJ IDEA

---

## 3. Package Structure
```
com.restaurant.billing
├── BillingApplication.java          # Spring Boot Main Entry Point
├── config/                          # Security, CORS, Jackson, JWT Filter
├── controller/                      # REST Controllers inheriting BaseController
├── dto/                             # Common, Auth, Billing, Menu, Table, Report, Activity DTOs
├── exception/                       # GlobalExceptionHandler (mirrors ModelStateValidator)
├── repository/                      # Repositories & DbQueryUtils calling fn_* routines
├── service/                         # Business Logic & Authoritative Calculation Engine
└── util/                            # CalculationUtils, DateTimeUtils, JwtUtil
```

---

## 4. Database Setup via pgAdmin 4
1. Open **pgAdmin 4**.
2. Create a local database named `restaurant_db`.
3. Open the **Query Tool** on `restaurant_db`.
4. Open and execute:
   ```
   database/00_master_setup.sql
   ```
   *(Creates all `tbl_*` tables, compiles all `fn_*` functions, and seeds demo accounts).*

### Default Credentials
| Username | Password | Role | Description |
| :--- | :--- | :--- | :--- |
| `admin` | `password123` | `ADMIN` | System Administrator |
| `cashier` | `password123` | `CASHIER` | Front Desk Cashier |
| `manager` | `password123` | `MANAGER` | Floor Manager |

---

## 5. Running the Backend in IntelliJ IDEA
1. Open this repository folder in **IntelliJ IDEA**.
2. Verify local database credentials in `src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/restaurant_db
   spring.datasource.username=postgres
   spring.datasource.password=postgres
   ```
3. Run `com.restaurant.billing.BillingApplication`.
4. The service listens on port `8080`.
