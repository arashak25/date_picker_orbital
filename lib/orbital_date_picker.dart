// DatePicker widget, a stateful widget for selecting a date range (from and to dates).
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({
    super.key,
    this.buttonStyle, // Custom style for the date selection buttons.
    this.buttonFromTitle, // Title for the "From" date button.
    this.buttonToTitle, // Title for the "To" date button.
    this.buttonTitleStyle, // Text style for the button titles.
    this.title, // Title for the date picker dialog.
    this.titleStyle, // Text style for the title.
    this.showSelectedDate =
        true, // Whether to show the selected date in the dialog.
    this.decorationOfSelectedDate, // Decoration for the selected date container.
    this.showOrbital = true, // Whether to show the orbital date picker UI.
    this.backgroundGradient, // Gradient for the dialog background.
    this.backgroundColor, // Background color for the dialog.
    this.datePickerButtonText, // Text for the date picker button.
    this.datePickerButtonTextStyle, // Style for the date picker button text.
    this.hasSoundEffect = true, // Whether to enable sound effects on selection.
    this.showAppBar = true, // Whether to show an app bar in the dialog.
    this.datePickerBackgroungColor, // Background color for the picker area.
    this.selecetdDatePickerRowBackgroungColor, // Background color for the selected picker row.
    this.showWeekDays = true, // Whether to show weekday names in the picker.
  });

  final ButtonStyle? buttonStyle;
  final String? buttonFromTitle;
  final String? buttonToTitle;
  final TextStyle? buttonTitleStyle;
  final String? title;
  final TextStyle? titleStyle;
  final bool showSelectedDate;
  final Decoration? decorationOfSelectedDate;
  final bool showOrbital;
  final Gradient? backgroundGradient;
  final Color? backgroundColor;
  final String? datePickerButtonText;
  final ButtonStyle? datePickerButtonTextStyle;
  final bool hasSoundEffect;
  final bool showAppBar;
  final Color? datePickerBackgroungColor;
  final Color? selecetdDatePickerRowBackgroungColor;
  final bool showWeekDays;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

// State class for the DatePicker widget, managing the date selection logic.
class _DatePickerState extends State<DatePicker> {
  // Map of months and their respective number of days (excluding leap year for Feb).
  final Map<String, int> monthDays = {
    "Jan": 31,
    "Feb": 28, // 29 in leap years
    "Mar": 31,
    "Apr": 30,
    "May": 31,
    "Jun": 30,
    "Jul": 31,
    "Aug": 31,
    "Sep": 30,
    "Oct": 31,
    "Nov": 30,
    "Dec": 31,
  };

  // List of years, starting from the current year and going back 100 years.
  final List<int> years = List.generate(
    100,
    (index) => DateTime.now().year - index,
  );

  // State variables for the "From" date.
  String? fromMonth;
  int? fromYear;
  int? fromDay;
  bool hasFromDate = false;

  // State variables for the "To" date.
  String? toMonth;
  int? toYear;
  int? toDay;
  bool hasToDate = false;

