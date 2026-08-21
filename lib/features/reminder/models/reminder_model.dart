import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../core/models/base_entity.dart';

/// مدل اصلی برای یادآوری‌ها (Reminder)
class Reminder extends BaseEntity with EquatableMixin {
  final String id;
  final String? taskId;
  final String title;
  final String? description;
  final DateTime reminderDateTime;
  final bool isActive;
  final bool isCompleted;
  final RepeatType repeatType;
  final Priority priority;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    this.id = '',
    this.taskId,
    this.title = '',
    this.description,
    required this.reminderDateTime,
    this.isActive = true,
    this.isCompleted = false,
    this.repeatType = RepeatType.none,
    this.priority = Priority.medium,
    this.color = Colors.blue,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Reminder copyWith({
    String? id,
    String? taskId,
    String? title,
    String? description,
    DateTime? reminderDateTime,
    bool? isActive,
    bool? isCompleted,
    RepeatType? repeatType,
    Priority? priority,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      repeatType: repeatType ?? this.repeatType,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'description': description,
      'reminderDateTime': reminderDateTime.toIso8601String(),
      'isActive': isActive,
      'isCompleted': isCompleted,
      'repeatType': repeatType.toString(),
      'priority': priority.toString(),
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      taskId: json['taskId'],
      title: json['title'] ?? '',
      description: json['description'],
      reminderDateTime: DateTime.parse(json['reminderDateTime']),
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      repeatType: RepeatType.fromString(json['repeatType'] ?? 'none'),
      priority: Priority.fromString(json['priority'] ?? 'medium'),
      color: Color(json['color'] ?? Colors.blue.value),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        taskId,
        title,
        description,
        reminderDateTime,
        isActive,
        isCompleted,
        repeatType,
        priority,
        color,
        createdAt,
        updatedAt,
      ];
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
  custom;

  static RepeatType fromString(String value) {
    return RepeatType.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => RepeatType.none,
    );
  }

  String get displayName {
    switch (this) {
      case RepeatType.none:
        return 'بدون تکرار';
      case RepeatType.daily:
        return 'روزانه';
      case RepeatType.weekly:
        return 'هفتگی';
      case RepeatType.monthly:
        return 'ماهانه';
      case RepeatType.yearly:
        return 'سالانه';
      case RepeatType.custom:
        return 'سفارشی';
    }
  }
}

enum Priority {
  low,
  medium,
  high;

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.toString() == value,
      orElse: () => Priority.medium,
    );
  }

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'کم';
      case Priority.medium:
        return 'متوسط';
      case Priority.high:
        return 'بالا';
    }
  }

  Color get color {
    switch (this) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }
}