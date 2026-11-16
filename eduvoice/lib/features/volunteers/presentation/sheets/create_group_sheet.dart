import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../application/roster_controller.dart';
import '../../domain/models/roster_exception.dart';
import '../../domain/models/roster_models.dart';
import '../../domain/models/volunteer_group.dart';
import 'leader_picker_sheet.dart';
import 'roster_sheet_frame.dart';

/// Opens the form that creates a volunteer group.
Future<VolunteerGroup?> showCreateGroupSheet(
  BuildContext context, {
  required AppUser actor,
}) {
  return showRosterSheet<VolunteerGroup>(
    context,
    (_) => CreateGroupSheet(actor: actor),
  );
}

/// Creates a group and optionally puts a volunteer in charge of it.
class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key, required this.actor});

  final AppUser actor;

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final _nameController = TextEditingController();

  RosterContact? _leader;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLeader() async {
    final picked = await showLeaderPickerSheet(
      context,
      actor: widget.actor,
      title: 'Choose a leader',
      subtitle:
          'This account will lead the new group. You can change the leader '
          'later from the Groups tab.',
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() => _leader = picked);
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(
        () => _error = 'Give the group a name of at least 3 characters.',
      );
      return;
    }

    final roster = RosterScope.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final group = await roster.addGroup(
        actor: widget.actor,
        name: name,
        leaderId: _leader?.id,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(group);
    } on RosterException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return RosterSheetFrame(
      title: 'New volunteer group',
      subtitle:
          'Groups are the rosters the host reaches when a tri-alarm goes out. '
          'Each one can have a youth leader.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RosterFieldLabel('Group name'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('create-group-name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: palette.textPrimary,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _submit(),
            decoration: rosterFieldDecoration(
              context,
              hint: 'e.g. Red Cross Youth C',
              icon: Icons.groups_2_outlined,
            ),
          ),
          const SizedBox(height: 20),
          const RosterFieldLabel('Leader'),
          const SizedBox(height: 8),
          RosterPickTile(
            key: const Key('create-group-leader'),
            title: _leader?.name ?? 'Assign later',
            subtitle: _leader == null
                ? 'No leader yet · you can set one any time'
                : '${_leader!.role.label} · '
                      '${_leader!.groupName ?? 'no group'}',
            onTap: _pickLeader,
          ),
          const SizedBox(height: 10),
          Text(
            'Leaders receive alerts for their group and can add members to it.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              height: 1.4,
              color: palette.textSecondary,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('create-group-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.alertRedOn,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('create-group-submit'),
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create group',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
