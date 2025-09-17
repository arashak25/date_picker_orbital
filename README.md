Orbital Date Picker

 A customizable Flutter date picker widget with an orbital UI for selecting date ranges (from and to dates). This package provides a unique, visually engaging way to pick dates, with support for customization such as button styles, background gradients, and optional orbital animation.

 ## Features

 - Select date ranges with "From" and "To" date buttons.
 - Interactive orbital UI (optional) with Sun, Earth, and Moon emojis to represent year, month, and day.
 - Customizable button styles, text, and colors.
 - Support for sound effects and haptic feedback on selection.
 - Configurable display options (e.g., show/hide selected date, app bar, weekdays).
 - Responsive design with dynamic sizing based on screen dimensions.

 ## Installation

 Add `date_picker_orbital` to your `pubspec.yaml`:

 ```yaml
 dependencies:
   date_picker_orbital: ^1.0.0
 ```

 Then run:

 ```bash
 flutter pub get
 ```

 ## Usage

 ### Basic Example

 Add the `DatePicker` widget to your app:

 ```dart
 import 'package:flutter/material.dart';
 import 'package:date_picker_orbital/date_picker_orbital.dart';

 void main() {
   runApp(const MyApp());
 }

 class MyApp extends StatelessWidget {
   const MyApp({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       home: Scaffold(
         appBar: AppBar(title: const Text('Orbital Date Picker Demo')),
         body: const Center(child: DatePicker()),
       ),
     );
   }
 }
 ```

 ### Advanced Example with Customization

 Customize the appearance and behavior of the `DatePicker`:

 ```dart
 import 'package:flutter/material.dart';
 import 'package:date_picker_orbital/date_picker_orbital.dart';

 void main() {
   runApp(const MyApp());
 }

 class MyApp extends StatelessWidget {
   const MyApp({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       home: Scaffold(
         appBar: AppBar(title: const Text('Custom Orbital Date Picker')),
         body: Center(
           child: DatePicker(
             buttonStyle: ElevatedButton.styleFrom(
               backgroundColor: Colors.blueAccent,
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
             ),
             buttonFromTitle: 'Pick Start Date',
             buttonToTitle: 'Pick End Date',
             title: 'Select Your Date Range',
             titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
             showOrbital: true,
             backgroundGradient: const LinearGradient(
               colors: [Colors.purple, Colors.blue],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
             showWeekDays: true,
             hasSoundEffect: true,
             datePickerBackgroungColor: Colors.white.withOpacity(0.1),
             selectedDatePickerRowBackgroundColor: Colors.grey.shade200,
           ),
         ),
       ),
     );
   }
 }
 ```

 ## Screenshots

 ![Default Date Picker](https://github.com/arashak25/date_picker_orbital/blob/main/screenshots/second.png)
 *Default view of the Orbital Date Picker with "From" and "To" buttons.*

 ![Customized Date Picker](https://github.com/arashak25/date_picker_orbital/blob/main/screenshots/third.png)
 *Customized date picker with a gradient background and styled buttons.*

 ![Orbital Animation](https://github.com/arashak25/date_picker_orbital/blob/main/screenshots/gif.gif)
 *GIF showcasing the orbital UI with Sun, Earth, and Moon animations.*

 ## Configuration Options

 | Property                              | Type             | Description                                                                 | Default Value                     |
 |---------------------------------------|------------------|-----------------------------------------------------------------------------|-----------------------------------|
 | `buttonStyle`                         | `ButtonStyle?`   | Custom style for the date selection buttons.                                | `ElevatedButton.styleFrom(...)`   |
 | `buttonFromTitle`                     | `String?`        | Text for the "From" date button.                                           | `"Select From Date"`              |
 | `buttonToTitle`                       | `String?`        | Text for the "To" date button.                                             | `"Select To Date"`                |
 | `buttonTitleStyle`                    | `TextStyle?`     | Text style for the button titles.                                          | `TextStyle(fontSize: ...)`        |
 | `title`                               | `String?`        | Title for the date picker dialog.                                          | `"Date of Birth"`                 |
 | `titleStyle`                          | `TextStyle?`     | Text style for the dialog title.                                           | `TextStyle(fontSize: ...)`        |
 | `showSelectedDate`                    | `bool`           | Whether to show the selected date in the dialog.                            | `true`                            |
 | `decorationOfSelectedDate`            | `Decoration?`    | Decoration for the selected date container.                                | `BoxDecoration(...)`              |
 | `showOrbital`                         | `bool`           | Whether to show the orbital date picker UI.                                 | `true`                            |
 | `backgroundGradient`                   | `Gradient?`      | Gradient for the dialog background.                                        | `LinearGradient(...)`             |
 | `backgroundColor`                     | `Color?`         | Background color for the dialog (overrides gradient if set).                | `null`                            |
 | `datePickerButtonText`                | `String?`        | Text for the date picker button (not currently used).                       | `null`                            |
 | `datePickerButtonTextStyle`           | `ButtonStyle?`   | Style for the date picker button text (not currently used).                 | `null`                            |
 | `hasSoundEffect`                      | `bool`           | Whether to enable sound effects and haptic feedback on selection.           | `true`                            |
 | `showAppBar`                          | `bool`           | Whether to show an app bar in the dialog.                                   | `true`                            |
 | `datePickerBackgroungColor`           | `Color?`         | Background color for the picker area.                                       | `Colors.transparent.withOpacity(0.05)` |
 | `selectedDatePickerRowBackgroundColor`| `Color?`         | Background color for the selected picker row.                               | `Colors.black12`                  |
 | `showWeekDays`                        | `bool`           | Whether to show weekday names in the day picker.                            | `true`                            |

 ## Notes

 - The `OrbitalDatePicker` provides a unique orbital animation where the Sun represents the year, the Earth orbits for the month, and the Moon orbits for the day.
 - The package requires the `flutter` and `flutter/services` dependencies, included by default.
 - Ensure you select the "From" date before the "To" date, as enforced by the widget's logic.
 - The orbital UI (`showOrbital: true`) requires gesture interactions to be fully implemented for optimal usability (currently, `onPanUpdate` and `onPanEnd` are placeholders).

 ## Contributing

 Contributions are welcome! Please open an issue or submit a pull request on the [GitHub repository](https://github.com/arashak25/date_picker_orbital).

 ## License

 This package is licensed under the [MIT License](LICENSE).

 ## Contact

 For questions or feedback, reach out via [GitHub Issues](https://github.com/arashak25/date_picker_orbital/issues).