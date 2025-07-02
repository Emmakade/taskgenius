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
  Future<void> addProject(Project project) {
    // TODO: implement addProject
    throw UnimplementedError();
  }

  @override
  Future<void> deleteProject(String id) {
    // TODO: implement deleteProject
    throw UnimplementedError();
  }

  @override
  Future<List<Project>> getProjects() {
    // TODO: implement getProjects
    throw UnimplementedError();
  }

  @override
  Future<void> updateProject(Project project) {
    // TODO: implement updateProject
    throw UnimplementedError();
  }

  // TODO: Implement ProjectRepository methods
}
