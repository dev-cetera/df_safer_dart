<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img align="right" src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="48"></a>
<a href="https://discord.gg/gEQ8y2nfyX" target="_blank"><img align="right" src="https://raw.githubusercontent.com/dev-cetera/resources/refs/heads/main/assets/discord_icon/discord_icon.svg" height="48"></a>

Dart & Flutter Packages by dev-cetera.com & contributors.

[![Pub Package](https://img.shields.io/pub/v/df_safer_dart.svg)](https://pub.dev/packages/df_safer_dart)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE)

---

## Summary

This package, inspired by [Rust](<https://en.wikipedia.org/wiki/Rust_(programming_language)>) and [functional programming](https://en.wikipedia.org/wiki/Functional_programming), aims to enhance the structure, safety and debuggability of your applications by leveraging [monads](<https://en.wikipedia.org/wiki/Monad_(functional_programming)>) and other advanced mechanisms.

Dart’s traditional error-handling approach depends on null checks, try-catch blocks, and Futures that can throw errors at any time, necessitating asynchronous error handling. This often leads to complex and unpredictable error management.

Aiming to address these challenges, this package offers safer alternatives and more predictable mechanisms.

While it introduces some boilerplate and incurs a minor performance trade-off due to safety checks, it is best suited for mission critical sections of your project where reliability and safety are essential. For less sensitive code, standard approaches like Future, FutureOr, try-catch, and nullable types may be more appropriate.

This package introduces three core monads —- `Result`, `Option`, and `Resolvable` -- that work seamlessly together:

- `Result`: Encapsulates a value that is either `Ok` (success) or `Err` (failure), providing a structured approach to error handling.
- `Option`: Represents a value that is either `Some` (present) or `None` (absent), ensuring explicit handling of nullable scenarios.
- `Resolvable`: Unifies asynchronous and synchronous values, creating a consistent interface for both paradigms.

These monads form the foundation for more predictable, expressive, and maintainable error handling in Dart.

Additionally, the package includes two complementary mechanisms:

- `SafeCompleter`: A secure alternative to Dart’s Completer, leveraging the included monads to handle both synchronous and asynchronous values with built-in safety.
- `Sequential`: A utility for executing synchronous or asynchronous code in guaranteed sequential order, simplifying the management of complex workflows.

With these tools, the package provides a solid framework for improving the reliability and readability of your Dart applications.

For a full feature set, please refer to the [API reference](https://pub.dev/documentation/df_safer_dart/).

## Usage Example

Example of avoiding try-catch blocks in Dart, to produce safer code:

```dart
import 'package:df_safer_dart/df_safer_dart.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  fetchIpAddress().flatMap(
    (result) => result.ifOk((e) {
      print('IP address: ${result.unwrap()}');
    }).ifErr((e) {
      print('Error: $e');
    }),
  );
}

Async<String> fetchIpAddress() {
  return Async(
    () async {
      final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode != 200) {
        throw const Err(
          debugPath: ['fetchIpAddress'],
          error: 'Failed to fetch IP address',
        );
      }
      final data = jsonDecode(response.body);
      final ip = data['ip'] as String;
      return ip;
    },
  );
}
```

---

## Contributing and Discussions

This is an open-source project, and we warmly welcome contributions from everyone, regardless of experience level. Whether you're a seasoned developer or just starting out, contributing to this project is a fantastic way to learn, share your knowledge, and make a meaningful impact on the community.

### Ways you can contribute

- **Buy me a coffee:** If you'd like to support the project financially, consider [buying me a coffee](https://www.buymeacoffee.com/dev_cetera). Your support helps cover the costs of development and keeps the project growing.
- **Find us on Discord:** Feel free to ask questions and engage with the community here: https://discord.gg/gEQ8y2nfyX.
- **Share your ideas:** Every perspective matters, and your ideas can spark innovation.
- **Help others:** Engage with other users by offering advice, solutions, or troubleshooting assistance.
- **Report bugs:** Help us identify and fix issues to make the project more robust.
- **Suggest improvements or new features:** Your ideas can help shape the future of the project.
- **Help clarify documentation:** Good documentation is key to accessibility. You can make it easier for others to get started by improving or expanding our documentation.
- **Write articles:** Share your knowledge by writing tutorials, guides, or blog posts about your experiences with the project. It's a great way to contribute and help others learn.

No matter how you choose to contribute, your involvement is greatly appreciated and valued!

### We drink a lot of coffee...

If you're enjoying this package and find it valuable, consider showing your appreciation with a small donation. Every bit helps in supporting future development. You can donate here: https://www.buymeacoffee.com/dev_cetera

<a href="https://www.buymeacoffee.com/dev_cetera" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" height="40"></a>

## License

This project is released under the MIT License. See [LICENSE](https://raw.githubusercontent.com/dev-cetera/df_safer_dart/main/LICENSE) for more information.
