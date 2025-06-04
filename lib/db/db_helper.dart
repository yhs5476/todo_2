import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

/**
 * 데이터베이스 헬퍼 클래스
 * SQLite를 사용하여 할 일 데이터를 로컬에 저장하고 관리하는 기능 제공
 */
class DBHelper {
  static Database? _db;               // 데이터베이스 인스턴스
  static const int _version = 1;      // 데이터베이스 버전
  static const String _tableName = 'tasks';  // 테이블 이름

  /**
   * 데이터베이스 초기화 메서드
   * 앱이 처음 시작될 때 호출되며 데이터베이스와 테이블을 생성
   */
  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('db not null');
      return;
    }
    try {
      String path = '${await getDatabasesPath()}task.db';
      debugPrint('in db path');
      _db = await openDatabase(path, version: _version,
          onCreate: (Database db, int version) async {
        debugPrint('Creating new one');
        // When creating the db, create the table
        // 테이블 생성 SQL 명령: 할 일 정보를 저장하는 테이블 스키마 정의
        return db.execute('CREATE TABLE $_tableName ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'remind INTEGER, repeat STRING, '
            'color INTEGER, '
            'isCompleted INTEGER)');
      });
      print('DB Created');
    } catch (e) {
      print(e);
    }
  }

  /**
   * 할 일 추가 메서드
   * 새로운 할 일을 데이터베이스에 저장
   * @param task 저장할 할 일 객체
   * @return 삽입된 할 일의 ID 또는 오류 발생 시 -1
   */
  static Future<int> insert(Task? task) async {
    print('insert function called');
    try {
      // 데이터베이스가 초기화되지 않은 경우 초기화
      if (_db == null) {
        print('Database is not initialized, initializing now');
        await initDb();
      }
      
      // 태스크가 null인지 확인
      if (task == null) {
        print('Task is null');
        return -1;
      }
      
      // 데이터베이스에 삽입
      int result = await _db!.insert(_tableName, task.toJson());
      print('Task inserted successfully with ID: $result');
      return result;
    } catch (e) {
      print('Error inserting task: $e');
      return -1; // 오류 발생 시 -1 반환
    }
  }

  /**
   * 할 일 삭제 메서드
   * 특정 ID의 할 일을 데이터베이스에서 삭제
   * @param task 삭제할 할 일 객체
   * @return 영향받은 행 수
   */
  static Future<int> delete(Task task) async {
    print('insert');
    return await _db!.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /**
   * 모든 할 일 삭제 메서드
   * 테이블의 모든 할 일을 삭제
   * @return 영향받은 행 수
   */
  static Future<int> deleteAll() async {
    print('insert');
    return await _db!.delete(_tableName);
  }

  /**
   * 모든 할 일 조회 메서드
   * 테이블에 저장된 모든 할 일 데이터를 가져옴
   * @return 할 일 목록의 Map 형태로 반환
   */
  static Future<List<Map<String, dynamic>>> query() async {
    print('Query Called!!!!!!!!!!!!!!!!!!!');
    print('insert');
    return await _db!.query(_tableName);
  }

  /**
   * 할 일 완료 상태 업데이트 메서드
   * 특정 ID의 할 일을 완료 상태로 변경
   * @param id 업데이트할 할 일의 ID
   * @return 영향받은 행 수
   */
  static Future<int> update(int id) async {
    print('insert');
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id = ?
    ''', [1, id]);
  }
}
