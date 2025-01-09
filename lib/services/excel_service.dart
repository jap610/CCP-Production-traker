// lib/services/excel_service.dart

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class ExcelService {
  /// **Load Machine Data** from an Excel file
  static Future<void> loadMachineData({
    required String machineName,
    required String filePath,
    required Map<String, int> machineSums, // Sum of cards per station
    required Map<String, int> machineOrders, // Number of orders per station
    required Map<String, TextEditingController> targetControllers,
    required BuildContext context,
  }) async {
    try {
      if (File(filePath).existsSync()) {
        final bytes = File(filePath).readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);
        Map<String, int> tempSums = {};
        Map<String, int> tempOrders = {}; // Temporary map for order counts
        int vipSum = 0; // Initialize VIP sum

        for (var table in excel.tables.keys) {
          final rows = excel.tables[table]!.rows;
          for (var i = 1; i < rows.length; i++) {
            // Skip the header row
            final row = rows[i];

            // Check if the row has enough columns and valid data
            if (row.length >= 5 &&
                row[2] != null &&
                row[4] != null &&
                row[3] != null &&
                row[2]!.value != null &&
                row[4]!.value != null &&
                row[3]!.value != null &&
                row[2]!.value.toString().trim().isNotEmpty &&
                row[4]!.value.toString().trim().isNotEmpty &&
                row[3]!.value.toString().trim().isNotEmpty) {
              // Extract and concatenate station names from columns 4 and 3
              final stationPart1 = row[4]!.value.toString();
              final stationPart2 = row[3]!.value.toString();
              final station = '$stationPart1 / $stationPart2'.trim();

              // Parse the number of cards from column index 2
              final numberOfCards = int.tryParse(row[2]!.value.toString()) ?? 0;

              // Accumulate the sum for the station
              tempSums[station] = (tempSums[station] ?? 0) + numberOfCards;

              // Increment the order count for the station
              tempOrders[station] = (tempOrders[station] ?? 0) + 1;

              // Initialize TextEditingController if not already present
              targetControllers.putIfAbsent(
                  station, () => TextEditingController(text: '0'));

              // Log for debugging
              print(
                  'Valid row: Station=$station, Cards=$numberOfCards, Orders=${tempOrders[station]}');
            }

            // VIP sum logic
            if (row.length >= 7 && row[7]?.value != null) {
              final vipValue = int.tryParse(row[7]!.value.toString()) ?? 0;

              if (vipValue > 0) {
                vipSum += vipValue;

                // Increment the order count for VIP only if the VIP value is non-zero
                tempOrders['VIP'] = (tempOrders['VIP'] ?? 0) + 1;
              }
            }
          }
        }

        // Add VIP to the station sums
        if (vipSum > 0) {
          tempSums['VIP'] = vipSum;

          // Initialize TextEditingController for VIP if not present
          targetControllers.putIfAbsent(
              'VIP', () => TextEditingController(text: '0'));
        }

        // Update the machineSums and machineOrders maps
        machineSums.clear();
        machineSums.addAll(tempSums);

        machineOrders.clear();
        machineOrders.addAll(tempOrders);
      } else {
        _showError(context, '$machineName file does not exist.');
      }
    } catch (e) {
      _showError(context, 'Error loading data for $machineName: $e');
    }
  }

  /// **Pick File** using file_picker package
  static Future<String?> pickFile(
      TextEditingController controller, BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xlsm'],
      );

      if (result != null && result.files.single.path != null) {
        controller.text = result.files.single.path!;
        return controller.text;
      }
    } catch (e) {
      _showError(context, 'Error picking file: $e');
    }
    return null;
  }

  /// **Show Error** using SnackBar
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
