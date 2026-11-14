import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:floww/config/utils/haptics/haptic_manager.dart';
import 'package:floww/config/widgets/scaffolds/inner_page_scaffold.dart';
import 'package:floww/core/premium/providers/premium_access_provider.dart';
import 'package:floww/core/workout/models/program_list_args.dart';
import 'package:floww/core/workout/models/workout_view_data.dart';
import 'package:floww/core/workout/view_models/workout_view_model.dart';
import 'package:floww/core/workout/widgets/program_list_section.dart';

class ProgramListView extends StatefulWidget {
  const ProgramListView({super.key, required this.args});

  final ProgramListArgs args;

  @override
  State<ProgramListView> createState() => _ProgramListViewState();
}

class _ProgramListViewState extends State<ProgramListView> {
  late final WorkoutViewModel _viewModel = widget.args.viewModel;
  late String _title = _viewModel.programListTitle;
  late String _countLabel = _viewModel.programsCountLabel;
  late List<ProgramItem> _programs = _viewModel.programs;
  bool _isClosed = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    if (!_viewModel.showProgramExplore) {
      setState(() {
        _title = _viewModel.programListTitle;
        _countLabel = _viewModel.programsCountLabel;
        _programs = _viewModel.programs;
      });
      return;
    }
    if (_isClosed) return;
    _isClosed = true;
    final route = ModalRoute.of(context);
    if (route == null) return;
    final navigator = Navigator.of(context);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  void _onPopped(bool didPop) {
    if (!didPop || _isClosed) return;
    _isClosed = true;
    _viewModel.backToExplore();
  }

  void _back() {
    HapticManager.selection();
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final isPremiumUnlocked = context.watch<PremiumAccessProvider>().canUse(
      PremiumCapability.multiModeWorkouts,
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) => _onPopped(didPop),
      child: InnerPageScaffold(
        title: _title,
        onBack: _back,
        children: [
          ProgramListSection(
            programs: _programs,
            countLabel: _countLabel,
            emptyMessage: _viewModel.programsEmptyMessage,
            isPremiumUnlocked: isPremiumUnlocked,
            onOpen: (program) => widget.args.onOpenProgram(context, program.id),
          ),
        ],
      ),
    );
  }
}
