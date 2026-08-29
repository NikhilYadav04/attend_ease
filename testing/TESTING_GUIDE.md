# Testing Guide — New Features

Manual test guide for every feature added on top of the original app this session.
Covers app-UI steps first, with a curl fallback for anything you can't easily trigger
from the UI. Skip anything already covered by the automated smoke scripts / `npm test`
if you just want the parts static analysis can't check (file picking, visual states).

## 0. Setup

**Backend**a
```bash
cd server
npm run dev          # nodemon index.js, http://localhost:2000
```
Check `server/.env` has `DATABASE_URL`, `DIRECT_URL`, `JWT_SECRET` set. `NODE_ENV` is
unset (dev), which matters for step 1 below.

**Flutter app**
```bash
flutter run
```
Point it at your machine's LAN IP if testing on a physical device/emulator, not
`localhost`.

## 1. Logging in (OTP workaround)

Twilio SMS sending is **disabled** (left that way deliberately — do not re-enable
without asking). In dev mode, `POST /api/v1/otp/send-otp` returns the OTP directly in
the response `message` field instead of texting it, so:

- On the phone-entry screen, request the code as normal.
- The OTP won't arrive by SMS. Get it from the backend terminal log (each request is
  logged) or by calling the endpoint directly:
  ```bash
  curl -X POST http://localhost:2000/api/v1/otp/send-otp \
    -H "Content-Type: application/json" \
    -d '{"phoneNumber":"+91XXXXXXXXXX"}'
  ```
  The 6-digit code is in `"message"`. Type it into the app's OTP screen.

This applies to every login below (HR admin and employee).

## 2. Late / on-time detection

1. Log in as an employee, punch in **after** the company's configured office start
   time + grace period.
2. Confirm the punch-in success toast/state shows a "Late" indicator.
3. Open the employee's calendar/log screen — the day should show a "Late" caption
   badge.
4. Punch in on time on a different day (or with the server clock/company hours
   adjusted) and confirm no "Late" badge appears.
5. As HR, open **Analytics** and confirm "Late this week" reflects the late punch-in.

## 3. Attendance correction requests

**Employee side**
1. From the employee dashboard, open **Corrections** (icon button near the calendar).
2. Submit a correction request for a past date — provide a requested in/out time and a
   reason.
3. Open **My Corrections** and confirm the new request shows as `Pending`.

**HR side**
1. From HR dashboard → **Correction Requests**.
2. Confirm the new request appears with the employee's name, date, requested times,
   and reason.
3. Use the **search box** ("Search by name…") — type a partial employee name, confirm
   the list filters live; clear it (X button) and confirm the full list returns.
4. Approve one request — confirm the underlying attendance record for that date is
   updated (check the employee's attendance log reflects the corrected in/out time).
5. Reject a different request — confirm it moves out of the pending list and the
   employee sees it as `Rejected` in **My Corrections**.

## 4. Employee offboarding (soft delete)

1. As HR, open **Staff List**, pick an employee, use the overflow menu →
   **Remove Employee**, confirm in the dialog.
2. Confirm the employee disappears from the active staff list.
3. Try logging in as that removed employee (or, if already logged in on a test device,
   pull-to-refresh / navigate) — confirm they're signed out / blocked with
   "Account deactivated" rather than able to keep using the app.
4. Re-add an employee with the **same name** afterward (Add Staff, same
   name/number/position) and confirm it works cleanly (soft-delete un-deletes on
   upsert) — this is the "employee rejoins" path.

## 5. Multiple admins per company

1. As an existing HR admin, open **Manage Admins**.
2. Add a new admin (name + phone number not already used).
3. Confirm the new admin appears in the list.
4. Log out, log in with the new admin's phone number (OTP flow) — confirm they land on
   the same HR dashboard with full access.
5. Back on the original admin's account, try removing an admin when only one is left —
   confirm it's blocked (app should show an error; the backend rejects removing the
   last admin).
6. With 2+ admins present, remove one — confirm it disappears from the list and that
   admin can no longer log in.

## 6. HR analytics dashboard

1. As HR, open **Analytics**.
2. Confirm it shows: a trend line chart of daily attendance rate, pending leave count,
   leaves approved this month, and late-this-week count.
3. Cross-check one number manually — e.g. approve a leave request, refresh Analytics,
   confirm "approved this month" incremented by 1.

## 7. Leave status in attendance calendar/log

1. As an employee, request and have HR approve a leave for a specific date (or a date
   range).
2. Open the employee's calendar screen — the approved leave date(s) should render with
   a distinct tint (blue) and a beach/leave icon, not counted as absent.
3. Check the monthly log list below the calendar — the on-leave day should show as a
   separate "On Leave" row, not blank.
4. As HR, open that employee's attendance detail (Staff List → tap employee) — same
   on-leave day should show an "On Leave" row there too (not counted in the
   present/absent rate).
5. Sanity check: a day that's both marked present AND has an approved leave (edge
   case, shouldn't normally happen) — present should win the display.

## 8. Search in HR approval lists

Already exercised in step 3 for corrections. Repeat for leave:
1. HR dashboard → **Leave Requests**.
2. Type a partial name into "Search by name…", confirm live filtering.
3. Clear search, confirm full pending list returns.
4. Search for a name with no matches, confirm the "No matches for '...'" empty state.

## 9. Company settings (edit city)

1. As HR, open **Profile → Company Settings**.
2. Confirm the company **name** is shown read-only, with a short note explaining why
   it can't be changed here.
3. Edit the **city** field, save.
4. Confirm a success toast and that re-opening the screen shows the updated city.
5. Confirm login still works afterward (log out, log back in with the same HR phone) —
   this proves the city edit didn't touch anything the JWT depends on.

