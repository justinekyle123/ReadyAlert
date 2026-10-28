import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fade_slide_in.dart';
import '../widgets/emergency_hero.dart';
import '../widgets/login_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSignedIn});

  final VoidCallback onSignedIn;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSignedIn();
    }
  }

  void _showRecoveryMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Password recovery will be available soon.'),
        ),
      );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12.5,
        color: Colors.white.withValues(alpha: 0.45),
      ),
      prefixIcon: Icon(
        icon,
        size: 19,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
      enabledBorder: border(Colors.white.withValues(alpha: 0.22)),
      focusedBorder: border(Colors.white.withValues(alpha: 0.82), width: 1.4),
      errorBorder: border(AppColors.alertYellowSoft.withValues(alpha: 0.72)),
      focusedErrorBorder: border(AppColors.alertYellowSoft, width: 1.4),
      errorStyle: TextStyle(
        fontSize: 10.5,
        height: 1.2,
        color: AppColors.alertYellowSoft.withValues(alpha: 0.95),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.splashStart,
                AppColors.primary,
                AppColors.splashEnd,
              ],
              stops: [0, 0.52, 1],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(child: LoginBackground()),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 440,
                            minHeight: constraints.maxHeight > 44
                                ? constraints.maxHeight - 44
                                : 0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const FadeSlideIn(child: EmergencyHero()),
                              const SizedBox(height: 6),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 60),
                                child: Column(
                                  children: [
                                    const Text(
                                      'READY ALERT',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 4,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Polomolok National High School',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: Colors.white.withValues(
                                          alpha: 0.62,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 110),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Welcome back.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 28,
                                        height: 1.1,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.8,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Sign in to check on your volunteer group '
                                      'and stay ready for earthquake emergencies.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: Colors.white.withValues(
                                          alpha: 0.78,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 190),
                                child: TextSelectionTheme(
                                  data: TextSelectionThemeData(
                                    cursorColor: Colors.white,
                                    selectionColor: Colors.white.withValues(
                                      alpha: 0.28,
                                    ),
                                    selectionHandleColor: Colors.white,
                                  ),
                                  child: AutofillGroup(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.lock_outline_rounded,
                                                size: 13,
                                                color: Colors.white.withValues(
                                                  alpha: 0.6,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'SECURE SIGN-IN',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.3,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          const _FieldLabel(
                                            'School ID or email',
                                          ),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            key: const Key('login-email'),
                                            controller: _identifierController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            keyboardAppearance: Brightness.dark,
                                            textInputAction:
                                                TextInputAction.next,
                                            cursorColor: Colors.white,
                                            autofillHints: const [
                                              AutofillHints.username,
                                            ],
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white,
                                            ),
                                            decoration: _fieldDecoration(
                                              hint: 'e.g. juan.delacruz',
                                              icon: Icons.badge_outlined,
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return 'Enter your school ID '
                                                    'or email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          const _FieldLabel('Password'),
                                          const SizedBox(height: 8),
                                          TextFormField(
                                            key: const Key('login-password'),
                                            controller: _passwordController,
                                            obscureText: _obscurePassword,
                                            enableSuggestions: false,
                                            autocorrect: false,
                                            keyboardAppearance: Brightness.dark,
                                            textInputAction:
                                                TextInputAction.done,
                                            cursorColor: Colors.white,
                                            autofillHints: const [
                                              AutofillHints.password,
                                            ],
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              color: Colors.white,
                                            ),
                                            onFieldSubmitted: (_) => _submit(),
                                            decoration: _fieldDecoration(
                                              hint: 'Enter your password',
                                              icon: Icons.lock_outline_rounded,
                                              suffixIcon: IconButton(
                                                key: const Key(
                                                  'login-password-toggle',
                                                ),
                                                tooltip: _obscurePassword
                                                    ? 'Show password'
                                                    : 'Hide password',
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons
                                                            .visibility_off_outlined
                                                      : Icons
                                                            .visibility_outlined,
                                                  size: 19,
                                                ),
                                                color: Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Password is required';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            alignment:
                                                WrapAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            spacing: 8,
                                            runSpacing: 2,
                                            children: [
                                              _RememberMe(
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe = value;
                                                  });
                                                },
                                              ),
                                              TextButton(
                                                onPressed: _showRecoveryMessage,
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white
                                                      .withValues(alpha: 0.82),
                                                  minimumSize: const Size(
                                                    0,
                                                    36,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 2,
                                                      ),
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                child: const Text(
                                                  'Forgot password?',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w700,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        Colors.white54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 18),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.14),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: FilledButton(
                                              key: const Key('login-submit'),
                                              onPressed: _submit,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor:
                                                    AppColors.primaryDark,
                                                elevation: 0,
                                                minimumSize:
                                                    const Size.fromHeight(54),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Sign in',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.1,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 250),
                                child: Text(
                                  'Accounts are issued by your school '
                                  'volunteer coordinator.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              FadeSlideIn(
                                delay: const Duration(milliseconds: 290),
                                child: Text(
                                  'POLOMOLOK NATIONAL HIGH SCHOOL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.4,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.78),
      ),
    );
  }
}

class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (newValue) => onChanged(newValue ?? false),
                activeColor: Colors.white,
                checkColor: AppColors.primary,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 7),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
