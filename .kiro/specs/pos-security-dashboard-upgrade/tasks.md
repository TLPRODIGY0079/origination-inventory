# Implementation Plan: POS Security & Dashboard Upgrade

## Overview

Incremental implementation across five areas: RLS policies, frontend role guards + staff management, dashboard analytics, export service, and low-stock notifications + mobile UI. Each task builds on the previous and ends with wired, working functionality.

## Tasks

- [ ] 1. Apply Supabase RLS policies and helper functions
  - Create `get_my_role()` and `get_my_business_id()` SECURITY DEFINER functions in Supabase SQL editor
  - Add `business_id` column to `sales`, `products`, and `variants` tables if not present
  - Write and apply RLS policies for `sales` (SELECT all, INSERT admin+cashier, UPDATE admin, DELETE admin)
  - Write and apply RLS policies for `products` (SELECT all, INSERT/UPDATE admin+manager, DELETE admin)
  - Write and apply RLS policies for `variants` (SELECT all, INSERT/UPDATE admin+manager)
  - Write and apply RLS policy for `profiles` (SELECT own row + admin same business)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [ ]* 1.1 Write integration property tests for RLS role enforcement
    - **Property 1: RLS role enforcement is exhaustive**
    - **Validates: Requirements 1.1, 1.2, 1.3**
    - Use a Supabase test project; generate random role/operation pairs and assert permit/deny matches policy matrix

  - [ ]* 1.2 Write integration property test for RLS business_id isolation
    - **Property 2: RLS business_id isolation**
    - **Validates: Requirements 1.4**
    - Insert rows for two business_ids; verify SELECT as user A returns only business A rows

- [ ] 2. Implement frontend Role Guard module
  - Add `data-role-min` and `data-role-allow` attributes to existing nav items and action buttons in `index.html`
  - Implement `applyRoleGuards(role)` function that reads these attributes and sets `display:none` / `disabled` accordingly
  - Define role hierarchy: `viewer=0, cashier=1, manager=2, admin=3`
  - Call `applyRoleGuards(currentUser.role)` at the end of every `navigate()` call
  - Hide Reports nav item and export buttons for cashier/viewer roles
  - Hide Staff nav item for non-admin roles
  - Hide delete-sale button for non-admin roles
  - Disable all write buttons (add product, edit product, new sale) for viewer role
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [ ]* 2.1 Write property test for role guard visibility completeness
    - **Property 3: Role guard visibility is role-determined**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
    - Use fast-check to generate random roles; assert visible element set matches expected set for each role

  - [ ]* 2.2 Write property test for role guard idempotence
    - **Property 4: Role guard is idempotent**
    - **Validates: Requirements 2.6**
    - Call `applyRoleGuards(role)` twice with same role; assert DOM state is identical after both calls

- [ ] 3. Add backend `/invite-staff` endpoint and Staff Manager UI
  - Add `POST /invite-staff` to `backend/server.js` that calls `supabase.auth.admin.inviteUserByEmail` and upserts a `profiles` row with the given role and `business_id`
  - Return 409 if email already exists, 400 for missing fields
  - Add "Staff" section to sidebar nav with `data-role-allow="admin"` attribute
  - Implement `renderStaffManager()` that renders the staff list and invite form inside `#mainContent`
  - Implement `loadStaffList()` — SELECT from `profiles` WHERE `business_id` = currentUser.business_id
  - Implement `inviteStaff(email, role)` — POST to `/invite-staff`, show success/error toast
  - Implement `updateStaffRole(userId, role)` — UPDATE `profiles.role` via supabaseClient
  - Wire invite form submit and role-change dropdown to the above functions
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

  - [ ]* 3.1 Write property test for staff list business scoping
    - **Property 5: Staff list is business-scoped**
    - **Validates: Requirements 3.4**
    - Mock supabaseClient; generate profiles with mixed business_ids; assert only matching ones are returned

  - [ ]* 3.2 Write unit tests for invite staff validation
    - Test empty email returns validation error (edge case — Req 3.3)
    - Test duplicate email returns error message (edge case — Req 3.2)

