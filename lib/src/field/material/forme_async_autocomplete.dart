import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:forme/forme.dart';

typedef FormeAutocompleteOptionsViewBuilder<T extends Object> = Widget Function(
    BuildContext context,
    AutocompleteOnSelected<T> onSelected,
    Iterable<T> options,
    double? width);

typedef FormeAsyncAutocompleteOptionsBuilder<T> = Future<Iterable<T>> Function(
    TextEditingValue value);

typedef FormeSearchCondition = bool Function(TextEditingValue value);

class FormeAsyncAutocomplete<T extends Object> extends FormeField<T?> {
  FormeAsyncAutocomplete({
    super.key,
    super.name,
    super.initialValue,
    super.asyncValidator,
    super.asyncValidatorDebounce,
    super.autovalidateMode,
    super.decorator,
    super.enabled = true,
    super.focusNode,
    super.onInitialized,
    super.onSaved,
    super.onStatusChanged,
    super.order,
    super.quietlyValidate = false,
    super.readOnly = false,
    super.requestFocusOnUserInteraction = true,
    super.validationFilter,
    super.validator,
    this.optionsMaxHeight = 200,
    this.debounce,
    required this.optionsBuilder,
    this.searchCondition,
    this.fieldViewDecorator,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    InputDecoration? decoration = const InputDecoration(),
    this.fieldViewBuilder,
    this.optionsViewBuilder,
  }) : super.allFields(
          builder: (genericState) {
            final FormeAsyncAutocompleteState<T> state =
                genericState as FormeAsyncAutocompleteState<T>;
            final bool readOnly = state.readOnly;
            return RawAutocomplete<T>(
              focusNode: state.focusNode,
              textEditingController: state._textEditingController,
              onSelected: (T t) {
                state.didChange(t);
                state.effectiveController.selection = TextSelection.collapsed(
                    offset: state.effectiveController.text.length);
                state._clearOptionsAndWaiting();
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<T> onSelected, Iterable<T> options) {
                state._optionsViewVisibleStateNotifier.value = true;

                return LayoutBuilder(builder: (context, constraints) {
                  final Size? size = state._fieldSizeGetter?.call();
                  final double? width = size?.width;
                  return optionsViewBuilder?.call(
                          context, onSelected, state._options, width) ??
                      AutocompleteOptions(
                        displayStringForOption: displayStringForOption,
                        onSelected: onSelected,
                        options: state._options,
                        maxOptionsHeight: optionsMaxHeight,
                        width: width,
                      );
                });
              },
              optionsBuilder: (TextEditingValue value) {
                if (state._stateNotifier.value ==
                    FormeAsyncOperationState.success) {
                  return state._options;
                }
                return const Iterable.empty();
              },
              displayStringForOption: displayStringForOption,
              fieldViewBuilder:
                  (context, textEditingController, focusNode, onSubmitted) {
                Widget field;
                if (fieldViewBuilder != null) {
                  field = fieldViewBuilder(context, state.effectiveController,
                      focusNode, onSubmitted);
                } else {
                  field = TextField(
                    enabled: state.enabled,
                    onSubmitted: readOnly
                        ? null
                        : (v) {
                            onSubmitted();
                          },
                    decoration: decoration?.copyWith(
                        errorText: state.errorText,
                        suffixIcon: decoration.suffixIcon ??
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder<
                                        FormeAsyncOperationState?>(
                                    valueListenable: state._stateNotifier,
                                    builder: (context, state, child) {
                                      if (state == null) {
                                        return const SizedBox.shrink();
                                      }
                                      switch (state) {
                                        case FormeAsyncOperationState
                                            .processing:
                                          return const Padding(
                                            padding: EdgeInsets.all(0),
                                            child: SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          );
                                        case FormeAsyncOperationState.success:
                                          return const SizedBox.shrink();
                                        case FormeAsyncOperationState.error:
                                          return const Icon(Icons.dangerous,
                                              color: Colors.redAccent);
                                      }
                                    }),
                              ],
                            )),
                    focusNode: focusNode,
                    controller: state.effectiveController,
                    onChanged: readOnly
                        ? null
                        : (String v) {
                            final T? value = state.value;
                            if (value != null &&
                                displayStringForOption(value) != v) {
                              state.didChange(null);
                            }
                          },
                  );
                }
                return _FieldView(
                    state: state,
                    child: fieldViewDecorator == null
                        ? field
                        : fieldViewDecorator.build(
                            context,
                            field,
                            state,
                          ));
              },
            );
          },
        );

  /// **this decorator is used to decorate fieldView Only**
  final FormeFieldDecorator<T?>? fieldViewDecorator;
  final AutocompleteOptionToString<T> displayStringForOption;

  /// async loader debounce
  final Duration? debounce;

  final FormeAsyncAutocompleteOptionsBuilder<T> optionsBuilder;

  final double optionsMaxHeight;

  /// whether perform a search with current input
  ///
  /// return false means **DO NOT** perform a search and will clear prev options immediately
  final FormeSearchCondition? searchCondition;

  final AutocompleteFieldViewBuilder? fieldViewBuilder;
  final FormeAutocompleteOptionsViewBuilder<T>? optionsViewBuilder;
  @override
  FormeFieldState<T?> createState() => FormeAsyncAutocompleteState();
}

