import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/tool_model.dart';

part 'quick_actions_provider.g.dart';

const String _quickActionsKey = 'quick_actions';

/// Quick actions notifier
@riverpod
class QuickActions extends _$QuickActions {
  @override
  List<ToolModel> build() {
    _loadQuickActions();
    return AppTools.defaultQuickActions;
  }

  /// Load quick actions from shared preferences
  Future<void> _loadQuickActions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_quickActionsKey);

    if (savedIds != null && savedIds.isNotEmpty) {
      final tools = savedIds
          .map((id) => AppTools.allTools.firstWhere(
                (tool) => tool.id == id,
                orElse: () => AppTools.allTools.first,
              ))
          .toList();

      state = tools;
    }
  }

  /// Update quick actions
  Future<void> updateQuickActions(List<ToolModel> tools) async {
    // max 8 tools
    final updatedTools = tools.take(8).toList();
    state = updatedTools;

    // save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    final toolIds = updatedTools.map((tool) => tool.id).toList();
    await prefs.setStringList(_quickActionsKey, toolIds);
  }

  /// Add tool to quick actions
  Future<void> addTool(ToolModel tool) async {
    if (state.length < 8 && !state.any((t) => t.id == tool.id)) {
      await updateQuickActions([...state, tool]);
    }
  }

  /// Remove tool from quick actions
  Future<void> removeTool(String toolId) async {
    final updatedTools = state.where((tool) => tool.id != toolId).toList();
    await updateQuickActions(updatedTools);
  }

  /// Reset to default quick actions
  Future<void> resetToDefault() async {
    await updateQuickActions(AppTools.defaultQuickActions);
  }
}
