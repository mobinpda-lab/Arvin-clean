      throw const FormatException('Arvin backup tasks are invalid');
    }

    return document;
  }

  String createBackupFileName(DateTime dateTime) {
    final jalali = _toJalali(dateTime.year, dateTime.month, dateTime.day);
    final year = jalali.$1.toString().padLeft(4, '0');
    final month = jalali.$2.toString().padLeft(2, '0');
    final day = jalali.$3.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return 'Arvin_Backup_$year-$month-$day_$hour-$minute.json';
  }

  /// Converts a Gregorian date to the Jalali/Persian calendar.
  (int, int, int) _toJalali(int gy, int gm, int gd) {
    final gregorianDay = _daysFromGregorianEpoch(gy, gm, gd);
    var jy = 1 + ((gregorianDay - _jalaliEpochDay) ~/ 12053) * 33;
    var remaining = (gregorianDay - _jalaliEpochDay) % 12053;