class FormeAsyncAutocompleteState<T extends Object> extends FormeFieldState<T?>
    with FormeAsyncOperationHelper<Iterable<T>> {
  final TextEditingController _textEditingController = TextEditingController();
  late final TextEditingController effectiveController;
  final ValueNotifier<FormeAsyncOperationState?> _stateNotifier =
      FormeMountedValueNotifier(null);
  final ValueNotifier<bool> _optionsViewVisibleStateNotifier =
      FormeMountedValueNotifier(false);

  Iterable<T> _options = [];
  Timer? _debounce;
  String? _oldTextValue;
  Size? Function()? _fieldSizeGetter;

  ValueListenable<bool> get optionsViewVisibleListenable =>
      FormeValueListenableDelegate(_optionsViewVisibleStateNotifier);

  @override
  void initStatus() {
    super.initStatus();
    final String initialText = initialValue == null
        ? ''
        : widget.displayStringForOption(initialValue!);
    effectiveController = TextEditingController(text: initialText);
    effectiveController.addListener(_fieldChange);
  }

  void _fieldChange() {
    final String text = effectiveController.text;
    if (_oldTextValue != text) {
      _oldTextValue = text;
      if (value != null && widget.displayStringForOption(value!) == text) {
        return;
      }

      if (widget.searchCondition != null) {
        final bool performSearch =
            widget.searchCondition!(effectiveController.value);

        if (!performSearch) {
          _clearOptionsAndWaiting();
          return;
        }
      }
      _queryOptions(effectiveController.value);
    }
  }

  @override
  FormeAsyncAutocomplete<T> get widget =>
      super.widget as FormeAsyncAutocomplete<T>;

  void _clearOptionsAndWaiting() {
    cancelAsyncOperation();
    _debounce?.cancel();
    _options = [];
    _stateNotifier.value = null;
    _updateTextEditingController();
    _optionsViewVisibleStateNotifier.value = false;
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<T?> status) {
    super.onStatusChanged(status);
    if (status.isFocusChanged) {
      if (!status.hasFocus) {
        _optionsViewVisibleStateNotifier.value = false;
      }
    }

    if (status.isValueChanged) {
      if (status.value != null) {
        final String text = widget.displayStringForOption(status.value!);
        if (effectiveController.text != text) {
          effectiveController.text = text;
        }
      }
    }

    if (status.isReadOnlyChanged && status.readOnly) {
      _clearOptionsAndWaiting();
    }
  }

  void _queryOptions(TextEditingValue value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce ?? const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      perform(widget.optionsBuilder(value));
    });
  }

  void _updateTextEditingController() {
    String newText =
        value == null ? '' : '${widget.displayStringForOption(value!)} ';
    if (newText == _textEditingController.text) {
      newText += ' ';
    }
    _textEditingController.text = newText;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _stateNotifier.dispose();
    _optionsViewVisibleStateNotifier.dispose();
    _textEditingController.dispose();
    effectiveController.dispose();
    super.dispose();
  }

  @override
  void reset() {
    _debounce?.cancel();
    _oldTextValue = null;
    _options = [];
    super.reset();
    _stateNotifier.value = null;
    if (hasFocusNode) {
      focusNode.unfocus();
    }
    // we do not want to perform a search
    effectiveController.removeListener(_fieldChange);
    if (value != null) {
      effectiveController.text = widget.displayStringForOption(value!);
    } else {
      effectiveController.text = '';
    }
    effectiveController.addListener(_fieldChange);
  }

  String? get displayStringForOption =>
      value == null ? null : widget.displayStringForOption(value!);

  @override
  void onAsyncStateChanged(FormeAsyncOperationState state, Object? key) {
    if (mounted) {
      _stateNotifier.value = state;
    }
  }

  @override
  void onSuccess(Iterable<T> result, Object? key) {
    if (mounted) {
      _options = result;
      _updateTextEditingController();
    }
  }
}

// The default Material-style Autocomplete options.
class AutocompleteOptions<T extends Object> extends StatelessWidget {
  const AutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.width,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final BoxConstraints constraints = width == null
        ? BoxConstraints(maxHeight: maxOptionsHeight)
        : BoxConstraints(maxHeight: maxOptionsHeight, maxWidth: width!);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: constraints,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final T option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(builder: (BuildContext context) {
                  final bool highlight =
                      AutocompleteHighlightedOption.of(context) == index;
                  if (highlight) {
                    SchedulerBinding.instance
                        .addPostFrameCallback((Duration timeStamp) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(displayStringForOption(option)),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FieldView extends StatefulWidget {
  final Widget child;
  final FormeAsyncAutocompleteState state;

  const _FieldView({Key? key, required this.child, required this.state})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _FieldViewState();
}

class _FieldViewState extends State<_FieldView> {
  @override
  void deactivate() {
    widget.state._fieldSizeGetter = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    widget.state._fieldSizeGetter =
        () => (context.findRenderObject()! as RenderBox).size;
    return widget.child;
  }
}
