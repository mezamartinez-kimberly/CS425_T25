import 'dart:collection';
import 'package:edna/backend_utils.dart';
import 'package:edna/dbs/pantry_db.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edna/calendar_utils.dart';
import 'package:edna/provider.dart';
import 'package:provider/provider.dart';
import 'package:edna/widgets/product_widget.dart'; // pantry item widget

class CalendarClass extends StatefulWidget {
  //can also turn off prefer_const_constructor under rules and put false so that you dont need these
  const CalendarClass({super.key});
  @override
  CalendarClassState createState() => CalendarClassState();
}

class CalendarClassState extends State<CalendarClass> {
  late final ValueNotifier<List<ProductWidget>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late List<Pantry> activePantryItems;
  List<ProductWidget> activePantryWidgets = [];

  late final Map<DateTime, List<ProductWidget>> _kEventSource =
      <DateTime, List<ProductWidget>>{};

  late LinkedHashMap<DateTime, List<ProductWidget>> _kEvents;

  // ignore: non_constant_identifier_names
  _TableEventsExampleState() async {
    // get the active pantry items from the provider
    final allPantryItems = await BackendUtils.getAllPantry();

    // only get pantry items that are visible in the pantry and arent deleted
    final activePantryItems = allPantryItems
        .where((item) => item.isVisibleInPantry == 1 && item.isDeleted == 0)
        .toList();
    // activePantryItems = Provider.of<PantryProvider>(context, listen: false)
    //     .activePantryAllLocations;

    for (final pantry in activePantryItems) {
      activePantryWidgets.add(ProductWidget(
        pantryItem: pantry,
        callingWidget: widget,
      ));
    }

    for (final productWidget in activePantryWidgets) {
      (_kEventSource[productWidget.pantryItem.expirationDate as DateTime] ??=
              [])
          .add(productWidget);

      // print the name of the item
      // print(productWidget.pantryItem.name);
    }

    _kEvents = LinkedHashMap<DateTime, List<ProductWidget>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_kEventSource);
  }

  @override
  void initState() {
    super.initState();

    _TableEventsExampleState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<ProductWidget> _getEventsForDay(DateTime day) {
    // Implementation example
    return _kEventSource.entries
        .where((entry) => isSameDay(entry.key, day))
        .expand((entry) => entry.value)
        .toList();

    // print the selected day's events name
  }

  List<ProductWidget> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //change text color to black and align the text to the left
        title: const Text('Calendar',
            style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto')),
        leadingWidth: 0,
        centerTitle: false,
        // make transparent
        backgroundColor: Colors.transparent,
        // remove shadow
        shadowColor: Colors.transparent,
        elevation: 1,
      ),
      body: Column(
        children: [
          TableCalendar<ProductWidget>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            daysOfWeekHeight: 40.0,
            rowHeight: 50.0,
            //month name & arrow(chevron) customization
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(
                fontFamily: 'Noto Sans',
                fontSize: 19.45,
                color: Color(0xFF4A5660),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Color(0xFF8E8E93),
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Color(0xFF8E8E93),
              ),
            ),
            //days of week/weekend UI customization
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontFamily: 'Dekko',
                color: Color(0xFFB5BEC6),
              ),
              weekendStyle: TextStyle(
                fontFamily: 'Dekko',
                color: Color(0xFFB5BEC6),
              ),
            ),
            //numbers UI customization
            calendarStyle: const CalendarStyle(
              weekNumberTextStyle: TextStyle(
                fontFamily: 'Noto Serif',
                color: Color(0xFF4A5660),
              ),
              weekendTextStyle: TextStyle(
                fontFamily: 'Noto Serif',
                color: Color(0xFF4A5660),
              ),
              //todays color circle
              todayDecoration: BoxDecoration(
                color: Color(0xFFF7A4A2),
                shape: BoxShape.circle,
              ),
              //selected color
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(131, 247, 164, 162),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<ProductWidget>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    //  print(value[index]);
                    return value[index];
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//----------------------
