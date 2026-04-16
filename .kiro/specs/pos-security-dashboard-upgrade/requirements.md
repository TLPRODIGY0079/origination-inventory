# Requirements Document

## Introduction

This feature upgrades the Marble POS system across five areas: role-based security enforcement at both the database (Supabase RLS) and frontend levels; a visual dashboard overhaul with KPI cards, charts, and leaderboards; report export capabilities (Excel and PDF); automated low-stock notifications with browser push support; and a mobile-optimized responsive UI. The system already has a `profiles` table with a `role` column and a `business_id` column. All new capabilities must respect the existing multi-tenant architecture scoped by `business_id`.

## Glossary

- **System**: The Marble POS web application
- **RLS_Policy**: A Supabase Row Level Security policy that restricts database operations based on the authenticated user's role
- **Role**: A string value stored in `profiles.role`; one of `admin`, `manager`, `cashier`, or `viewer`
- **Admin**: A user with role `admin`; has unrestricted access to all operations within their business
- **Manager**: A user with role `manager`; can access reports and manage inventory but cannot delete sales
- **Cashier**: A user with role `cashier`; can create sales but cannot access reports or manage products
- **Viewer**: A user with role `viewer`; has read-only access to the dashboard
- **Role_Guard**: A frontend function that hides or disables UI elements based on the current user's role
- **KPI_Card**: A summary card on the dashboard displaying a single key performance indicator
- **Revenue_Chart**: A Chart.js bar chart showing daily revenue for the current week (Mon–Sun)
- **Top_Products_Widget**: A dashboard widget listing the top 5 products by quantity sold from `sale_items`
- **Leaderboard_Widget**: A dashboard widget ranking cashiers by total sales amount
- **Export_Service**: A frontend module that generates Excel files via SheetJS (xlsx) and PDF files via jsPDF from sales data
- **Low_Stock_Monitor**: A frontend module that polls the `variants` table every 5 seconds for items with `qty < 10`
- **Notification_Banner**: An in-app UI alert box listing low-stock products
- **Push_Notification**: A browser Web Push API notification sent when low-stock items are detected
- **Staff_Manager**: An admin-only UI panel for inviting staff members by email and assigning them a role, scoped to the admin's `business_id`
- **Sticky_Checkout_Bar**: A fixed-position bar at the bottom of the POS screen on mobile showing cart total and checkout button

---

## Requirements

### Requirement 1: Role-Based Database Security (RLS Policies)

**User Story:** As a system administrator, I want database-level role enforcement so that unauthorized users cannot manipulate sales or product data even if they bypass the frontend.

#### Acceptance Criteria

1. THE RLS_Policy SHALL restrict `DELETE` operations on the `sales` table to users whose `profiles.role` is `admin` and whose `profiles.business_id` matches the row's `business_id`
2. THE RLS_Policy SHALL restrict `UPDATE` operations on the `products` table to users whose `profiles.role` is `admin` or `manager` and whose `profiles.business_id` matches the row's `business_id`
3. THE RLS_Policy SHALL restrict `INSERT` operations on the `sales` table to users whose `profiles.role` is `admin` or `cashier` and whose `profiles.business_id` matches the row's `business_id`
4. THE RLS_Policy SHALL restrict `SELECT` operations on all tables to rows where `business_id` matches the authenticated user's `profiles.business_id`
5. WHEN a user attempts a database operation not permitted by their role, THE RLS_Policy SHALL reject the operation and return a permission-denied error
6. THE RLS_Policy SHALL use a Postgres helper function `get_my_role()` that reads `profiles.role` for the current `auth.uid()` to avoid repeated subqueries

---

### Requirement 2: Frontend Role Guards

**User Story:** As a business owner, I want the UI to hide or disable actions that a user's role does not permit, so that staff cannot accidentally trigger unauthorized operations.

#### Acceptance Criteria

1. WHEN the current user's role is `cashier` or `viewer`, THE Role_Guard SHALL hide all navigation items and UI elements that are designated admin-only or manager-only
2. WHEN the current user's role is `viewer`, THE Role_Guard SHALL disable all buttons that trigger write operations (create, update, delete)
3. WHEN the current user's role is `cashier`, THE Role_Guard SHALL hide the Products edit and delete buttons, the Reports section, and the Staff management panel
4. WHEN the current user's role is `manager`, THE Role_Guard SHALL hide the Staff management panel and the delete-sale button
5. WHEN the current user's role is `admin`, THE Role_Guard SHALL display all navigation items and UI elements without restriction
6. THE Role_Guard SHALL evaluate role on every page navigation and re-apply visibility rules without requiring a page reload

