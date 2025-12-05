import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionGate extends StatelessWidget {
  final Widget authenticated;
  final Widget unauthenticated;

  const SessionGate({
    super.key,
    required this.authenticated,
    required this.unauthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return authenticated; // Sudah login → masuk home
        } else {
          return unauthenticated; // Belum login → ke login/onboarding
        }
      },
    );
  }
}