  // Global key to access the OrbitalDatePicker state.
  final orbitalKey = GlobalKey<_OrbitalDatePickerState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: _selectDateButton(isFrom: true),
        ), // Button for selecting "From" date.
        SizedBox(height: MediaQuery.of(context).size.height * 0.02), // Spacer.
        Center(
          child: _selectDateButton(isFrom: false),
        ), // Button for selecting "To" date.
      ],
    );
  }

  // Builds an ElevatedButton for selecting a date (either "From" or "To").
  ElevatedButton _selectDateButton({required bool isFrom}) {
    final hasDate = isFrom ? hasFromDate : hasToDate;
    final month = isFrom ? fromMonth : toMonth;
    final day = isFrom ? fromDay : toDay;
    final year = isFrom ? fromYear : toYear;

    return ElevatedButton(
      onPressed: () async {
        // Prevents selecting "To" date before "From" date.
        if (!isFrom && !hasFromDate) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select From date first")),
          );
          return;
        }

        final now = DateTime.now();
        // Opens the date picker bottom sheet with initial values.
        final result = await _openBottomSheet(
          initialMonth:
              month ??
              (isFrom
                  ? monthDays.keys.elementAt(now.month - 1)
                  : fromMonth ?? monthDays.keys.elementAt(now.month - 1)),
          initialDay: day ?? (isFrom ? now.day : fromDay ?? now.day),
          initialYear: year ?? (isFrom ? now.year : fromYear ?? now.year),
        );

        // Updates state with selected date.
        if (result != null) {
          setState(() {
            if (isFrom) {
              fromMonth = result['month'] as String;
              fromDay = result['day'] as int;
              fromYear = result['year'] as int;
              hasFromDate = true;
            } else {
              toMonth = result['month'] as String;
              toDay = result['day'] as int;
              toYear = result['year'] as int;
              hasToDate = true;
            }
          });
        }
      },
      style:
          widget.buttonStyle ??
          ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.015,
            ),
          ),
      child: Text(
        hasDate
            ? "$year-$month-$day"
            : (isFrom
                ? widget.buttonFromTitle ?? "Select From Date"
                : widget.buttonToTitle ?? "Select To Date"),
        style:
            widget.buttonTitleStyle ??
            TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045),
      ),
    );
  }

  // Opens a modal bottom sheet for date selection.
  Future<Map<String, dynamic>?> _openBottomSheet({
    required String initialMonth,
    required int initialDay,
    required int initialYear,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take full height.
      builder: (context) {
        String tempMonth = initialMonth;
        int tempYear = initialYear;
        int tempDay = initialDay;
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> monthItems = monthDays.keys.toList();
            int monthInitialIndex = monthItems.indexOf(tempMonth);

            List<int> dayItems =
                List.generate(
                  _daysInMonthFor(tempMonth, tempYear),
                  (i) => i + 1,
                ).reversed.toList();
            int dayInitialIndex =
                dayItems.contains(tempDay) ? dayItems.indexOf(tempDay) : 0;

            int yearInitialIndex =
                years.contains(tempYear) ? years.indexOf(tempYear) : 0;

            return Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.width * 0.06,
                ),
                gradient:
                    widget.backgroundGradient ??
                    LinearGradient(
                      colors: [Color(0xFFEA8D8D), Color(0xFFA890FE)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
              ),
              child: Column(
                children: [
                  // Optional app bar with title.
                  if (widget.showAppBar) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height / 15,
                      ),
                      child: Text(
                        widget.title ?? "Date of Birth",
                        style:
                            widget.titleStyle ??
                            TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.06,
                            ),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      indent: MediaQuery.of(context).size.width * 0.05,
                      endIndent: MediaQuery.of(context).size.width * 0.05,
                    ),
                  ],
                  // Displays the selected date if enabled.
                  if (widget.showSelectedDate)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration:
                            widget.decorationOfSelectedDate ??
                            BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.transparent.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.width * 0.03,
                              ),
                            ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Selected Date:",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.045,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.02,
                              ),
                              child: Text(
                                '$tempMonth $tempDay, $tempYear ${getWeekdayName(DateTime(tempYear, monthItems.indexOf(tempMonth) + 1, tempDay))}',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Orbital date picker UI if enabled.
                  if (widget.showOrbital)
                    OrbitalDatePicker(
                      key: orbitalKey,
                      size: MediaQuery.of(context).size.width * 0.6,
                      initialDate: DateTime(
                        initialYear,
                        monthItems.indexOf(initialMonth) + 1,
                        initialDay,
                      ),
                      onDateChanged: (date) {
                        setModalState(() {
                          tempMonth = monthDays.keys.elementAt(date.month - 1);
                          tempDay = date.day;
                        });
                      },
                    ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  // Picker row for selecting month, day, and year.
                  Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    widget
                                        .selecetdDatePickerRowBackgroungColor ??
                                    Colors.black12,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    MediaQuery.of(context).size.width * 0.02,
                                  ),
                                ),
                              ),
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                widget.datePickerBackgroungColor ??
                                // ignore: deprecated_member_use
                                Colors.transparent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.04,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildPicker(
                                  key: const ValueKey('month'),
                                  items: monthItems,
                                  initialIndex: monthInitialIndex,
                                  onSelected: (month) {
                                    setModalState(() {
                                      tempMonth = month;
                                      final maxDays = _daysInMonthFor(
                                        tempMonth,
                                        tempYear,
                                      );
                                      if (tempDay > maxDays) tempDay = maxDays;
                                    });
                                    orbitalKey.currentState?.animateToDate(
                                      DateTime(
                                        tempYear,
                                        monthItems.indexOf(tempMonth) + 1,
                                        tempDay,
                                      ),
                                    );
                                  },
                                  dateTime: DateTime(
                                    tempYear,
                                    monthItems.indexOf(tempMonth) + 1,
                                    tempDay,
                                  ),
                                  showWeekDay: false,
                                  month: tempMonth,
                                  year: tempYear,
                                ),
                                _buildPicker(
                                  key: ValueKey(
                                    'day-$tempMonth-$tempYear-${_daysInMonthFor(tempMonth, tempYear)}',
                                  ),
                                  items: dayItems,
                                  initialIndex: dayInitialIndex,
                                  onSelected: (day) {
                                    setModalState(() => tempDay = day);
                                    orbitalKey.currentState?.animateToDate(
                                      DateTime(
                                        tempYear,
                                        monthItems.indexOf(tempMonth) + 1,
                                        tempDay,
                                      ),
                                    );
                                  },
                                  dateTime: DateTime(
                                    tempYear,
                                    monthItems.indexOf(tempMonth) + 1,
                                    tempDay,
                                  ),
                                  showWeekDay: widget.showWeekDays,
                                  month: tempMonth,
                                  year: tempYear,
                                ),
                                _buildPicker(
                                  key: const ValueKey('year'),
                                  items: years,
                                  initialIndex: yearInitialIndex,
                                  onSelected: (year) {
                                    setModalState(() {
                                      tempYear = year;
                                      final maxDays = _daysInMonthFor(
                                        tempMonth,
                                        tempYear,
                                      );
                                      if (tempDay > maxDays) tempDay = maxDays;
                                    });
                                    orbitalKey.currentState?.animateToDate(
                                      DateTime(
                                        tempYear,
                                        monthItems.indexOf(tempMonth) + 1,
                                        tempDay,
                                      ),
                                    );
                                  },
                                  dateTime: DateTime(
                                    tempYear,
                                    monthItems.indexOf(tempMonth) + 1,
                                    tempDay,
                                  ),
                                  showWeekDay: false,
                                  month: tempMonth,
                                  year: tempYear,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SizedBox(),
                  ), // Spacer to push the submit button to the bottom.
                  // Submit button to confirm the selected date.
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'month': tempMonth,
                        'day': tempDay,
                        'year': tempYear,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0088CC),
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      fixedSize: Size(
                        MediaQuery.of(context).size.width * 0.9,
                        MediaQuery.of(context).size.height * 0.06,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.width * 0.03,
                        ),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Returns the number of days in a given month, accounting for leap years.
  int _daysInMonthFor(String month, int year) {
    int days = monthDays[month] ?? 30;
    if (month == "Feb" && _isLeapYear(year)) days = 29;
    return days;
  }

  // Checks if a year is a leap year.
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Builds a picker widget for selecting month, day, or year.
  Widget _buildPicker({
    Key? key,
    required List items,
    required Function(dynamic) onSelected,
    required DateTime dateTime,
    required bool showWeekDay,
    required String month,
    required int year,
    int initialIndex = 0,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.25,
      child: _PickerWidget(
        key: key,
        items: items,
        initialIndex: initialIndex,
        onSelected: onSelected,
        useSoundEffect: true,
        dateTime: dateTime,
        showWeekDay: showWeekDay,
        month: month,
        year: year,
      ),
    );
  }
}

