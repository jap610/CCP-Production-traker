import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart'
    as pw; // Alias to differentiate between Flutter and PDF widgets

/// **CombinedView** encapsulated in a Card widget
class CombinedView extends StatelessWidget {
  // Map holding the sum values for each station
  final Map<String, int> combinedSums;

  // Map holding TextEditingControllers for target inputs for each station
  final Map<String, TextEditingController> targetControllers;

  // Controller to manage the scrolling behavior of the ListView
  final ScrollController scrollController;

  // Base font size used for scaling text within the widget
  final double baseFontSize;

  /// Constructor for CombinedView requiring all necessary parameters
  const CombinedView({
    Key? key,
    required this.combinedSums,
    required this.targetControllers,
    required this.scrollController,
    required this.baseFontSize,
  }) : super(key: key);

  /// **Print Function** to generate and print the combined view as a PDF
  /// **Print Function** to generate and print the combined view as a PDF
  /// **Print Function** to generate and print the combined view as a PDF
  /// **Print Function** to generate and print the combined view as a PDF
  void _printCombinedView() async {
    // Create a new PDF document
    final pdf = pw.Document();

    // Retrieve the sorted list of stations using the existing sorting logic
    List<String> sortedStations = getSortedStations(combinedSums);

    // Filter out stations with empty names or zero sums
    List<String> filteredStations = sortedStations.where((station) {
      final sum =
          combinedSums[station] ?? 0; // Get the sum for the current station
      return station.isNotEmpty &&
          sum !=
              0; // Include only if station name is not empty and sum is not zero
    }).toList();

    // Calculate the total sum of the filtered stations
    int totalSum = filteredStations.fold(
        0, (sum, station) => sum + (combinedSums[station] ?? 0));

    // Get the current date
    String formattedDate =
        DateTime.now().toLocal().toString().split(' ')[0]; // YYYY-MM-DD format

    // Add a new page to the PDF document
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          // Define the layout of the PDF page using a column
          return pw.Column(
            crossAxisAlignment: pw
                .CrossAxisAlignment.start, // Align content to the start (left)
            children: [
              // Header Section
              pw.Text(
                'Combined Sum',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8), // Spacing between header and date
              pw.Text(
                'Date: $formattedDate', // Display the current date
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.normal,
                ),
              ),
              pw.SizedBox(height: 16), // Spacing between date and list

              // List of Stations
              ...filteredStations.map((station) {
                final sum = combinedSums[station] ??
                    0; // Get the sum for the current station

                // Ignore everything before the '/' in the station name
                String displayStation = station.contains('/')
                    ? station.split('/')[1].trim()
                    : station;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment
                      .start, // Align content to the start (left)
                  children: [
                    pw.Container(
                      margin: const pw.EdgeInsets.symmetric(vertical: 1),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          // Station Name
                          pw.Text(
                            displayStation, // Display the station name, ignoring the part before '/'
                            style: pw.TextStyle(fontSize: 8),
                          ),
                          // Sum Value
                          pw.Text(
                            sum.toString(),
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: sum >=
                                      (targetControllers[station] != null
                                          ? (int.tryParse(
                                                  targetControllers[station]!
                                                      .text) ??
                                              0)
                                          : 0)
                                  ? PdfColors.green
                                  : PdfColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(), // Horizontal divider between stations
                  ],
                );
              }).toList(),

              // Total Sum
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "Total:",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      totalSum.toString(),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Trigger the print dialog to allow the user to print the generated PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// **Get Sorted Stations**
  /// Sorts the stations with VIP first, then alphabetically based on the part after '/'
  List<String> getSortedStations(Map<String, int> stationSums) {
    // Extract the list of station names
    List<String> sortedStations = stationSums.keys.toList();

    // Sort the station names based on custom logic
    sortedStations.sort((a, b) {
      // Extract parts after '/' for both station names, or use the full name if '/' is not present
      String aStation = a.contains('/')
          ? a.split('/')[1].trim().toLowerCase()
          : a.toLowerCase();
      String bStation = b.contains('/')
          ? b.split('/')[1].trim().toLowerCase()
          : b.toLowerCase();

      // Ensure that 'VIP' station always comes first
      if (a.toLowerCase() == 'vip') return -1;
      if (b.toLowerCase() == 'vip') return 1;

      // Compare the extracted station names alphabetically
      return aStation.compareTo(bStation);
    });

    return sortedStations;
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the sorted list of stations using the existing sorting logic
    List<String> sortedStations = getSortedStations(combinedSums);

    return Card(
      // Set the background color based on the current theme (dark or light)
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.grey[200],
      elevation: 4, // Elevation for shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      margin: const EdgeInsets.all(8.0), // Margin around the card
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          children: [
            // Header section containing the title, print button, and total cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title of the combined view
                Text(
                  'Combined View',
                  style: TextStyle(
                    fontSize: baseFontSize * 1.5, // Scaled font size
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                  ),
                ),
                // Print icon button to trigger the print function
                IconButton(
                  icon: Icon(Icons.print),
                  onPressed:
                      _printCombinedView, // Call the print function when pressed
                ),
                // Display the total number of perso cards
                Text(
                  'PERSO CARDS: ${combinedSums.values.fold(0, (sum, value) => sum + value)}',
                  style: TextStyle(
                    fontSize: baseFontSize * 1.5, // Scaled font size
                    color: Colors.greenAccent, // Text color
                    fontWeight: FontWeight.bold, // Bold text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Spacing between header and divider
            const Divider(color: Colors.white70, thickness: 1), // Divider line
            // Expanded widget to allow the list to take up available space
            Expanded(
              child: ScrollConfiguration(
                // Customize the scroll behavior to hide scrollbars
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  controller: scrollController, // Assign the scroll controller
                  itemCount:
                      sortedStations.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    final station =
                        sortedStations[index]; // Current station name
                    final sum = combinedSums[station] ??
                        0; // Sum for the current station

                    // Skip rendering if the station name is empty or sum is zero
                    if (station.isEmpty || sum == 0) {
                      return const SizedBox.shrink(); // Returns an empty widget
                    }

                    final targetController = targetControllers[
                        station]!; // Controller for target input

                    // Parse the target value, defaulting to 0 if parsing fails
                    int target = int.tryParse(targetController.text) ?? 0;
                    target = target.clamp(
                        0, 9999); // Ensure target is between 0 and 9999

                    // Determine the color based on whether the sum meets the target
                    final color =
                        sum >= target ? Colors.greenAccent : Colors.redAccent;

                    // Check if the current station is 'VIP'
                    final bool isVIP = station.toLowerCase() == 'vip';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0), // Vertical padding between rows
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Spacer to add horizontal space
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 90,
                              ),
                              // Expanded widget to allow the station name to take up available space
                              Expanded(
                                flex: 4, // Flex factor for layout proportions
                                child: Row(
                                  children: [
                                    if (isVIP)
                                      const SizedBox(
                                          width:
                                              4), // Additional spacing for VIP
                                    Expanded(
                                      child: Text(
                                        station, // Display station name
                                        style: GoogleFonts.roboto(
                                          fontSize: baseFontSize *
                                              1.5, // Scaled font size
                                          color: Colors.white, // Text color
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handle overflow with ellipsis
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      8), // Horizontal spacing between elements
                              // Target Input Field
                              Expanded(
                                flex: 1, // Flex factor for layout proportions
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height /
                                      20, // Fixed height for the input field
                                  child: TextField(
                                    textAlign: TextAlign
                                        .center, // Center the input text
                                    controller:
                                        targetController, // Assign the controller
                                    keyboardType: TextInputType
                                        .number, // Numeric keyboard
                                    inputFormatters: [
                                      FilteringTextInputFormatter
                                          .digitsOnly, // Allow only digits
                                      LengthLimitingTextInputFormatter(
                                          5), // Limit input to 5 digits
                                    ],
                                    decoration: const InputDecoration(
                                      enabledBorder: InputBorder
                                          .none, // No border when not focused
                                      focusedBorder: InputBorder
                                          .none, // No border when focused
                                      fillColor: Color.fromARGB(0, 255, 255,
                                          255), // Transparent background
                                    ),
                                    style: TextStyle(
                                      color: Colors.white, // Text color
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              60, // Scaled font size
                                      fontWeight: FontWeight.bold, // Bold text
                                    ),
                                    onChanged: (value) {
                                      // Trigger a rebuild to update sum colors when input changes
                                      (context as Element).markNeedsBuild();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      8), // Horizontal spacing between elements
                              // Sum Display with Color Indicator
                              Expanded(
                                flex: 2, // Flex factor for layout proportions
                                child: AnimatedSwitcher(
                                  duration: const Duration(
                                      milliseconds: 500), // Animation duration
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    // Define the transition animation
                                    return ScaleTransition(
                                        scale: animation, child: child);
                                  },
                                  child: Text(
                                    '$sum', // Display the sum
                                    key: ValueKey<int>(
                                        sum), // Unique key for animation
                                    style: TextStyle(
                                      fontSize: baseFontSize *
                                          1.5, // Scaled font size
                                      color:
                                          color, // Color based on target comparison
                                      fontWeight: FontWeight.bold, // Bold text
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              color: Colors.white,
                              thickness: 1), // Divider between rows
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
