<div align="center">

# 📋 Attend Ease

### Attendance and leave management for companies — built for HR admins and employees alike

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev) [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev) [![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=nodedotjs)](https://nodejs.org) [![MongoDB](https://img.shields.io/badge/MongoDB-8.x-47A248?logo=mongodb)](https://mongodb.com) [![Express](https://img.shields.io/badge/Express-4-000000?logo=express)](https://expressjs.com) [![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

</div>

---

## 📸 App Screenshots

<div align="center">

<table>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/cde34324-7cdd-4b4c-8698-fb734fe4d123" width="160"/></td>
    <td><img src="https://github.com/user-attachments/assets/daa8a01b-5b26-41fc-bc9b-4da4eafa83a4" width="160"/></td>
  </tr>
</table>

</div>

---

## 📖 Overview

Attend Ease is a full-stack Flutter + Node.js application that streamlines workforce attendance. HR admins define a company geo-radius; employees can only clock in when physically inside it. Authentication flows through Twilio OTP and device biometrics. Leave requests, daily attendance reports, and staff counts are all managed in-app, with PDF export for records and real-time video calls powered by Zego UIKit.

---

## 🗂️ Project Structure

### Flutter (Frontend)

```
lib/
├── core/
│   ├── constants/        # AppColors, AppTextStyles, AppSpacing, AppDimensions
│   ├── di/               # GetIt service locator setup
│   ├── network/          # ApiService (Dio), ApiEndpoints, ApiResponse, ApiConfig
│   ├── providers/        # BaseProvider
│   ├── router/           # GoRouter — AppRoutes, guards
│   ├── storage/          # SharedPreferences wrapper (LocalStorage / HelperFunctions)
│   └── utils/            # Validators
├── features/
│   ├── attendance/       # BiometricAuthScreen, AttendanceProvider, LocationService
│   ├── auth/             # OnboardingScreen, OtpAuthScreen, HomeScreen, AuthProvider
│   ├── communication/    # VideoCallScreen (Zego)
│   ├── company/          # HR dashboard, staff list, location setup, leave approvals, admin profile
│   ├── employee/         # Employee dashboard (tabs), profile, setup, EmployeeProvider
│   └── leave/            # LeaveRequestScreen, MyLeavesScreen, HrLeaveScreen, LeaveProvider
└── shared/
    └── widgets/          # AppCard, PrimaryButton, AppTextField, StatusBadge, SkeletonBox
```

### Node.js (Backend)

```
server/
├── controllers/    # authController, otpController, companyController, employeeController,
│                   # attendanceController, leaveController, locationController
├── routes/         # userRoutes (otp), authRoute, companyRoutes, employeeRoute,
│                   # attendanceRoutes, leaveRoute, locationRoute
├── middleware/     # auth.js (JWT verifyToken), validate.js (requireFields)
├── models/         # employee, attendance (Report), leave, location, otp, staffReport, staffCount
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
| Local storage | SharedPreferences |
| Location | Geolocator 13, Geocoding 3 |
| Biometrics | local_auth 2 |
| Video calls | Zego UIKit Prebuilt Call 4 |
| PDF export | pdf 3 + printing 5 |
| OTP input | Pinput 5 |
| Fonts | Google Fonts 6 |

### Backend

| Layer | Technology |
|---|---|
| Runtime | Node.js 20 |
| Framework | Express 4 |
| Database | MongoDB + Mongoose 8 |
| Auth | JSON Web Tokens (jsonwebtoken 9) |
| OTP / SMS | Twilio 5 + otp-generator 4 |
| Password hashing | bcryptjs 2 |
| Rate limiting | express-rate-limit 7 |

---

## 🏗️ Architecture

The Flutter side follows **feature-first clean architecture**:

- **Core layer** — shared infrastructure (networking, storage, DI, routing, constants)
- **Feature layer** — each feature owns its `screens/`, `widgets/`, `providers/`, `services/`, and `models/`
- **Shared layer** — reusable UI primitives with no feature dependency

State flows top-down via `Provider` / `ChangeNotifier`. `GetIt` resolves singleton services (e.g., `ApiService`, `LocalStorage`) without widget-tree coupling. Navigation is declarative via `GoRouter` with redirect guards that check login state from `LocalStorage` before allowing access to protected routes.

The backend is a thin RESTful API: controllers handle request/response, Mongoose models own persistence, and two middleware functions (`verifyToken`, `requireFields`) handle auth and input validation globally.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.4.0`
- Node.js `>=20`
- MongoDB Atlas or local MongoDB instance
- Twilio account (for OTP SMS)

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
DB="mongodb+srv://..."
JWT_SECRET="your-secret-key"
TWILIO_ACCOUNT_SID="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
TWILIO_AUTH_TOKEN="your-auth-token"
TWILIO_PHONE_NUMBER="+1xxxxxxxxxx"
```

```bash
npm start
```

The server starts at **`http://localhost:2000`**.

### Flutter Setup

```bash
cd attend_ease-main
flutter pub get
flutter run
```

---

## 📡 REST API Reference

All routes are prefixed with **`/api/v1`**. Protected routes require `Authorization: Bearer <token>`.

### OTP

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/otp/send-otp` | — | Send OTP to phone number |
| `POST` | `/otp/verify-otp` | — | Verify OTP, receive JWT |

### Auth

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/auth/identify` | — | Identify role (HR / employee) by phone |

### Company

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/company/add-company` | — | Register a new company |
| `GET` | `/company/get-report` | ✓ | Fetch full attendance report |
| `POST` | `/company/store-history` | ✓ | Save daily staff count snapshot |
| `POST` | `/company/get-history` | ✓ | Get staff count history for a date |
| `GET` | `/company/history-list` | ✓ | List all stored history dates |
| `POST` | `/company/send-notifications` | ✓ | Send push notification to an employee |

### Location

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/location/store-location` | ✓ | Set company geo-fence (lat, lng, radius) |
| `GET` | `/location/get-location` | ✓ | Get company's stored location |
| `GET` | `/location/get-company-location` | ✓ | Get location by company name (employee use) |

### Employee

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/employee/add-employee` | ✓ | HR adds a new employee |
| `POST` | `/employee/join-employee` | — | Employee joins a company by ID |
| `GET` | `/employee/get-history` | ✓ | Get employee's attendance report |
| `POST` | `/employee/change-count` | ✓ | Update live in/out/total staff count |
| `GET` | `/employee/get-count` | ✓ | Fetch current live staff count |

### Attendance

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/attendance/mark-in` | ✓ | Clock in (requires `InTime`, `Date`) |
| `POST` | `/attendance/mark-out` | ✓ | Clock out (requires `InTime`, `OutTime`, `Date`) |
| `POST` | `/attendance/get-attend` | ✓ | Get attendance record for a date |
| `GET` | `/attendance/get-attend-days` | ✓ | Get all attendance days (calendar view) |

### Leave

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `POST` | `/leave/request-leave` | ✓ | Employee submits a leave request |
| `GET` | `/leave/my-leaves` | ✓ | Employee's own leave history |
| `GET` | `/leave/pending-leaves` | ✓ | HR fetches pending leave requests |
| `POST` | `/leave/action-leave` | ✓ | HR approves or rejects a leave |

---

## 🗄️ Database Schema

```
Employee ──< Report (attendance records)
Company ──< Location (one geo-fence per company)
Company ──< StaffCount (live in/out counter)
Company ──< StaffReport (daily count history)
Employee ──< Leave (leave requests)
Phone ──< Otp (active OTP per number)
```

| Model | Key Fields |
|---|---|
| `Employee` | `employeeID` (unique), `employeeName`, `employeeNumber`, `employeePosition`, `employeeCompany` |
| `Report` | `employeeName`, `employeeCompany`, `daysPresent`, `attendance[]` → `{InTime, OutTime, Date, isPresent}` |
| `Location` | `companyName` (unique), `latitude`, `longitude`, `radius`, `workStartTime` |
| `StaffCount` | `companyName` (unique), `In`, `Out`, `Total` |
| `StaffReport` | `companyName`, `list[]` → `{isSubmit, totalCount, currentDate}` |
| `Leave` | `employeeName`, `employeeCompany`, `leaveType`, `fromDate`, `toDate`, `reason`, `status` |
| `Otp` | `phoneNumber`, `otp` |

---

## 📱 App Screens

| Screen | Role | Description |
|---|---|---|
| `OnboardingScreen` | Both | Welcome carousel |
| `OtpAuthScreen` | Both | Phone number + OTP login |
| `HomeScreen` | Both | Role selector (HR / Employee) |
| `CompanySetupScreen` | HR | Register company |
| `CompanyLocationScreen` | HR | Set geo-fence on map |
| `CompanyHrScreen` | HR | Main HR dashboard |
| `StaffListScreen` | HR | Browse all employees |
| `AddStaffScreen` | HR | Add a new employee |
| `ApprovalReqScreen` | HR | Approve / reject employee join requests |
| `HrLeaveScreen` | HR | Review pending leave requests |
| `EmployeeAttendanceScreen` | HR | View a specific employee's attendance |
| `AdminProfileScreen` | HR | HR profile and company settings |
| `EmployeeSetupScreen` | Employee | First-time setup (join company) |
| `EmployeeMainScreen` | Employee | Dashboard with attendance tabs |
| `BiometricAuthScreen` | Employee | Fingerprint / face verification |
| `LeaveRequestScreen` | Employee | Submit a leave request |
| `MyLeavesScreen` | Employee | View own leave history |
| `EmployeeProfileScreen` | Employee | Profile details |
| `VideoCallScreen` | Both | Zego UIKit video call |

---

## 🔒 Security

- **OTP authentication** — phone-based login via Twilio SMS; tokens are single-use
- **JWT sessions** — all protected routes require a signed Bearer token verified by `verifyToken` middleware
- **Biometric gate** — `local_auth` enforces fingerprint or face ID before attendance is marked
- **Geo-radius enforcement** — `LocationService` computes the distance between the device and the company pin; clock-in is blocked if outside the configured radius
- **Input validation** — `requireFields` middleware rejects requests missing required body fields before they reach controllers
- **Rate limiting** — `express-rate-limit` is configured on OTP and company routes (currently bypassed for development; enable by restoring the limiter in `index.js`)
- **Password hashing** — bcryptjs hashes any stored credentials

---

## 🧪 Testing

Manual testing checklist:

- [ ] OTP send and verify flow
- [ ] Company registration and geo-fence setup
- [ ] Employee join flow with company ID
- [ ] Attendance mark-in and mark-out within radius
- [ ] Attendance blocked outside radius
- [ ] Biometric prompt appears before clock-in
- [ ] Leave request submission and HR approval / rejection
- [ ] PDF report generation and share

---

## 📄 License

MIT © 2025 — feel free to fork and build on top of this.