// Picker widget for scrolling through items (months, days, or years).
class _PickerWidget extends StatefulWidget {
  final List items;
  final Function(dynamic) onSelected;
  final int initialIndex;
  final bool useSoundEffect;
  final DateTime dateTime;
  final bool showWeekDay;
  final String month;
  final int year;

  const _PickerWidget({
    super.key,
    required this.items,
    required this.onSelected,
    this.initialIndex = 0,
    this.useSoundEffect = true,
    required this.dateTime,
    required this.showWeekDay,
    required this.month,
    required this.year,
  });

  @override
  State<_PickerWidget> createState() => _PickerWidgetState();
}

class _PickerWidgetState extends State<_PickerWidget> {
  late FixedExtentScrollController _controller;
  late List reversedItems;

  @override
  void initState() {
    super.initState();
    reversedItems = widget.items.reversed.toList();
    _controller = FixedExtentScrollController(
      initialItem: reversedItems.length - 1 - widget.initialIndex,
    );
  }

  // Plays haptic and sound feedback on selection.
  void _playFeedback() {
    if (widget.useSoundEffect) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return ListWheelScrollView.useDelegate(
      controller: _controller,
      physics: const FixedExtentScrollPhysics(),
      itemExtent: MediaQuery.of(context).size.height * 0.06,
      diameterRatio: 2.5,
      perspective: 0.003,
      useMagnifier: true,
      magnification: 1.2,
      onSelectedItemChanged: (index) {
        final originalIndex = reversedItems.length - 1 - index;
        widget.onSelected(widget.items[originalIndex]);
        _playFeedback();
      },
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= reversedItems.length) return null;
          final item = reversedItems[index];
          String? weekDay;

          if (widget.showWeekDay) {
            final monthIndex =
                [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec",
                ].indexOf(widget.month) +
                1;
            final dateForItem = DateTime(widget.year, monthIndex, item as int);
            weekDay = getWeekdayName(dateForItem);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  item.toString(),
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
              if (widget.showWeekDay && weekDay != null)
                Padding(
                  padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.01,
                  ),
                  child: Text(
                    weekDay,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      color:
                          weekDay == 'Sat' || weekDay == 'Sun'
                              ? Colors.red.shade600
                              : Colors.black,
                    ),
                  ),
                ),
            ],
          );
        },
        childCount: reversedItems.length,
      ),
    );
  }
}

