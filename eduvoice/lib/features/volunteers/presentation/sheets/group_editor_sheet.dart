import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../application/roster_controller.dart';
import '../../data/group_repository.dart';
import '../../domain/models/roster_exception.dart';
import '../../domain/models/volunteer_group.dart';
import 'edit_user_sheet.dart';
import 'leader_picker_sheet.dart';
import 'roster_sheet_frame.dart';

/// Opens the host-only editor for a volunteer group.
Future<bool?> showGroupEditorSheet(
  BuildContext context, {
  required AppUser actor,
  required VolunteerGroup group,
}) {
  return showRosterSheet<bool>(
    context,
    (_) => GroupEditorSheet(actor: actor, group: group),
  );
}

/// Renames a group, changes its check-in status, assigns its leader and lets
/// the host edit individual members.
class GroupEditorSheet extends StatefulWidget {
  const GroupEditorSheet({super.key, required this.actor, required this.group});

  final AppUser actor;
  final VolunteerGroup group;

  @override
  State<GroupEditorSheet> createState() => _GroupEditorSheetState();
}

class _GroupEditorSheetState extends State<GroupEditorSheet> {
  final _nameController = TextEditingController();
  final _groupRepository = GroupRepository();

  late GroupReportStatus _status = widget.group.status;
  int? _leaderId;
  String _leaderName = '';
  List<AppUser> _members = const [];
  bool _loadingMembers = true;
  bool _loadingStarted = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _leaderId = widget.group.leaderId;
    _leaderName = widget.group.leader;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loadingStarted) {
      return;
    }
    _loadingStarted = true;
    _loadMembers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    final roster = RosterScope.of(context);
    final members = await roster.membersForGroup(
      actor: widget.actor,
      groupId: widget.group.id,
    );
    final groups = await _groupRepository.groupsFor(widget.actor);
    VolunteerGroup? fresh;
    for (final group in groups) {
      if (group.id == widget.group.id) {
        fresh = group;
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _members = members;
      _loadingMembers = false;
      if (fresh != null) {
        _leaderId = fresh.leaderId;
        _leaderName = fresh.leader;
      }
    });
  }

  Future<void> _pickLeader() async {
    final picked = await showLeaderPickerSheet(
      context,
      actor: widget.actor,
      groupId: widget.group.id,
      currentLeaderId: _leaderId,
      title: 'Choose a leader',
      subtitle:
          'This account will lead ${_nameController.text.trim()}. They can '
          'send alerts to this roster.',
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _leaderId = picked.id;
      _leaderName = picked.name;
    });
  }

  Future<void> _editMember(AppUser member) async {
    final changed = await showEditUserSheet(
      context,
      actor: widget.actor,
      user: member,
    );
    if (!mounted || changed != true) {
      return;
    }
    await _loadMembers();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();

    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Give the group a name of at least 3 characters.');
      return;
    }

    final roster = RosterScope.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await roster.updateGroup(
        actor: widget.actor,
        groupId: widget.group.id,
        name: name,
        status: _status,
        leaderId: _leaderId,
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
        _saving = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return RosterSheetFrame(
      title: 'Edit group',
      subtitle:
          'Hosts can rename this group, change its check-in status, choose '
          'its leader, and edit every member.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RosterFieldLabel('Group name'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('group-editor-name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: palette.textPrimary,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _save(),
            decoration: rosterFieldDecoration(
              context,
              hint: 'e.g. Red Cross Youth C',
              icon: Icons.groups_2_outlined,
            ),
          ),
          const SizedBox(height: 20),
          const RosterFieldLabel('Check-in status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in GroupReportStatus.values)
                RosterChoice(
                  key: Key('group-status-${status.name}'),
                  label: status.label,
                  selected: _status == status,
                  onTap: () => setState(() => _status = status),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const RosterFieldLabel('Leader'),
          const SizedBox(height: 8),
          RosterPickTile(
            key: const Key('group-editor-leader'),
            title: _leaderName,
            subtitle: 'Tap to choose who leads this group',
            onTap: _pickLeader,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: RosterFieldLabel('Members')),
              Text(
                '${_members.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: palette.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tap a volunteer to edit their name, role or group.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          if (_loadingMembers)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          else if (_members.isEmpty)
            Text(
              'No volunteers in this group yet.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: palette.textSecondary,
              ),
            )
          else
            for (final member in _members) ...[
              _MemberTile(member: member, onTap: () => _editMember(member)),
              if (member != _members.last)
                Divider(height: 1, color: palette.border),
            ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('group-editor-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.alertRedOn,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('group-editor-save'),
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _saving
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

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});

  final AppUser member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('group-member-${member.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  member.initials,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: palette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.role.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: palette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
