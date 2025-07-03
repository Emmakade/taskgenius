import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects();
  Future<List<Project>> getAllProjects();
  Future<void> addProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(String id);
}
