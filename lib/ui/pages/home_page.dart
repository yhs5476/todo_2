// 필요한 패키지 및 모듈 가져오기
import 'package:date_picker_timeline/date_picker_timeline.dart';  // 달력 날짜 선택을 위한 패키지
import 'package:firebase_auth/firebase_auth.dart';  // Firebase 사용자 인증
import 'package:flutter/material.dart';  // 기본 Material 디자인
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';  // 애니메이션 효과
import 'package:flutter_svg/flutter_svg.dart';  // SVG 이미지 표시
import 'package:get/get.dart';  // GetX 상태 관리 패키지
import 'package:google_fonts/google_fonts.dart';  // 구글 폰트 적용
import 'package:intl/intl.dart';  // 날짜 및 시간 포맷팅
import 'package:todo/services/auth_service.dart';  // 사용자 인증 서비스
import 'package:todo/services/theme_services.dart';  // 테마 관리 서비스
import 'package:todo/ui/pages/login_page.dart';  // 로그인 페이지
import 'package:todo/ui/pages/add_speech_to_text.dart';  // 음성인식으로 할일 추가 페이지
import 'package:todo/ui/pages/add_task_page.dart';  // 할일 추가 페이지
import 'package:todo/ui/widgets/button.dart';  // 커스텀 버튼 위젯
import 'package:todo/ui/widgets/task_tile.dart';  // 할일 목록 아이템 위젯
import '../../controllers/task_controller.dart';  // 할일 관리 컨트롤러
import '../../models/task.dart';  // 할일 모델 정의
import '../../services/notification_services.dart';  // 알림 서비스
import '../size_config.dart';  // 화면 크기 관리 유틸리티
import '../theme.dart';  // 앱 테마 설정

// 홈 페이지 - 할일 관리의 메인 화면 위젯
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();  // 상태 관리 클래스 생성
}

// 홈화면의 상태를 관리하는 클래스
class _HomePageState extends State<HomePage> {
  // 알림 관리를 위한 헬퍼 객체
  late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();
    // 알림 헬퍼 초기화
    notifyHelper = NotifyHelper();
    // iOS에서 알림 권한 요청
    notifyHelper.requestIOSPermissions();
    // 알림 기능 초기화
    notifyHelper.initializeNotification();
    // 할일 목록 가져오기
    _taskController.getTasks();
    