## 10. Bulk CSV staff import

1. Prepare a CSV file with header row `employeeName,employeeNumber,employeePosition`
   and a handful of data rows. Include at least one deliberately bad row (duplicate
   phone number matching an existing employee/admin, or a missing field) to test
   partial failure.

   Example:
   ```csv
   employeeName,employeeNumber,employeePosition
   Test One,+911111111111,Developer
   Test Two,+912222222222,Designer
   Test Three,,QA Engineer
   ```
2. HR dashboard → **Bulk Import**.
3. Tap **Pick CSV File**, select the file — confirm the preview list appears with a
   green check per valid row and a red icon on the row missing a field.
4. Tap **Import**.
5. Confirm the results list shows success for the valid rows and a failure message
   for the bad row(s), and the toast summary ("`X of Y added`") matches.
6. Go to **Staff List**, confirm the successfully-imported employees now appear.
7. Try importing a CSV with a header missing one of the three required columns —
   confirm the app shows the "Bad header" error and doesn't attempt an import.
8. Try importing an empty CSV (header only, no data rows) — confirm a sensible
   empty/no-op state instead of a crash.

## 11. Leave balance

1. As an employee, open **Request Leave**. Confirm a banner near the top shows
   "X of Y leave days remaining" (default quota is 12).
2. Submit a leave request within the remaining balance, have HR approve it.
3. Reopen **Request Leave** — confirm the remaining count dropped by the number of
   days approved.
4. Try requesting more days than remain — confirm the app blocks it with an
   "Insufficient balance" message before even hitting submit.
5. As HR, open that employee's attendance detail (Staff List → tap employee) —
   confirm a "Leave" pill shows remaining/quota (e.g. "9/12 Leave") alongside the
   Present/Absent/Total pills.

## 12. Company holidays

1. As HR, open **Profile → Company Holidays**.
2. Add a holiday (pick a date, give it a name), confirm it appears in the list.
3. Try adding another holiday on the same date — confirm it's rejected as a duplicate.
4. As an employee, open the calendar screen — confirm the holiday date shows a
   distinct tint (purple) different from present (green) and on-leave (blue).
5. Back in HR, remove the holiday — confirm it disappears from the list and the
   employee's calendar tint clears on refresh.

## 13. Working hours / overtime

1. As an employee, punch in, then punch out later the same day.
2. Check the calendar/log screen — confirm the row shows worked hours (e.g.
   "8h 30m worked").
3. If the gap between in/out exceeds 9 hours, confirm an "Overtime" badge appears
   next to "Late" (if applicable) — same visual pattern as the existing Late badge.
4. As HR, open that employee's attendance detail — confirm the same Overtime badge
   appears there too.
5. Open **Analytics** — confirm "Hours This Week" shows a nonzero total once there's
   at least one punched-out day in the current week.

## 14. Audit log

1. As HR, perform a few trackable actions: approve/reject a leave, approve/reject a
   correction, add/remove an admin, add/remove a holiday, add an employee, run a bulk
   import, update company settings.
2. Open **Profile → Audit Log**.
3. Confirm each action appears as a new entry, newest first, with a readable label
   (e.g. "Leave approved"), a detail line (employee name/date), who did it, and a
   timestamp.
4. Confirm an employee account cannot reach this screen/endpoint (HR-only).

## 15. Configurable shift hours

1. As HR, open **Company Settings**. Confirm a "Standard Shift Hours" field appears
   below City, defaulting to 9.
2. Change it to a small number (e.g. 5) and save.
3. Have an employee punch in and out with more than 5 hours between them (or use a
   correction request to set specific in/out times) — confirm the day now shows the
   "Overtime" badge on both the employee's log and HR's staff detail.
4. Set it back to a normal value (e.g. 9) and confirm a 6-hour day no longer shows
   Overtime.
5. Try entering 0, a negative number, or something over 24 — confirm the app blocks
   the save with a clear error.

## 16. Team leave calendar

1. As HR, open **Profile → Team Leave Calendar**.
2. Confirm the calendar shows a purple dot/tint on holiday dates and a blue dot on
   dates where at least one employee is on approved leave.
3. Tap a holiday date — confirm the holiday name appears below the calendar.
4. Tap a date where someone is on leave — confirm their name(s) appear in a list
   below.
5. Tap a date with nothing scheduled — confirm an "Everyone is in on this day"
   empty state.
6. Cross-check against **Company Holidays** and an employee's approved leave to
   confirm the calendar reflects the same data.

## 17. Pending-count badges on HR dashboard

1. As an employee, submit a leave request and a correction request.
2. As HR, open the dashboard (Quick Actions grid). Confirm the "Leave Requests" and
   "Corrections" tiles each show a small red count badge on the icon matching the
   number of pending items.
3. Tap into "Leave Requests" and approve/reject the pending one, then go back —
   confirm the badge count drops (goes away if that was the only one).
4. Same check for "Corrections".
5. With zero pending items, confirm no badge shows on either tile.

## 18. Regression pass

Run once at the end, since several of the above touch shared code paths:
- `flutter analyze` → should report "No issues found!"
- `cd server && npm test` → all tests should pass
- Basic employee flow still works end-to-end: login → punch in → punch out → view
  today's log.
- Basic HR flow still works end-to-end: login → view staff report → view a single
  employee's attendance detail.

## Cleanup

Any test employees / admins / companies created while testing (e.g. "Test One",
"Test Two" from step 10, or extra admins from step 5) should be removed afterward so
only real data remains — same convention used throughout backend development this
session.
