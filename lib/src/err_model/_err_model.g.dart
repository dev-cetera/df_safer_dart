//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// GENERATED - DO NOT MODIFY BY HAND
// See: https://github.com/dev-cetera/df_generate_dart_models
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// ignore_for_file: annotate_overrides
// ignore_for_file: overridden_fields

part of 'err_model.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Generated class for [_ErrModel].
class ErrModel {
  //
  //
  //

  /// No description provided.
  final String? type;

  /// No description provided.
  final String? debugPath;

  /// No description provided.
  final String? error;

  /// No description provided.
  final int? statusCode;

  /// No description provided.
  final List<String>? stackTrace;

  /// Constructs a new instance of [ErrModel]
  /// from optional and required parameters.
  const ErrModel({
    required this.type,
    this.debugPath,
    required this.error,
    this.statusCode,
    this.stackTrace,
  });

  /// Creates a copy of this instance, replacing the specified fields.
  ErrModel copyWith({
    String? type,
    String? debugPath,
    String? error,
    int? statusCode,
    List<String>? stackTrace,
  }) {
    return ErrModel(
      type: type ?? this.type,
      debugPath: debugPath ?? this.debugPath,
      error: error ?? this.error,
      statusCode: statusCode ?? this.statusCode,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  /// Creates a copy of this instance, removing the specified fields.
  ErrModel copyWithout({
    bool type = true,
    bool debugPath = true,
    bool error = true,
    bool statusCode = true,
    bool stackTrace = true,
  }) {
    return ErrModel(
      type: type ? this.type : null,
      debugPath: debugPath ? this.debugPath : null,
      error: error ? this.error : null,
      statusCode: statusCode ? this.statusCode : null,
      stackTrace: stackTrace ? this.stackTrace : null,
    );
  }

  /// Returns the value of the [type] field.
  /// If the field is nullable, the return value may be null; otherwise, it
  /// will always return a non-null value.
  @pragma('vm:prefer-inline')
  String get type$ => type!;

  /// Returns the value of the [debugPath] field.
  /// If the field is nullable, the return value may be null; otherwise, it
  /// will always return a non-null value.
  @pragma('vm:prefer-inline')
  String? get debugPath$ => debugPath;

  /// Returns the value of the [error] field.
  /// If the field is nullable, the return value may be null; otherwise, it
  /// will always return a non-null value.
  @pragma('vm:prefer-inline')
  String get error$ => error!;

  /// Returns the value of the [statusCode] field.
  /// If the field is nullable, the return value may be null; otherwise, it
  /// will always return a non-null value.
  @pragma('vm:prefer-inline')
  int? get statusCode$ => statusCode;

  /// Returns the value of the [stackTrace] field.
  /// If the field is nullable, the return value may be null; otherwise, it
  /// will always return a non-null value.
  @pragma('vm:prefer-inline')
  List<String>? get stackTrace$ => stackTrace;
}
