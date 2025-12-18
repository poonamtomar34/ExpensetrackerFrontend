import 'package:flutter/material.dart';
import 'package:frontend/screens/LogOut.dart';
import 'package:frontend/screens/ViewSummaryScreen.dart';
import 'package:frontend/utils/MessageSnackar.dart';
import '../services/api.dart';
import 'CreateExpenseScreen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => ExpenseListScreenState();
}

class ExpenseListScreenState extends State<ExpenseListScreen> {
  Future<Map<String, dynamic>>? expensesFuture;
  final ApiService apiService = ApiService();

  bool selectionMode = false;
  final Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    expensesFuture = loadExpenses();
  }

  Future<Map<String, dynamic>> loadExpenses() async {
    try {
      return await apiService.getExpenses();
    } catch (error) {
      return {'success': false, 'data': []};
    }
  }

  void refreshExpenses() {
    setState(() {
      expensesFuture = loadExpenses();
    });
  }

  void startSelection(String expenseId) {
    setState(() {
      selectionMode = true;
      selectedIds.add(expenseId);
    });
  }

  void toggleSelection(String expenseId) {
    setState(() {
      if (selectedIds.contains(expenseId)) {
        selectedIds.remove(expenseId);
        if (selectedIds.isEmpty) {
          selectionMode = false;
        }
      } else {
        selectedIds.add(expenseId);
      }
    });
  }

Future<void> deleteSelected() async {
  if (selectedIds.isEmpty) return;

  try {
    final response =
        await apiService.deleteExpensesBulk(selectedIds.toList());

    if (response['success'] == true) {
      showAppSnackBar(
        context,
        '${selectedIds.length} expense(s) deleted successfully',
      );

      setState(() {
        selectionMode = false;
        selectedIds.clear();
        expensesFuture = loadExpenses();
      });
    } else {
      showAppSnackBar(
        context,
        response['message'] ?? 'Failed to delete expenses',
        isError: true,
      );
    }
  } catch (e) {
    showAppSnackBar(
      context,
      'Something went wrong. Please try again.',
      isError: true,
    );
  }
}


  String formatDate(String isoDate) {
    try {
      final DateTime dateTime = DateTime.parse(isoDate).toLocal();
      return '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    } catch (error) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    selectionMode
                        ? '${selectedIds.length} selected'
                        : 'Expenses',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bar_chart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ExpenseSummaryView(apiService: apiService),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const LogoutScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: expensesFuture,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot,
                ) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
        
                  final List expensesList =
                      snapshot.data!['data'] ?? [];
        
                  if (expensesList.isEmpty) {
                    return const Center(child: Text('No expenses'));
                  }
        
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: expensesList.length,
                    separatorBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      final Map<String, dynamic> expenseItem =
                          expensesList[index];
        
                      final String? expenseId =
                          expenseItem['_id']?.toString();
        
                      if (expenseId == null) {
                        return const SizedBox();
                      }
        
                      final bool isSelected =
                          selectedIds.contains(expenseId);
        
                      return GestureDetector(
                        onLongPress: () => startSelection(expenseId),
                        onTap: () async {
                          if (selectionMode) {
                            toggleSelection(expenseId);
                          } else {
                            final bool? updated =
                                await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CreateExpenseScreen(
                                  expense: expenseItem,
                                ),
                              ),
                            );
                            if (updated == true) {
                              refreshExpenses();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.grey.shade100
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.receipt),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expenseItem['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(expenseItem['category'] ?? ''),
                                    Text(
                                      formatDate(
                                        expenseItem['expenseDate'] ??
                                            expenseItem['createdAt'],
                                      ),
                                      style:
                                          const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${expenseItem['amount']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (selectionMode)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: selectionMode
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.delete),
                        label:
                            Text('Delete (${selectedIds.length})'),
                        onPressed: deleteSelected,
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Expense'),
                        onPressed: () async {
                          final bool? created =
                              await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const CreateExpenseScreen(),
                            ),
                          );
                          if (created == true) {
                            refreshExpenses();
                          }
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
