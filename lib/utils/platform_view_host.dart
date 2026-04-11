import 'package:flutter/widgets.dart';

/// Provides stable sizing/compositing for native platform views.
///
/// Some platform views can fail to paint reliably when they are hosted by
/// sliver-based scrollables and receive loose box constraints. This wrapper
/// keeps the view behind a repaint boundary and resolves a finite width from
/// the current layout constraints whenever one is available.
class PlatformViewHost extends StatefulWidget {
  /// Creates a host box for an embedded native platform view.
  const PlatformViewHost({
    super.key,
    required this.child,
    required this.height,
    this.width,
    this.centerChild = false,
  });

  /// The platform-view widget to embed.
  final Widget child;

  /// The fixed height to apply to the hosted platform view.
  final double height;

  /// Optional explicit width. When omitted, the current bounded max width is used.
  final double? width;

  /// Whether to center the hosted view when it does not consume the full width.
  final bool centerChild;

  @override
  State<PlatformViewHost> createState() => _PlatformViewHostState();
}

class _PlatformViewHostState extends State<PlatformViewHost>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            widget.width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);

        Widget content = ClipRect(
          child: RepaintBoundary(
            child: SizedBox(
              height: widget.height,
              width: resolvedWidth,
              child: widget.child,
            ),
          ),
        );

        if (widget.centerChild) {
          content = Center(child: content);
        }

        return content;
      },
    );
  }
}
