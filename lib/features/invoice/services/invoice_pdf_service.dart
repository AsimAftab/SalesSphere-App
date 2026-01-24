import 'dart:io';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/services/downloads_saver_service.dart';
import '../../../core/utils/logger.dart';
import '../models/invoice.models.dart';

class InvoicePdfService {
  /// Generate a beautiful commercial invoice or estimate PDF
  /// Returns the PDF bytes for further processing
  static Future<List<int>> generateInvoicePdfBytes(
    InvoiceDetailsData invoice,
  ) async {
    final pdf = pw.Document();
    final deliveryDate = invoice.expectedDeliveryDate != null
        ? DateTime.parse(invoice.expectedDeliveryDate!)
        : null;
    final createdDate = DateTime.parse(invoice.createdAt);
    final dateFormat = DateFormat('dd MMM yyyy');

    // Determine if this is an estimate
    final isEstimate = invoice.isEstimate ?? false;

    // Calculate totals
    final subtotal =
        invoice.subtotal ??
        invoice.items.fold<double>(0.0, (sum, item) => sum + item.total);
    final discountPercent = invoice.discount ?? 0.0;
    final discountAmount =
        invoice.discountAmount ?? (subtotal * discountPercent / 100);
    final total = invoice.totalAmount ?? (subtotal - discountAmount);

    // Define colors based on type
    final primaryColor = isEstimate
        ? PdfColor.fromHex('#F57C00')
        : PdfColor.fromHex('#1976D2');
    final lightColor = isEstimate
        ? PdfColor.fromHex('#FFF3E0')
        : PdfColor.fromHex('#E3F2FD');
    final borderColor = isEstimate
        ? PdfColor.fromHex('#FFB74D')
        : PdfColor.fromHex('#90CAF9');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(
            invoice,
            createdDate,
            dateFormat,
            primaryColor,
            isEstimate,
          ),
          pw.SizedBox(height: 30),

          // Organization and Party Details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _buildFromSection(invoice)),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _buildToSection(invoice)),
            ],
          ),
          pw.SizedBox(height: 30),

          // Invoice/Estimate Details
          _buildInvoiceInfo(
            invoice,
            deliveryDate,
            dateFormat,
            lightColor,
            borderColor,
            isEstimate,
          ),
          pw.SizedBox(height: 30),

          // Items Table
          _buildItemsTable(invoice.items, primaryColor),
          pw.SizedBox(height: 30),

          // Pricing Summary
          _buildPricingSummary(
            subtotal,
            discountPercent,
            discountAmount,
            total,
            primaryColor,
          ),
          pw.SizedBox(height: 40),

          // Footer
          _buildFooter(),
        ],
      ),
    );

    return await pdf.save();
  }

  /// Save PDF directly to Downloads folder (Google Play compliant)
  /// Uses MediaStore API on Android 10+ - no special permissions needed
  /// Returns the file path/URI if successful, null otherwise
  static Future<String?> saveToDownloads(InvoiceDetailsData invoice) async {
    try {
      AppLogger.i('Saving PDF to Downloads folder...');

      // Generate PDF bytes
      final pdfBytes = await generateInvoicePdfBytes(invoice);

      // Determine filename
      final invoiceNumber = invoice.isEstimate ?? false
          ? (invoice.estimateNumber ?? 'Estimate')
          : (invoice.invoiceNumber ?? 'Invoice');
      final fileName = '$invoiceNumber.pdf';

      // Save to Downloads using MediaStore API (Android) or app storage (other platforms)
      final savedPath = await DownloadsSaverService.saveToDownloads(
        fileName: fileName,
        bytes: pdfBytes,
        mimeType: 'application/pdf',
      );

      if (savedPath != null) {
        AppLogger.i('PDF saved successfully to: $savedPath');
      } else {
        AppLogger.w('Failed to save PDF to Downloads');
      }

      return savedPath;
    } catch (e) {
      AppLogger.e('Error saving PDF to Downloads: $e');
      rethrow;
    }
  }

  /// Share PDF using system share sheet
  /// This allows users to save to Downloads, Drive, cloud storage, etc.
  static Future<void> sharePdf(InvoiceDetailsData invoice) async {
    try {
      AppLogger.i('Sharing PDF...');

      // Generate PDF bytes
      final pdfBytes = await generateInvoicePdfBytes(invoice);

      // Determine filename
      final invoiceNumber = invoice.isEstimate ?? false
          ? (invoice.estimateNumber ?? 'Estimate')
          : (invoice.invoiceNumber ?? 'Invoice');
      final fileName = '$invoiceNumber.pdf';

      // Save and share
      await DownloadsSaverService.saveAndShare(
        fileName: fileName,
        bytes: pdfBytes,
      );

      AppLogger.i('PDF shared successfully');
    } catch (e) {
      AppLogger.e('Error sharing PDF: $e');
      rethrow;
    }
  }

  /// Open a PDF file at the given path or URI
  static Future<OpenResult> openPdf(String filePath) async {
    return await OpenFile.open(filePath);
  }

  /// Legacy method: Generate and save PDF to app-specific storage
  /// @deprecated Use saveToDownloads or sharePdf instead
  static Future<File> generateInvoicePdf(InvoiceDetailsData invoice) async {
    final pdfBytes = await generateInvoicePdfBytes(invoice);
    final invoiceNumber = invoice.invoiceNumber ?? 'Invoice';
    return await _saveToAppDirectory(invoiceNumber, pdfBytes);
  }

  /// Save PDF to app-specific directory (fallback)
  static Future<File> _saveToAppDirectory(
    String invoiceNumber,
    List<int> pdfBytes,
  ) async {
    try {
      Directory? baseDir;

      if (Platform.isAndroid) {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final salesSphereDir = Directory(
            '${externalDir.path}/SalesSphere/Invoices',
          );
          if (!await salesSphereDir.exists()) {
            await salesSphereDir.create(recursive: true);
          }
          baseDir = salesSphereDir;
        }
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
        final salesSphereDir = Directory(
          '${baseDir.path}/SalesSphere/Invoices',
        );
        if (!await salesSphereDir.exists()) {
          await salesSphereDir.create(recursive: true);
        }
        baseDir = salesSphereDir;
      }

      baseDir ??= await getTemporaryDirectory();

      final file = File('${baseDir.path}/$invoiceNumber.pdf');
      await file.writeAsBytes(pdfBytes);
      AppLogger.d('PDF saved to: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.e('Error saving PDF to app directory: $e');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$invoiceNumber.pdf');
      await file.writeAsBytes(pdfBytes);
      return file;
    }
  }

  static pw.Widget _buildHeader(
    InvoiceDetailsData invoice,
    DateTime createdDate,
    DateFormat dateFormat,
    PdfColor primaryColor,
    bool isEstimate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: primaryColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                isEstimate ? 'ESTIMATE' : 'INVOICE',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                isEstimate
                    ? (invoice.estimateNumber ?? 'N/A')
                    : (invoice.invoiceNumber ?? 'N/A'),
                style: const pw.TextStyle(fontSize: 18, color: PdfColors.white),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(invoice.status),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
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
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.white),
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
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
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
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
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
    DateTime? deliveryDate,
    DateFormat dateFormat,
    PdfColor lightColor,
    PdfColor borderColor,
    bool isEstimate,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: lightColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: borderColor),
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
            deliveryDate != null
                ? DateFormat('EEEE, MMMM dd, yyyy').format(deliveryDate)
                : 'Not set',
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

  static pw.Widget _buildItemsTable(
    List<InvoiceItemData> items,
    PdfColor primaryColor,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: primaryColor),
          children: [
            _buildTableHeader('#'),
            _buildTableHeader('Item Description'),
            _buildTableHeader('Qty'),
            _buildTableHeader('Unit Price'),
            _buildTableHeader('Discount'),
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
              _buildTableCell(
                'Rs. ${item.price.toStringAsFixed(2)}',
                isRight: true,
              ),
              _buildTableCell(
                item.discount > 0
                    ? '${item.discount.toStringAsFixed(1)}%'
                    : '-',
                isCenter: true,
              ),
              _buildTableCell(
                'Rs. ${item.total.toStringAsFixed(2)}',
                isRight: true,
              ),
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
    PdfColor primaryColor,
  ) {
    final lightColor = primaryColor == PdfColor.fromHex('#F57C00')
        ? PdfColor.fromHex('#FFF3E0')
        : PdfColor.fromHex('#E3F2FD');

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 280,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: lightColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: primaryColor),
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
            pw.Divider(color: primaryColor, thickness: 2),
            pw.SizedBox(height: 12),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  'Rs. ${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
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
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
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
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated by SalesSphere',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
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
