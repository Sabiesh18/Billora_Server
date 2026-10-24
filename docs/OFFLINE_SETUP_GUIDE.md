# Offline Restaurant Billing Software - Local Setup & Execution Guide

## 1. System Requirements & Architecture
- **Operating System**: Windows (100% Offline Capable)
- **Database**: PostgreSQL 12+ (Managed locally via pgAdmin 4)
- **Backend**: Java 17+ / Spring Boot 3 (IntelliJ IDEA)
- **Frontend**: React.js + Tailwind CSS (Vite Local Server)
- **Project Root**: `S:\Billing_software`

---

## 2. Step 1: PostgreSQL Database Setup via pgAdmin 4

1. Open **pgAdmin 4** on your computer.
2. In the left browser tree, expand **Servers** and connect to your local PostgreSQL server (enter your `postgres` password if prompted).
3. Right-click on **Databases** > **Create** > **Database...**
   - **Database**: `restaurant_db`
   - Click **Save**.
4. Right-click on `restaurant_db` > select **Query Tool**.
5. Click the folder icon (**Open File**) or press `Ctrl + O`:
   - Navigate to `S:\Billing_software\database\00_master_setup.sql`.
6. Click the **Execute / Run** button (Play icon / `F5`).
7. **Done!** The script creates all `tbl_*` tables, compiles all `fn_*` PostgreSQL functions, and seeds initial users, dining tables, categories, menu items, and business settings.

---

## 3. Step 2: Open and Run Java Backend in IntelliJ IDEA

1. Launch **IntelliJ IDEA**.
2. Click **Open** (or `File > Open...`).
3. Select the folder: `S:\Billing_software\backend`.
4. IntelliJ will detect `pom.xml` and automatically load the Maven dependencies.
5. In `src/main/resources/application.properties`, verify the database password matches your local PostgreSQL password:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/restaurant_db
   spring.datasource.username=postgres
   spring.datasource.password=postgres
   ```
6. Locate `com.restaurant.billing.BillingApplication.java`:
   - Right-click and select **Run 'BillingApplication'** (or press `Shift + F10`).
7. Verify console output:
   ```
   Restaurant Billing Backend successfully started on port 8080
   Database target: localhost:5432/restaurant_db
   ```

---

## 4. Step 3: Run React Frontend

1. Open PowerShell or Command Prompt.
2. Navigate to the frontend directory:
   ```bash
   cd S:\Billing_software\frontend
   ```
3. Install dependencies and start the development server:
   ```bash
   npm install
   npm run dev
   ```
4. Open your browser and navigate to:
   ```
   http://localhost:5173
   ```
*(Or double-click `S:\Billing_software\run_app.bat` to launch both backend and frontend automatically).*

---

## 5. Step 4: Login Credentials & Verification Flow

### Pre-configured Accounts (Stored in `tbl_Users`):
| Username | Password | Role | Description |
| :--- | :--- | :--- | :--- |
| `admin` | `password123` | `ADMIN` | Full administrative access, user creation, settings |
| `cashier` | `password123` | `CASHIER` | Live POS billing, order creation, receipt printing |
| `manager` | `password123` | `MANAGER` | Table management, sales reports, menu editing |

---

## 6. Offline POS Billing Flow Test
1. **Sign In**: Login with `cashier` / `password123`.
2. **Take Order**:
   - Select order type (`Dine-In`, `Takeaway`, or `Delivery`).
   - For Dine-In, pick an available dining table (e.g. `T-01`).
   - Click menu items (e.g. `Paneer Tikka`, `Butter Chicken Masala`, `Butter Naan`).
   - Adjust quantities with `+` / `-` buttons.
   - Optionally apply a discount (`%` or flat `₹`).
3. **Print KOT**:
   - Click **Print KOT** to generate the Kitchen Order Ticket slip.
4. **Hold Bill / Settle**:
   - Click **Hold Bill** to save order while guests dine (Table turns `OCCUPIED` in real-time).
   - When guests are ready to pay, click **Settle Bill**.
   - Select payment method (`Cash`, `UPI`, `Card`, or `Split`).
   - Enter amount tendered; system displays change to return.
   - Click **Confirm & Settle**.
5. **Print Receipt**:
   - System automatically generates a clean 80mm thermal receipt.
   - Click **Print Thermal Slip** to send to any local thermal printer via standard Windows printer drivers.
6. **Audit & Reports**:
   - Navigate to **Order History** to inspect or reprint any historical bill.
   - Navigate to **Sales Reports** to review daily/weekly/monthly revenue and tax summaries.
   - Navigate to **Audit History** to see immutable audit records in `tbl_ActivityHistory`.
