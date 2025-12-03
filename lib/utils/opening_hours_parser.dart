import 'package:flutter/material.dart';

class OpeningHoursParser {
  /// Checks if the facility is open at the given [dateTime].
  /// Returns true if open, false if closed.
  /// Returns true (safe default) if openingHours string is null or unparseable,
  /// but you can check [isParseable] to know if we actually understood the format.
  static bool isOpen(String? openingHours, DateTime dateTime) {
    if (openingHours == null || openingHours.isEmpty) {
      return true; // Assume open if unknown
    }

    try {
      return _checkTime(openingHours, dateTime);
    } catch (e) {
      debugPrint('Error parsing opening hours: $e');
      return true; // Fallback
    }
  }

  static bool _checkTime(String openingHours, DateTime dateTime) {
    // Basic parser for "Mo-Fr 08:00-18:00" or "Mo,Tu,We 08:00-12:00; Th 08:00-18:00" style
    // This is NOT a full OSM opening_hours parser, but covers common simple cases.

    // Normalize
    final normalized = openingHours.replaceAll(' ', ''); 
    // Example: Mo-Fr08:00-18:00

    // Get current day abbreviation (Mo, Tu, We, Th, Fr, Sa, Su)
    final weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final currentDay = weekDays[dateTime.weekday - 1];

    // Split by semicolon for different rules
    final rules = normalized.split(';');

    for (var rule in rules) {
      // Check if this rule applies to the current day
      if (_appliesToDay(rule, currentDay, weekDays)) {
        // Parse time ranges
        return _checkTimeRange(rule, dateTime);
      }
    }

    // If no rule matched the day, it's usually closed (unless 24/7)
    if (normalized.contains('24/7')) return true;

    return false; 
  }

  static bool _appliesToDay(String rule, String currentDay, List<String> weekDays) {
    // Extract day part (e.g., "Mo-Fr" from "Mo-Fr08:00-18:00")
    // Simple regex to find day part
    // Matches "Mo-Fr", "Mo,Tu", "Mo" at start
    final dayPartMatch = RegExp(r'^([a-zA-Z,\-]+)').firstMatch(rule);
    if (dayPartMatch == null) return false;

    final dayPart = dayPartMatch.group(1)!;

    if (dayPart.contains('-')) {
      // Range: Mo-Fr
      final parts = dayPart.split('-');
      if (parts.length == 2) {
        final start = weekDays.indexOf(parts[0]);
        final end = weekDays.indexOf(parts[1]);
        final current = weekDays.indexOf(currentDay);
        if (start != -1 && end != -1 && current != -1) {
          if (start <= end) {
            return current >= start && current <= end;
          } else {
            // Wrap around (e.g. Fr-Mo)
            return current >= start || current <= end;
          }
        }
      }
    } else if (dayPart.contains(',')) {
      // List: Mo,Tu,We
      final days = dayPart.split(',');
      return days.contains(currentDay);
    } else {
      // Single day: Mo
      return dayPart == currentDay;
    }
    
    // Check for "PH" (Public Holidays) or "off" - ignoring for simplicity
    return false;
  }

  static bool _checkTimeRange(String rule, DateTime dateTime) {
    // Extract time part. Everything after the first digit?
    // Regex for time ranges: \d{1,2}:\d{2}-\d{1,2}:\d{2}
    final timeRegex = RegExp(r'(\d{1,2}:\d{2})-(\d{1,2}:\d{2})');
    final matches = timeRegex.allMatches(rule);

    if (matches.isEmpty) return false; // No time found?

    final currentMinutes = dateTime.hour * 60 + dateTime.minute;

    for (var match in matches) {
      final startStr = match.group(1)!;
      final endStr = match.group(2)!;

      final startMinutes = _timeToMinutes(startStr);
      final endMinutes = _timeToMinutes(endStr);

      if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
        return true;
      }
    }

    return false;
  }

  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
  
  /// Formats opening hours for display
  static String formatForDisplay(String? openingHours) {
      if (openingHours == null) return "Hours not available";
      return openingHours.replaceAll(';', '\n');
  }
}
