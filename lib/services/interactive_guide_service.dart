import 'package:shared_preferences/shared_preferences.dart';

class InteractiveGuideService {
  static const seenKey = 'arvin.guide.homeCoachMarksSeen.v1';

  Future<bool> shouldShow() async {
    final preferences = await SharedPreferences.getInstance();
    return !(preferences.getBool(seenKey) ?? false);
  }

  Future<void> markSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(seenKey, true);
  }

  Future<void> reset() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(seenKey);
  }
}
