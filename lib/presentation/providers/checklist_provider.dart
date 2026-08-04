import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/checklist_item.dart';
import 'repository_providers.dart';

class ChecklistNotifier extends StateNotifier<List<ChecklistItem>> {
  final Ref ref;

  ChecklistNotifier(this.ref) : super([]) {
    _loadChecklist();
  }

  Future<void> _loadChecklist() async {
    final prefs = ref.read(sharedPrefsServiceProvider);
    final items = await prefs.getChecklist();
    state = items;
  }

  Future<void> toggleItem(String id) async {
    final updatedList =
        state.map((item) {
          if (item.id == id) {
            return item.copyWith(isChecked: !item.isChecked);
          }
          return item;
        }).toList();

    state = updatedList;
    final prefs = ref.read(sharedPrefsServiceProvider);
    await prefs.saveChecklist(updatedList);
  }

  double get completionPercentage {
    if (state.isEmpty) return 0.0;
    final checkedCount = state.where((item) => item.isChecked).length;
    return checkedCount / state.length;
  }
}

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, List<ChecklistItem>>((ref) {
      return ChecklistNotifier(ref);
    });

final checklistProgressProvider = Provider<double>((ref) {
  final checklist = ref.watch(checklistProvider);
  if (checklist.isEmpty) return 0.0;
  final checkedCount = checklist.where((item) => item.isChecked).length;
  return checkedCount / checklist.length;
});
