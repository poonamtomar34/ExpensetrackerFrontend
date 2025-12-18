import 'package:flutter/material.dart';
import 'package:frontend/utils/MessageSnackar.dart';
import '../services/api.dart';

class CreateExpenseScreen extends StatefulWidget {
  final Map<String, dynamic>? expense;
  const CreateExpenseScreen({super.key, this.expense});

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool loading = false;
  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final expense = widget.expense!;
      titleController.text = (expense['title'] ?? '') as String;
      categoryController.text = (expense['category'] ?? '') as String;
      amountController.text = (expense['amount'] ?? '').toString();
      if (expense['expenseDate'] != null) {
        selectedDate = DateTime.parse(expense['expenseDate']).toLocal();
      } else if (expense['createdAt'] != null) {
        selectedDate = DateTime.parse(expense['createdAt']).toLocal();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final body = {
      'title': titleController.text.trim(),
      'category': categoryController.text.trim(),
      'amount': double.tryParse(amountController.text),
      'expenseDate': selectedDate.toIso8601String(),
    };

    try {
      final bool isEdit =
          widget.expense != null &&
          (widget.expense!['_id'] ?? widget.expense!['id']) != null;

      final decoded = isEdit
          ? await apiService.updateExpense(
              widget.expense!['_id'] ?? widget.expense!['id'],
              body,
            )
          : await apiService.createExpense(body);

      if (decoded['success'] == true) {
        showAppSnackBar(
          context,
          decoded['message'] ??
              (isEdit
                  ? 'Expense updated successfully'
                  : 'Expense created successfully'),
        );
        Navigator.of(context).pop(true);
      } else {
        showAppSnackBar(
          context,
          decoded['message'] ?? 'Operation failed',
          isError: true,
        );
      }
    } catch (e) {
      showAppSnackBar(
        context,
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.expense != null ? 'Edit Expense' : 'New Expense',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  if (loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.expense != null
                                  ? 'Edit your expense details'
                                  : 'Add a new expense',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Title is required'
                                    : null,
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: categoryController,
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Category is required'
                                    : null,
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: TextFormField(
                                controller: amountController,
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  labelStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Colors.black87,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) =>
                                    v == null || double.tryParse(v) == null
                                    ? 'Enter a valid amount'
                                    : null,
                              ),
                            ),

                            Container(
                              margin: const EdgeInsets.only(bottom: 32),
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.black54,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _formatDate(selectedDate),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: loading
                                        ? null
                                        : () =>
                                              Navigator.of(context).pop(false),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.black87,
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: loading ? null : submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black87,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Save',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
