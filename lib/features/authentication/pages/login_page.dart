import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitquest/core/constants/app_colors.dart';
import 'package:fitquest/core/constants/app_spacing.dart';
import 'package:fitquest/core/utils/validators.dart';
import 'package:fitquest/core/navigation/app_router.dart';
import 'package:fitquest/shared/widgets/premium_button.dart';
import 'package:fitquest/features/authentication/bloc/auth_bloc.dart';
import 'package:fitquest/features/authentication/bloc/auth_event.dart';
import 'package:fitquest/features/authentication/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthSignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              AppRouter.navigateAndRemoveUntil(context, AppRouter.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),
                    // Enhanced Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to continue your wellness journey',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Enter your email',
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 12),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Show forgot password dialog
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Login button
                    PremiumButton(
                      label: 'Sign In',
                      onPressed: state is AuthLoading ? null : _handleLogin,
                      icon: Icons.login_rounded,
                      gradient: AppColors.primaryGradient,
                      width: double.infinity,
                      height: 56,
                    ),
                    if (state is AuthLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        TextButton(
                          onPressed: () {
                            AppRouter.navigateAndReplace(
                              context,
                              AppRouter.signUp,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
