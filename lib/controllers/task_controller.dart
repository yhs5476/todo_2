import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

/**
 * 할 일 컨트롤러 클래스
 * GetX 상태 관리를 활용하여 할 일 목록을 관리하는 컨트롤러
 * UI와 데이터베이스 간 연결을 처리하는 역할 수행
 */
class TaskController extends GetxController {
  // 할 일 목록을 저장하는 Observable 변수 - UI에서 자동 업데이트되도록 관찰 가능
  final RxList<Task> taskList = <Task>[].obs;

  /**
   * 새 할 일 추가 메서드
   * 할 일 객체를 데이터베이스에 저장하고 목록 갱신
   * @param task 추가할 할 일 객체
   * @return 삽입 결과 ID 반환
   */
  Future<int> addTask({Task? task}) async {
    int result = await DBHelper.insert(task);
    await getTasks(); // 작업 추가 후 목록 갱신
    return result;
  }

  /**
   * 모든 할 일 조회 메서드
   * 데이터베이스에서 모든 할 일을 가져와 taskList에 업데이트
   */
  Future<void> getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
  }

  /**
   * 할 일 삭제 메서드
   * 특정 할 일을 데이터베이스에서 삭제하고 목록 갱신
   * @param task 삭제할 할 일 객체
   */
  void deleteTasks(Task task) async {
    await DBHelper.delete(task);
    getTasks();
  }

  /**
   * 모든 할 일 삭제 메서드
   * 데이터베이스의 모든 할 일 데이터를 삭제하고 목록 갱신
   */
  void deleteAllTasks() async {
    await DBHelper.deleteAll();
    getTasks();
  }

  /**
   * 할 일 완료 표시 메서드
   * 특정 ID의 할 일을 완료 상태로 변경하고 목록 갱신
   * @param id 완료 표시할 할 일의 ID
   */
  void markTaskAsCompleted(int id) async {
    await DBHelper.update(id);
    getTasks();
  }
}
