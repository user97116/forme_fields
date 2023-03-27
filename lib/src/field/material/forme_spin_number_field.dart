import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:decimal/decimal.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';

class FormeSpinNumberField extends FormeField<double> {
  FormeSpinNumberField({
    super.key,
    super.name,
    double? initialValue = 0,
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
    this.strictStep = false,
    this.interval = const Duration(milliseconds: 100),
    this.step = 1,
    this.acceleration = 0,
    required this.max,
    required this.min,
    this.increasementIconConfiguration,
    this.decreasementIconConfiguration,
    this.editable = true,
    this.decoration = const InputDecoration(),
    this.maxLines = 1,
    this.autofocus = false,
    this.minLines,
    this.maxLength,
    this.style,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.strutStyle,
    this.textAlignVertical,
    this.textDirection,
    this.showCursor,
    this.smartDashesType,
    this.smartQuotesType,
    this.expands = false,
    this.maxLengthEnforcement,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = BoxHeightStyle.tight,
    this.selectionWidthStyle = BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20),
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.scrollPhysics,
    this.enableInteractiveSelection = true,
    this.onEditingComplete,
    this.inputFormatters,
    this.appPrivateCommandCallback,
    this.onTap,
    this.onSubmitted,
    this.scrollController,
    this.textSelectionControls,
    this.onTapOutside,
    this.clipBehavior,
    this.scribbleEnabled,
    this.contextMenuBuilder = _defaultContextMenuBuilder,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  }) : super.allFields(
          initialValue: initialValue == null
              ? min
              : initialValue < min || initialValue > max
                  ? min
                  : initialValue,
          builder: (baseState) {
            final bool readOnly = baseState.readOnly;
            final bool enabled = baseState.enabled;

            final _FormeSpinNumberFieldState state =
                baseState as _FormeSpinNumberFieldState;

            final InputDecoration finalDecoration =
                (decoration ?? const InputDecoration()).copyWith(
              errorText: state.errorText,
              prefixIcon: IconButton(
                iconSize: decreasementIconConfiguration?.iconSize ?? 24,
                visualDensity: decreasementIconConfiguration?.visualDensity,
                padding: decreasementIconConfiguration?.padding ??
                    const EdgeInsets.all(8.0),
                alignment: decreasementIconConfiguration?.alignment ??
                    Alignment.center,
                splashRadius: decreasementIconConfiguration?.splashRadius,
                color: decreasementIconConfiguration?.color,
                focusColor: decreasementIconConfiguration?.focusColor,
                hoverColor: decreasementIconConfiguration?.hoverColor,
                highlightColor: decreasementIconConfiguration?.highlightColor,
                splashColor: decreasementIconConfiguration?.splashColor,
                disabledColor: decreasementIconConfiguration?.disabledColor,
                tooltip: decreasementIconConfiguration?.tooltip,
                enableFeedback:
                    decreasementIconConfiguration?.enableFeedback ?? true,
                constraints: decreasementIconConfiguration?.constraints,
                onPressed: readOnly ? null : state.subtract,
                icon: GestureDetector(
                  onLongPress: readOnly
                      ? null
                      : () {
                          state.startAccelerate(_CalcType.subtract);
                        },
                  onLongPressUp: state.stopAccelerate,
                  child: decreasementIconConfiguration?.icon ??
                      const Icon(Icons.remove),
                ),
              ),
              suffixIcon: IconButton(
                iconSize: increasementIconConfiguration?.iconSize ?? 24,
                visualDensity: increasementIconConfiguration?.visualDensity,
                padding: increasementIconConfiguration?.padding ??
                    const EdgeInsets.all(8.0),
                alignment: increasementIconConfiguration?.alignment ??
                    Alignment.center,
                splashRadius: increasementIconConfiguration?.splashRadius,
                color: increasementIconConfiguration?.color,
                focusColor: increasementIconConfiguration?.focusColor,
                hoverColor: increasementIconConfiguration?.hoverColor,
                highlightColor: increasementIconConfiguration?.highlightColor,
                splashColor: increasementIconConfiguration?.splashColor,
                disabledColor: increasementIconConfiguration?.disabledColor,
                tooltip: increasementIconConfiguration?.tooltip,
                enableFeedback:
                    increasementIconConfiguration?.enableFeedback ?? true,
                constraints: increasementIconConfiguration?.constraints,
                onPressed: readOnly ? null : state.add,
                icon: GestureDetector(
                  onLongPress: readOnly
                      ? null
                      : () {
                          state.startAccelerate(_CalcType.plus);
                        },
                  onLongPressUp: state.stopAccelerate,
                  child: increasementIconConfiguration?.icon ??
                      const Icon(Icons.add),
                ),
              ),
            );

            return TextField(
              decoration: finalDecoration,
              inputFormatters: state.numberFormatters(
                  decimal: state.decimal,
                  allowNegative: min < 0,
                  max: max.toDouble()),
              controller: state.textEditingController,
              focusNode: state.focusNode,
              onSubmitted: readOnly
                  ? null
                  : (v) {
                      onSubmitted?.call(state.value);
                    },
              enabled: enabled,
              readOnly: !editable || readOnly,
              onChanged: state.onTextFieldChange,
              textAlign: TextAlign.center,
              onTapOutside: onTapOutside,
              clipBehavior: clipBehavior ?? Clip.hardEdge,
              scribbleEnabled: scribbleEnabled ?? true,
              contextMenuBuilder: contextMenuBuilder,
              spellCheckConfiguration: spellCheckConfiguration,
              magnifierConfiguration: magnifierConfiguration ??
                  TextMagnifier.adaptiveMagnifierConfiguration,
              maxLines: maxLines,
              minLines: minLines,
              onTap: onTap,
              onEditingComplete: onEditingComplete,
              onAppPrivateCommand: appPrivateCommandCallback,
              textInputAction: textInputAction,
              textCapitalization: textCapitalization,
              style: style,
              strutStyle: strutStyle,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              showCursor: showCursor,
              smartDashesType: smartDashesType,
              smartQuotesType: smartQuotesType,
              expands: expands,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              selectionHeightStyle: selectionHeightStyle,
              selectionWidthStyle: selectionWidthStyle,
              keyboardAppearance: keyboardAppearance,
              scrollPadding: scrollPadding,
              dragStartBehavior: dragStartBehavior,
              mouseCursor: mouseCursor,
              scrollPhysics: scrollPhysics,
              autofocus: autofocus,
              enableInteractiveSelection: enableInteractiveSelection,
              maxLengthEnforcement: maxLengthEnforcement,
              keyboardType: TextInputType.number,
              maxLength: maxLength,
              scrollController: scrollController,
              selectionControls: textSelectionControls,
            );
          },
        );

  final double max;
  final double min;
  final double step;
  final double acceleration;
  final Duration interval;
  final IconConfiguration? increasementIconConfiguration;
  final IconConfiguration? decreasementIconConfiguration;
  final bool editable;

  /// if [strictStep] is true ,  value is only accepted when  match condition `(value - initialValue) % step`
  ///
  /// acceleration will not work when [strictStep] is true
  final bool strictStep;
  final ValueChanged<double>? onSubmitted;
  final InputDecoration? decoration;
  final int? maxLines;
  final bool autofocus;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final StrutStyle? strutStyle;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool? showCursor;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool expands;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final BoxHeightStyle selectionHeightStyle;
  final BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final MouseCursor? mouseCursor;
  final ScrollPhysics? scrollPhysics;
  final bool enableInteractiveSelection;
  final VoidCallback? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final AppPrivateCommandCallback? appPrivateCommandCallback;
  final GestureTapCallback? onTap;
  final ScrollController? scrollController;
  final TextSelectionControls? textSelectionControls;
  final TapRegionCallback? onTapOutside;
  final Clip? clipBehavior;
  final bool? scribbleEnabled;
  final EditableTextContextMenuBuilder? contextMenuBuilder;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  static Widget _defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  @override
  FormeFieldState<double> createState() => _FormeSpinNumberFieldState();
}

