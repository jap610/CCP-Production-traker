// lib/screens/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/excel_service.dart';
import '../widgets/machine_view.dart';
import '../widgets/combined_view.dart'; // Import CombinedView
import '../utils/constants.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

/// **ExcelReaderHomePage** is the main screen of the app
class ExcelReaderHomePage extends StatefulWidget {
  const ExcelReaderHomePage({Key? key}) : super(key: key);

  @override
  _ExcelReaderHomePageState createState() => _ExcelReaderHomePageState();
}

class _ExcelReaderHomePageState extends State<ExcelReaderHomePage> {
  // Machine sums
  Map<String, int> _machine1Sums = {};
  Map<String, int> _machine2Sums = {};

  // Current DateTime
  String _currentDateTime = '';

  // Previous Shifts Sum
  int _previousShiftsSum = 0;
// Add these to store the number of orders for each machine
  Map<String, int> _machine1Orders = {};
  Map<String, int> _machine2Orders = {};

  // Controllers
  final TextEditingController _previousShiftsController =
      TextEditingController();
  final TextEditingController _machine1PathController = TextEditingController();
  final TextEditingController _machine2PathController = TextEditingController();

  // Target Controllers for Machines
  final Map<String, TextEditingController> _machine1TargetsControllers = {};
  final Map<String, TextEditingController> _machine2TargetsControllers = {};

  // Timer for periodic data refresh
  late Timer _timer;

  // Loading indicator
  bool _isLoading = false;

  // Fullscreen state
  bool _isFullScreen = false;

  // Auto-Scroll state
  bool _autoScrollEnabled = true; // New state variable for auto-scroll

  // View Mode state
  bool _isCombinedView = false; // New state variable for view mode

  // ScrollControllers for automatic scrolling
  final ScrollController _machine1ScrollController = ScrollController();
  final ScrollController _machine2ScrollController = ScrollController();
  final ScrollController _combinedScrollController =
      ScrollController(); // For combined view

  // Flags to prevent multiple scrolling loops
  bool _machine1Scrolling = false;
  bool _machine2Scrolling = false;
  bool _combinedScrolling = false; // For combined view

