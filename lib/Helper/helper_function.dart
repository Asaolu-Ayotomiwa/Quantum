import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== DISPLAY MESSAGE TO USER ====================
/// Shows a simple alert dialog with a message
///
/// Usage:
/// ```dart
/// displayMessageToUser('Login successful!', context);
/// ```
void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Notice'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ==================== BUILD TAB ITEM ====================
/// Builds a custom tab item with icon and label
/// Used in tab bars for messages screen or other tabbed interfaces
///
/// Usage:
/// ```dart
/// _buildTabItem(ref, 'Chats', 0, selectedTab, Icons.chat)
/// ```
Widget buildTabItem(
    WidgetRef ref,
    String label,
    int index,
    int selectedTab,
    StateProvider<int> tabProvider, {
      IconData? icon,
    }) {
  final bool isSelected = selectedTab == index;

  return Expanded(
    child: GestureDetector(
      onTap: () => ref.read(tabProvider.notifier).state = index,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ==================== SHOW SNACKBAR ====================
/// Shows a snackbar at the bottom of the screen
/// More modern alternative to dialog for simple messages
///
/// Usage:
/// ```dart
/// showSnackbar(context, 'Message sent successfully!');
/// showSnackbar(context, 'Error occurred', isError: true);
/// ```
void showSnackbar(
    BuildContext context,
    String message, {
      bool isError = false,
      Duration duration = const Duration(seconds: 3),
    }) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
    ),
  );
}

// ==================== SHOW CONFIRMATION DIALOG ====================
/// Shows a confirmation dialog with Yes/No options
/// Returns true if user confirms, false if cancelled
///
/// Usage:
/// ```dart
/// final shouldDelete = await showConfirmationDialog(
///   context,
///   'Delete Property',
///   'Are you sure you want to delete this property?',
/// );
/// if (shouldDelete == true) {
///   // Delete the property
/// }
/// ```
Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
      String confirmText = 'Yes',
      String cancelText = 'Cancel',
    }) async {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

// ==================== SHOW LOADING DIALOG ====================
/// Shows a loading dialog with circular progress indicator
///
/// Usage:
/// ```dart
/// showLoadingDialog(context);
/// await someAsyncOperation();
/// Navigator.pop(context); // Close loading
/// ```
void showLoadingDialog(BuildContext context, {String? message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.green),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    ),
  );
}

// ==================== FORMAT TIME ====================
/// Formats TimeOfDay to readable string
///
/// Usage:
/// ```dart
/// final time = TimeOfDay.now();
/// final formatted = formatTime(time); // "2:30 PM"
/// ```
String formatTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

// ==================== FORMAT DATE ====================
/// Formats DateTime to readable string
///
/// Usage:
/// ```dart
/// final date = DateTime.now();
/// final formatted = formatDate(date); // "Feb 20, 2026"
/// ```
String formatDate(DateTime date) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

// ==================== VALIDATE EMAIL ====================
/// Validates email format
/// Returns error message if invalid, null if valid
///
/// Usage:
/// ```dart
/// final error = validateEmail('user@example.com');
/// if (error != null) {
///   // Show error
/// }
/// ```
String? validateEmail(String email) {
  if (email.isEmpty) {
    return 'Email is required';
  }

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(email)) {
    return 'Invalid email format';
  }

  return null;
}

// ==================== VALIDATE PASSWORD ====================
/// Validates password strength
/// Returns error message if invalid, null if valid
///
/// Usage:
/// ```dart
/// final error = validatePassword('MyPass123!');
/// if (error != null) {
///   // Show error
/// }
/// ```
String? validatePassword(String password) {
  if (password.isEmpty) {
    return 'Password is required';
  }

  if (password.length < 8) {
    return 'Password must be at least 8 characters';
  }

  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter';
  }

  if (!password.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain at least one lowercase letter';
  }

  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one number';
  }

  return null;
}

// ==================== FORMAT PRICE ====================
/// Formats number to currency string
///
/// Usage:
/// ```dart
/// final formatted = formatPrice(45000000); // "₦45,000,000"
/// ```
String formatPrice(double price) {
  if (price >= 1000000) {
    return '₦${(price / 1000000).toStringAsFixed(1)}M';
  } else if (price >= 1000) {
    return '₦${(price / 1000).toStringAsFixed(0)}K';
  }
  return '₦${price.toStringAsFixed(0)}';
}