class _FormeSpinNumberFieldState extends FormeFieldState<double> {
  late TextEditingController textEditingController;

  List<TextInputFormatter> numberFormatters(
      {required int decimal, required bool allowNegative, required num? max}) {
    final RegExp regex =
        RegExp('[0-9${decimal > 0 ? '.' : ''}${allowNegative ? '-' : ''}]');
    return [
      TextInputFormatter.withFunction((oldValue, newValue) {
        if (newValue.text == '') {
          return newValue;
        }
        if (allowNegative && newValue.text == '-') {
          return newValue;
        }
        final double? parsed = double.tryParse(newValue.text);
        if (parsed == null) {
          return oldValue;
        }
        final int indexOfPoint = newValue.text.indexOf('.');
        if (indexOfPoint != -1) {
          final int decimalNum = newValue.text.length - (indexOfPoint + 1);
          if (decimalNum > decimal) {
            return oldValue;
          }
        }

        final double? oldParsed = double.tryParse(oldValue.text);

        if (max != null && parsed > max) {
          if (oldParsed != null && oldParsed > parsed) {
            return newValue;
          }
          return oldValue;
        }
        return newValue;
      }),
      FilteringTextInputFormatter.allow(regex)
    ];
  }

  @override
  FormeSpinNumberField get widget => super.widget as FormeSpinNumberField;

