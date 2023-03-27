import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:forme/forme.dart';

/// https://pub.dev/packages/flutter_rating_bar
class FormeRatingBar extends FormeField<double> {
  FormeRatingBar({
    super.key,
    super.name,
    super.initialValue = 0,
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
    this.ratingWidget,
    this.glowColor,
    this.maxRating,
    this.textDirection,
    this.unratedColor,
    this.allowHalfRating = false,
    this.direction = Axis.horizontal,
    this.glow = true,
    this.glowRadius = 2,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40,
    this.minRating = 0,
    this.tapOnlyMode = false,
    this.updateOnDrag = false,
    this.wrapAlignment = WrapAlignment.start,
    this.itemBuilder,
  }) : super.allFields(
          builder: (state) {
            final bool readOnly = state.readOnly;
            final double value = state.value;

            void onRatingUpdate(double value) {
              state.didChange(value);
              state.requestFocusOnUserInteraction();
            }

            Widget ratingBar;

            if (ratingWidget == null) {
              final IndexedWidgetBuilder builder = itemBuilder == null
                  ? (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      )
                  : (context, _) {
                      return itemBuilder(state.value, context, _);
                    };
              ratingBar = RatingBar.builder(
                itemBuilder: builder,
                onRatingUpdate: onRatingUpdate,
                glowColor: glowColor,
                maxRating: maxRating,
                textDirection: textDirection,
                unratedColor: unratedColor,
                allowHalfRating: allowHalfRating,
                direction: direction,
                glow: glow,
                glowRadius: glowRadius,
                ignoreGestures: readOnly,
                initialRating: value,
                itemCount: itemCount,
                itemPadding: itemPadding,
                itemSize: itemSize,
                minRating: minRating,
                tapOnlyMode: tapOnlyMode,
                updateOnDrag: updateOnDrag,
                wrapAlignment: wrapAlignment,
              );
            } else {
              ratingBar = RatingBar(
                onRatingUpdate: onRatingUpdate,
                ratingWidget: ratingWidget,
                glowColor: glowColor,
                maxRating: maxRating,
                textDirection: textDirection,
                unratedColor: unratedColor,
                allowHalfRating: allowHalfRating,
                direction: direction,
                glow: glow,
                glowRadius: glowRadius,
                ignoreGestures: readOnly,
                initialRating: value,
                itemCount: itemCount,
                itemPadding: itemPadding,
                itemSize: itemSize,
                minRating: minRating,
                tapOnlyMode: tapOnlyMode,
                updateOnDrag: updateOnDrag,
                wrapAlignment: wrapAlignment,
              );
            }
            return Focus(
              focusNode: state.focusNode,
              child: ratingBar,
            );
          },
        );

  final RatingWidget? ratingWidget;
  final Color? glowColor;
  final double? maxRating;
  final TextDirection? textDirection;
  final Color? unratedColor;
  final bool allowHalfRating;
  final Axis direction;
  final bool glow;
  final double glowRadius;
  final int itemCount;
  final EdgeInsets itemPadding;
  final double itemSize;
  final double minRating;
  final bool tapOnlyMode;
  final bool updateOnDrag;
  final WrapAlignment wrapAlignment;
  final Widget Function(double value, BuildContext context, int index)?
      itemBuilder;
}

class FormeRatingBarIndicator extends FormeField<double> {
  FormeRatingBarIndicator({
    super.key,
    super.name,
    super.initialValue = 0,
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
    this.itemBuilder,
    this.textDirection,
    this.unratedColor,
    this.direction = Axis.horizontal,
    this.itemCount = 5,
    this.itemPadding = EdgeInsets.zero,
    this.itemSize = 40,
    this.physics = const NeverScrollableScrollPhysics(),
  }) : super.allFields(
          builder: (state) {
            final IndexedWidgetBuilder builder = itemBuilder == null
                ? (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    )
                : (context, _) {
                    return itemBuilder(state.value, context, _);
                  };
            return RatingBarIndicator(
              itemBuilder: builder,
              textDirection: textDirection,
              unratedColor: unratedColor,
              direction: direction,
              itemCount: itemCount,
              itemPadding: itemPadding,
              itemSize: itemSize,
              physics: physics,
              rating: state.value,
            );
          },
        );

  final double itemSize;
  final TextDirection? textDirection;
  final Color? unratedColor;
  final Axis direction;
  final int itemCount;
  final EdgeInsets itemPadding;
  final Widget Function(double value, BuildContext context, int index)?
      itemBuilder;
  final ScrollPhysics physics;
}
