# Testing Guide 2 — Quick Checklist

A condensed checkbox version of `TESTING_GUIDE.md`, for when you just want to tick
through everything fast instead of reading full steps. Same feature order. Check the
full guide if a box fails and you need the detailed repro steps.

## Setup

- [ ] Backend running (`cd server && npm run dev`), `http://localhost:2000/health` returns `{"status":"ok"}`
- [ ] Flutter app running and pointed at the right host
- [ ] Know how to get an OTP in dev mode (response `message` field — Twilio is off, don't touch it)

## Core flows (regression)

- [ ] Employee: login → punch in → punch out → today's log shows the entry
- [ ] HR: login → staff report loads → tap an employee → attendance detail loads

## Feature checklist

**Late / on-time**
- [ ] Late punch-in shows "Late" badge on employee log
- [ ] On-time punch-in shows no badge
- [ ] Analytics "Late This Week" reflects it

**Corrections**
- [ ] Employee submits correction → shows Pending in My Corrections
- [ ] HR sees it in Correction Requests, search-by-name filters correctly
- [ ] Approve → attendance record updates
- [ ] Reject → status updates on employee side

**Offboarding**
- [ ] Remove employee from Staff List → disappears from list
- [ ] Removed employee blocked from using the app
- [ ] Re-adding same name/number re-activates cleanly

**Multiple admins**
- [ ] Add a second admin → they can log in with full access
- [ ] Removing the last admin is blocked
- [ ] Removing a non-last admin works, they're logged out

**Analytics**
- [ ] Trend chart, pending leaves, approved-this-month, late-this-week all populated
- [ ] Hours This Week shows a nonzero number once someone's punched out this week

**Leave + calendar**
- [ ] Approved leave shows tinted on employee calendar + "On Leave" log row
- [ ] Same shows on HR's per-employee attendance detail
- [ ] Leave Requests search-by-name filters correctly

**Company settings**
- [ ] City is editable and saves
- [ ] Company name is read-only with explanation
- [ ] Login still works after a city change

**Bulk import**
- [ ] Valid CSV rows import successfully
- [ ] Bad rows (missing field, duplicate phone) fail individually without blocking good rows
- [ ] Bad header / empty file handled without a crash

**Leave balance**
- [ ] Request Leave screen shows "X of Y days remaining"
- [ ] Balance drops after an approved leave
- [ ] Over-quota request is blocked with a clear message
- [ ] HR sees the same balance on the employee's attendance detail

**Company holidays**
- [ ] HR can add a holiday, duplicate date is rejected
- [ ] Holiday shows a distinct tint on employee calendar
- [ ] HR can remove a holiday, tint clears

**Working hours / overtime**
- [ ] Worked hours show on a punched-out day ("Xh Ym worked")
- [ ] Overtime badge appears past the threshold, on both employee and HR views

**Audit log**
- [ ] Actions (approve/reject leave & correction, add/remove admin, add/remove holiday,
      add employee, bulk import, settings update) each produce a new entry
- [ ] Entries show newest-first with actor, action, detail, timestamp
- [ ] Employee account cannot open this screen

**Configurable shift hours**
- [ ] Company Settings shows a "Standard Shift Hours" field, default 9
- [ ] Changing it changes when the Overtime badge kicks in
- [ ] 0 / negative / over-24 values are rejected

**Team leave calendar**
- [ ] Holiday dates show a purple mark, leave dates show a blue mark
- [ ] Tapping a day lists who's on leave or shows the holiday name
- [ ] Empty day shows "Everyone is in on this day"

**Pending-count badges**
- [ ] Leave Requests / Corrections tiles show a red count badge when items are pending
- [ ] Badge count drops after approving/rejecting and returning to the dashboard
- [ ] No badge shown when nothing is pending

## Wrap-up

- [ ] `flutter analyze` → no issues
- [ ] `cd server && npm test` → all pass
- [ ] Test data cleaned up — only real company data remains in the database