  String get formatText => doFormat(value);

  Timer? timer;
  late double step;

  double? copyValue;

  @override
  void initStatus() {
    super.initStatus();
    step = widget.step;
    textEditingController = TextEditingController(text: formatText);
  }

  int get decimal => Decimal.parse(widget.step.toString()).scale;

  void onTextFieldChange(String text) {
    if (timer != null) {
      return;
    }
    final double? value = double.tryParse(text);
    if (value != null) {
      didChange(double.parse(value.toString()), format: false);
    }
  }

  void subtract() {
    if (widget.step == 0) {
      return;
    }
    didChange(max(widget.min, doSubtract(value, widget.step)));
  }

  void add() {
    if (widget.step == 0) {
      return;
    }
    didChange(min(widget.max, doAdd(value, widget.step)));
  }

  String doFormat(double value) {
    return value.toStringAsFixed(decimal);
  }

  void startAccelerate(_CalcType type) {
    if (timer != null) {
      return;
    }
    timer = Timer.periodic(widget.interval, (timer) {
      copyValue ??= value;

      if (!widget.strictStep) {
        step = doAdd(step, widget.acceleration);
      }

      if (step == 0) {
        stopAccelerate();
        return;
      }

      double calcValue;

      switch (type) {
        case _CalcType.subtract:
          calcValue = doSubtract(copyValue!, step);
          break;
        case _CalcType.plus:
          calcValue = doAdd(copyValue!, step);
          break;
      }

      if (calcValue > widget.max || calcValue < widget.min) {
        if (widget.strictStep) {
          stopAccelerate();
          return;
        }

        if (copyValue! < widget.max && copyValue! > widget.min) {
          switch (type) {
            case _CalcType.subtract:
              copyValue = widget.min;
              break;
            case _CalcType.plus:
              copyValue = widget.max;
              break;
          }
        } else {
          stopAccelerate();
          return;
        }
      } else {
        copyValue = calcValue;
      }

      formatTextField(copyValue!);
    });
  }

  void formatTextField(double value) {
    final String text = doFormat(value);
    if (textEditingController.text != text) {
      textEditingController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length,
          ));
    }
  }

  @override
  void didChange(
    double newValue, {
    bool format = true,
  }) {
    if (newValue < widget.min || newValue > widget.max) {
      return;
    }
    if (widget.strictStep && !isStrictStep(newValue)) {
      return;
    }

    super.didChange(double.parse(newValue.toStringAsFixed(decimal)));
    if (format) {
      formatTextField(value);
    }
  }

  @override
  void reset() {
    super.reset();
    formatTextField(value);
  }

  void stopAccelerate() {
    timer?.cancel();
    timer = null;
    step = widget.step;

    if (copyValue != null && mounted) {
      didChange(copyValue!);
      copyValue = null;
    }
  }

  @override
  void dispose() {
    stopAccelerate();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<double> status) {
    super.onStatusChanged(status);
    if (!status.hasFocus) {
      formatTextField(value);
    }
  }

  bool isStrictStep(double v1) {
    return (Decimal.parse(v1.toString()) -
                Decimal.parse(widget.initialValue.toString())) %
            Decimal.parse(widget.step.toString()) ==
        Decimal.zero;
  }

  double doAdd(double v1, double v2) {
    return (Decimal.parse(v1.toString()) + Decimal.parse(v2.toString()))
        .toDouble();
  }

  double doSubtract(double v1, double v2) {
    return (Decimal.parse(v1.toString()) - Decimal.parse(v2.toString()))
        .toDouble();
  }
}

enum _CalcType {
  subtract,
  plus,
}

class IconConfiguration {
  final double iconSize;
  final VisualDensity? visualDensity;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;
  final double? splashRadius;
  final Widget? icon;
  final Color? focusColor;
  final Color? hoverColor;
  final Color? color;
  final Color? splashColor;
  final Color? highlightColor;
  final Color? disabledColor;
  final String? tooltip;
  final bool enableFeedback;
  final BoxConstraints? constraints;

  IconConfiguration({
    this.iconSize = 24,
    this.visualDensity,
    this.padding = const EdgeInsets.all(8.0),
    this.alignment = Alignment.center,
    this.splashRadius,
    this.color,
    this.focusColor,
    this.hoverColor,
    this.highlightColor,
    this.splashColor,
    this.disabledColor,
    this.tooltip,
    this.enableFeedback = true,
    this.constraints,
    required this.icon,
  });
}
