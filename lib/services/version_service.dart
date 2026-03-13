import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../app.dart';
import '../core/utils/app_api.dart';

class VersionService {
  static const String _currentVersion = '1.0.0+1';

  static Future<Map<String, dynamic>> checkVersion() async {
    try {
      print('═' * 60);
      print('[VersionService] 🔍 تحقق من إصدار التطبيق');
      print('[VersionService] 📱 الإصدار الحالي: $_currentVersion');
      print(
        '[VersionService] 🌍 المنصة: ${Platform.isAndroid
            ? 'Android'
            : Platform.isIOS
            ? 'iOS'
            : 'Other'}',
      );

      var uri = Uri.parse('${AppApi.baseUrl}/PrivacyPolicy/app_version');
      print('[VersionService] 🌐 API URL: $uri');

      var request = http.Request('GET', uri);

      request.headers.addAll({
        'Accept': 'application/json',
        'Accept-Language': 'en',
      });

      print('[VersionService] ⏳ جاري إرسال الطلب...');
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('[VersionService] ✅ استجابة API تلقيت');
      print('[VersionService] Status: ${response.statusCode}');
      print('[VersionService] Body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          var data = jsonDecode(responseData);
          print('[VersionService] 📋 الاستجابة الكاملة: $data');

          // Handle nested data structure - API wraps data in 'data' field
          var versionData;
          if (data is Map && data.containsKey('data')) {
            versionData = data['data'];
            print('[VersionService] ℹ️  تم استخراج البيانات من حقل data');
            print('[VersionService] 📋 بيانات الإصدار: $versionData');
          } else {
            versionData = data is Map ? data : null;
          }

          if (versionData == null || versionData is! Map) {
            print(
              '[VersionService] ❌ صيغة الاستجابة غير صحيحة أو بيانات فارغة',
            );
            return {
              'success': false,
              'shouldUpdate': true,
              'reason': 'صيغة الاستجابة غير صحيحة',
            };
          }

          // Get platform-specific version
          String? appVersion;
          if (Platform.isAndroid) {
            appVersion = versionData['version_android']?.toString();
            print('[VersionService] 🤖 إصدار Android من API: $appVersion');
          } else if (Platform.isIOS) {
            appVersion = versionData['version_ios']?.toString();
            print('[VersionService] 🍎 إصدار iOS من API: $appVersion');
          } else {
            appVersion =
                versionData['version_android']?.toString() ??
                versionData['version_ios']?.toString();
            print(
              '[VersionService] ⚙️  الإصدار من API (fallback): $appVersion',
            );
          }

          // Check force flag (0 = mandatory/اجباري, 1 = optional/اختياري)
          int? forceFlag = versionData['force'] != null
              ? int.tryParse(versionData['force'].toString())
              : null;
          print(
            '[VersionService] 🚀 علم التحديث: $forceFlag (0=اجباري/mandatory, 1=اختياري/optional)',
          );

          // Extract platform links if provided by API
          String? androidLink = versionData['android_link']?.toString();
          String? iosLink = versionData['ios_link']?.toString();
          print(
            '[VersionService] 🔗 روابط التحديث: android=$androidLink, ios=$iosLink',
          );

          if (appVersion != null && appVersion.trim().isNotEmpty) {
            // Keep full version string with build number for comparison
            String fullVersion = appVersion.trim();
            print('[VersionService] 📌 الإصدار من API: $fullVersion');
            print(
              '[VersionService] 🔄 المقارنة: API=$fullVersion vs Current=$_currentVersion',
            );

            bool versionMatches = fullVersion == _currentVersion;
            print('[VersionService] ✓ تطابق الإصدار: $versionMatches');

            // New Logic:
            // If force == 1 (optional): Check version compatibility
            //   - If version matches: Allow entry
            //   - If version doesn't match: Show update screen
            // If force == 0 (mandatory): Allow entry directly without version check

            if (forceFlag == 1) {
              // Optional update - check version compatibility
              print(
                '[VersionService] 📌 التحديث اختياري (force=1) - فحص التوافق',
              );

              if (versionMatches) {
                print('[VersionService] ✅ الإصدارات متطابقة - السماح بالدخول');
                print('═' * 60);
                return {
                  'success': true,
                  'shouldUpdate': false,
                  'reason': 'الإصدارات متطابقة - السماح بالدخول',
                  'android_link': androidLink,
                  'ios_link': iosLink,
                };
              } else {
                print(
                  '[VersionService] ⚠️  الإصدارات غير متطابقة - عرض صفحة التحديث',
                );
                print('═' * 60);
                return {
                  'success': true,
                  'shouldUpdate': true,
                  'reason':
                      'عدم تطابق الإصدار (API=$fullVersion, Current=$_currentVersion)',
                  'android_link': androidLink,
                  'ios_link': iosLink,
                };
              }
            } else if (forceFlag == 0) {
              // Mandatory update - allow entry directly without version check
              print(
                '[VersionService] 📌 التحديث إجباري (force=0) - السماح بالدخول مباشرة بدون فحص',
              );
              print('═' * 60);
              return {
                'success': true,
                'shouldUpdate': false,
                'reason':
                    'التحديث إجباري - السماح بالدخول المباشر بدون فحص النسخة',
                'android_link': androidLink,
                'ios_link': iosLink,
              };
            } else {
              // Unknown force flag - treat as optional
              print(
                '[VersionService] ⚠️  علم التحديث غير معروف: $forceFlag - التعامل كاختياري',
              );

              if (versionMatches) {
                print('[VersionService] ✅ الإصدارات متطابقة - السماح بالدخول');
                print('═' * 60);
                return {
                  'success': true,
                  'shouldUpdate': false,
                  'reason': 'الإصدارات متطابقة - السماح بالدخول',
                  'android_link': androidLink,
                  'ios_link': iosLink,
                };
              } else {
                print(
                  '[VersionService] ⚠️  الإصدارات غير متطابقة - عرض صفحة التحديث',
                );
                print('═' * 60);
                return {
                  'success': true,
                  'shouldUpdate': true,
                  'reason':
                      'عدم تطابق الإصدار (API=$fullVersion, Current=$_currentVersion)',
                  'android_link': androidLink,
                  'ios_link': iosLink,
                };
              }
            }
          } else {
            print('[VersionService] ❌ لا يوجد إصدار في استجابة API');
            print('═' * 60);
            return {
              'success': false,
              'shouldUpdate': true,
              'reason': 'لا يوجد إصدار في استجابة API',
              'android_link': androidLink,
              'ios_link': iosLink,
            };
          }
        } catch (e) {
          print('[VersionService] ❌ خطأ في تحليل الاستجابة: $e');
          print('═' * 60);
          return {
            'success': false,
            'shouldUpdate': true,
            'reason': 'خطأ في تحليل الاستجابة: $e',
          };
        }
      } else {
        print('[VersionService] ❌ خطأ API: ${response.statusCode}');
        print('[VersionService] السبب: خطأ في الخادم أو الاتصال');
        print('═' * 60);
        return {
          'success': false,
          'shouldUpdate': false,
          'reason': 'خطأ API: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('[VersionService] ❌ استثناء أثناء التحقق: $e');
      print('[VersionService] السبب: فشل الاتصال أو خطأ في المعالجة');
      print('═' * 60);
      return {'success': false, 'shouldUpdate': false, 'reason': 'استثناء: $e'};
    }
  }
  /// Get the app store URL for the current platform
  static String getAppStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.salhly.app';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/salhly/id1234567890';
    }
    return '';
  }
}
