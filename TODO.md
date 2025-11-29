# TODO: Implement Role-Based Transactions Screen

## Tasks

- [ ] Modify lib/screens/transactions.dart to implement role-based rendering logic
- [ ] Add state variables for cooperatives, shops, and aggregated transactions
- [ ] Implement data fetching methods for each role:
  - [ ] RetailerCooperativeShop: Fetch transactions by shop ID
  - [ ] RetailerCooperative: Fetch shops by cooperative ID, fetch transactions for all shops, aggregate data
  - [ ] TradeBureau/SubCityOffice: Fetch all cooperatives and shops, group shops by cooperative
  - [ ] WoredaOffice: Fetch cooperatives by woreda ID, fetch shops, group by cooperative
- [ ] Create helper widgets for cooperative list with expandable shops
- [ ] Create helper widgets for shop buttons in RetailerCooperative view
- [ ] Implement navigation to ShopTransactionsScreen with correct data
- [ ] Handle loading states and error handling
- [ ] Ensure design consistency with shop_transactions.dart
- [ ] Test all role scenarios

## Dependent Files

- lib/screens/transactions.dart (main file to edit)
- lib/api/transactions_api.dart (already has fetchTransactionsByShopId)
- lib/api/retailer_cooperatives_api.dart (for fetching cooperatives)
- lib/api/retailer_cooperative_shops_api.dart (for fetching shops)
- lib/models/retailer_cooperative_model.dart
- lib/models/retailer_cooperative_shop_model.dart
- lib/models/transaction_model.dart

## Followup Steps

- [ ] Test the implementation with different user roles
- [ ] Verify data aggregation is correct
- [ ] Check navigation flows
- [ ] Ensure UI is responsive and matches design
