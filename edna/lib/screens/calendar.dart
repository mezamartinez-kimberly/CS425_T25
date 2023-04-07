import 'dart:collection';
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
  late final ValueNotifier<List<Pantry>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  late List<Pantry> activePantryItems;

  late final Map<DateTime, List<Pantry>> _kEventSource;

  late LinkedHashMap<DateTime, List<Pantry>> _kEvents;

  // ignore: non_constant_identifier_names
  _TableEventsExampleState() {
    // get the active pantry items from the provider
    activePantryItems = Provider.of<PantryProvider>(context, listen: false).activePantryItems;

    // loop through the active patry list and translate it into a map where the key is the expiration date and the value is the pantry object
    _kEventSource = {
      for (final pantry in activePantryItems) pantry.expirationDate!: [pantry]
    };

    print(_kEventSource);

    _kEvents = LinkedHashMap<DateTime, List<Pantry>>(
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

  List<Pantry> _getEventsForDay(DateTime day) {
    // Implementation example
    return _kEvents[day] ?? [];
  }

  List<Pantry> _getEventsForRange(DateTime start, DateTime end) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontSize: 30.0,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar<Pantry>(
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
            child: ValueListenableBuilder<List<Pantry>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        onTap: () => print('${value[index]}'),
                        title: Text('${value[index]}'),
                      ),
                    );
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