- [ ] 4. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Implement Dashboard KPI cards, Revenue Chart, Top Products, and Leaderboard
  - Add Chart.js CDN script tag to `index.html` head
  - Implement `getKPIs()` — three parallel Supabase queries: today's sales sum, week's sales sum, low-stock count
  - Implement `getWeeklyRevenue()` — query sales for current Mon–Sun week, aggregate by `date_str` into array[7]
  - Implement `getTopProducts()` — query `sale_items`, group by `product_name`, sum `qty`, return top 5
  - Implement `getLeaderboard()` — query `sales`, group by `cashier_name`, sum `total_amount`, order desc
  - Implement `renderRevenueChart(data)` — destroy existing Chart.js instance if present, create new bar chart using `--ac` color
  - Update `renderDashboard()` to call all four functions and render KPI cards, chart canvas, top products list, and leaderboard table
  - Ensure KPI cards show `K0.00` / `0` when values are zero
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1, 6.2, 6.3, 7.1, 7.2, 7.3_

  - [ ]* 5.1 Write property test for KPI sum correctness
    - **Property 6: KPI card sums are correct**
    - **Validates: Requirements 4.1, 4.2, 4.3**
    - Use fast-check to generate random sales arrays with known totals; assert `getKPIs()` returns correct sums

  - [ ]* 5.2 Write property test for weekly revenue aggregation
    - **Property 7: Weekly revenue chart data matches sales aggregation**
    - **Validates: Requirements 5.1, 5.2, 5.3**
    - Generate random sales spread across a week; assert `getWeeklyRevenue()` returns 7 entries with correct per-day totals

  - [ ]* 5.3 Write property test for top products ranking
    - **Property 8: Top products ranking is correct**
    - **Validates: Requirements 6.1, 6.2, 6.3**
    - Generate random sale_items; assert `getTopProducts()` returns ≤5 entries ordered by qty desc with correct sums

  - [ ]* 5.4 Write property test for leaderboard ranking
    - **Property 9: Leaderboard ranking is correct**
    - **Validates: Requirements 7.1, 7.2**
    - Generate random sales with multiple cashiers; assert `getLeaderboard()` returns correct order and sums

  - [ ]* 5.5 Write unit test for chart canvas reuse prevention
    - Simulate two `renderDashboard()` calls; assert previous Chart.js instance is destroyed before new one is created (Req 5.5)

- [ ] 6. Implement Export Service (Excel and PDF)
  - Add SheetJS CDN script tag to `index.html` head
  - Add jsPDF CDN script tag to `index.html` head
  - Implement `exportToExcel(sales)` — build worksheet with columns: Receipt No, Date, Cashier, Customer, Items, Total Amount, Payment Method; trigger download as `sales-export-YYYY-MM-DD.xlsx`
  - Implement `exportToPDF(sales)` — build jsPDF document with header (business name, export date, total), table of sales rows; trigger download as `sales-report-YYYY-MM-DD.pdf`
  - Add Export Excel and Export PDF buttons to the Reports/History section with `data-role-min="manager"` attribute
  - Wire buttons to `exportToExcel` and `exportToPDF` using the currently loaded sales data
  - Show toast "No data to export" and skip download when sales array is empty
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 9.1, 9.2, 9.3, 9.4_

  - [ ]* 6.1 Write property test for Excel export completeness
    - **Property 10: Excel export contains all sales rows with correct columns**
    - **Validates: Requirements 8.1, 8.2**
    - Use fast-check to generate random sales arrays; assert workbook has correct headers and one row per sale

  - [ ]* 6.2 Write property test for PDF export completeness
    - **Property 11: PDF export contains all sales rows with correct header**
    - **Validates: Requirements 9.1, 9.2, 9.3**
    - Generate random sales arrays; assert PDF text content includes business name, date, total, and all sale rows

  - [ ]* 6.3 Write unit tests for export edge cases
    - Empty sales array shows toast and skips download (Req 8.1, 9.1)
    - Filename format matches `sales-export-YYYY-MM-DD.xlsx` and `sales-report-YYYY-MM-DD.pdf` (Req 8.3, 9.4)

