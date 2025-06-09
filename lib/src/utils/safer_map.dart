import '../monads/monad.dart';

extension SaferMap<K, V extends Object> on Map<K, V> {
  Option<V> getOption(K key) {
    if (containsKey(key)) {
      return Some(this[key]!);
    }
    return const None();
  }

  Option<T> getAndCast<T extends Object>(K key) {
    if (containsKey(key)) {
      final value = this[key];
      if (value is T) {
        return Some(value);
      }
    }
    return const None();
  }
}
