import 'package:taskgenius/domain/entities/project.dart';

import '../../domain/repositories/project_repository.dart';
import '../datasources/local/database_helper.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final DatabaseHelper databaseHelper;

  ProjectRepositoryImpl(this.databaseHelper);

  Future<List<Project>> getAllProjects() async {
    final db = await databaseHelper.database;
    final projectMaps = await db.query('projects');
    return projectMaps.map((map) => Project.fromMap(map)).toList();
  }

  @override
  Future<void> addProject(Project project) async {
    final db = await databaseHelper.database;
    await db.insert('projects', project.toMap());
  }

  @override
  Future<void> deleteProject(String id) async {
    final db = await databaseHelper.database;
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Project>> getProjects() async {
    final db = await databaseHelper.database;
    final projectMaps = await db.query('projects');
    return projectMaps.map((map) => Project.fromMap(map)).toList();
  }

  @override
  Future<void> updateProject(Project project) async {
    final db = await databaseHelper.database;
    await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<Project?> getProjectById(String id) async {
    final db = await databaseHelper.database;
    final maps = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Project.fromMap(maps.first);
    }
    return null;
  }
}
