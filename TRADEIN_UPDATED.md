# ✅ Trade-In Feature Updated

## New Trade-In System

The Trade-in page now works exactly as you described:

### Form Layout (Two Columns)

**Left Column - TRADE-IN DEVICE**:
- Device Name (e.g., iPhone 11)
- IMEI/Serial
- Trade-In Value (K)

**Right Column - NEW DEVICE**:
- Select Variant (SKU) dropdown
  - Shows all in-stock variants
  - Format: "Product Name — SKU (Price)"
  - Example: "iPhone 11 — IPH-WH12-8215 (K5,700.00)"
- New Device IMEI (optional)

**Bottom Section**:
- Customer Name
- **Net Payment** (auto-calculated)
  - Formula: New Device Price - Trade-In Value
  - Displayed prominently in gold color

### How It Works

1. **Customer brings old device**:
   - Enter device name
   - Enter IMEI/Serial
   - Set trade-in value

2. **Customer selects new device**:
   - Choose from dropdown (only shows in-stock items)
   - Each option shows: Product — SKU (Price)

3. **Net Payment auto-calculates**:
   - Updates instantly when you:
     - Select a new device
     - Change trade-in value
   - Shows: New Price - Trade-in Value

4. **Enter customer name**

5. **Click "Process Trade-In"**

### Recent Trade-Ins Table

Shows history with columns:
- Receipt
- Date
- Customer
- Trade-In Device
- Trade-In Value
- New Device
- Net Payment

## Example Scenario

**Customer trades in iPhone X for iPhone 11**:

1. Trade-In Device:
   - Device: iPhone X
   - IMEI: 353912110001
   - Trade-In Value: K2,500

2. New Device:
   - Select: iPhone 11 — IPH-WH12-8215 (K5,700.00)

3. Net Payment:
   - K5,700 - K2,500 = **K3,200**

4. Customer pays K3,200 and gets iPhone 11

## Features

✅ **Two-column layout** (Trade-in | New Device)  
✅ **Auto-calculated net payment**  
✅ **Dropdown shows in-stock variants only**  
✅ **Real-time price calculation**  
✅ **Clean, professional UI**  
✅ **Recent trade-ins table**  

## Validation

- Customer name required
- Old device name required
- New device selection required
- Trade-in value must be > 0

## Next Steps (Database Integration)

To make it persist data, you'll need to:

### 1. Create trade_ins table
```sql
CREATE TABLE trade_ins (
  id TEXT PRIMARY KEY,
  receipt_no TEXT UNIQUE,
  customer_name TEXT NOT NULL,
  old_device TEXT NOT NULL,
  old_imei TEXT,
  trade_in_value DECIMAL(10,2) NOT NULL,
  new_variant_id TEXT REFERENCES variants(id),
  new_device_imei TEXT,
  new_device_price DECIMAL(10,2) NOT NULL,
  net_payment DECIMAL(10,2) NOT NULL,
  business_id UUID REFERENCES profiles(business_id),
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### 2. Update the save function
Replace the current `processTradeinBtn` click handler with:
```javascript
const { error } = await supabaseClient.from('trade_ins').insert([{
  id: uid(),
  receipt_no: nextReceipt(),
  customer_name: customer,
  old_device: oldDevice,
  old_imei: oldIMEI,
  trade_in_value: tradeValue,
  new_variant_id: newVariantId,
  new_device_imei: $('tiNewIMEI').value.trim(),
  new_device_price: newPrice,
  net_payment: netPayment,
  business_id: currentUser.business_id,
  created_by: currentUser.id
}]);
```

### 3. Load and display trade-ins
Add to `loadDB()` and render in table.

## Testing

1. **Clear cache**: Ctrl + Shift + Delete
2. **Hard refresh**: Ctrl + F5
3. **Click "Trade-in"** in sidebar
4. **Click "New Trade-in"**
5. **Fill in trade-in device** (name, IMEI, value)
6. **Select new device** from dropdown
7. **Watch net payment calculate** automatically
8. **Enter customer name**
9. **Click "Process Trade-In"**

## UI Preview

```
┌─────────────────────────────────────────────────────────┐
│  New Trade-In                                      [X]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────┐  ┌──────────────────────┐   │
│  │ TRADE-IN DEVICE      │  │ NEW DEVICE           │   │
│  │                      │  │                      │   │
│  │ Device Name          │  │ Select Variant (SKU) │   │
│  │ [iPhone X          ] │  │ [iPhone 11 — IPH...] │   │
│  │                      │  │                      │   │
│  │ IMEI/Serial          │  │ New Device IMEI      │   │
│  │ [353912110001      ] │  │ [optional          ] │   │
│  │                      │  │                      │   │
│  │ Trade-In Value (K)   │  │                      │   │
│  │ [2500.00           ] │  │                      │   │
│  └──────────────────────┘  └──────────────────────┘   │
│                                                         │
│  Customer Name                                          │
│  [John Doe                                           ]  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │           Net Payment: K3,200.00                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  [Cancel]                    [Process Trade-In]        │
└─────────────────────────────────────────────────────────┘
```

## Summary

✅ **Two-column layout** matching your design  
✅ **Auto-calculating net payment**  
✅ **Dropdown with in-stock variants**  
✅ **Clean, professional interface**  
✅ **Ready for database integration**  

The UI is complete and functional - just needs database setup to persist trade-ins!
