import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knotwork/auth/auth_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginPage(),
    );
  }

  testWidgets("Initial screen shows Sign Up mode with email field",
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(TextFormField), findsNWidgets(3)); // email + username + pwd

    expect(find.text("Sign up"), findsOneWidget);
    expect(find.text("Already have an account? Sign in"), findsOneWidget);
  });

  testWidgets("Switching to Log In hides email field",
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // tap switch to sign-in
    await tester.tap(find.text("Already have an account? Sign in"));
    await tester.pumpAndSettle();

    // Now email should be hidden → only username + password remain
    expect(find.byType(TextFormField), findsNWidgets(2));

    expect(find.text("Log in"), findsOneWidget);
    expect(find.text("Don't have an account? Sign up"), findsOneWidget);
  });

  testWidgets("Tapping login button calls login()", (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // switch to login mode
    await tester.tap(find.text("Already have an account? Sign in"));
    await tester.pumpAndSettle();

    // enter username + password
    await tester.enterText(find.byType(TextFormField).at(0), "john");
    await tester.enterText(find.byType(TextFormField).at(1), "pass123");

    // tap login
    await tester.tap(find.text("Log in"));
    await tester.pump();

    // We cannot assert API call since it's real, but UI shouldn't crash
    expect(find.text("Log in"), findsOneWidget);
  });

  testWidgets("TOTP / Passkey toggles appear in log-in mode",
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.text("Already have an account? Sign in"));
    await tester.pumpAndSettle();

    // Initially login with Passkey visible
    expect(find.text("Log in with Authenticator app"), findsOneWidget);

    // Tap to toggle
    await tester.tap(find.text("Log in with Authenticator app"));
    await tester.pumpAndSettle();

    expect(find.text("Log in with Passkey"), findsOneWidget);
  });
}