---

### Requirement 3: Staff Management

**User Story:** As an admin, I want to invite staff members by email and assign them a role, so that I can control who has access to my business's POS system.

#### Acceptance Criteria

1. WHEN an admin submits the Staff_Manager form with a valid email and a role of `manager`, `cashier`, or `viewer`, THE System SHALL call the Supabase `auth.admin.inviteUserByEmail` API and create a `profiles` row with the specified role and the admin's `business_id`
2. WHEN an admin submits the Staff_Manager form with an email that is already registered, THE System SHALL display an error message indicating the email is already in use
3. WHEN an admin submits the Staff_Manager form with an empty email field, THE System SHALL prevent submission and display a validation error
4. THE Staff_Manager SHALL display a list of all staff members scoped to the admin's `business_id`, showing name, email, role, and status
5. WHEN an admin changes a staff member's role using the Staff_Manager, THE System SHALL update `profiles.role` for that staff member in Supabase
6. WHEN a non-admin user attempts to access the Staff_Manager panel, THE Role_Guard SHALL prevent access and display an unauthorized message

---

### Requirement 4: Dashboard KPI Cards

**User Story:** As a manager or admin, I want to see today's sales total, this week's sales total, and the count of low-stock items at a glance on the dashboard.

#### Acceptance Criteria

1. WHEN the dashboard loads, THE System SHALL query the `sales` table and display a KPI_Card showing the sum of `total_amount` for sales where `date_str` equals today's date
2. WHEN the dashboard loads, THE System SHALL query the `sales` table and display a KPI_Card showing the sum of `total_amount` for sales where `date_str` falls within the current Mon–Sun week
3. WHEN the dashboard loads, THE System SHALL query the `variants` table and display a KPI_Card showing the count of rows where `qty < 10`
4. WHEN a KPI_Card value is zero, THE System SHALL display `K0.00` for monetary values and `0` for counts rather than leaving the card blank
5. WHEN the dashboard is visible and data changes, THE System SHALL refresh KPI_Card values without a full page reload upon the next dashboard navigation

---

### Requirement 5: Revenue Bar Chart

**User Story:** As a manager or admin, I want to see a daily revenue breakdown for the current week as a bar chart, so that I can identify high and low sales days.

#### Acceptance Criteria

1. WHEN the dashboard loads, THE Revenue_Chart SHALL render a Chart.js bar chart with seven bars representing Monday through Sunday of the current ISO week
2. THE Revenue_Chart SHALL calculate each bar's value by summing `total_amount` from the `sales` table for the corresponding `date_str`
3. WHEN a day has no sales, THE Revenue_Chart SHALL render that bar with a value of zero
4. THE Revenue_Chart SHALL use the existing CSS design token `--ac` (`#007AFF`) as the bar fill color to match the app's visual theme
5. WHEN the dashboard section is re-navigated to, THE Revenue_Chart SHALL destroy the previous Chart.js instance before creating a new one to prevent canvas reuse errors

---

### Requirement 6: Top Products Widget

**User Story:** As a manager or admin, I want to see which products sell the most by quantity, so that I can make informed restocking decisions.

#### Acceptance Criteria

1. WHEN the dashboard loads, THE Top_Products_Widget SHALL query the `sale_items` table, group by `product_name`, sum `qty`, and display the top 5 results ordered by total quantity descending
2. THE Top_Products_Widget SHALL display each entry with the product name and total quantity sold
3. WHEN fewer than 5 distinct products have been sold, THE Top_Products_Widget SHALL display only the available products without padding with empty rows

---

### Requirement 7: Cashier Leaderboard

**User Story:** As a manager or admin, I want to see which cashiers are generating the most revenue, so that I can recognize top performers.

#### Acceptance Criteria

1. WHEN the dashboard loads, THE Leaderboard_Widget SHALL query the `sales` table, group by `cashier_name`, sum `total_amount`, and display results ordered by total amount descending
2. THE Leaderboard_Widget SHALL display each entry with the cashier's name and their total sales amount formatted as currency
3. WHEN no sales exist, THE Leaderboard_Widget SHALL display an empty-state message

---

### Requirement 8: Export to Excel

