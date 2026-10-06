import '../../models/phase2/landing_task.dart';

abstract class LandingRepository {
  Future<List<LandingTask>> getTasks();
  Future<void> toggleTaskCompleted(String taskId, bool isCompleted);
}
