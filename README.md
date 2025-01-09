<a href="https://www.buymeacoffee.com/robmllze" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="48"></a>
<a href="https://discord.gg/8hcxk6ZD" target="_blank"><img align="right" src="https://raw.githubusercontent.com/dev-cetera/resources/refs/heads/main/assets/discord_icon/discord_icon.svg" height="48"></a>

Dart & Flutter Packages by dev-cetera.com & contributors.

[![Pub Package](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

## Summary

A package inspired by Rust and functional programming, designed to bring structure, clarity, and safety to your Dart applications.

Dart traditionally uses nulls and try-catch blocks, which can introduce runtime errors and complicate error handling. In contrast, languages like Rust prioritize safer error handling through types like Result and Option, ensuring explicit handling at compile time.

This package introduces Result and Option types to Dart, reducing the reliance on try-catch blocks and nulls. By leveraging these constructs, you can write more predictable, maintainable, and error-resilient code.

For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_safer_dart/).

## Usage Example

Example of avoiding try-catch blocks in Dart, to produce safer code:

```dart
import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  fetchIpAddress().fold(
    (value) => print('IP address: $value'),
    (error) => print('Error: $error'),
  );
}

Result<String> fetchIpAddress() {
  return Result(() async {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    // This throws an exception if the status code is not 200.
    PanicIf(response.statusCode != 200, 'Failed to fetch IP address');
    final data = jsonDecode(response.body);
    final ip = data['ip'] as String;
    // Return the result.
    return ip;
  });
}
```

---

## Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### Ways you can contribute

- **Buy me a coffee:** If you'd like to support the project financially, consider [buying me a coffee](https://www.buymeacoffee.com/robmllze). Your support helps cover the costs of development and keeps the project growing.
- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/8hcxk6ZD.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

### We drink a lot of coffee...

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here: https://www.buymeacoffee.com/robmllze

<a href="https://www.buymeacoffee.com/robmllze" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="40"></a>

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE) for more information.
