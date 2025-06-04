import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:todo/services/auth_service.dart';
import 'package:todo/services/theme_services.dart';
import 'package:todo/ui/theme.dart';
import 'package:todo/ui/pages/login_page.dart';

import 'db/db_helper.dart';
import 'firebase_options.dart';

/**
 * 앱의 진입점(Entry Point)
 * Firebase, 데이터베이스, 상태 관리 등 앱에 필요한 모든 서비스를 초기화
 */
void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 초기화 - 인증 및 데이터베이스 서비스를 위해 필요
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 로컬 데이터베이스 초기화 - 할 일 정보를 로컬에 저장
  await DBHelper.initDb();
  // GetStorage 초기화 - 앱 설정 및 사용자 기본 설정 저장에 사용
  await GetStorage.init();
  
  // 인증 서비스 초기화 - 사용자 로그인, 로그아웃 등 인증 관련 기능 제공
  Get.put(AuthService());
  
  // MyApp을 실행하여 앱 시작
  runApp(const MyApp());
}

/**
 * 앱의 루트 위젯
 * 테마, 라우팅, 앱 타이틀 등 앱의 전역 설정을 정의
 */
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  /**
   * 앱의 UI 구조를 빌드하는 메서드
   * GetMaterialApp을 사용하여 라우팅, 테마, 홈 화면 등을 설정
   */
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // 라이트 테마 설정
      theme: Themes.light,
      // 다크 테마 설정
      darkTheme: Themes.dark,
      // 현재 사용 중인 테마 모드 설정 (라이트/다크)
      themeMode: ThemeServices().theme,
      // 앱 타이틀 설정
      title: '할 일 관리',
      // 디버그 배너 숨김
      debugShowCheckedModeBanner: false,
      // 앱 시작 시 표시할 첫 화면 (로그인 페이지)
      home: const LoginPage(),
    );
  }
}
