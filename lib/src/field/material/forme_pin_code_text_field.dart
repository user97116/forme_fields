import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forme/forme.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// https://pub.dev/packages/pin_code_fields
class FormePinCodeTextField extends FormeField<String> {
  FormePinCodeTextField({
    super.key,
    super.name,
    super.initialValue = '',
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
    required this.length,
    this.onTap,
    this.textStyle,
    this.animationCurve = Curves.easeInOut,
    this.autofocus = false,
    this.keyboardAppearance,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.visiblePassword,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.cursorWidth = 2,
    this.cursorColor,
    this.cursorHeight,
    this.obscuringCharacter = '●',
    this.obscuringWidget,
    this.blinkWhenObscuring = false,
    this.blinkDuration = const Duration(milliseconds: 500),
    this.backgroundColor,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationType = AnimationType.slide,
    this.useHapticFeedback = false,
    this.enableActiveFill = false,
    this.autoDismissKeyboard = true,
    this.pinTheme = const PinTheme.defaults(),
    this.errorTextSpace = 16,
    this.enablePinAutofill = false,
    this.errorAnimationDuration = 500,
    this.hintCharacter,
    this.hintStyle,
    this.onAutoFillDisposeAction = AutofillContextAction.commit,
    this.useExternalAutoFillGroup = false,
    this.scrollPadding = const EdgeInsets.all(20),
    this.hapticFeedbackTypes = HapticFeedbackTypes.light,
    this.pastedTextStyle,
    this.errorAnimationController,
    this.beforeTextPaste,
    this.dialogConfig,
    this.boxShadows,
    this.showCursor = true,
    this.textGradient,
    this.onCompleted,
    this.autoUnfocus = true,
  }) : super.allFields(
          builder: (genericState) {
            final bool readOnly = genericState.readOnly;
            final bool enabled = genericState.enabled;
            final _FormePinCodeTextFieldState state =
                genericState as _FormePinCodeTextFieldState;
            return PinCodeTextField(
              onAutoFillDisposeAction: onAutoFillDisposeAction,
              useExternalAutoFillGroup: useExternalAutoFillGroup,
              scrollPadding: scrollPadding,
              autoUnfocus: autoUnfocus,
              onChanged: state.didChange,
              onCompleted: onCompleted,
              appContext: state.context,
              length: length,
              onTap: onTap,
              controller: state.textEditingController,
              focusNode: state.focusNode,
              textStyle: textStyle,
              animationCurve: animationCurve,
              animationDuration: animationDuration,
              enabled: enabled,
              keyboardAppearance: keyboardAppearance,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textCapitalization: textCapitalization,
              textInputAction: textInputAction,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorColor: cursorColor,
              obscuringCharacter: obscuringCharacter,
              obscuringWidget: obscuringWidget,
              blinkWhenObscuring: blinkWhenObscuring,
              blinkDuration: blinkDuration,
              backgroundColor: backgroundColor,
              mainAxisAlignment: mainAxisAlignment,
              animationType: animationType,
              autoFocus: autofocus,
              readOnly: readOnly,
              useHapticFeedback: useHapticFeedback,
              hapticFeedbackTypes: hapticFeedbackTypes,
              pastedTextStyle: pastedTextStyle,
              enableActiveFill: enableActiveFill,
              autoDismissKeyboard: autoDismissKeyboard,
              autoDisposeControllers: false,
              errorAnimationController: errorAnimationController,
              beforeTextPaste: beforeTextPaste,
              dialogConfig: dialogConfig,
              pinTheme: pinTheme,
              errorTextSpace: errorTextSpace,
              enablePinAutofill: !readOnly && enablePinAutofill,
              errorAnimationDuration: errorAnimationDuration,
              boxShadows: boxShadows,
              showCursor: showCursor,
              hintCharacter: hintCharacter,
              hintStyle: hintStyle,
              textGradient: textGradient,
            );
          },
        );

  final int length;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final Curve animationCurve;
  final bool autofocus;
  final Brightness? keyboardAppearance;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final double cursorWidth;
  final Color? cursorColor;
  final double? cursorHeight;
  final String obscuringCharacter;
  final Widget? obscuringWidget;
  final bool blinkWhenObscuring;
  final Duration blinkDuration;
  final Color? backgroundColor;
  final MainAxisAlignment mainAxisAlignment;
  final Duration animationDuration;
  final AnimationType animationType;
  final bool useHapticFeedback;
  final bool enableActiveFill;
  final bool autoDismissKeyboard;
  final PinTheme pinTheme;
  final double errorTextSpace;
  final bool enablePinAutofill;
  final int errorAnimationDuration;
  final String? hintCharacter;
  final TextStyle? hintStyle;
  final AutofillContextAction onAutoFillDisposeAction;
  final bool useExternalAutoFillGroup;
  final EdgeInsets scrollPadding;
  final HapticFeedbackTypes hapticFeedbackTypes;
  final TextStyle? pastedTextStyle;
  final StreamController<ErrorAnimationType>? errorAnimationController;
  final bool Function(String? text)? beforeTextPaste;
  final DialogConfig? dialogConfig;
  final List<BoxShadow>? boxShadows;
  final bool showCursor;
  final Gradient? textGradient;
  final ValueChanged<String>? onCompleted;
  final bool autoUnfocus;
  @override
  FormeFieldState<String> createState() => _FormePinCodeTextFieldState();
}

class _FormePinCodeTextFieldState extends FormeFieldState<String> {
  late final TextEditingController textEditingController;

  @override
  FormePinCodeTextField get widget => super.widget as FormePinCodeTextField;

  @override
  void initStatus() {
    super.initStatus();
    textEditingController = TextEditingController(text: value);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  String get value {
    final String value = super.value;
    if (value.length > widget.length) {
      return value.substring(0, widget.length);
    }
    return value;
  }

  @override
  void didChange(String newValue) {
    final String value = newValue.length > widget.length
        ? newValue.substring(0, widget.length)
        : newValue;
    super.didChange(value);
  }

  @override
  void onStatusChanged(FormeFieldChangedStatus<String> status) {
    super.onStatusChanged(status);
    if (status.isValueChanged) {
      if (textEditingController.text != status.value) {
        textEditingController.text = status.value;
      }
    }
  }
}
