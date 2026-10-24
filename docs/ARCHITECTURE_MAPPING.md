# C# Reference to Java Architectural Mapping

## 1. Context & Reference Codebase Review
The reference project provided was a 4-tier .NET enterprise architecture:
- `Workflow.slnx`
  - `Workflow` (Web API Controllers)
  - `Workflow.Core` (Response models, JSON converters, Filters)
  - `Workflow.Data` (Repository contracts & Dapper query implementations)
  - `Workflow.Data.Core` (DBQueryUtils for executing Stored Procedures)

## 2. Comparative Component Matrix

| C# Reference Pattern | Java Architecture Implementation | Architectural Purpose |
| :--- | :--- | :--- |
| `ApiResponse<T>` (`Workflow.Core.Model`) | `com.restaurant.billing.dto.common.ApiResponse<T>` | Universal API response envelope containing `isSuccessful`, `responseCode`, `resultMessage`, `data`, and `errorMessage`. |
| `DbExecutionResult` (`Workflow.Core.Model`) | `com.restaurant.billing.dto.common.DbExecutionResult` | Encapsulates database execution status, custom application result code (`resCode`), message (`resMsg`), created record ID (`createdId`), and pagination metadata. |
| `CommonUtilis.cs` (`Workflow.Controllers.Utilis`) | `com.restaurant.billing.controller.BaseController` | Base class for controllers offering `generateResponse(exeResult, data)`, `generateSuccessResponse(...)`, and `generateErrorResponse(...)`. |
| `DBQueryUtils.cs` (`Workflow.Data.Core`) | `com.restaurant.billing.repository.DbQueryUtils` | Interacts with PostgreSQL functions (`fn_...`), maps function execution outputs, and parses JSONB result sets into strongly-typed DTOs. |
| `ModelStateValidator.cs` (`Workflow.Core.Services`) | `com.restaurant.billing.exception.GlobalExceptionHandler` | Global `@RestControllerAdvice` intercepting validation violations, formatting field-level errors (`ErrorCode = 'MSTATE_ERR'`), and returning HTTP 400 envelopes. |
| `ResponseManager.cs` (`Workflow.Core.Services`) | `com.restaurant.billing.config.JacksonConfig` & `DateTimeUtils` | Enforces uniform timezone serialization (`Asia/Kolkata` - India Standard Time) and clean date formatting. |
| `UserController.cs` (`Workflow.Controllers`) | `com.restaurant.billing.controller.UserController` | Provides `/api/User/add` and `/api/User/fetchAll` endpoints mirroring the exact method signatures from the C# controller. |
| SQL Server Stored Procedures (`USP_*`) | PostgreSQL Stored Functions (`fn_*`) | All database operations are executed strictly through PostgreSQL functions returning standard composite records. |
| Explicit DB Constraints | In-Code & Function Validations | Satisfies the requirement: no explicit DB constraints (FK/UNIQUE/CHECK) defined; integrity enforced logically. |
| Audit Trail | `tbl_ActivityHistory` + `fn_LogActivity` | Centralized audit log tracking every login attempt, bill creation, settlement, cancellation, and configuration update. |

## 3. Database Execution Flow
1. **Frontend Request**: React sends JSON request (e.g. `POST /api/bills`).
2. **Controller Validation**: Controller verifies `@Valid` request; any violation is caught by `GlobalExceptionHandler`.
3. **Service Logic**: Authoritative computation (line totals, discounts, taxes, rounding) executed via `CalculationUtils`.
4. **Repository Invocation**: Calls `DbQueryUtils.executeFunction("fn_CreateBill", params, targetClass)`.
5. **PostgreSQL Execution**: Function `fn_CreateBill` performs transactional insertions into `tbl_Bills` and `tbl_BillItems`, marks the table `OCCUPIED`, logs to `tbl_ActivityHistory`, and returns composite columns.
6. **Unified Envelope Returned**: `BaseController.generateResponse()` wraps the output into standard `ApiResponse` with HTTP 200/201.