- [ ] 7. Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Implement Low Stock Monitor and Notification Banner
  - Add a `#lowStockBanner` div to the top of `#mainContent` (hidden by default via `display:none`)
  - Implement `renderNotificationBanner(items)` — show banner with list of `{product_name, qty}` when items.length > 0, hide when empty
  - Implement `checkLowStock()` — query `variants` WHERE `qty < 10` AND `business_id` = currentUser.business_id; call `renderNotificationBanner`; compute diff vs previous poll; call `sendPushNotification` for new items; catch errors with `console.error`
  - Implement `startLowStockMonitor()` — call `checkLowStock()` immediately, then `setInterval(checkLowStock, 5000)`
  - Implement `stopLowStockMonitor()` — `clearInterval` on the stored interval ID
  - Call `startLowStockMonitor()` after successful login/session restore for admin and manager roles
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ]* 8.1 Write property test for notification banner state
    - **Property 12: Notification banner reflects current low-stock state**
    - **Validates: Requirements 10.2, 10.3, 10.4**
    - Use fast-check to generate random low-stock item lists; assert banner renders exactly those items; assert banner hidden when list is empty

  - [ ]* 8.2 Write unit test for low-stock monitor error handling
    - Mock supabaseClient to throw; assert `console.error` is called and interval is not cleared (Req 10.5)

- [ ] 9. Implement Browser Push Notifications for Low Stock
  - Implement `requestPushPermission()` — call `Notification.requestPermission()` once on login for admin/manager; store result in a session variable
  - Implement `sendPushNotification(newItems)` — if permission is `granted` and `newItems.length > 0`, create `new Notification(...)` with title "Low Stock Alert" and body listing product names and quantities
  - Integrate `sendPushNotification` into `checkLowStock()` diff logic (only fire for items not present in previous poll)
  - Skip permission request and notification if `Notification` API is not available in the browser
  - _Requirements: 11.1, 11.2, 11.3, 11.4_

  - [ ]* 9.1 Write property test for push notification diff logic
    - **Property 13: Push notification fires only for newly low-stock items**
    - **Validates: Requirements 11.2**
    - Use fast-check to generate pairs of (previous, current) low-stock lists; assert notification is sent iff current has items not in previous

  - [ ]* 9.2 Write unit tests for push notification edge cases
    - Permission denied: assert no `new Notification()` call is made (Req 11.3)
    - Permission granted, no new items: assert no notification sent (Req 11.2)
    - Notification API unavailable: assert no error thrown (Req 11.4)

- [ ] 10. Implement Mobile UI Optimizations
  - Update CSS media query `@media(max-width:768px)` in `index.html`:
    - Set `.stats-grid` to `grid-template-columns: repeat(2, 1fr)`
    - Set `.product-grid` to `grid-template-columns: repeat(2, 1fr)`
    - Set primary action buttons (`btn-primary`, `.btn-success`) to `width: 100%; min-height: 48px`
  - Update CSS media query `@media(max-width:480px)`:
    - Set `.stats-grid` to `grid-template-columns: 1fr`
  - Add `#stickyCheckoutBar` element to the POS section HTML: fixed bottom bar with cart total and checkout button
  - Show `#stickyCheckoutBar` only when viewport ≤ 768px (CSS `display:none` on larger screens via media query)
  - Wire `#stickyCheckoutBar` checkout button to the existing `checkout()` function
  - Update cart total display in `#stickyCheckoutBar` whenever `renderCart()` is called
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6_

- [ ] 11. Final Checkpoint — Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP
- Each task references specific requirements for traceability
- RLS policies (Task 1) must be applied before testing any data access from the frontend
- The `/invite-staff` backend endpoint requires the `SUPABASE_SERVICE_KEY` env var already present in `backend/server.js`
- Property tests use fast-check; unit tests use plain JS assertions or Jest
- All CDN libraries are added as `<script>` tags — no build step required
