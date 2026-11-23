import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../auth/domain/models/app_user.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../profile/domain/models/profile_models.dart';
import '../../../volunteers/presentation/sheets/roster_sheet_frame.dart';

/// Opens the form where an account holder edits their own details.
Future<AppUser?> showEditProfileSheet(
  BuildContext context, {
  required AppUser user,
}) {
  return showRosterSheet<AppUser>(
    context,
    (_) => EditProfileSheet(user: user),
  );
}

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key, required this.user});

  final AppUser user;

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repository = ProfileRepository();

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email ?? '';
    _phoneController.text = widget.user.phone ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final updated = await _repository.updateContactDetails(
        user: widget.user,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(updated);
    } on ProfileUpdateException catch (error) {
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
      title: 'Edit my details',
      subtitle:
          'Update your name, sign-in email and contact number. Your role and '
          'group can only be changed by the host.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RosterFieldLabel('Full name'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('edit-profile-name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: palette.textPrimary,
            ),
            onChanged: (_) => setState(() => _error = null),
            decoration: rosterFieldDecoration(
              context,
              hint: 'Your full name',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),
          const RosterFieldLabel('Email'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('edit-profile-email'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: palette.textPrimary,
            ),
            onChanged: (_) => setState(() => _error = null),
            decoration: rosterFieldDecoration(
              context,
              hint: 'you@pnhs.edu.ph',
              icon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 16),
          const RosterFieldLabel('Contact number'),
          const SizedBox(height: 8),
          TextField(
            key: const Key('edit-profile-phone'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.5,
              color: palette.textPrimary,
            ),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _submit(),
            decoration: rosterFieldDecoration(
              context,
              hint: 'e.g. 0917 123 4567',
              icon: Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Signed in as ${widget.user.schoolId ?? widget.user.name} · '
            '${widget.user.role.label}. The school ID stays the same.',
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
              key: const Key('edit-profile-error'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: palette.alertRedOn,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton(
            key: const Key('edit-profile-save'),
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
                    'Save details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}
