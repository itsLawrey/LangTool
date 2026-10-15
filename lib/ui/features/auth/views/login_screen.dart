import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/login_view_model.dart';
import 'email_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'LangTool',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (viewModel.supportsGoogleSignIn) ...[
                  FilledButton.tonal(
                    onPressed: viewModel.busy
                        ? null
                        : viewModel.signInWithGoogle,
                    child: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                EmailForm(viewModel: viewModel),
                if (viewModel.error case final error?) ...[
                  const SizedBox(height: 16),
                  Text(
                    error,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (viewModel.info case final info?) ...[
                  const SizedBox(height: 16),
                  Text(info, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
