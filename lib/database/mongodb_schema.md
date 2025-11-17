# MongoDB Schema for Ryse Two

## Collections Overview

### 1. **cofounders** Collection
Stores team member/co-founder information.

```json
{
  "_id": ObjectId,
  "name": String,
  "email": String,
  "phone": String,
  "avatarColor": String (hex format "FFXXXXXX"),
  "createdAt": ISODate,
  "isActive": Boolean,
  "role": String,
  "bankName": String,
  "bankAccountNumber": String,
  "bankIFSC": String,
  "targetContribution": Double (default: 0)
}
```

### 2. **expenses** Collection
Stores all expense transactions (personal and company fund).

```json
{
  "_id": ObjectId,
  "description": String,
  "amount": Double,
  "paidById": String or ObjectId (hex string of co-founder._id),
  "contributorIds": Array of String (hex strings of co-founder._id),
  "category": String,
  "date": ISODate,
  "notes": String,
  "receipt": String (optional),
  "createdAt": ISODate,
  "isCompanyFund": Boolean,
  "companyName": String (for company fund expenses)
}
```

**Important Rules:**
- `paidById` must match a valid cofounder ID
- `contributorIds` should include all co-founders who contributed to this expense
- For personal expenses: `isCompanyFund = false`, payer must be set
- For company fund expenses: `isCompanyFund = true`, paidById can be null/empty
- Expense amount is equally divided among all contributors

### 3. **settlements** Collection
Stores settlement transactions between co-founders.

```json
{
  "_id": ObjectId,
  "fromId": String (hex string of co-founder._id),
  "toId": String (hex string of co-founder._id),
  "amount": Double,
  "date": ISODate,
  "notes": String,
  "settled": Boolean (default: false)
}
```

**Important Rules:**
- `fromId` = co-founder who owes money
- `toId` = co-founder who receives money
- Once settled, reduces balance calculation
- Settled transactions are historical records

### 4. **company_funds** Collection
Tracks company fund balance changes (additions/removals).

```json
{
  "_id": ObjectId,
  "amount": Double,
  "description": String,
  "type": String ("add" or "remove"),
  "date": ISODate,
  "createdAt": ISODate
}
```

**Important Rules:**
- `type: "add"` increases company fund balance
- `type: "remove"` decreases company fund balance
- All amounts are positive (type determines direction)
- Used for tracking fund transactions history

## Key Relationships

1. **CoFounders** are referenced by their ObjectId (stored as hex string)
2. **Expenses** are linked to cofounders via `paidById` and `contributorIds`
3. **Settlements** represent debt transfers between cofounders
4. **Company Funds** are independent transaction records

## Data Flow

1. Add Co-founder → MongoDB generates ObjectId, stored in cofounders
2. Add Expense → Creates expense record with contributor references
3. Calculate Balance → Sum expenses and deduct settlements
4. Record Settlement → Creates settlement record, adjusts balances
5. Add Company Fund → Tracks fund additions/removals separately

## Index Recommendations

```javascript
// cofounders
db.cofounders.createIndex({ "email": 1 }, { unique: true })
db.cofounders.createIndex({ "createdAt": -1 })

// expenses
db.expenses.createIndex({ "paidById": 1 })
db.expenses.createIndex({ "date": -1 })
db.expenses.createIndex({ "isCompanyFund": 1 })
db.expenses.createIndex({ "category": 1 })

// settlements
db.settlements.createIndex({ "fromId": 1 })
db.settlements.createIndex({ "toId": 1 })
db.settlements.createIndex({ "date": -1 })
db.settlements.createIndex({ "settled": 1 })

// company_funds
db.company_funds.createIndex({ "date": -1 })
db.company_funds.createIndex({ "type": 1 })
```

## Data Type Consistency

All IDs in MongoDB:
- MongoDB generates `ObjectId` 
- When stored in Dart models, converted to hex string via `.toHexString()`
- When retrieved, stored as `dynamic` (can be String or int)
- When queried, use `ObjectId.fromHexString()` to convert back
