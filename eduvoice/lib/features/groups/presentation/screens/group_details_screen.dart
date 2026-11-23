import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/application/session_controller.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../auth/domain/role_permissions.dart';
import '../../../volunteers/application/roster_controller.dart';
import '../../../volunteers/data/group_repository.dart';
import '../../../volunteers/domain/models/roster_exception.dart';
import '../../../volunteers/domain/models/volunteer_group.dart';
import '../../../volunteers/presentation/sheets/edit_user_sheet.dart';
import '../../../volunteers/presentation/sheets/group_editor_sheet.dart';

/// One group's leader and roster.
///
/// The host opens this for whichever group they picked and can edit it; a
/// leader or member can open only their own group and reads it without edit
/// actions.
class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({super.key, required this.initialGroup});

  final VolunteerGroup initialGroup;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  late VolunteerGroup _group = widget.initialGroup;
  List<AppUser> _members = const [];
  bool _loading = true;
  String? _error;
  AppUser? _user;
  int _revision = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = SessionScope.of(context).user;
    final revision = RosterScope.of(context).revision;
    if (user == null) {
      return;
    }
    if (user.id == _user?.id && revision == _revision) {
      return;
    }
    _user = user;
    _revision = revision;
    _load(user);
  }

  Future<void> _load(AppUser user) async {
    final roster = RosterScope.of(context);
    try {
      final groups = await GroupRepository().groupsFor(user);
      VolunteerGroup? fresh;
      for (final group in groups) {
        if (group.id == widget.initialGroup.id) {
          fresh = group;
        }
      }
      if (fresh == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _error = 'This group is no longer available to your account.';
        });
        return;
      }

      final members = await roster.membersForGroup(
        actor: user,
        groupId: fresh.id,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _group = fresh!;
        _members = members;
        _loading = false;
        _error = null;
      });
    } on RosterException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.message;
      });
    }
  }

  Future<void> _editGroup() async {
    final user = _user;
    if (user == null) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final changed = await showGroupEditorSheet(
      context,
      actor: user,
      group: _group,
    );
    if (!mounted || changed != true) {
      return;
    }
    await _load(user);
    if (!mounted) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Group updated.')));
  }

  Future<void> _editMember(AppUser member) async {
    final user = _user;
    if (user == null) {
      return;
    }
    final changed = await showEditUserSheet(
      context,
      actor: user,
      user: member,
    );
    if (!mounted || changed != true) {
      return;
    }
    await _load(user);
  }

  (Color, Color) _statusColors(AppPalette palette) => switch (_group.status) {
    GroupReportStatus.safe => (palette.alertGreenOn, palette.alertGreenSoft),
    GroupReportStatus.awaiting => (
      palette.alertYellowOn,
      palette.alertYellowSoft,
    ),
    GroupReportStatus.needsAssistance => (
      palette.alertRedOn,
      palette.alertRedSoft,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final palette = context.palette;
    final permissions = RolePermissions.of(user);
    final (foreground, background) = _statusColors(palette);

    return Scaffold(
      backgroundColor: palette.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.primarySoft, palette.background],
            stops: const [0, 0.22],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            key: const Key('group-details-back'),
                            onPressed: () => Navigator.of(context).pop(),
                            padding: EdgeInsets.zero,
                            tooltip: 'Back to groups',
                            icon: const Icon(
                              Icons.chevron_left_rounded,
                              size: 26,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Group details',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 18),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.groups_2_rounded,
                                  size: 23,
                                  color: foreground,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _group.name,
                                      key: const Key('group-details-title'),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                          ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${_members.length} volunteers',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 11.5,
                                            color: palette.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusChip(
                                label: _group.status.label,
                                foreground: foreground,
                                background: background,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            decoration: BoxDecoration(
                              color: palette.surfaceMuted,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_outline_rounded,
                                  size: 18,
                                  color: palette.primaryOnSoft,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Leader',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.4,
                                              color: palette.textSecondary,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _group.leader,
                                        key: const Key(
                                          'group-details-leader',
                                        ),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (permissions.canAssignLeaders)
                                  Text(
                                    'Host-managed',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: palette.textSecondary,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          if (permissions.canEditGroups) ...[
                            const SizedBox(height: 14),
                            OutlinedButton.icon(
                              key: const Key('group-details-edit'),
                              onPressed: _editGroup,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.textPrimary,
                                side: BorderSide(color: palette.border),
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 17),
                              label: const Text(
                                'Edit group',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SectionHeader(
                      title: 'Members',
                      subtitle: permissions.canEditUsers
                          ? 'Tap a volunteer to edit their name, role or group'
                          : 'Everyone in this group and its leader',
                    ),
                    const SizedBox(height: 10),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                        ),
                      )
                    else if (_error != null)
                      Text(
                        _error!,
                        key: const Key('group-details-error'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: palette.alertRedOn,
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
                      AppCard(
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < _members.length;
                              index++
                            ) ...[
                              _MemberRow(
                                member: _members[index],
                                editable: permissions.canEditUsers,
                                onTap: permissions.canEditUsers
                                    ? () => _editMember(_members[index])
                                    : null,
                              ),
                              if (index != _members.length - 1)
                                Divider(height: 1, color: palette.border),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.editable,
    this.onTap,
  });

  final AppUser member;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;

    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: member.role == UserRole.leader
                  ? palette.primarySoft
                  : palette.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Text(
              member.initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: member.role == UserRole.leader
                    ? palette.primaryOnSoft
                    : palette.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 11),
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
          if (editable)
            Icon(
              Icons.chevron_right_rounded,
              size: 19,
              color: palette.textSecondary,
            ),
        ],
      ),
    );

    if (onTap == null) {
      return KeyedSubtree(
        key: Key('group-details-member-${member.name}'),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('group-details-member-${member.name}'),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
