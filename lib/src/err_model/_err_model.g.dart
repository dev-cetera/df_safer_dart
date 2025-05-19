//.title
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// GENERATED - DO NOT MODIFY BY HAND
// See: https://github.com/dev-cetera/df_generate_dart_models
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//.title~

// ignore_for_file: annotate_overrides
// ignore_for_file: argument_type_not_assignable
// ignore_for_file: invalid_null_aware_operator
// ignore_for_file: overridden_fields
// ignore_for_file: require_trailing_commas
// ignore_for_file: unnecessary_non_null_assertion
// ignore_for_file: unnecessary_null_comparison
// ignore_for_file: unnecessary_question_mark

part of 'err_model.dart';

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

/// Generated class for [_ErrModel].
class ErrModel extends Model {
  //
  //
  //

  /// The runtime type of this class as a String.
  static const CLASS_NAME = 'ErrModel';

  @override
  String get $className => CLASS_NAME;

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

  /// Construcs a new instance of [ErrModel],
  /// forcing all parameters to be optional.
  const ErrModel.optional({
    this.type,
    this.debugPath,
    this.error,
    this.statusCode,
    this.stackTrace,
  });

  /// Constructs a new instance of [ErrModel],
  /// and asserts that all required parameters are not null.
  factory ErrModel.assertRequired({
    String? type,
    String? debugPath,
    String? error,
    int? statusCode,
    List<String>? stackTrace,
  }) {
    assert(type != null);

    assert(error != null);

    return ErrModel(
      type: type,
      debugPath: debugPath,
      error: error,
      statusCode: statusCode,
      stackTrace: stackTrace,
    );
  }

