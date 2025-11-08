import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/invoice.models.dart';
import '../../../core/utils/logger.dart';

class InvoicePdfService {
  /// Generate a beautiful commercial invoice PDF
  static Future<File> generateInvoicePdf(InvoiceDetailsData invoice) async {
    final pdf = pw.Document();
    final deliveryDate = DateTime.parse(invoice.expectedDeliveryDate);
    final createdDate = DateTime.parse(invoice.createdAt);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Calculate totals
    final subtotal = invoice.items.fold<double>(0.0, (sum, item) => sum + item.total);
    final discountPercent = invoice.discount ?? 0.0;
    final discountAmount = invoice.discountAmount ?? (subtotal * discountPercent / 100);
    final total = invoice.totalAmount ?? (subtotal - discountAmount);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(invoice, createdDate, dateFormat),
          pw.SizedBox(height: 30),

          // Organization and Party Details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildFromSection(invoice),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildToSection(invoice),
              ),
            ],
          ),
          pw.SizedBox(height: 30),

          // Invoice Details
          _buildInvoiceInfo(invoice, deliveryDate, dateFormat),
          pw.SizedBox(height: 30),

          // Items Table
          _buildItemsTable(invoice.items),
          pw.SizedBox(height: 30),

          // Pricing Summary
          _buildPricingSummary(subtotal, discountPercent, discountAmount, total),
          pw.SizedBox(height: 40),

          // Footer
          _buildFooter(),
        ],
      ),
    );

    // Save PDF to SalesSphere folder
    final file = await _savePdfToSalesSpherFolder(invoice.invoiceNumber, await pdf.save());
    return file;
  }

  /// Get or create the SalesSphere/Invoices folder and save the PDF
  static Future<File> _savePdfToSalesSpherFolder(String invoiceNumber, List<int> pdfBytes) async {
    try {
      Directory? baseDir;

      // Get the appropriate base directory based on platform
      if (Platform.isAndroid) {
        // Request storage permission for Android
        final hasPermission = await _requestStoragePermission();

        if (hasPermission) {
          // Try to save to Downloads/SalesSphere/Invoices (easily accessible)
          try {
            // Get external storage directory to navigate to Downloads
            final externalDir = await getExternalStorageDirectory();

            if (externalDir != null) {
              // Navigate to the public Downloads directory
              // From: /storage/emulated/0/Android/data/com.example.app/files
              // To: /storage/emulated/0/Download
              final pathSegments = externalDir.path.split('/');
              final storageIndex = pathSegments.indexOf('Android');

              if (storageIndex > 0) {
                final publicStoragePath = pathSegments.sublist(0, storageIndex).join('/');
                final downloadsPath = '$publicStoragePath/Download/SalesSphere/Invoices';

                final salesSphereDir = Directory(downloadsPath);

                // Create the directory if it doesn't exist
                if (!await salesSphereDir.exists()) {
                  await salesSphereDir.create(recursive: true);
                  AppLogger.d('Created SalesSphere/Invoices folder at: ${salesSphereDir.path}');
                }

                baseDir = salesSphereDir;
                AppLogger.i('Using Downloads folder for PDF storage');
              }
            }
          } catch (e) {
            AppLogger.w('Could not access Downloads folder: $e');
          }
        } else {
          AppLogger.w('Storage permission not granted, using app-specific directory');
        }

        // Fallback to external storage directory if Downloads is not accessible
        if (baseDir == null) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final salesSphereDir = Directory('${externalDir.path}/SalesSphere/Invoices');

            if (!await salesSphereDir.exists()) {
              await salesSphereDir.create(recursive: true);
              AppLogger.d('Created SalesSphere/Invoices folder at: ${salesSphereDir.path}');
            }

            baseDir = salesSphereDir;
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        baseDir = await getApplicationDocumentsDirectory();

        final salesSphereDir = Directory('${baseDir.path}/SalesSphere/Invoices');

        if (!await salesSphereDir.exists()) {
          await salesSphereDir.create(recursive: true);
          AppLogger.d('Created SalesSphere/Invoices folder at: ${salesSphereDir.path}');
        }

        baseDir = salesSphereDir;
      } else {
        // For other platforms (Web, Windows, macOS, Linux), use documents directory
        baseDir = await getApplicationDocumentsDirectory();

        final salesSphereDir = Directory('${baseDir.path}/SalesSphere/Invoices');

        if (!await salesSphereDir.exists()) {
          await salesSphereDir.create(recursive: true);
          AppLogger.d('Created SalesSphere/Invoices folder at: ${salesSphereDir.path}');
        }

        baseDir = salesSphereDir;
      }

      // Fallback to temporary directory if all else fails
      baseDir ??= await getTemporaryDirectory();

      // Create the file
      final file = File('${baseDir.path}/$invoiceNumber.pdf');
      await file.writeAsBytes(pdfBytes);

      AppLogger.d('PDF saved to: ${file.path}');

      return file;
    } catch (e) {
      AppLogger.e('Error saving PDF to SalesSphere folder: $e');

      // Fallback to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$invoiceNumber.pdf');
      await file.writeAsBytes(pdfBytes);

      AppLogger.w('PDF saved to temporary directory as fallback: ${file.path}');

      return file;
    }
  }

  /// Request storage permission for Android
  static Future<bool> _requestStoragePermission() async {
    try {
      // Check Android version
      if (Platform.isAndroid) {
        // For Android 13+ (API 33+), we might need MANAGE_EXTERNAL_STORAGE
        // For Android 10-12, we need WRITE_EXTERNAL_STORAGE
        // For Android < 10, we need WRITE_EXTERNAL_STORAGE

        // First try with storage permission
        var status = await Permission.storage.status;

        if (status.isGranted) {
          return true;
        }

        // Request permission
        status = await Permission.storage.request();

        if (status.isGranted) {
          return true;
        }

        // For Android 11+ (API 30+), try manageExternalStorage if storage permission is denied
        if (status.isDenied || status.isPermanentlyDenied) {
          var manageStatus = await Permission.manageExternalStorage.status;

          if (manageStatus.isGranted) {
            return true;
          }

          // Request manage external storage permission
          manageStatus = await Permission.manageExternalStorage.request();

          return manageStatus.isGranted;
        }

        return false;
      }

      // For non-Android platforms, no permission needed
      return true;
    } catch (e) {
      AppLogger.e('Error requesting storage permission: $e');
      return false;
    }
  }

  static pw.Widget _buildHeader(
    InvoiceDetailsData invoice,
    DateTime createdDate,
    DateFormat dateFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1976D2'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                invoice.invoiceNumber,
                style: const pw.TextStyle(
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(invoice.status),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  invoice.status.displayName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Date: ${dateFormat.format(createdDate)}',
                style: const pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFromSection(InvoiceDetailsData invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'FROM',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1976D2'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            invoice.organizationName,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.organizationAddress,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Phone: ${invoice.organizationPhone}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'PAN/VAT: ${invoice.organizationPanVatNumber}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildToSection(InvoiceDetailsData invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1976D2'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            invoice.partyName,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Attn: ${invoice.partyOwnerName}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.partyAddress,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'PAN/VAT: ${invoice.partyPanVatNumber}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceInfo(
    InvoiceDetailsData invoice,
    DateTime deliveryDate,
    DateFormat dateFormat,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF3E0'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColor.fromHex('#FFB74D')),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Expected Delivery Date',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            DateFormat('EEEE, MMMM dd, yyyy').format(deliveryDate),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#F57C00'),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItemData> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#1976D2'),
          ),
          children: [
            _buildTableHeader('#'),
            _buildTableHeader('Item Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Unit Price'),
            _buildTableHeader('Amount'),
          ],
        ),
        // Items
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
            ),
            children: [
              _buildTableCell((index + 1).toString(), isCenter: true),
              _buildTableCell(item.productName),
              _buildTableCell(item.quantity.toString(), isCenter: true),
              _buildTableCell('Rs. ${item.price.toStringAsFixed(2)}', isRight: true),
              _buildTableCell('Rs. ${item.total.toStringAsFixed(2)}', isRight: true),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isCenter = false,
    bool isRight = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
        textAlign: isCenter
            ? pw.TextAlign.center
            : isRight
                ? pw.TextAlign.right
                : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildPricingSummary(
    double subtotal,
    double discountPercent,
    double discountAmount,
    double total,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 280,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#E3F2FD'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColor.fromHex('#1976D2')),
        ),
        child: pw.Column(
          children: [
            _buildSummaryRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(2)}'),
            if (discountPercent > 0) ...[
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                'Discount ($discountPercent%)',
                '- Rs. ${discountAmount.toStringAsFixed(2)}',
                isDiscount: true,
              ),
            ],
            pw.SizedBox(height: 12),
            pw.Divider(color: PdfColor.fromHex('#1976D2'), thickness: 2),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1976D2'),
                  ),
                ),
                pw.Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1976D2'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: isDiscount ? PdfColors.green700 : PdfColors.black,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: isDiscount ? PdfColors.green700 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(top: 20),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1976D2'),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated by SalesSphere',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return PdfColors.grey;
      case OrderStatus.inProgress:
        return PdfColors.blue;
      case OrderStatus.inTransit:
        return PdfColors.orange;
      case OrderStatus.completed:
        return PdfColors.green;
      case OrderStatus.rejected:
        return PdfColors.red;
    }
  }
}
