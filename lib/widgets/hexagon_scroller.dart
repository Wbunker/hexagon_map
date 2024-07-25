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
    // Get the current scroll positions in pixels
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;

    // Calculate the dimensions of the viewport including the cache extent
    final double viewportWidth = viewportDimension.width + cacheExtent;
    final double viewportHeight = viewportDimension.height + cacheExtent;

    // Cast the delegate to TwoDimensionalChildBuilderDelegate to access max indices
    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;

    // Get the maximum row and column indices from the builder delegate
    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    // Calculate the leading column index to start rendering from
    // This is based on the current horizontal scroll position divided by the width of a hexagon
    // Subtract the cache extent divided by the hexagon width to include off-screen items for smooth scrolling
    // Ensure the index is not less than 0
    final int leadingColumn = math.max(
        (horizontalPixels / hexagonWidth).floor() -
            (cacheExtent / hexagonWidth).floor(),
        0);
    // Calculate the trailing column index to stop rendering at
    // This is based on the current horizontal scroll position plus the viewport width divided by the width of a hexagon
    // Add the cache extent divided by the hexagon width to include off-screen items for smooth scrolling
    // Ensure the index does not exceed the maximum column index
    final int trailingColumn = math.min(
        ((horizontalPixels + viewportWidth) / hexagonWidth).ceil() +
            (cacheExtent / hexagonWidth).floor(),
        maxColumnIndex);

    final int leadingRow = math.max(
        (verticalPixels / hexagonHeight).floor() -
            (cacheExtent / hexagonHeight).floor(),
        0);
    final int trailingRow = math.min(
        ((verticalPixels + viewportHeight) / hexagonHeight).ceil() +
            (cacheExtent / hexagonHeight).floor(),
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