  /// Constructs a new instance of [ErrModel],
  /// from the fields of [another] instance. Throws if the conversion fails.
  factory ErrModel.from(
    BaseModel another,
  ) {
    try {
      return fromOrNull(another)!;
    } catch (e) {
      assert(false, '$ErrModel.from: $e');
      rethrow;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from the fields of [another] instance. Returns `null` if [another] is
  /// `null` or if the conversion fails.
  @pragma('vm:prefer-inline')
  static ErrModel? fromOrNull(
    BaseModel? another,
  ) {
    return fromJsonOrNull(another?.toJson())!;
  }

  /// Constructs a new instance of [ErrModel],
  /// from the fields of [another] instance. Throws if the conversion fails.
  factory ErrModel.of(
    ErrModel another,
  ) {
    try {
      return ofOrNull(another)!;
    } catch (e) {
      assert(false, '$ErrModel.of: $e');
      rethrow;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from the fields of [another] instance. Returns `null` if [another] is
  /// `null` or if the conversion fails.
  @pragma('vm:prefer-inline')
  static ErrModel? ofOrNull(
    ErrModel? other,
  ) {
    return fromJsonOrNull(other?.toJson());
  }

  /// Constructs a new instance of [ErrModel],
  /// from [jsonString], which must be a valid JSON String. Throws if the
  /// conversion fails.
  factory ErrModel.fromJsonString(
    String jsonString,
  ) {
    try {
      return fromJsonStringOrNull(jsonString)!;
    } catch (e) {
      assert(false, '$ErrModel.fromJsonString: $e');
      rethrow;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from [jsonString], which must be a valid JSON String. Returns `null` if
  /// [jsonString] is `null` or if the conversion fails.
  static ErrModel? fromJsonStringOrNull(
    String? jsonString,
  ) {
    try {
      if (jsonString!.isNotEmpty) {
        final decoded = letMapOrNull<String, dynamic>(jsonDecode(jsonString));
        return ErrModel.fromJson(decoded);
      } else {
        return ErrModel.assertRequired();
      }
    } catch (_) {
      return null;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from [json], which must be a valid JSON object. Throws if the conversion
  /// fails.
  factory ErrModel.fromJson(
    Map<String, dynamic>? json,
  ) {
    try {
      return fromJsonOrNull(json)!;
    } catch (e) {
      assert(false, '$ErrModel.fromJson: $e');
      rethrow;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from [json], which must be a valid JSON object. Returns `null` if
  /// [json] is `null` or if the conversion fails.
  static ErrModel? fromJsonOrNull(
    Map<String, dynamic>? json,
  ) {
    try {
      final type = json?['type']?.toString().trim().nullIfEmpty;
      final debugPath = json?['debugPath']?.toString().trim().nullIfEmpty;
      final error = json?['error']?.toString().trim().nullIfEmpty;
      final statusCode = letAsOrNull<int>(json?['statusCode']);
      final stackTrace = letListOrNull<dynamic>(json?['stackTrace'])
          ?.map(
            (p0) => p0?.toString().trim().nullIfEmpty,
          )
          .nonNulls
          .nullIfEmpty
          ?.toList()
          .unmodifiable;
      return ErrModel(
        type: type,
        debugPath: debugPath,
        error: error,
        statusCode: statusCode,
        stackTrace: stackTrace,
      );
    } catch (e) {
      return null;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from the query parameters of [uri]. Throws if the conversion
  /// fails.
  factory ErrModel.fromUri(
    Uri? uri,
  ) {
    try {
      return fromUriOrNull(uri)!;
    } catch (e) {
      assert(false, '$ErrModel.fromUri: $e');
      rethrow;
    }
  }

  /// Constructs a new instance of [ErrModel],
  /// from the query parameters of [uri]. Returns `null` if [uri] is `null` or
  /// if the conversion fails.
  static ErrModel? fromUriOrNull(
    Uri? uri,
  ) {
    try {
      if (uri != null && uri.path == CLASS_NAME) {
        return ErrModel.fromJson(uri.queryParameters);
      } else {
        return ErrModel.assertRequired();
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson({
    bool includeNulls = false,
  }) {
    try {
      final type0 = type?.trim().nullIfEmpty;
      final debugPath0 = debugPath?.trim().nullIfEmpty;
      final error0 = error?.trim().nullIfEmpty;
      final statusCode0 = statusCode;
      final stackTrace0 = stackTrace
          ?.map(
            (p0) => p0?.trim().nullIfEmpty,
          )
          .nonNulls
          .nullIfEmpty
          ?.toList();
      final withNulls = {
        'type': type0,
        'statusCode': statusCode0,
        'stackTrace': stackTrace0,
        'error': error0,
        'debugPath': debugPath0,
      };
      return includeNulls ? withNulls : withNulls.nonNulls;
    } catch (e) {
      assert(false, '$ErrModel.toJson: $e');
      rethrow;
    }
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

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

abstract final class ErrModelFieldNames {
  /// The field name of [ErrModel.type].
  static const type = 'type';

  /// The field name of [ErrModel.debugPath].
  static const debugPath = 'debugPath';

  /// The field name of [ErrModel.error].
  static const error = 'error';

  /// The field name of [ErrModel.statusCode].
  static const statusCode = 'statusCode';

  /// The field name of [ErrModel.stackTrace].
  static const stackTrace = 'stackTrace';
}

extension ErrModelX on ErrModel {
  /// Creates a copy of this instance, merging another model's fields into
  /// this model's fields.
  ErrModel mergeWith(
    BaseModel? other, {
    bool deepMerge = false,
  }) {
    final a = toJson();
    final b = other?.toJson() ?? {};
    final data = (deepMerge ? mergeDataDeep(a, b) : {...a, ...b}) as Map;
    return ErrModel.fromJson(data.cast());
  }

  /// Creates a copy of this instance, replacing the specified fields.
  ErrModel copyWith({
    String? type,
    String? debugPath,
    String? error,
    int? statusCode,
    List<String>? stackTrace,
  }) {
    return ErrModel.assertRequired(
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
    return ErrModel.assertRequired(
      type: type ? this.type : null,
      debugPath: debugPath ? this.debugPath : null,
      error: error ? this.error : null,
      statusCode: statusCode ? this.statusCode : null,
      stackTrace: stackTrace ? this.stackTrace : null,
    );
  }
}
