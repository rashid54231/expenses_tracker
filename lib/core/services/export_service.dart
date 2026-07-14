import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/transactions/data/transaction_repository.dart';

class ExportService {
  final TransactionRepository _repository;

  ExportService(this._repository);

  Future<void> exportToCSV() async {
    final transactions = await _repository.getAllTransactions();
    
    List<List<dynamic>> rows = [
      ["Date", "Type", "Amount", "Note", "Category ID"]
    ];

    for (var tx in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(tx.date),
        tx.type.toUpperCase(),
        tx.amount,
        tx.note ?? "",
        tx.categoryId,
      ]);
    }

    String csvData = csv.encode(rows);
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/expenses_report_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);
    
    // In a real app, use share_plus to share the file.
    // For now, we just print the path.
    print("CSV saved to: $path");
  }

  Future<void> exportToPDF() async {
    final transactions = await _repository.getAllTransactions();
    
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Expense Tracker Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Date', 'Type', 'Amount', 'Note'],
                data: transactions.map((tx) => [
                  DateFormat('yyyy-MM-dd').format(tx.date),
                  tx.type.toUpperCase(),
                  "PKR ${tx.amount}",
                  tx.note ?? "",
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    // This will open a print preview / save to PDF dialog on mobile.
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'expense_report.pdf'
    );
  }
}
