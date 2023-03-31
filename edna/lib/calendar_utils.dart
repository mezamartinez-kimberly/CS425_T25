/* 
==============================
*    Title: utils.dart
*    Author: Kimberly Meza Martinez
*    Date: Dec 2022
==============================
*/

/* Referenced code:
* https://github.com/aleksanderwozniak/table_calendar/blob/master/example/lib/utils.dart 
*/

import 'dart:collection';
import 'package:path/path.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:edna/dbs/pantry_db.dart';
import 'package:edna/provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:edna/screens/all.dart';

/// Example event class.
// class Event {
//   final String title;

//   const Event(this.title);

//   @override
//   String toString() => title;
// }

/// Example events.
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
/// --------------------
// final kEvents = LinkedHashMap<DateTime, List<Pantry>>(
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll(_kEventSource);

//create pantry map almost does same as createEvents, createEvents better?
//create a linked hash map of pantry items using createPantryMap()
Map<DateTime, List<Pantry>> createPantryMap() {   //was LinkedHashMap
  final List<Pantry> activePantryItems = CalendarClassState().getActivePantryItems();

  // Loop through the pantry items and group them by date
  for (Pantry item in activePantryItems) {
    // Parse the date from the item (assuming not null)
    DateTime date = item.expirationDate as DateTime;

    // Check if a list for the date already exists in the map, and create one if not
    if (!kEvents.containsKey(date)) {
      kEvents[date] = [];
    }

    // Add the item to the list for the date
    kEvents[date]?.add(item);
  }

  return kEvents;
}

//create a LinkedHashMap<DateTime, List<Event>> from the pantry items
LinkedHashMap<DateTime, List<Pantry>> createEvents() { //was LinkedHashMap<DateTime, List<Pantry>> createEvents(List<Pantry> pantryItems)

  final List<Pantry> activePantryItems = CalendarClassState().getActivePantryItems();

  // Loop through the pantry items and group them by date
  for (Pantry item in activePantryItems) {
    // Parse the date from the item (assuming not null)
    DateTime date = item.expirationDate as DateTime;

    // Check if a list for the date already exists in the map, and create one if not
    if (!kEvents.containsKey(date)) {
      kEvents[date] = [];
    }

    // Add the item to the list for the date
    kEvents[date]?.add(item);
  }

  return kEvents;
}

//final newEvents = createEvents(kEvents);

// final _kEventSource = { for (var item in List.generate(50, (index) => index)) DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5) : List.generate(
//         item % 4 + 1, (index) => Pantry()) }
//   ..addAll({
//     kToday: [
//        Pantry(),
//        Pantry(),
//     ],
//   });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
//-----------------------------------------------------------

final kEvents = LinkedHashMap<DateTime, List<Pantry>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(createPantryMap());

// final _kEventSource = { for (var item in List.generate(50, (index) => index)) DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5) : List.generate(
//         item % 4 + 1, (index) => Pantry()) }
//   ..addAll({
//     kToday: [
//        Pantry(),
//        Pantry(),
//     ],
//   });

 // final eventsReturned = LinkedHashMap<DateTime, List<Pantry>>(createPantryMap());

 // final _kEventSource = createPantryMap();


///////////////////////////////
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
// final kEvents = LinkedHashMap<DateTime, List<Pantry>>(
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll(createEvents(getActivePantryItems()));


// final LinkedHashMap<DateTime, List<Pantry>> myEvents = {};

// myEvents = LinkedHashMap<DateTime, List<Pantry>>(
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll();
//-------------
//  Map<DateTime, List<Pantry>> createPantryMap() {
//   // get active pantry items
//     final List<Pantry> activePantryItems = CalendarClassState().getActivePantryItems();
//   var pantryItems = activePantryItems;  
//   // print(pantryItems.length);

//   Map<DateTime, List<Pantry>> pantryMap = {};

//   // Loop through the pantry items and group them by date
//   for (Pantry item in pantryItems) {
//     // Parse the date from the item (assuming not null)
//     DateTime date = item.expirationDate as DateTime;

//     // Check if a list for the date already exists in the map, and create one if not
//     if (!pantryMap.containsKey(date)) {
//       pantryMap[date] = [];
//     }

//     // Add the item to the list for the date
//     pantryMap[date]?.add(item);
//   }

//   return pantryMap;
// }