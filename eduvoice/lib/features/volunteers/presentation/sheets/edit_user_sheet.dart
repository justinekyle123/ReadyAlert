import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../application/roster_controller.dart';
import '../../data/group_repository.dart';
import '../../domain/models/roster_exception.dart';
import '../../domain/models/volunteer_group.dart';
import 'roster_sheet_frame.dart';

/// Opens the form the host uses to edit an existing account.
Future<bool?> showEditUserSheet(
  BuildContext context, {
  required AppUser actor,
  required AppUser user,
}) {
  return showRosterSheet<bool>(
    context,
    (_) => EditUserSheet(actor: actor, user: user),
  );
}

/// Renames an account, changes its role, or moves it to another group.
class EditUserSheet extends StatefulWidget {
  const EditUserSheet({super.key, required this.actor, required this.user});

  final AppUser actor;
  final AppUser user;

  @override
  State<EditUserSheet> createState() => _EditUserSheetState();
}

class _EditUserSheetState extends State<EditUserSheet> {
  final _nameController = TextEditingController();
  final _groupRepository = GroupRepository();

  late UserRole _role = widget.user.role;
  int? _groupId;
  List<VolunteerGroup> _groups = const [];
  bool _submitting = false;
  String? _error;

  bool get _isHost => widget.user.role == UserRole.host;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _groupId = widget.user.groupId;
    _loadGroups();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final groups = await _groupRepository.groupsFor(widget.actor);
    if (!mounted) {
      return;
    }
    setState(() => _groups = groups);
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = "Enter the volunteer's full name.");
      return;
    }
    if (!_isHost && _groupId == null) {
      setState(() => _error = 'Choose the group this volunteer belongs to.');
      return;
    }

    final roster = RosterScope.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await roster.updateUser(
        actor: widget.actor,
        userId: widget.user.id,
        name: name,
        role: _isHost ? UserRole.host : _role,
        groupId: _isHost ? null : _groupId,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
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
      title: 'Edit account',
      subtitle:
          'Only the host can change accounts. The school ID stays the same, '
          'so this person signs in with the same details after the edit.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RosterFieldLabel('Full name'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('edit-user-name'),
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
              hint: 'e.g. Maria Clara Santos',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 13,
                color: palette.textSecondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Signs in as ${widget.user.schoolId ?? widget.user.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (_isHost) ...([
            const SizedBox(height: 20),
            const RosterFieldLabel('Role'),
            const SizedBox(height: 8),
            Text(
              'Host · oversees every group and the whole roster.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: palette.primaryOnSoft,
              ),
            ),
          ]) else ...([
            const SizedBox(height: 20),
            const RosterFieldLabel('Role'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RosterChoice(
                  key: const Key('edit-user-role-member'),
                  label: 'Member',
                  icon: Icons.person_outline_rounded,
                  selected: _role == UserRole.member,
                  onTap: () => setState(() => _role = UserRole.member),
                ),
                RosterChoice(
                  key: const Key('edit-user-role-leader'),
                  label: 'Youth leader',
                  icon: Icons.star_outline_rounded,
                  selected: _role == UserRole.leader,
                  onTap: () => setState(() => _role = UserRole.leader),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const RosterFieldLabel('Group'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final group in _groups)
                  RosterChoice(
                    key: Key('edit-user-group-${group.id}'),
                    label: group.name,
                    selected: _groupId == group.id,
                    onTap: () => setState(() => _groupId = group.id),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _role == UserRole.leader
                  ? 'A youth leader leads the selected group and can send '
                        'alerts to it.'
                  : 'Members receive their group leader’s alerts.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.4,
                color: palette.textSecondary,
              ),
            ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('edit-user-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.alertRedOn,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('edit-user-save'),
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
                    'Save changes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
