import '../monads/monad.dart';

extension SaferIterable<E extends Object> on Iterable<E> {
  Option<E> get firstOrNone {
    final it = iterator;
    if (it.moveNext()) {
      return Some(it.current);
    }
    return const None();
  }

  Option<E> get lastOrNone {
    final it = iterator;
    if (!it.moveNext()) {
      return const None();
    }
    E result;
    do {
      result = it.current;
    } while (it.moveNext());
    return Some(result);
  }

  Option<E> get singleOrNone {
    final it = iterator;
    if (it.moveNext()) {
      final result = it.current;
      if (!it.moveNext()) {
        return Some(result);
      }
    }
    return const None();
  }

  Option<E> firstWhereOrNone(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) return Some(element);
    }
    return const None();
  }

  Option<E> lastWhereOrNone(bool Function(E element) test) {
    Option<E> result = const None();
    for (final element in this) {
      if (test(element)) {
        result = Some(element);
      }
    }
    return result;
  }

  Option<E> singleWhereOrNone(bool Function(E element) test) {
    Option<E> result = const None();
    for (final element in this) {
      if (test(element)) {
        if (result.isSome()) {
          return const None();
        }
        result = Some(element);
      }
    }
    return result;
  }

  Option<E> reduceOrNone(E Function(E value, E element) combine) {
    final it = iterator;
    if (!it.moveNext()) {
      return const None();
    }
    var value = it.current;
    while (it.moveNext()) {
      value = combine(value, it.current);
    }
    return Some(value);
  }

  Option<E> elementAtOrNone(int index) {
    if (index < 0) return const None();

    var i = 0;
    for (final element in this) {
      if (i == index) {
        return Some(element);
      }
      i++;
    }
    return const None();
  }
}
