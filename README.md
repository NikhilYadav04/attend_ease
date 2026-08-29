<div align="center">

# 📋 Attend Ease

### Attendance and leave management for companies — built for HR admins and employees alike

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev) [![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs)](https://nodejs.org) [![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-3ECF8E?logo=supabase)](https://supabase.com) [![Prisma](https://img.shields.io/badge/Prisma-6-2D3748?logo=prisma)](https://prisma.io) [![Express](https://img.shields.io/badge/Express-4-000000?logo=express)](https://expressjs.com) [![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## 📸 App Screenshots

<div align="center">

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/e864dce2-8bf9-4b40-9a42-a3878f63afce" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/83492c50-0e79-4bb3-84a4-4d77a1a5de97" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/d34f9e48-80ff-4b4f-a710-49a9a5219357" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/32bc7a9f-c440-438f-a169-2ec744732990" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/cd4b83dd-a2c0-4fb9-8979-7e411147a81f" width="160"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/114b6496-94b0-4b00-a054-10c5fa7b96dc" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/a52aea49-a890-45d1-8807-92b2cbc10f49" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/5b874fed-6d05-48a9-ba4f-403accb62e19" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/7663fefd-de6d-4511-865e-0ae20849378c" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/ca3bf892-f681-43cf-a5a1-ad69dbda67e5" width="160"/></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/a6414059-39a4-4e36-841d-cb535ab2f009" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/c378d453-f535-4a57-bfeb-bccc4380204b" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/3ad8c52a-0832-4f7a-82c1-fb952ef9d899" width="160"/></td>
  </tr>
</table>

</div>



---

## 📖 Overview

Attend Ease is a full-stack Flutter + Node.js application that streamlines workforce attendance. HR admins define a company geo-radius; employees can only clock in when physically inside it. Beyond the core punch-in/punch-out flow, HR gets tools to actually run a team day to day: multiple admins per company, a searchable leave/correction approval queue with live pending-count badges on the dashboard, a team leave calendar, a month/year-filterable attendance analytics dashboard, bulk CSV staff import, company holidays, per-employee leave quotas, configurable overtime detection, and a full audit trail of every approval and change. Leave requests, attendance corrections, daily attendance reports, and staff counts are all managed in-app, with PDF export for records and real-time video calls powered by Zego UIKit.

The backend was migrated from MongoDB/Mongoose to a Postgres database (hosted on Supabase) via Prisma, with the API response shape kept byte-identical to the old Mongo version — the Flutter client required zero changes as a result.

---

## 🗂️ Project Structure

### Flutter (Frontend)

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTextStyles, AppSpacing, AppRadius
│   ├── di/               # GetIt service locator setup
│   ├── network/          # ApiService (Dio), ApiEndpoints, ApiResponse, ApiConfig
│   ├── providers/        # BaseProvider
│   ├── router/           # GoRouter — AppRoutes, guards
│   ├── storage/          # SharedPreferences wrapper (LocalStorage / HelperFunctions)
│   └── utils/            # AttendanceTime (date/hours parsing), Validators
├── features/
│   ├── attendance/       # BiometricAuthScreen, AttendanceService, LocationService
│   ├── auth/             # OnboardingScreen, OtpAuthScreen, HomeScreen, AuthProvider
│   ├── communication/    # VideoCallScreen (Zego)
│   ├── company/          # HR dashboard, staff list + bulk import, holidays, admins,
│   │                     # analytics, team leave calendar, audit log, company settings
│   ├── correction/       # Attendance correction requests (employee submit, HR approve)
│   ├── employee/         # Employee dashboard (tabs), profile, setup, EmployeeProvider
│   └── leave/            # LeaveRequestScreen, HrLeaveScreen, LeaveProvider, leave balance
└── shared/
    └── widgets/          # AppCard, PrimaryButton, AppTextField, StatusBadge, SkeletonBox
```

### Node.js (Backend)

```
server/
├── controllers/    # authController, otpController, companyController, employeeController,
│                   # attendanceController, leaveController, correctionController,
│                   # locationController, holidayController, auditController
├── routes/         # userRoutes (otp), authRoute, companyRoutes, employeeRoute,
│                   # attendanceRoutes, leaveRoute, correctionRoutes, locationRoute,
│                   # holidayRoutes, auditRoutes
├── middleware/     # auth.js (verifyToken, requireRole, requireActiveEmployee),
│                   # validate.js (requireFields)
├── lib/            # prisma.js (client singleton), serializers.js (Prisma → legacy JSON shape)
├── utils/          # dateUtils.js (dd/MM/yy parsing), timeUtils.js (worked-hours/overtime)
├── prisma/         # schema.prisma, migrations/
└── index.js        # Express server — port 2000
```

---

## 🛠️ Tech Stack

### Mobile / Frontend

| Layer | Technology |
|---|---|
| Framework | Flutter 3 |
| Language | Dart 3 |
| State management | Provider 6 |
| Navigation | GoRouter 14 |
| Dependency injection | GetIt 7 |
| HTTP client | Dio 5 |
| Local storage | SharedPreferences + flutter_secure_storage |
| Location | Geolocator 13, Geocoding 3 |
| Biometrics | local_auth 2 |
| Video calls | Zego UIKit Prebuilt Call 4 |
| Calendar UI | table_calendar 3 |
| Charts | fl_chart 1 |
| CSV import | csv 8 + file_picker 10 |
| PDF export | pdf 3 + printing 5 |
| OTP input | Pinput 5 |
| Fonts | Google Fonts 6 |

### Backend

| Layer | Technology |
|---|---|
| Runtime | Node.js 20 |
| Framework | Express 4 |
| Database | PostgreSQL (Supabase) via Prisma 6 |
| Auth | JSON Web Tokens (jsonwebtoken 9) |
| OTP | otp-generator 4 (Twilio wired but disabled — see [OTP / SMS](#-security)) |
| Security headers | helmet 7 |
| Rate limiting | express-rate-limit 7 |
| Testing | Node's built-in `node:test` runner |

---

## 🏗️ Architecture

The Flutter side follows **feature-first clean architecture**:

- **Core layer** — shared infrastructure (networking, storage, DI, routing, constants)
- **Feature layer** — each feature owns its `screens/`, `widgets/`, `providers/`, `services/`, and `models/`
- **Shared layer** — reusable UI primitives with no feature dependency

State flows top-down via `Provider` / `ChangeNotifier`. `GetIt` resolves singleton services (e.g., `ApiService`, `LocalStorage`) without widget-tree coupling. Navigation is declarative via `GoRouter`, with the HR and employee dashboards each built as a tabbed shell (`CompanyHrScreen`, `EmployeeMainScreen`) hosting their numbered sub-screens, and every other feature screen pushed on top via named routes.

The backend is a RESTful API on top of Prisma/Postgres: controllers handle request/response, Prisma models own persistence, and middleware (`verifyToken`, `requireRole`, `requireActiveEmployee`, `requireFields`) handles auth, role gating, and input validation globally. `server/lib/serializers.js` translates Prisma's camelCase columns back into the legacy Mongo-style JSON keys (`InTime`, `isPresent`, `In`/`Out`/`Total`, ...) the Flutter client expects, so the migration from Mongo didn't require any client-side changes. Every HR-side approval, add, or remove action (leave, correction, admin, employee, holiday, settings, bulk import) writes a row to an `AuditLog` table via a shared `logAction()` helper.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Node.js `>=18.18`
- A Supabase (or any PostgreSQL) project — pooled + direct connection strings

### Clone Repository

```bash
git clone https://github.com/yourusername/attend-ease.git
cd attend-ease
```

### Backend Setup

```bash
cd server
npm install
cp .env.example .env
```

Edit `.env`:

```env
PORT=2000
DATABASE_URL="postgresql://...pgbouncer=true"   # pooled connection (port 6543)
DIRECT_URL="postgresql://..."                    # direct connection (port 5432), used by migrations
JWT_SECRET="your-secret-key"
NODE_ENV=development
TIMEZONE=Asia/Kolkata
CORS_ORIGINS=
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
TWILIO_PHONE_NUMBER=
```

```bash
npx prisma migrate dev
npm start
```

The server starts at **`http://localhost:2000`**. Health check: `GET /health`.

### Flutter Setup

```bash
cd attend_ease-main
flutter pub get
flutter run --dart-define=ENV=dev   # points at 10.0.2.2 (Android emulator loopback)
```

---

## 📡 REST API Reference

All routes are prefixed with **`/api/v1`**. Protected routes require `Authorization: Bearer <token>`. `hrOnly` routes require a company-role token, `employeeOnly` routes require an employee-role token (and, except for `join-employee`, an active — non-offboarded — employee).

### OTP

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/otp/send-otp` | — | Send OTP to phone number |
| `POST` | `/otp/verify-otp` | — | Verify OTP, receive a short-lived `otpToken` |

### Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/identify` | — | Identify role (HR / employee) by phone |

### Company

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/company/add-company` | — | Register a new company (creates first admin) |
| `GET` | `/company/get-report` | hrOnly | Full staff attendance + leave-balance report |
| `POST` | `/company/store-history` | hrOnly | Save daily staff count snapshot |
| `POST` | `/company/get-history` | hrOnly | Get staff count history for a date |
| `GET` | `/company/history-list` | hrOnly | List all stored history dates |
| `POST` | `/company/send-notifications` | hrOnly | Look up an employee's number for a notification |
| `POST` | `/company/add-admin` | hrOnly | Add another company admin |
| `GET` | `/company/admins` | hrOnly | List company admins |
| `POST` | `/company/remove-admin` | hrOnly | Remove an admin (blocked if it's the last one) |
| `GET` | `/company/analytics` | hrOnly | Attendance trend (optional `?month=&year=`), pending leaves, late/overtime stats |
| `GET` | `/company/settings` | hrOnly | Get company city + overtime threshold |
| `POST` | `/company/update-settings` | hrOnly | Update city + overtime threshold hours |

### Location

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/location/store-location` | hrOnly | Set company geo-fence (lat, lng, radius) |
| `GET` | `/location/get-location` | employeeOnly | Get company's stored location |
| `GET` | `/location/get-company-location` | hrOnly | Get the HR's own company location |

### Employee

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/employee/add-employee` | hrOnly | Add a single employee |
| `POST` | `/employee/bulk-add-employees` | hrOnly | Import many employees (per-row success/failure) |
| `POST` | `/employee/remove-employee` | hrOnly | Offboard an employee (soft delete) |
| `POST` | `/employee/join-employee` | — | Employee joins a company by ID + OTP |
| `GET` | `/employee/get-history` | employeeOnly | Get employee's own attendance report |
| `POST` | `/employee/change-count` | employeeOnly | Update live in/out/total staff count |
| `GET` | `/employee/get-count` | hrOnly | Fetch current live staff count |

### Attendance

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/attendance/mark-in` | employeeOnly | Clock in (geo-fence checked; flags `isLate`) |
| `POST` | `/attendance/mark-out` | employeeOnly | Clock out |
| `POST` | `/attendance/get-attend` | employeeOnly | Get attendance record for a date |
| `GET` | `/attendance/get-attend-days` | employeeOnly | Get days-present count |

### Leave

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/leave/request-leave` | employeeOnly | Submit a leave request (checked against balance) |
| `GET` | `/leave/my-leaves` | employeeOnly | Employee's own leave history |
| `GET` | `/leave/my-balance` | employeeOnly | Remaining leave days vs. quota |
| `GET` | `/leave/pending-leaves` | hrOnly | HR fetches pending leave requests |
| `POST` | `/leave/action-leave` | hrOnly | HR approves or rejects a leave |

### Corrections

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/correction/request-correction` | employeeOnly | Request a fix to a punch-in/out record |
| `GET` | `/correction/my-corrections` | employeeOnly | Employee's own correction requests |
| `GET` | `/correction/pending-corrections` | hrOnly | HR fetches pending correction requests |
| `POST` | `/correction/action-correction` | hrOnly | HR approves (patches the record) or rejects |

### Holidays

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/holiday/add-holiday` | hrOnly | Add a company holiday |
| `GET` | `/holiday/list` | any role | List company holidays |
| `POST` | `/holiday/remove-holiday` | hrOnly | Remove a holiday |

### Audit log

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/audit/log` | hrOnly | Chronological log of admin/employee/leave/correction/holiday/settings actions |

---

## 🗄️ Database Schema

Managed by Prisma, defined in `server/prisma/schema.prisma`, backed by PostgreSQL.

```
Company ──< CompanyAdmin (multiple HR logins per company)
Company ──< Employee ──< AttendanceRecord
Company ──< Employee ──< Leave
Company ──< Employee ──< AttendanceCorrection
Company ──< Location (one geo-fence per company)
Company ──< StaffCount (live in/out counter)
Company ──< StaffReportEntry (daily count history)
Company ──< Holiday
Company ──< AuditLog
Phone ──< Otp (active OTP per number)
```

| Model | Key Fields |
|---|---|
| `Company` | `companyName` (unique), `companyCode` (unique), `companyCity`, `hrPhone`, `overtimeThresholdMinutes` |
| `CompanyAdmin` | `companyId`, `name`, `phone` (unique) — auth source for HR login |
| `Employee` | `employeeName`, `employeeNumber` (unique), `employeePosition`, `employeeCode` (unique), `leaveQuota`, `deletedAt` (soft delete) |
| `AttendanceRecord` | `employeeId`, `date`, `inTime`, `outTime`, `isPresent`, `isLate` |
| `Location` | `companyId` (unique), `latitude`, `longitude`, `radius`, `workStartTime` |
| `StaffCount` | `companyId` (unique), `inCount`, `outCount`, `total` |
| `StaffReportEntry` | `companyId`, `isSubmit`, `totalCount`, `currentDate` |
| `Leave` | `employeeId`, `companyId`, `leaveType`, `fromDate`, `toDate`, `reason`, `status` |
| `AttendanceCorrection` | `employeeId`, `companyId`, `date`, `requestedInTime`, `requestedOutTime`, `reason`, `status` |
| `Holiday` | `companyId`, `date`, `name` (unique per company+date) |
| `AuditLog` | `companyId`, `actorName`, `action`, `detail`, `createdAt` |
| `Otp` | `phoneNumber` (unique), `otp`, `createdAt` (5-minute TTL, enforced in code) |

`AttendanceRecord`, `Leave`, and `AttendanceCorrection` dates are stored as `dd/MM/yy` strings to match the app's existing date format everywhere.

---

## 📱 App Screens

| Screen | Role | Description |
|---|---|---|
| `OnboardingScreen` | Both | Welcome carousel |
| `OtpAuthScreen` | Both | Phone number + OTP login |
| `HomeScreen` | Both | Role selector (HR / Employee) |
| `CompanySetupScreen` | HR | Register company |
| `CompanyLocationScreen` | HR | Set geo-fence on map |
| `CompanyHrScreen` | HR | Tabbed shell: dashboard (with pending leave/correction count badges), history, staff report |
| `StaffListScreen` | HR | Browse employees, search, remove (offboard) |
| `AddStaffScreen` | HR | Add a single employee |
| `BulkImportScreen` | HR | Import staff from a CSV, per-row results |
| `EmployeeAttendanceScreen` | HR | One employee's attendance, leave balance, overtime |
| `HrLeaveScreen` | HR | Search + approve/reject pending leave requests |
| `HrCorrectionScreen` | HR | Search + approve/reject correction requests |
| `ManageAdminsScreen` | HR | Add/remove company admins |
| `ManageHolidaysScreen` | HR | Add/remove company holidays |
| `TeamLeaveCalendarScreen` | HR | Calendar of who's on leave + holidays |
| `CompanyAnalyticsScreen` | HR | Month/year-filterable attendance trend chart (calendar picker + stepper), pending/late/hours stats |
| `AuditLogScreen` | HR | Chronological log of HR actions |
| `CompanySettingsScreen` | HR | Edit city + overtime threshold |
| `AdminProfileScreen` | HR | HR profile + links to every screen above |
| `EmployeeSetupScreen` | Employee | First-time setup (join company) |
| `EmployeeMainScreen` | Employee | Tabbed shell: punch in/out, profile, calendar/log |
| `BiometricAuthScreen` | Employee | Fingerprint / face verification |
| `LeaveRequestScreen` | Employee | Submit a leave request (shows remaining balance) |
| `CorrectionRequestScreen` | Employee | Request a fix to a punch record |
| `MyCorrectionsScreen` | Employee | View own correction request history |
| `EmployeeProfileScreen` | Employee | Profile details |
| `VideoCallScreen` | Both | Zego UIKit video call |

---

## 🔒 Security

- **JWT sessions** — every protected route requires a signed Bearer token, verified by `verifyToken`; `requireRole` gates HR-only vs. employee-only routes, and `requireActiveEmployee` blocks a token from an offboarded employee
- **JWT design constraint** — `companyName` is embedded directly in every token and used as the lookup key throughout the backend, which is why company **renaming** is intentionally not supported (would orphan every issued token); only the city and other non-key fields are editable
- **Geo-radius enforcement** — the backend computes the distance between the device and the company's stored location; clock-in/out is rejected if outside the configured radius
- **Biometric gate** — `local_auth` enforces fingerprint or face ID before attendance is marked
- **Soft-delete offboarding** — removed employees are marked `deletedAt` rather than deleted, and `requireActiveEmployee` immediately revokes their session on the next request
- **Input validation** — `requireFields` middleware rejects requests missing required body fields before they reach controllers
- **Rate limiting & headers** — `express-rate-limit` on auth/company routes, `helmet` for standard security headers
- **Audit trail** — every leave/correction approval, admin/employee add-or-remove, holiday change, and settings update is recorded via `logAction()`, viewable in the Audit Log screen
- **OTP / SMS** — Twilio is wired into `otpController.js` but the actual SMS send is currently commented out; in non-production (`NODE_ENV` unset), `send-otp` returns the code directly in the response instead, for local testing. Re-enabling real SMS just needs the Twilio call uncommented and credentials set

---

## 🧪 Testing

- **Backend unit tests**: `cd server && npm test` (Node's built-in test runner — auth middleware, OTP token verification, role guards)
- **Backend smoke tests**: ad-hoc Node scripts hitting the live API end-to-end (not checked into the repo; see `testing/` for the manual equivalent)
- **Static analysis**: `flutter analyze` (Flutter/Dart) — should report no issues
- **Manual test guides**: [`testing/TESTING_GUIDE.md`](testing/TESTING_GUIDE.md) (full walkthrough, one section per feature) and [`testing/TESTING_GUIDE_2.md`](testing/TESTING_GUIDE_2.md) (condensed checkbox version) cover every feature in the app end-to-end

---

## 📄 License

MIT © 2025 — feel free to fork and build on top of this.
