import 'dart:html';
import 'dart:math';

Future<CssStyleDeclaration> fadeAway(CssStyleDeclaration css,
    {double initialValue = 1.0,
    Duration duration = const Duration(milliseconds: 300)}) async {
  initialValue = max(0.0, min(initialValue, 1.0));
  if (initialValue == 0.0) return css;
  const stepDuration = Duration(milliseconds: 10);
  if (duration < stepDuration) duration = stepDuration;
  final steps = duration.inMilliseconds / stepDuration.inMilliseconds;
  final stepChange = initialValue / steps;
  var opacity = initialValue;
  for (var i = 0; i < steps; i++) {
    css.opacity = opacity.toString();
    opacity -= stepChange;
    await Future.delayed(stepDuration);
  }
  css
    ..opacity = "0"
    ..display = 'none';
  return css;
}

Future<T> showLoadingUntilCompletion<T>(
    Future<T> future, Element overlay) async {
  const initialOpacity = 0.5;
  overlay.style
    ..opacity = initialOpacity.toString()
    ..display = '';
  try {
    return await future;
  } finally {
    // ignore: unawaited_futures
    fadeAway(overlay.style, initialValue: initialOpacity);
  }
}
