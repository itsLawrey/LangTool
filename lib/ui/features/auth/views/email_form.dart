import 'package:flutter/material.dart';

import '../view_models/login_view_model.dart';

/// Email/password sign-in or sign-up, depending on [LoginViewModel.mode].
class EmailForm extends StatefulWidget {
  const EmailForm({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<EmailForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.submitEmail(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final signUp = viewModel.mode == LoginMode.signUp;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) => (value ?? '').contains('@')
                ? null
                : 'Enter a valid email address.',
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            autofillHints: [
              signUp ? AutofillHints.newPassword : AutofillHints.password,
            ],
            validator: (value) =>
                (value ?? '').length < 6 ? 'Use at least 6 characters.' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: viewModel.busy ? null : _submit,
            child: Text(signUp ? 'Create account' : 'Sign in'),
          ),
          TextButton(
            onPressed: viewModel.busy ? null : viewModel.toggleMode,
            child: Text(
              signUp
                  ? 'Already have an account? Sign in'
                  : 'No account? Create one',
            ),
          ),
        ],
      ),
    );
  }
}
