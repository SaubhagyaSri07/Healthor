import 'package:flutter_test/flutter_test.dart';
     import 'package:healthor/main.dart'; // Adjust path if needed

     void main() {
       testWidgets('Healthor app basic UI test', (WidgetTester tester) async {
         // Build our app and trigger a frame.
         await tester.pumpWidget(const HealthorApp());

         // Verify that the app title is present.
         expect(find.text('Healthor'), findsOneWidget);

         // Verify that the welcome text is present.
         expect(find.text('Welcome to Healthor!'), findsOneWidget);
       });
     }