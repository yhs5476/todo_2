/**
 * 할 일(Task) 모델 클래스
 * 사용자의 할 일 정보를 저장하고 관리하는 데이터 구조
 */
class Task {
  int? id; // 할 일 고유 식별자
  String? title; // 할 일 제목
  String? note; // 할 일 상세 내용
  int? isCompleted; // 완료 상태 (0: 미완료, 1: 완료)
  String? date; // 할 일 날짜
  String? startTime; // 시작 시간
  String? endTime; // 종료 시간
  int? color; // 색상 코드
  int? remind; // 알림 설정 (분 단위)
  String? repeat; // 반복 설정 (없음, 매일, 매주 등)

  Task(
      {this.id,
      this.title,
      this.note,
      this.isCompleted,
      this.date,
      this.startTime,
      this.endTime,
      this.color,
      this.remind,
      this.repeat});

  /**
   * Task 객체를 JSON 형식으로 변환하는 메서드
   * 데이터베이스 저장 및 API 통신에 사용
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'isCompleted': isCompleted,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'color': color,
      'remind': remind,
      'repeat': repeat,
    };
  }

  /**
   * JSON 데이터로부터 Task 객체를 생성하는 생성자
   * 데이터베이스나 API에서 받아온 데이터를 객체로 변환
   */
  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    note = json['note'];
    isCompleted = json['isCompleted'];
    date = json['date'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    color = json['color'];
    remind = json['remind'];
    repeat = json['repeat'];
  }
}
