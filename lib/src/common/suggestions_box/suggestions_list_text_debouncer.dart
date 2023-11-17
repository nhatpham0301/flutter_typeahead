import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/src/common/suggestions_box/connector_widget.dart';

/// A widget that notifies of changes to a [TextEditingController],
/// but only after a specified duration has passed since the last change.
class SuggestionsListTextDebouncer extends StatefulWidget {
  const SuggestionsListTextDebouncer({
    super.key,
    required this.controller,
    required this.onChanged,
    this.debounceDuration,
    required this.child,
  });

  /// The controller whose text to listen to.
  final TextEditingController controller;

  /// Called when the text in the controller's text field changes.
  final ValueSetter<String> onChanged;

  /// The duration to wait after the last change in the controller's text.
  ///
  /// Defaults to 300 milliseconds.
  /// Set to `Duration.zero` to disable debouncing.
  final Duration? debounceDuration;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<SuggestionsListTextDebouncer> createState() =>
      _SuggestionsListTextDebouncerState();
}

class _SuggestionsListTextDebouncerState
    extends State<SuggestionsListTextDebouncer> {
  String? lastTextValue;
  Timer? debounceTimer;

  @override
  void initState() {
    super.initState();
    // avoid triggering a change when the widget is first built
    lastTextValue = widget.controller.text;
  }

  void onChange() {
    if (widget.controller.text == lastTextValue) return;
    lastTextValue = widget.controller.text;

    Duration? debounceDuration = widget.debounceDuration;
    debounceDuration ??= const Duration(milliseconds: 300);

    debounceTimer?.cancel();
    if (debounceDuration == Duration.zero) {
      widget.onChanged(widget.controller.text);
    } else {
      debounceTimer = Timer(
        debounceDuration,
        () => widget.onChanged(widget.controller.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectorWidget(
      value: widget.controller,
      connect: (value) {
        // if we switch controllers, we call onChange.
        onChange();
        value.addListener(onChange);
      },
      disconnect: (value, key) {
        debounceTimer?.cancel();
        value.removeListener(onChange);
      },
      child: widget.child,
    );
  }
}