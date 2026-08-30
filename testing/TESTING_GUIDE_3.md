# Testing Guide 3 — Calendar Hints, Tab Reload Fix, HR History, Profile Edit, Logout, Pagination, PDF Export

Manual test guide for the features added in this round only. Same setup as
`TESTING_GUIDE.md` (backend on `npm run dev`, OTP comes back in the `send-otp`
response `message` field since Twilio is off — do not re-enable it). Use
`TESTING_GUIDE_2.md` for a fast checkbox pass over everything built to date; this file
is just today's batch, with more detail since it hasn't been run yet.

## 0. Setup

```bash
cd server && npm run dev          # http://localhost:2000
flutter run                       # point at your machine's LAN IP if on a device
```

## 1. Calendar tap hint

1. Log in as an employee, open the **History** tab (attendance calendar).
2. Tap a day that's tinted **green** (present) — confirm a snackbar/toast appears
   reading something like `Present · in 09:12` (shows the punch-in time if present).
3. Tap a day tinted **blue** (on leave) — confirm the hint reads `On Leave`.
4. Tap a day tinted **purple** (holiday) — confirm the hint shows the holiday name,
   e.g. `🎉 Diwali · Holiday`. (Add a holiday first via HR → Company Holidays if none
   exist yet.)
5. Tap a plain, untinted day — confirm no hint pops up (nothing to say about it).
6. Tap several tinted days in a row quickly — confirm each new tap replaces the
   previous snackbar rather than stacking multiple toasts.

## 2. Tab-switch no longer reloads

This was the real bug: switching tabs used to dispose each tab's state and refetch
from scratch every time, flashing a loading skeleton.

1. As an **employee**, open the app, let the Home tab finish loading.
2. Switch to Attendance → History → Leaves → back to Home, several times, fairly
   quickly.
3. Confirm: no loading skeleton reappears on tabs you've already visited once this
   session, and no repeated "Verifying your location…" spinner on the Attendance tab
   after the first check.
4. Do the same as **HR**: Dashboard → Approvals → Staff → back to Dashboard,
   repeatedly. Confirm the dashboard's stats/chart don't reload/flicker on return.
5. Pull-to-refresh on any tab should still work and re-fetch normally — this only
   removes the *unwanted* automatic refetch on tab switch, not manual refresh.

## 3. HR Leave / Correction history view

1. As HR, open **Leave Requests**. Confirm you land on **Pending** by default,
   showing only pending requests (unchanged from before).
2. Tap the **History** chip. Confirm it fetches and shows only **Approved**/
   **Rejected** leaves (no Pending ones, no Approve/Reject buttons — read-only cards
   with a status chip).
3. Tap back to **Pending** — confirm it still shows the live pending list (and didn't
   lose it while you were on History).
4. Use the search box while on History — confirm it filters by employee name within
   the history list too.
5. Repeat all of the above on **Correction Requests** (Pending/History toggle,
   read-only history cards, search filtering).
6. Approve or reject a new leave/correction from Pending, then switch to History and
   pull-to-refresh — confirm the just-actioned request now appears there with the
   correct status.

## 4. Employee profile edit

1. As an employee, open **My Profile** (tap your avatar/name in the top bar).
2. Confirm a **Job Title** row appears in the details card (shows `—` if never set).
3. Tap the pencil/edit icon next to it. A dialog opens with the current title
   pre-filled.
4. Change it and tap **Save** — confirm a success toast, and the row updates
   immediately without needing to leave the screen.
5. Leave the field blank and try to save — confirm it's rejected (client-side; the
   dialog just closes/no-ops, or the server returns "Job title cannot be empty" if you
   hit the endpoint directly).
6. Close the app fully and reopen (or navigate away and back to My Profile) — confirm
   the new title persisted (fetched fresh from the server, not just cached locally).
7. Confirm **Full Name**, **Employee ID**, **Company** are still read-only (no edit
   icon) — only Job Title is editable, by design (name/phone are used as login lookup
   keys, see README/plan notes).

**curl fallback** (need an employee JWT — grab it from the app's Dio logs or
`getEmployeeToken()`):
```bash
curl http://localhost:2000/api/v1/employee/my-profile \
  -H "Authorization: Bearer <employee_jwt>"

curl -X POST http://localhost:2000/api/v1/employee/update-profile \
  -H "Authorization: Bearer <employee_jwt>" -H "Content-Type: application/json" \
  -d '{"employeePosition":"Senior Engineer"}'
```