**User Story:** As a manager or admin, I want to export the sales report to an Excel file, so that I can analyze data in spreadsheet tools.

#### Acceptance Criteria

1. WHEN a user with role `admin` or `manager` clicks the Export Excel button, THE Export_Service SHALL use the SheetJS (`xlsx`) library to generate a `.xlsx` file from the current `sales` table data scoped to the user's `business_id`
2. THE Export_Service SHALL include the following columns in the Excel export: Receipt No, Date, Cashier, Customer, Items, Total Amount, Payment Method
3. WHEN the export is triggered, THE Export_Service SHALL prompt the browser to download the file with a filename in the format `sales-export-YYYY-MM-DD.xlsx`
4. WHEN a user with role `cashier` or `viewer` attempts to trigger the export, THE Role_Guard SHALL hide the export buttons so the action is not available

---

### Requirement 9: Export to PDF

**User Story:** As a manager or admin, I want to export the sales report to a PDF file, so that I can share or print formatted reports.

#### Acceptance Criteria

1. WHEN a user with role `admin` or `manager` clicks the Export PDF button, THE Export_Service SHALL use the jsPDF library to generate a `.pdf` file from the current `sales` table data scoped to the user's `business_id`
2. THE Export_Service SHALL include a report header with the business name, export date, and a summary of total sales amount
3. THE Export_Service SHALL render each sale as a row in a table within the PDF with columns: Receipt No, Date, Cashier, Total Amount, Payment Method
4. WHEN the export is triggered, THE Export_Service SHALL prompt the browser to download the file with a filename in the format `sales-report-YYYY-MM-DD.pdf`

---

### Requirement 10: Low Stock Detection and In-App Notifications

**User Story:** As a manager or admin, I want to be automatically alerted when product stock falls below 10 units, so that I can reorder before running out.

#### Acceptance Criteria

1. WHEN the application is active, THE Low_Stock_Monitor SHALL poll the `variants` table every 5 seconds and retrieve all rows where `qty < 10` scoped to the user's `business_id`
2. WHEN the Low_Stock_Monitor detects one or more low-stock variants, THE Notification_Banner SHALL display an alert box listing each affected product name and current quantity
3. WHEN the Low_Stock_Monitor detects no low-stock variants, THE Notification_Banner SHALL be hidden
4. WHEN the low-stock list changes between polls (items added or resolved), THE Notification_Banner SHALL update its content to reflect the current state
5. IF the Low_Stock_Monitor encounters a Supabase query error, THEN THE System SHALL log the error to the console and continue polling without crashing

---

### Requirement 11: Browser Push Notifications for Low Stock

**User Story:** As a manager or admin, I want to receive browser push notifications when stock is low, so that I am alerted even when the POS tab is not in focus.

#### Acceptance Criteria

1. WHEN the application loads for a user with role `admin` or `manager`, THE System SHALL request browser notification permission using the Web Notifications API
2. WHEN the Low_Stock_Monitor detects newly low-stock items that were not low-stock in the previous poll, THE System SHALL send a browser Push_Notification listing the newly affected product names
3. WHEN the user has denied notification permission, THE System SHALL not attempt to send Push_Notifications and SHALL not display a permission prompt again in the same session
4. WHERE browser push notifications are supported, THE System SHALL include the product name and current quantity in the Push_Notification body

---

### Requirement 12: Mobile-Responsive Dashboard Layout

**User Story:** As a cashier or manager using a mobile device, I want the dashboard and POS to be fully usable on a small screen, so that I can operate the system without a desktop.

#### Acceptance Criteria

1. WHEN the viewport width is 768px or less, THE System SHALL render the dashboard stats grid in a 2-column layout
2. WHEN the viewport width is 480px or less, THE System SHALL render the dashboard stats grid in a single-column layout
3. WHEN the viewport width is 768px or less, THE System SHALL render the POS product grid in a 2-column layout
4. WHEN the viewport width is 768px or less, THE System SHALL render all primary action buttons as full-width with a minimum height of 48px to ensure adequate tap targets
5. WHEN the viewport width is 768px or less and the POS cart is visible, THE Sticky_Checkout_Bar SHALL be fixed to the bottom of the viewport showing the cart total and a checkout button
6. WHEN the viewport width is greater than 768px, THE Sticky_Checkout_Bar SHALL not be rendered, and the standard cart panel layout SHALL be used instead
