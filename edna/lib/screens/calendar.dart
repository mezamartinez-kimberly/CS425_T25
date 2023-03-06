/* 
==============================
*    Title: calendar.dart
*    Author: Kimberly Meza Martinez
*    Date: Dec 2022
==============================
*/

/* Referenced code:
* https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/pages/events_example.dart 
*/

//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:edna/calendar_utils.dart';

class CalendarClass extends StatefulWidget {
  //can also turn off prefer_const_constructor under rules and put false so that you dont need these
  const CalendarClass({super.key});
  @override
  CalendarClassState createState() => CalendarClassState();
}

class CalendarClassState extends State<CalendarClass> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month; //format is by month
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  // DateTime? _rangeStart;
  // DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  
  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }


  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        // _rangeStart = null; // Important to clean those
        // _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Calendar', 
        style: TextStyle(fontSize: 30.0,
        color: Colors.black, 
        ),
      ),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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
                color:Color(0xFF4A5660),
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
                color: Color(0xFFF7A4A2),
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
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
            child: ValueListenableBuilder<List<Event>>(
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