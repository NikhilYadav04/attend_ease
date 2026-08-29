import 'package:attend_ease/core/utils/attendance_time.dart';
import 'package:attend_ease/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AttendanceTime.parseEntryDate', () {
    test('parses dd/MM/yy', () {
      expect(AttendanceTime.parseEntryDate('02/07/26'), DateTime(2026, 7, 2));
    });

    test('parses four-digit year', () {
      expect(AttendanceTime.parseEntryDate('02/07/2026'), DateTime(2026, 7, 2));
    });

    test('returns null for garbage', () {
      expect(AttendanceTime.parseEntryDate(''), isNull);
      expect(AttendanceTime.parseEntryDate('02-07-26'), isNull);
      expect(AttendanceTime.parseEntryDate('aa/bb/cc'), isNull);
      expect(AttendanceTime.parseEntryDate('02/07'), isNull);
    });
  });

  group('AttendanceTime.calcHoursWorked', () {
    test('computes hours and minutes', () {
      expect(AttendanceTime.calcHoursWorked('09:00', '17:30'), '8h 30m');
    });

    test('whole hours omit minutes', () {
      expect(AttendanceTime.calcHoursWorked('09:00', '17:00'), '8h');
    });

    test('under an hour shows minutes only', () {
      expect(AttendanceTime.calcHoursWorked('09:00', '09:45'), '45m');
    });

    test('null for missing punch-out sentinel', () {
      expect(AttendanceTime.calcHoursWorked('09:00', '00:00'), isNull);
      expect(AttendanceTime.calcHoursWorked('00:00', '17:00'), isNull);
    });

    test('null for out before in', () {
      expect(AttendanceTime.calcHoursWorked('17:00', '09:00'), isNull);
    });

    test('null for nulls and dashes', () {
      expect(AttendanceTime.calcHoursWorked(null, '17:00'), isNull);
      expect(AttendanceTime.calcHoursWorked('—', '17:00'), isNull);
    });
  });

  group('AttendanceTime.isInMonth', () {
    test('matches same month and year', () {
      expect(AttendanceTime.isInMonth('15/07/26', DateTime(2026, 7, 1)), isTrue);
    });

    test('rejects different month', () {
      expect(AttendanceTime.isInMonth('15/06/26', DateTime(2026, 7, 1)), isFalse);
    });

    test('rejects unparseable', () {
      expect(AttendanceTime.isInMonth('', DateTime(2026, 7, 1)), isFalse);
    });
  });

  group('Validators.employeeId', () {
    test('accepts Name_code format', () {
      expect(Validators.employeeId('Nikhil_a3b4c5'), isNull);
    });

    test('rejects missing underscore', () {
      expect(Validators.employeeId('Nikhila3b4c5'), isNotNull);
    });

    test('rejects empty', () {
      expect(Validators.employeeId(''), isNotNull);
    });
  });
}