  @override
  void initState() {
    super.initState();

    // Set default file paths
    _machine1PathController.text = defaultMachine1Path;
    _machine2PathController.text = defaultMachine2Path;

    // Load previous shifts from persistent storage
    _loadPreviousShifts();

    // Load initial data
    _loadData();

    // Set up periodic data refresh every 10 seconds
    _timer =
        Timer.periodic(const Duration(seconds: 10), (Timer t) => _loadData());

    // Initialize and start the date/time updater
    _updateDateTime();

    // Start automatic scrolling for both machines after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollMachine1();
      _autoScrollMachine2();
    });
  }

  /// **Auto-Scroll for Machine 1**
  Future<void> _autoScrollMachine1() async {
    if (_machine1Scrolling) return;
    _machine1Scrolling = true;

    while (mounted) {
      if (!_autoScrollEnabled || _isCombinedView) {
        // If auto-scroll is disabled or combined view is active, wait
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      if (!_machine1ScrollController.hasClients) {
        // Wait if the controller is not attached to any scroll view
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      // Wait if data is loading to prevent conflicts
      if (_isLoading) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final maxScroll = _machine1ScrollController.position.maxScrollExtent;
      final minScroll = _machine1ScrollController.position.minScrollExtent;

      // Avoid scrolling if the list is too short
      if (maxScroll - minScroll < 20) {
        // Threshold of 20 pixels
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      try {
        // Scroll to the end
        await _machine1ScrollController.animateTo(
          maxScroll,
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
        );

        // Pause for a moment
        await Future.delayed(const Duration(seconds: 2));

        // Scroll back to the start
        await _machine1ScrollController.animateTo(
          minScroll,
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
        );

        // Pause before repeating
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // Handle any exceptions, possibly due to list changes
        _showError('Auto-scroll error for Machine 1: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    _machine1Scrolling = false;
  }

  /// **Auto-Scroll for Machine 2**
  Future<void> _autoScrollMachine2() async {
    if (_machine2Scrolling) return;
    _machine2Scrolling = true;

    while (mounted) {
      if (!_autoScrollEnabled || _isCombinedView) {
        // If auto-scroll is disabled or combined view is active, wait
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      if (!_machine2ScrollController.hasClients) {
        // Wait if the controller is not attached to any scroll view
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      // Wait if data is loading to prevent conflicts
      if (_isLoading) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final maxScroll = _machine2ScrollController.position.maxScrollExtent;
      final minScroll = _machine2ScrollController.position.minScrollExtent;

      // Avoid scrolling if the list is too short
      if (maxScroll - minScroll < 20) {
        // Threshold of 20 pixels
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      try {
        // Scroll to the end
        await _machine2ScrollController.animateTo(
          maxScroll,
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
        );

        // Pause for a moment
        await Future.delayed(const Duration(seconds: 2));

        // Scroll back to the start
        await _machine2ScrollController.animateTo(
          minScroll,
          duration: const Duration(seconds: 10),
          curve: Curves.linear,
        );

        // Pause before repeating
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // Handle any exceptions, possibly due to list changes
        _showError('Auto-scroll error for Machine 2: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    _machine2Scrolling = false;
  }

  /// **Auto-Scroll for Combined View**
  Future<void> _autoScrollCombinedView() async {
    if (_combinedScrolling) return;
    _combinedScrolling = true;

    while (mounted) {
      if (!_autoScrollEnabled || !_isCombinedView) {
        // If auto-scroll is disabled or combined view is not active, wait
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      if (!_combinedScrollController.hasClients) {
        // Wait if the controller is not attached to any scroll view
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      // Wait if data is loading to prevent conflicts
      if (_isLoading) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final maxScroll = _combinedScrollController.position.maxScrollExtent;
      final minScroll = _combinedScrollController.position.minScrollExtent;

      // Avoid scrolling if the list is too short
      if (maxScroll - minScroll < 20) {
        // Threshold of 20 pixels
        await Future.delayed(const Duration(seconds: 5));
        continue;
      }

      try {
        // Scroll to the end
        await _combinedScrollController.animateTo(
          maxScroll,
          duration: const Duration(seconds: 20),
          curve: Curves.linear,
        );

        // Pause for a moment
        await Future.delayed(const Duration(seconds: 2));

        // Scroll back to the start
        await _combinedScrollController.animateTo(
          minScroll,
          duration: const Duration(seconds: 20),
          curve: Curves.linear,
        );

        // Pause before repeating
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        // Handle any exceptions, possibly due to list changes
        _showError('Auto-scroll error for Combined View: $e');
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    _combinedScrolling = false;
  }

  /// **Load Previous Shifts Sum** from SharedPreferences
  Future<void> _loadPreviousShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousShiftsSum = prefs.getInt('previousShiftsSum') ?? 0;
      _previousShiftsController.text =
          _previousShiftsSum > 0 ? _previousShiftsSum.toString() : '';
    });
  }

  /// **Save Previous Shifts Sum** to SharedPreferences
  Future<void> _savePreviousShifts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('previousShiftsSum', _previousShiftsSum);
  }

  /// **Update Current DateTime** every second
  void _updateDateTime() {
    _currentDateTime =
        DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _currentDateTime =
            DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
      });
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    // Load data for Machine 1
    await ExcelService.loadMachineData(
      machineName: 'Machine 1',
      filePath: _machine1PathController.text,
      machineSums: _machine1Sums,
      machineOrders: _machine1Orders, // Pass the orders map
      targetControllers: _machine1TargetsControllers,
      context: context,
    );

    // Load data for Machine 2
    await ExcelService.loadMachineData(
      machineName: 'Machine 2',
      filePath: _machine2PathController.text,
      machineSums: _machine2Sums,
      machineOrders: _machine2Orders, // Pass the orders map
      targetControllers: _machine2TargetsControllers,
      context: context,
    );

    setState(() {
      _isLoading = false;
    });
  }

  /// **Pick File** using file_picker package
  Future<void> _pickFile(
      TextEditingController controller, String machineName) async {
    final selectedPath = await ExcelService.pickFile(controller, context);
    if (selectedPath != null) {
      await _loadData(); // Reload data after file selection

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Selected file for $machineName: ${selectedPath.split('/').last}'),
          backgroundColor: Theme.of(context).hintColor,
        ),
      );
    }
  }

  /// **Show Error** using SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// **Set Fullscreen Mode**
  void setFullScreen(bool isFullScreen) async {
    try {
      await FullScreenWindow.setFullScreen(isFullScreen);
      setState(() {
        _isFullScreen = isFullScreen;
      });
    } catch (e) {
      _showError('Failed to toggle fullscreen mode: $e');
    }
  }

  /// **Toggle Auto-Scroll**
  void _toggleAutoScroll() {
    setState(() {
      _autoScrollEnabled = !_autoScrollEnabled;
    });
  }

  /// **Toggle View Mode**
  void _toggleViewMode() {
    setState(() {
      _isCombinedView = !_isCombinedView;
    });

    if (_isCombinedView) {
      // Start auto-scroll for combined view
      _autoScrollCombinedView();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _previousShiftsController.dispose();
    _machine1PathController.dispose();
    _machine2PathController.dispose();
    for (var controller in _machine1TargetsControllers.values) {
      controller.dispose();
    }
    for (var controller in _machine2TargetsControllers.values) {
      controller.dispose();
    }

    // Dispose of the ScrollControllers
    _machine1ScrollController.dispose();
    _machine2ScrollController.dispose();
    _combinedScrollController.dispose();

    super.dispose();
  }

  /// **Calculate Total Sum** for a machine
  int _calculateMachineSum(Map<String, int> stationSums) {
    return stationSums.values.fold(0, (sum, stationSum) => sum + stationSum);
  }

  /// **Calculate Total Orders** for a machine
  int _calculateOrdersSum(Map<String, int> stationOrders) {
    // Use `fold` to sum up all values in the stationOrders map
    return stationOrders.values.fold(0, (sum, orderCount) => sum + orderCount);
  }

  /// **Combine Machine Sums** for Combined View
  Map<String, int> _combineMachineSums() {
    Map<String, int> combinedSums = {};

    // Combine Machine 1 Sums
    _machine1Sums.forEach((key, value) {
      combinedSums[key] = (combinedSums[key] ?? 0) + value;
    });

    // Combine Machine 2 Sums
    _machine2Sums.forEach((key, value) {
      combinedSums[key] = (combinedSums[key] ?? 0) + value;
    });

    return combinedSums;
  }

  /// **Combine Target Controllers** for Combined View
  Map<String, TextEditingController> _combineTargetControllers() {
    Map<String, TextEditingController> combinedTargets = {};

    // Combine Machine 1 Targets
    _machine1TargetsControllers.forEach((key, controller) {
      combinedTargets.putIfAbsent(key, () => TextEditingController(text: '0'));
    });

    // Combine Machine 2 Targets
    _machine2TargetsControllers.forEach((key, controller) {
      combinedTargets.putIfAbsent(key, () => TextEditingController(text: '0'));
    });

    return combinedTargets;
  }

  /// **Get Sorted Stations**
  List<String> getSortedStations(Map<String, int> stationSums) {
    List<String> sortedStations = stationSums.keys.toList();

    sortedStations.sort((a, b) {
      // Extract parts after '/' for both station names (or fallback to full name if no '/')
      String aStation = a.contains('/')
          ? a.split('/')[1].trim().toLowerCase()
          : a.toLowerCase();
      String bStation = b.contains('/')
          ? b.split('/')[1].trim().toLowerCase()
          : b.toLowerCase();

      // VIP station always comes first
      if (a.toLowerCase() == 'vip') return -1;
      if (b.toLowerCase() == 'vip') return 1;

      // Compare the names based on the part after the '/'
      return aStation.compareTo(bStation);
    });

    return sortedStations;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenWidth * 0.015;

    // Total sums for each machine
    int machine1Total = _calculateMachineSum(_machine1Sums);
    int machine2Total = _calculateMachineSum(_machine2Sums);

    int machine1Orders = _calculateOrdersSum(_machine1Orders);
    int machine2Orders = _calculateOrdersSum(_machine2Orders);

    // Combined total for both machines
    int combinedTotal = machine1Total + machine2Total;

    // Total for all shifts (combined total + previous shifts)
    int totalForAllShifts = combinedTotal + _previousShiftsSum;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height / 10,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 4,
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          // First Row: Logo, DateTime, Fullscreen, Auto-Scroll, and View Toggle Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Branding and DateTime
              Row(
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      "assets/veridos-logo.png",
                      height: MediaQuery.of(context).size.height / 13,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height / 20),
                  Text(
                    _currentDateTime,
                    style: TextStyle(
                        color: const Color.fromARGB(255, 27, 27, 25),
                        fontSize: MediaQuery.of(context).size.height / 30),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.height / 40),

                  IconButton(
                    iconSize: MediaQuery.of(context).size.width / 60,
                    icon: Icon(
                      _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.black,
                    ),
                    tooltip:
                        _isFullScreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
                    onPressed: () => setFullScreen(!_isFullScreen),
                  ),

                  // Auto-Scroll Toggle Button

                  IconButton(
                    iconSize: MediaQuery.of(context).size.width / 60,
                    icon: Icon(
                      _autoScrollEnabled
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: _autoScrollEnabled
                          ? Color.fromARGB(255, 0, 0, 0)
                          : Color.fromARGB(255, 0, 0, 0),
                    ),
                    tooltip: _autoScrollEnabled
                        ? 'Pause Auto-Scroll'
                        : 'Start Auto-Scroll',
                    onPressed: _toggleAutoScroll,
                  ),

                  // View Mode Toggle Button
                  IconButton(
                    iconSize: MediaQuery.of(context).size.width / 60,
                    icon: Icon(
                      _isCombinedView
                          ? Icons.view_comfortable
                          : Icons.view_agenda,
                      color: _isCombinedView
                          ? Color.fromARGB(255, 0, 0, 0)
                          : Color.fromARGB(255, 0, 0, 0),
                    ),
                    tooltip: _isCombinedView
                        ? 'Switch to Separate View'
                        : 'Switch to Combined View',
                    onPressed: _toggleViewMode,
                  ),
                ],
              ),

              // Controls and Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Fullscreen Toggle Button

                  SizedBox(
                    width: MediaQuery.of(context).size.width / 40,
                  ),

                  // Display Combined Personalized Cards
                  Row(
                    children: [
                      Text(
                        'This Shift: $combinedTotal',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 27, 27, 25),
                            fontSize: MediaQuery.of(context).size.height / 25),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 40,
                      ),

                      // Previous Shifts Input and Total for All Shifts
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 11,
                            child: TextField(
                              controller: _previousShiftsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                              ],
                              decoration: InputDecoration(
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Color.fromARGB(255, 248, 174, 6),
                                  ),
                                ),
                                fillColor: const Color.fromARGB(63, 0, 0, 0),
                                labelText: 'Prev Shifts',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 27, 27, 25),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 70,
                                  fontWeight: FontWeight.bold,
                                ),
                                hintText: 'Enter No',
                                hintStyle: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width / 70,
                                  color: Color.fromARGB(255, 27, 27, 25),
                                ),
                                suffixIcon: _previousShiftsController
                                        .text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _previousShiftsController.clear();
                                            _previousShiftsSum = 0;
                                            _savePreviousShifts();
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              style: TextStyle(
                                  color: Color.fromARGB(255, 27, 27, 25),
                                  fontSize:
                                      MediaQuery.of(context).size.width / 60,
                                  fontWeight: FontWeight.bold),
                              onChanged: (value) {
                                setState(() {
                                  int enteredValue = int.tryParse(value) ?? 0;
                                  if (enteredValue >= 1 &&
                                      enteredValue <= 99999) {
                                    _previousShiftsSum = enteredValue;
                                  } else {
                                    _previousShiftsSum = 0;
                                  }
                                  _savePreviousShifts();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 100,
                          ),
                          Text(
                            'All Shifts: $totalForAllShifts',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 27, 27, 25),
                                fontSize:
                                    MediaQuery.of(context).size.height / 25),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ]),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).hintColor,
              ),
            )
          : _isCombinedView
              ? CombinedView(
                  combinedSums: _combineMachineSums(),
                  targetControllers: _combineTargetControllers(),
                  scrollController: _combinedScrollController,
                  baseFontSize: baseFontSize,
                )
              : Row(
                  children: [
                    // Machine 1 View
                    Expanded(
                      child: MachineView(
                        machineName: 'M500',
                        totalSum: machine1Total,
                        stationSums: _machine1Sums,
                        stationOrders: _machine1Orders, // Pass order counts
                        targetControllers: _machine1TargetsControllers,
                        pathController: _machine1PathController,
                        baseFontSize: baseFontSize,
                        scrollController: _machine1ScrollController,
                        sortedStations: getSortedStations(_machine1Sums),
                        ordersSum: machine1Orders,
                      ),
                    ),
                    const VerticalDivider(
                      color: Colors.white, // Separator between machines
                      thickness: 2.0,
                    ),
                    // Machine 2 View
                    Expanded(
                      child: MachineView(
                        machineName: 'M501',
                        totalSum: machine2Total,
                        stationSums: _machine2Sums,
                        stationOrders: _machine2Orders, // Pass order counts
                        targetControllers: _machine2TargetsControllers,
                        pathController: _machine2PathController,
                        baseFontSize: baseFontSize,
                        scrollController: _machine2ScrollController,
                        sortedStations: getSortedStations(_machine2Sums),
                        ordersSum: machine2Orders,
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 30,
            child: Center(
              child: Text(
                "Designed and executed by: Eng.Shukur Kh & Eng.Alhasan Ahmed",
                style: TextStyle(
                  fontSize: baseFontSize * 0.75,
                  color: const Color.fromARGB(255, 224, 223, 223),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
