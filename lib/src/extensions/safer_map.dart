import '../monads/monad.dart';

extension SaferMap<K, V extends Object> on Map<K, V> {
  Option<V> getOption(K key) {
    if (containsKey(key)) {
      return Some(this[key]!);
    }
    return const None();
  }
}
