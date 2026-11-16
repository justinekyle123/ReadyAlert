import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../application/roster_controller.dart';
import '../../domain/models/roster_exception.dart';
import '../../domain/models/roster_models.dart';
import 'roster_sheet_frame.dart';

/// Opens the account picker used to assign a group leader.
Future<RosterContact?> showLeaderPickerSheet(
  BuildContext context, {
  required AppUser actor,
  String title = 'Assign leader',
  String? subtitle,
  int? groupId,
  int? currentLeaderId,
}) {
  final roster = RosterScope.of(context);
  return showRosterSheet<RosterContact>(
    context,
    (_) => LeaderPickerSheet(
      roster: roster,
      actor: actor,
      title: title,
      subtitle:
          subtitle ??
          'Choose the volunteer who runs this group. They can send alerts to '
              'their roster.',
      groupId: groupId,
      currentLeaderId: currentLeaderId,
    ),
  );
}

class LeaderPickerSheet extends StatefulWidget {
  const LeaderPickerSheet({
    super.key,
    required this.roster,
    required this.actor,
    required this.title,
    this.subtitle,
    this.groupId,
    this.currentLeaderId,
  });

  final RosterController roster;
  final AppUser actor;
  final String title;
  final String? subtitle;
  final int? groupId;
  final int? currentLeaderId;

  @override
  State<LeaderPickerSheet> createState() => _LeaderPickerSheetState();
}

class _LeaderPickerSheetState extends State<LeaderPickerSheet> {
  final _searchController = TextEditingController();

  List<RosterContact> _contacts = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final contacts = await widget.roster.leaderCandidates(
        actor: widget.actor,
        preferGroupId: widget.groupId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _contacts = contacts;
        _loading = false;
      });
    } on RosterException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  List<RosterContact> get _visibleContacts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _contacts;
    }
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          (contact.groupName?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final contacts = _visibleContacts;

    return RosterSheetFrame(
      title: widget.title,
      subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
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
              key: const Key('leader-picker-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: palette.alertRedOn,
              ),
            )
          else if (_contacts.isEmpty)
            Text(
              'No accounts can lead a group yet. Add a volunteer first.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: palette.textSecondary,
              ),
            )
          else ...[
            TextField(
              key: const Key('leader-search'),
              controller: _searchController,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: palette.textPrimary,
              ),
              onChanged: (_) => setState(() {}),
              decoration: rosterFieldDecoration(
                context,
                hint: 'Search volunteers',
                icon: Icons.search_rounded,
              ),
            ),
            const SizedBox(height: 14),
            if (contacts.isEmpty)
              Text(
                'No volunteer matches that search.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: palette.textSecondary,
                ),
              )
            else
              for (var index = 0; index < contacts.length; index++) ...[
                _ContactTile(
                  contact: contacts[index],
                  isCurrent: contacts[index].id == widget.currentLeaderId,
                  onTap: () => Navigator.of(context).pop(contacts[index]),
                ),
                if (index != contacts.length - 1)
                  Divider(height: 1, color: palette.border),
              ],
          ],
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.isCurrent,
    required this.onTap,
  });

  final RosterContact contact;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    final meta = contact.groupName == null
        ? contact.role.label
        : '${contact.role.label} · ${contact.groupName}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('leader-candidate-${contact.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCurrent ? palette.primarySoft : palette.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  contact.user.initials,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isCurrent
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
                      contact.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: palette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primarySoft,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'CURRENT',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: palette.primaryOnSoft,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: palette.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
