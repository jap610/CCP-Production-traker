// lib/widgets/machine_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/excel_service.dart';

/// **MachineView** encapsulated in a Card widget
class MachineView extends StatelessWidget {
  final String machineName;
  final int totalSum;
  final Map<String, int> stationSums; // Map for station sums
  final Map<String, int> stationOrders; // Map for order counts
  final Map<String, TextEditingController> targetControllers; // Target inputs
  final TextEditingController pathController; // Excel file path controller
  final double baseFontSize; // Base font size for UI scaling
  final ScrollController scrollController; // Scroll controller for auto-scroll
  final List<String> sortedStations; // Sorted station names
  final int ordersSum;
  const MachineView({
    Key? key,
    required this.machineName,
    required this.totalSum,
    required this.stationSums,
    required this.stationOrders, // Initialize this parameter
    required this.targetControllers,
    required this.pathController,
    required this.baseFontSize,
    required this.scrollController,
    required this.sortedStations,
    required this.ordersSum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[200],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Machine Name and File Picker
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        machineName,
                        style: TextStyle(
                          fontSize: baseFontSize * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 80,
                      ),
                      IconButton(
                        iconSize: MediaQuery.of(context).size.width / 60,
                        icon:
                            const Icon(Icons.folder_open, color: Colors.white),
                        tooltip: 'Select Excel File',
                        onPressed: () =>
                            ExcelService.pickFile(pathController, context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ords: $ordersSum',
                          style: TextStyle(
                            fontSize: baseFontSize * 1.5,
                            color: Colors.lightBlueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 40,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'P.C: $totalSum',
                          style: TextStyle(
                            fontSize: baseFontSize * 1.5,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.white70, thickness: 1),
            // List of Stations
            Expanded(
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: sortedStations.length,
                  itemBuilder: (context, index) {
                    final station = sortedStations[index];
                    final sum = stationSums[station] ?? 0;
                    final orderCount =
                        stationOrders[station] ?? 0; // Fetch order count

                    if (station.isEmpty || sum == 0) {
                      // Skip if the station or sum is null or zero
                      return const SizedBox.shrink();
                    }
                    final int totalOrders = stationOrders.values
                        .fold(0, (sum, orderCount) => sum + orderCount);

                    final targetController = targetControllers[station]!;

                    int target = int.tryParse(targetController.text) ?? 0;
                    target = target.clamp(
                        0, 9999); // Ensure target is between 0 and 9999
                    final color =
                        sum >= target ? Colors.greenAccent : Colors.redAccent;

                    final bool isVIP = station.toLowerCase() == 'vip';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 90,
                              ),
                              // Station Name Column
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    if (isVIP) const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        station,
                                        style: GoogleFonts.roboto(
                                          fontSize: baseFontSize * 1.5,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Orders Column
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '$orderCount Ords.', // Short term for orders
                                  style: TextStyle(
                                    fontSize: baseFontSize * 1.2,
                                    color: Colors.lightBlueAccent,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Target Input Column
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 20,
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    controller: targetController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(5),
                                    ],
                                    decoration: const InputDecoration(
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        fillColor:
                                            Color.fromARGB(0, 255, 255, 255)),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.width /
                                                60,
                                        fontWeight: FontWeight.bold),
                                    onChanged: (value) {
                                      // Trigger a rebuild to update sum colors
                                      (context as Element).markNeedsBuild();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Sum Column with Color Indicator
                              Expanded(
                                flex: 1,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 500),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: Text(
                                    '$sum',
                                    key: ValueKey<int>(sum),
                                    style: TextStyle(
                                      fontSize: baseFontSize * 1.5,
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white, thickness: 1),
                        ],
                      ),
                    );
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
