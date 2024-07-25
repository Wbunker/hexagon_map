import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

class HexagonGridView extends TwoDimensionalScrollView {
  final double hexagonSize;
  const HexagonGridView(
      {super.key,
      super.primary,
      super.mainAxis = Axis.vertical,
      super.verticalDetails = const ScrollableDetails.vertical(),
      super.horizontalDetails = const ScrollableDetails.horizontal(),
      super.cacheExtent,
      required this.hexagonSize,
      super.dragStartBehavior = DragStartBehavior.down,
      super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
      super.clipBehavior = Clip.hardEdge,
      super.diagonalDragBehavior,
      required TwoDimensionalChildBuilderDelegate super.delegate});

  @override
  Widget buildViewport(BuildContext context, ViewportOffset verticalOffset,
      ViewportOffset horizontalOffset) {
    return HexagonGridViewport(
      key: key,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      hexagonSize: hexagonSize,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
    );
  }
}

class HexagonGridViewport extends TwoDimensionalViewport {
  final double hexagonSize;
  const HexagonGridViewport({
    super.key,
    required this.hexagonSize,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalHexagonViewport(
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      hexagonSize: hexagonSize,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      mainAxis: mainAxis,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      childManager: context as TwoDimensionalChildManager,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderTwoDimensionalViewport renderObject) {
    renderObject
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..delegate = delegate as TwoDimensionalChildBuilderDelegate
      ..mainAxis = mainAxis
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalHexagonViewport extends RenderTwoDimensionalViewport {
  final double hexagonSize;
  final double hexagonWidth;
  final double hexagonHeight;
  RenderTwoDimensionalHexagonViewport({
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required this.hexagonSize,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    required super.childManager,
  })  : hexagonHeight = hexagonSize,
        hexagonWidth = math.sqrt(3) * (hexagonSize / 2),
        super(delegate: delegate);

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;

    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn =
        math.max((horizontalPixels / hexagonWidth).floor(), 0);
    final int trailingColumn = math.min(
        ((horizontalPixels + viewportWidth) / hexagonWidth).ceil(),
        maxColumnIndex);

    final int leadingRow =
        math.max((verticalPixels / hexagonHeight).floor(), 0);
    final int trailingRow = math.min(
        ((verticalPixels + viewportHeight) / hexagonHeight).ceil(),
        maxRowIndex);

    double xLayoutOffset =
        (leadingColumn * hexagonWidth) - horizontalOffset.pixels;
    for (int column = leadingColumn; column < trailingColumn; column++) {
      double yLayoutOffset =
          (leadingRow * hexagonHeight) - verticalOffset.pixels;

      for (int row = leadingRow; row < trailingRow; row++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;

        child.layout(constraints.loosen());

        // Subclasses only need to set the normalized layout offset
        // the super class adjusts for reverse
        parentDataOf(child).layoutOffset = Offset(
            row % 2 == 0 ? xLayoutOffset : xLayoutOffset + hexagonWidth / 2,
            row % 2 == 0 ? yLayoutOffset : yLayoutOffset);

        yLayoutOffset += 0.75 * hexagonHeight;
      }
      xLayoutOffset += hexagonWidth;
    }

    // set the min and max scroll extents for each axis
    final double verticalExtent = hexagonHeight * (maxRowIndex + 1);
    verticalOffset.applyContentDimensions(
        0.0,
        (verticalExtent - viewportDimension.height)
            .clamp(0.0, double.infinity));

    final double horizontalExtent = hexagonWidth * (maxColumnIndex + 1);
    horizontalOffset.applyContentDimensions(
        0.0,
        (horizontalExtent - viewportDimension.width)
            .clamp(0.0, double.infinity));
  }
}