## 5. Logout actually clears everything

This is the important one — previously the JWT token was never cleared on logout, and
cached lists could leak into a second login on the same device.

1. As an **employee**: punch in, verify biometric (so `isAuthenticated` is true),
   open a couple of tabs so data is cached, then tap **Logout**.
2. Confirm you land on the OTP/login screen.
3. Log in again as the **same** employee — should work normally.
4. More telling test — log in as a **different employee on the same company** (or a
   different company's admin) right after logging out of the first account. Confirm:
   - No stale attendance/leave/staff data flashes before the new fetches complete.
   - The Attendance tab does **not** show "Verified" biometric status immediately —
     you should have to verify again for the new session.
5. As **HR**: log in, browse Staff List / Leave Requests (data cached), tap **Logout**
   from Admin Profile. Confirm same clean landing on OTP screen, and a fresh HR login
   afterward doesn't show the previous company's staff list before its own fetch
   completes.
6. Also test the **Logout** icon on the Company Setup screen (shown right after
   creating a company, before location setup) — same expectation.
7. If you want to confirm the token itself is gone (not just UI): check secure storage
   isn't holding a stale value — easiest is to background the app immediately after
   logout, kill it from the OS app switcher, and relaunch. It should land on the OTP
   screen, not auto-log-in.

## 6. Pagination ("Load More")

Each of these now paginates at 20 items/page instead of returning everything (or, for
Audit Log, being capped at 200) in one shot.

**Audit Log**
1. Generate more than 20 audit events if you don't have that many yet (approve/reject
   a bunch of leaves and corrections, add/remove a couple of holidays, etc. — each
   produces one entry).
2. Open HR → Admin Profile → **Audit Log**. Confirm the first 20 (newest-first) load.
3. Scroll to the bottom — confirm a **Load More** button appears (only when more pages
   exist), tap it, confirm the next batch appends below the existing list (no
   duplicate entries, no flash-reload of the whole list).
4. Once you've loaded every page, confirm the **Load More** button disappears.

**Leave / Correction history**
1. Same idea: switch either screen to **History** mode, confirm Load More shows once
   there are 20+ past (non-pending) requests, and paginates correctly.

**Staff Count History**
1. HR Dashboard → **Approvals** tab (shows daily staff-count submissions).
2. Confirm it loads its own first page independently (this tab used to just show
   whatever the Dashboard tab had already fetched — it now fetches its own data).
3. If you have 20+ submissions, confirm Load More works the same way; pull-to-refresh
   resets back to page 1.
4. Confirm the Dashboard tab's weekly bar chart still shows correctly (it only ever
   needs the most recent page, unchanged).

**curl fallback** (any of the paginated endpoints, with an HR/company JWT):
```bash
curl "http://localhost:2000/api/v1/audit/log?page=2&limit=20" \
  -H "Authorization: Bearer <company_jwt>"
```
Confirm the response shape is `{ "data": { "items": [...], "page": 2, "totalPages": N,
"totalCount": N } }`, not a bare array.

## 7. PDF export redesign

The employee's Attendance Log export (History tab → red PDF icon) was rebuilt to look
like a real report instead of a plain table dump.

1. As an employee with some attendance history, open **History** and tap the PDF icon
   next to "Attendance Log" (disabled/greyed out only if there's zero data at all).
2. Share/save the generated PDF and open it. Confirm:
   - **Header**: "Attendance Report" title in the app's brand color, your name,
     company name, employee ID, and a "Generated <date>" stamp — not just a bare title.
   - A colored divider line under the header.
   - **Summary strip**: four boxes — Total, Present, Absent, Rate — with Present in
     green and Absent in red, matching the in-app summary card's numbers for the same
     data.
   - **Table**: header row in the brand color with white text; data rows alternate
     light grey / white (zebra striping); the Status column reads "Present" in green
     or "Absent" in red per row (not plain black text).
   - **Footer**: "Page X of Y" bottom-right on every page.
3. If your history spans multiple pages, confirm the footer page count is correct and
   the header block only appears once (at the top), not repeated per page.
4. Cross-check a couple of rows against the in-app log (same dates, in/out times,
   hours) to confirm nothing was mis-mapped in the rebuild.

## Wrap-up

- [ ] `flutter analyze` → no issues (should already be clean from this round)
- [ ] `cd server && npm test` → all pass
- [ ] No leftover test data skews your pagination testing before you clear it back out
