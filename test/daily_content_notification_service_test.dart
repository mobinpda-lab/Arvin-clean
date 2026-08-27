import 'package:flutter_test/flutter_test.dart';
import 'package:arvin/daily_content.dart';
import 'package:arvin/daily_content_notification_service.dart';

const _item = DailyContentItem(
  id: 'nahj-hikmat-1',
  kind: DailyContentKind.nahjAlBalagha,
  text: 'ارزش هر کس به اندازه چیزی است که آن را نیکو می‌داند.',
  author: 'امام علی (ع)',
  source: 'نهج‌البلاغه',
  reference: 'حکمت ۸۱',
  verifiedBy: 'مرجع معتبر',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('notification id is stable for the same content item', () {
    final service = DailyContentNotificationService();
    expect(service.notificationIdFor(_item), service.notificationIdFor(_item));
    expect(service.notificationIdFor(_item), greaterThan(0));
  });

  test('unpublishable content is ignored before notification initialization', () async {
    final service = DailyContentNotificationService();
    const invalid = DailyContentItem(
      id: 'invalid',
      kind: DailyContentKind.shiaHadith,
      text: 'متن بدون مأخذ',
      author: 'نامشخص',
      source: '',
      reference: '',
      verifiedBy: '',
    );

    await expectLater(service.show(invalid), completes);
  });
}