    // 사용자 로그인 상태 확인
    _checkUserLogin();
  }
  
  // 사용자 로그인 상태 확인 메소드
  Future<void> _checkUserLogin() async {
    // Firebase Auth 상태가 정확히 반영될 수 있도록 짧은 딜레이 추가
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 로그인되지 않았다면 로그인 화면으로 이동
    if (FirebaseAuth.instance.currentUser == null) {
      Get.offAll(() => const LoginPage(), transition: Transition.fadeIn);  // 로그인 페이지로 강제 이동 (뒤로가기 기록 삭제)
    } else {
      // 로그인되어 있는 경우 사용자 정보 출력 (디버깅 용도)
      print("사용자 로그인됨: ${FirebaseAuth.instance.currentUser?.displayName}");
    }
  }

  // 현재 선택된 날짜 (기본값은 오늘)
  DateTime _selectedDate = DateTime.now();
  
  // 할일 관리를 위한 컨트롤러 초기화 및 의존성 주입
  final TaskController _taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    // 화면 크기 관리 초기화 (반응형 디자인을 위함)
    SizeConfig().init(context);
    
    return Scaffold(
      // 배경색 설정 - 현재 테마에 따라 다른 배경색 적용
      // ignore: deprecated_member_use
      backgroundColor: context.theme.scaffoldBackgroundColor,
      
      // 상단 앱바 생성
      appBar: _customAppBar(),
      
      // 본문 내용 구성
      body: Column(
        children: [
          _addTaskBar(),   // 할일 추가 버튼과 날짜 표시 부분
          _addDateBar(),   // 달력 날짜 선택기 부분
          const SizedBox(
            height: 6,
          ),
          _showTasks(),    // 할일 목록 표시 부분
        ],
      ),
      
      // 음성 인식으로 할일 추가하는 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // 음성인식 페이지로 이동
          await Get.to(() => const AddSpeechToTextPage());
          // 새로운 할일 목록 가져오기
          _taskController.getTasks();
        },
        backgroundColor: primaryClr,
        child: const Icon(Icons.mic),  // 마이크 아이콘
      ),
      
      // 플로팅 버튼 위치 (왼쪽 아래쪽 설정)
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  // 커스텀 앱바 구성 메소드
  AppBar _customAppBar() {
    return AppBar(
      // 배경색 설정 - 현재 테마에 따라 표시
      // ignore: deprecated_member_use
      backgroundColor: context.theme.scaffoldBackgroundColor,
      
      // 그림자 제거 (평면 앱바)
      elevation: 0,
      
      // 좌측 버튼 - 테마 변경 버튼 구현
      leading: GestureDetector(
        onTap: () {
          // 테마 변경 (라이트/다크 모드 전환)
          ThemeServices().switchTheme();
          
          // 테마 변경 시 알림 표시
          notifyHelper.displayNotification(
              title: "Theme Changed",
              body: Get.isDarkMode
                  ? "Activated Light Theme"
                  : "Activated Dark Theme");
          //notifyHelper.scheduledNotification();
        },
        // 현재 테마에 따라 다른 아이콘 표시
        child: Icon(
          // 다크 모드일 때 해 아이콘, 라이트 모드일 때 달 아이콘
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          // 테마에 따라 아이콘 색상 변경
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      
      // 우측 기능 버튼들
      actions: [
        // 사용자 프로필 섹션 (로그아웃 메뉴 포함)
        _buildProfileSection(),
        const SizedBox(width: 20),
      ],
    );
  }
  
  // 사용자 프로필 및 계정 관리 섹션 구성 메소드
  Widget _buildProfileSection() {
    // 현재 Firebase에 로그인된 사용자 정보 가져오기
    User? user = FirebaseAuth.instance.currentUser;
    
    // 팝업 메뉴 버튼 구성
    return PopupMenuButton<String>(
      // 사용자 프로필 이미지 표시
      icon: CircleAvatar(
        // 구글 프로필 이미지가 있으면 해당 이미지를 사용, 없으면 기본 이미지 사용
        backgroundImage: user?.photoURL != null 
          ? NetworkImage(user!.photoURL!) 
          : const AssetImage("images/person.jpeg") as ImageProvider,
        radius: 18,
      ),
      // 메뉴 아이템 선택 시 작업 처리
      onSelected: (value) {
        if (value == 'logout') {
          // 로그아웃 기능 실행
          _handleSignOut();
        }
      },
      // 팝업 메뉴 아이템 구성
      itemBuilder: (BuildContext context) => [
        // 프로필 표시 메뉴
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, color: primaryClr),
              const SizedBox(width: 10),
              // 사용자 이름 표시 (없을 경우 기본값 설정)
              Text(user?.displayName ?? '사용자'),
            ],
          ),
        ),
        // 로그아웃 메뉴
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('로그아웃'),
            ],
          ),
        ),
      ],
    );
  }
  
  // 로그아웃 처리 메소드
  void _handleSignOut() async {
    // AuthService를 통한 로그아웃 처리
    await Get.find<AuthService>().signOut();
    
    // 로그인 화면으로 강제 이동 (뒤로가기 기록 삭제)
    Get.offAll(() => const LoginPage());
    
    // 로그아웃 성공 메시지 표시
    Get.snackbar(
      "로그아웃 성공", 
      "로그아웃되었습니다.",
      snackPosition: SnackPosition.BOTTOM,  // 하단에 표시
      backgroundColor: Colors.green,  // 배경색은 초록색
      colorText: Colors.white,  // 텍스트 색상은 흰색
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                '오늘',
                style: subHeadingStyle,
              ),
            ],
          ),
          MyButton(
              label: '+ 할 일 추가',
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              }),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
      child: DatePicker(
        DateTime.now(),
        width: 80,
        height: 100,
        initialSelectedDate: _selectedDate,
        selectedTextColor: Colors.white,
        selectionColor: primaryClr,
        dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        )),
        monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        )),
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    _taskController.getTasks();
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        if (_taskController.taskList.isEmpty) {
          return _noTaskMsg();
        } else {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              scrollDirection: SizeConfig.orientation == Orientation.landscape
                  ? Axis.horizontal
                  : Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                var task = _taskController.taskList[index];

                if (task.repeat == 'Daily' ||
                    task.date == DateFormat.yMd().format(_selectedDate) ||
                    (task.repeat == 'Weekly' &&
                        _selectedDate
                                    .difference(
                                        DateFormat.yMd().parse(task.date!))
                                    .inDays %
                                7 ==
                            0) ||
                    (task.repeat == 'Monthly' &&
                        DateFormat.yMd().parse(task.date!).day ==
                            _selectedDate.day)) {
                  try {
                    /*   var hour = task.startTime.toString().split(':')[0];
                    var minutes = task.startTime.toString().split(':')[1]; */
                    var date = DateFormat.jm().parse(task.startTime!);
                    var myTime = DateFormat('HH:mm').format(date);

                    notifyHelper.scheduledNotification(
                      int.parse(myTime.toString().split(':')[0]),
                      int.parse(myTime.toString().split(':')[1]),
                      task,
                    );
                  } catch (e) {
                    print('Error parsing time: $e');
                  }
                } else {
                  Container();
                }
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 1375),
                  child: SlideAnimation(
                    horizontalOffset: 300,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () => _showBottomSheet(context, task),
                        child: TaskTile(task),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _taskController.taskList.length,
            ),
          );
        }
      }),
    );
  }

  _noTaskMsg() {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 6,
                        )
                      : const SizedBox(
                          height: 220,
                        ),
                  SvgPicture.asset(
                    'images/task.svg',
                    // ignore: deprecated_member_use
                    color: primaryClr.withOpacity(0.5),
                    height: 90,
                    semanticsLabel: 'Task',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      '아직 할 일이 없습니다!\n새로운 할 일을 추가하여 하루를 생산적으로 만드세요.',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(
                          height: 120,
                        )
                      : const SizedBox(
                          height: 180,
                        ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.30
                : SizeConfig.screenHeight * 0.39),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: Column(
          children: [
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            task.isCompleted == 1
                ? Container()
                : _buildBottomSheet(
                    label: '할 일 완료',
                    onTap: () {
                      NotifyHelper().cancelNotification(task);
                      _taskController.markTaskAsCompleted(task.id!);
                      Get.back();
                    },
                    clr: primaryClr),
            _buildBottomSheet(
                label: '할 일 삭제',
                onTap: () {
                  NotifyHelper().cancelNotification(task);
                  _taskController.deleteTasks(task);
                  Get.back();
                },
                clr: Colors.red[300]!),
            Divider(color: Get.isDarkMode ? Colors.grey : darkGreyClr),
            _buildBottomSheet(
                label: '취소',
                onTap: () {
                  Get.back();
                },
                clr: primaryClr),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    ));
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isClose ? Colors.transparent : clr),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
