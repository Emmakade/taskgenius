import '../../domain/repositories/project_repository.dart';
import '../datasources/local/database_helper.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final DatabaseHelper databaseHelper;

  ProjectRepositoryImpl(this.databaseHelper);

  // TODO: Implement ProjectRepository methods
}
