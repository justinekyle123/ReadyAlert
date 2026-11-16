import 'package:flutter/material.dart';

import '../../../../core/database/school_id.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/domain/role_permissions.dart';
import '../../application/roster_controller.dart';
import '../../data/group_repository.dart';
import '../../domain/models/roster_exception.dart';
import '../../domain/models/roster_models.dart';
import '../../domain/models/volunteer_group.dart';
import 'roster_sheet_frame.dart';

/// Opens the form that provisions a new volunteer account.
Future<NewAccount?> showAddUserSheet(
  BuildContext context, {
  required AppUser actor,
}) {
  return showRosterSheet<NewAccount>(
    context,
    (_) => AddUserSheet(actor: actor),
  );
}

/// Creates a member or youth leader account with the default password.
class AddUserSheet extends StatefulWidget {
  const AddUserSheet({super.key, required this.actor});

  final AppUser actor;

  @override
  State<AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends State<AddUserSheet> {
  final _nameController = TextEditingController();
  final _groupRepository = GroupRepository();

  late final bool _canAppointLeaders = RolePermissions.of(
    widget.actor,
  ).canAddGroups;

  UserRole _role = UserRole.member;
  int? _groupId;
  List<VolunteerGroup> _groups = const [];
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!_canAppointLeaders) {
      _groupId = widget.actor.groupId;
    }
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

  String? get _groupName {
    for (final group in _groups) {
      if (group.id == _groupId) {
        return group.name;
      }
    }
    return null;
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
    if (_groupId == null) {
      setState(
        () => _error = _role == UserRole.leader
            ? 'Choose the group this youth leader will lead.'
            : 'Choose the group this volunteer belongs to.',
      );
      return;
    }

    final roster = RosterScope.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final account = await roster.addUser(
        actor: widget.actor,
        name: name,
        role: _role,
        groupId: _groupId,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(account);
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
    final typedName = _nameController.text.trim();

    return RosterSheetFrame(
      title: 'Add volunteer',
      subtitle:
          'Create a Ready Alert account for a student volunteer. Every '
          'volunteer belongs to one group, and that group is who receives the '
          'alerts they answer to.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RosterFieldLabel('Full name'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('add-user-name'),
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
          if (typedName.isNotEmpty) ...[
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Icon(
                    Icons.badge_outlined,
                    size: 13,
                    color: palette.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Signs in as ${schoolIdFor(typedName)}',
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
            ),
          ],
          if (_canAppointLeaders) ...[
            const SizedBox(height: 20),
            const RosterFieldLabel('Role'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                RosterChoice(
                  key: const Key('add-user-role-member'),
                  label: 'Member',
                  icon: Icons.person_outline_rounded,
                  selected: _role == UserRole.member,
                  onTap: () => setState(() => _role = UserRole.member),
                ),
                RosterChoice(
                  key: const Key('add-user-role-leader'),
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
            if (_groups.isEmpty)
              Text(
                'No groups yet. Create one from the + menu first.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: palette.textSecondary,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in _groups)
                    RosterChoice(
                      key: Key('add-user-group-${group.id}'),
                      label: group.name,
                      selected: _groupId == group.id,
                      onTap: () => setState(() => _groupId = group.id),
                    ),
                ],
              ),
          ] else ...[
            const SizedBox(height: 20),
            const RosterFieldLabel('Group'),
            const SizedBox(height: 8),
            RosterPickTile(
              icon: Icons.groups_2_outlined,
              title: _groupName ?? 'No group yet',
              subtitle: 'Leaders add volunteers to their own group',
              onTap: () {},
              interactive: false,
            ),
          ],
          const SizedBox(height: 20),
          const DefaultPasswordNote(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              key: const Key('add-user-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.alertRedOn,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('add-user-submit'),
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
                    'Add volunteer',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