// OrbitalDatePicker widget, providing an animated orbital UI for date selection.
class OrbitalDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final double size;

  const OrbitalDatePicker({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
    required this.size,
  });

  @override
  State<OrbitalDatePicker> createState() => _OrbitalDatePickerState();
}

class _OrbitalDatePickerState extends State<OrbitalDatePicker>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;
  late int _baseYear;
  late double _earthTotalAngle;
  late double _moonTotalAngle;

  late final AnimationController _snapController;
  Animation<double>? _snapAnim;

  String _interaction = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _baseYear = widget.initialDate.year;

    // Initialize angles for the orbital animation.
    _earthTotalAngle = (widget.initialDate.month - 1) * 30.0;
    final days = _daysInMonthFor(
      widget.initialDate.month,
      widget.initialDate.year,
    );
    _moonTotalAngle = (widget.initialDate.day - 1) * (360.0 / days);

    // Animation controller for snapping animations.
    _snapController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )
          ..addListener(() {
            setState(() {
              if (_interaction == 'earth_snap') {
                _earthTotalAngle = _snapAnim!.value;
              } else if (_interaction == 'moon_snap') {
                _moonTotalAngle = _snapAnim!.value;
              }
              _recomputeSelectedDateAndNotify();
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed ||
                status == AnimationStatus.dismissed) {
              _interaction = '';
            }
          });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  // Calculates the number of days in a month, accounting for leap years.
  int _daysInMonthFor(int month, int year) {
    if (month == 2) return _isLeapYear(year) ? 29 : 28;
    const thirty = <int>[4, 6, 9, 11];
    return thirty.contains(month) ? 30 : 31;
  }

  bool _isLeapYear(int y) => (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);


  // Recomputes the selected date based on angles and notifies the callback.
  void _recomputeSelectedDateAndNotify() {
    final yearsOffset = _earthTotalAngle ~/ 360;
    final year = _baseYear + yearsOffset;

    final monthIndex = (((_earthTotalAngle ~/ 30) % 12) + 12) % 12;
    final month = monthIndex + 1;

    final dim = _daysInMonthFor(month, year);

    final moonNormalized = ((_moonTotalAngle % 360) + 360) % 360;
    final dayIndex = (moonNormalized / (360.0 / dim)).floor().clamp(0, dim - 1);
    final day = dayIndex + 1;

    _selectedDate = DateTime(year, month, day);
    widget.onDateChanged(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final center = Offset(size / 2, size / 2);

    final sunRadius = size * 0.14;
    final earthOrbitRadius = size * 0.35; // Slightly larger for visibility.
    final earthRadius = size * 0.06;
    final moonOrbitRadius = earthRadius * 1.6;
    final moonRadius = earthRadius * 0.46;

    final earthDrawAngle = ((_earthTotalAngle % 360) + 360) % 360;
    final earthRad = earthDrawAngle * pi / 180.0;
    final earthPos = Offset(
      center.dx + earthOrbitRadius * cos(earthRad),
      center.dy + earthOrbitRadius * sin(earthRad),
    );

    final moonDrawAngle = ((_moonTotalAngle % 360) + 360) % 360;
    final moonRad = moonDrawAngle * pi / 180.0;
    final moonPos = Offset(
      earthPos.dx + moonOrbitRadius * cos(moonRad),
      earthPos.dy + moonOrbitRadius * sin(moonRad),
    );

    return GestureDetector(
      // Handles the start of a touch interaction.
      onPanStart: (details) {
        if (_snapController.isAnimating) _snapController.stop();

        final local = details.localPosition;

        final touchDistFromCenter = (local - center).distance;
        final distToEarth = (local - earthPos).distance;

        if (distToEarth <= earthRadius * 1.8) {
          _interaction = 'moon';
        } else if ((touchDistFromCenter - earthOrbitRadius).abs() <=
            earthRadius * 2.0) {
          _interaction = 'earth';
        } else {
          _interaction =
              touchDistFromCenter < earthOrbitRadius ? 'moon' : 'earth';
        }
      },
      onPanUpdate: (details) {
        // Implement if needed
      },
      onPanEnd: (_) {
        // Implement if needed
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: size,
        child: Stack(
          children: [
            // Sun emoji at the center.
            Positioned(
              left: center.dx + sunRadius + moonRadius + earthRadius,
              top: center.dy - moonRadius - earthRadius,
              child: Text(
                "☀️",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.12,
                ),
              ),
            ),
            // Earth emoji orbiting the sun.
            Positioned(
              left: earthPos.dx + sunRadius + moonRadius + (earthRadius * 1.5),
              top: earthPos.dy - earthRadius + (moonRadius / 2),
              child: Text(
                "🌍",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.07,
                ),
              ),
            ),
            // Moon emoji orbiting the Earth.
            Positioned(
              left: moonPos.dx + sunRadius + sunRadius,
              top: moonPos.dy - moonRadius,
              child: Text(
                "🌑",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Animates the orbital picker to a new date.
  void animateToDate(DateTime newDate) {
    final newEarthAngle = (newDate.month - 1) * 30.0;
    final newMoonAngle =
        (newDate.day - 1) *
        (360.0 / _daysInMonthFor(newDate.month, newDate.year));

    final earthTween = Tween<double>(
      begin: _earthTotalAngle,
      end: newEarthAngle,
    );
    final moonTween = Tween<double>(begin: _moonTotalAngle, end: newMoonAngle);

    final anim = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeInOut,
    );

    _snapAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: earthTween.chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
    ]).animate(anim);

    _snapController
      ..reset()
      ..duration = const Duration(milliseconds: 500)
      ..addListener(() {
        setState(() {
          _earthTotalAngle = earthTween.evaluate(anim);
          _moonTotalAngle = moonTween.evaluate(anim);
          _recomputeSelectedDateAndNotify();
        });
      })
      ..forward();
  }
}


// Returns the weekday name for a given date.
String getWeekdayName(DateTime date) {
  const weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  return weekdays[date.weekday - 1];
}
