import 'dart:io' show Platform;

bool get supportsAutomaticFollowUpScheduling => Platform.isAndroid;
