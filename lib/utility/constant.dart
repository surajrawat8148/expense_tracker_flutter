import 'package:flutter/material.dart';

class AppText {
  static const appTitle = 'Smart Expense';
  static const homeTitle = 'Smart Expense';
  static const historyTitle = 'History';
  static const addExpenseTitle = 'Add Expense';
  static const statsTitle = 'Stats';
  static const settingsTitle = 'Settings';
  static const fieldTitle = 'Title';
  static const fieldAmount = 'Amount';
  static const fieldCategory = 'Category';
  static const save = 'Save';
  static const online = 'Online';
  static const offline = 'Offline';
  static const success = 'Success';
  static const syncedToFirebase = 'Synced to Firebase';
  static const storedLocally = 'Stored locally';
  static const willSyncWhenOnline = 'Will sync when online';
  static const limitExceeded = 'Limit exceeded';
  static const limitCrossText = 'Amount crosses your daily limit';
  static const duplicateTitle = 'Possible duplicate';
  static const duplicateMsg =
      'This looks similar to a recent expense. Add anyway?';
  static const cancel = 'Cancel';
  static const add = 'Add';
  static const noExpenses = 'No expenses yet';
  static const noData = 'No data';
  static const thisMonth = 'This Month: ₹';
}

class AppColors {
  static const seed = Color(0xFF6750A4);
  static const online = Colors.green;
  static const offline = Colors.red;
  static const chip = Color(0xFFBDBDBD);
  static const catFood = Color(0xFFE57373);
  static const catTravel = Color(0xFF64B5F6);
  static const catBills = Color(0xFFFFB74D);
}

class AppSizes {
  static const p8 = 8.0;
  static const p12 = 12.0;
  static const p16 = 16.0;
}

class AppIds {
  static const catFood = 'food';
  static const catTravel = 'travel';
  static const catBills = 'bills';
  static const bFood = 'b_food';
  static const bTravel = 'b_travel';
  static const bBills = 'b_bills';
}
