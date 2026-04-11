import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/button_style.dart';
import '../style/sf_symbol.dart';
import '../utils/icon_renderer.dart';
import '../utils/theme_helper.dart';
import '../utils/version_detector.dart';
import 'icon.dart';

/// Base type for entries in a [CNPopupMenuButton] menu.
abstract class CNPopupMenuEntry {
  /// Const constructor for subclasses.
  const CNPopupMenuEntry();
}

/// A selectable item in a popup menu.
class CNPopupMenuItem extends CNPopupMenuEntry {
  /// Creates a selectable popup menu item.
  const CNPopupMenuItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.imageAsset,
    this.iconColor,
    this.enabled = true,
    this.checked = false,
  });

  /// Display label for the item.
  final String label;

  /// Optional SF Symbol shown before the label.
  /// Priority: [imageAsset] > [customIcon] > [icon]
  final CNSymbol? icon;

  /// Optional custom icon from CupertinoIcons, Icons, or any IconData.
  /// If provided, this takes precedence over [icon] but not [imageAsset].
  final IconData? customIcon;

  /// Optional image asset (SVG, PNG, etc.) shown before the label.
  /// If provided, this takes precedence over [icon] and [customIcon].
  final CNImageAsset? imageAsset;

  /// Optional color for custom icons. This applies a tint color to the custom icon.
  /// For SF Symbols, use the [icon]'s color parameter instead.
  final Color? iconColor;

  /// Whether the item can be selected.
  final bool enabled;

  /// Whether the item shows a checkmark (selected/active state).
  final bool checked;
}

/// A visual divider between popup menu items.
class CNPopupMenuDivider extends CNPopupMenuEntry {
  /// Creates a visual divider between items.
  const CNPopupMenuDivider();
}

/// A nested submenu in a popup menu.
class CNPopupMenuSubmenu extends CNPopupMenuEntry {
  /// Creates a submenu with nested [items].
  const CNPopupMenuSubmenu({
    required this.label,
    required this.items,
    this.icon,
    this.customIcon,
    this.imageAsset,
    this.iconColor,
    this.enabled = true,
  });

  /// Display label for the submenu.
  final String label;

  /// Nested entries shown when the submenu is opened.
  final List<CNPopupMenuEntry> items;

  /// Optional SF Symbol shown before the label.
  /// Priority: [imageAsset] > [customIcon] > [icon]
  final CNSymbol? icon;

  /// Optional custom icon from CupertinoIcons, Icons, or any IconData.
  /// If provided, this takes precedence over [icon] but not [imageAsset].
  final IconData? customIcon;

  /// Optional image asset (SVG, PNG, etc.) shown before the label.
  /// If provided, this takes precedence over [icon] and [customIcon].
  final CNImageAsset? imageAsset;

  /// Optional color for custom icons. This applies a tint color to the custom icon.
  /// For SF Symbols, use the [icon]'s color parameter instead.
  final Color? iconColor;

  /// Whether the submenu can be opened.
  final bool enabled;
}

// Reusable style enum for buttons across widgets (popup menu, future CNButton, ...)

/// A Cupertino-native popup menu button.
///
/// On iOS/macOS this embeds a native popup button and shows a native menu.
class CNPopupMenuButton extends StatefulWidget {
  /// Creates a text-labeled popup menu button.
  const CNPopupMenuButton({
    super.key,
    required this.buttonLabel,
    required this.items,
    required this.onSelected,
    this.onSelectedPath,
    this.tint,
    this.height = 32.0,
    this.shrinkWrap = false,
    this.buttonStyle = CNButtonStyle.plain,
    this.preserveTopToBottomOrder = false,
  }) : buttonIcon = null,
       buttonCustomIcon = null,
       buttonCustomIconColor = null,
       buttonImageAsset = null,
       width = null,
       round = false;

  /// Creates a round, icon-only popup menu button.
  CNPopupMenuButton.icon({
    super.key,
    this.buttonIcon,
    this.buttonCustomIcon,
    this.buttonCustomIconColor,
    this.buttonImageAsset,
    required this.items,
    required this.onSelected,
    this.onSelectedPath,
    this.tint,
    double size = 44.0, // button diameter (width = height)
    this.buttonStyle = CNButtonStyle.glass,
    this.preserveTopToBottomOrder = false,
  }) : buttonLabel = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super() {
    assert(
      buttonIcon != null ||
          buttonCustomIcon != null ||
          buttonImageAsset != null,
      'At least one of buttonIcon, buttonCustomIcon, or buttonImageAsset must be provided',
    );
  }

  /// Text for the button (null when using [buttonIcon]).
  final String? buttonLabel; // null in icon mode
  /// Icon for the button (non-null in icon mode).
  /// Priority: [buttonImageAsset] > [buttonCustomIcon] > [buttonIcon]
  final CNSymbol? buttonIcon; // non-null in icon mode
  /// Optional custom icon from CupertinoIcons, Icons, or any IconData for the button.
  /// If provided, this takes precedence over [buttonIcon] but not [buttonImageAsset].
  final IconData? buttonCustomIcon;

  /// Optional color for the [buttonCustomIcon].
  ///
  /// When provided, the custom icon is rendered with this color.
  /// Defaults to white when not specified (suitable for glass-style buttons).
  /// Has no effect on [buttonIcon] (SF Symbol) or [buttonImageAsset].
  final Color? buttonCustomIconColor;

  /// Optional image asset (SVG, PNG, etc.) for the button icon.
  /// If provided, this takes precedence over [buttonIcon] and [buttonCustomIcon].
  final CNImageAsset? buttonImageAsset;
  // Fixed size (width = height) when in icon mode.
  /// Fixed width in icon mode; otherwise computed/intrinsic.
  final double? width;

  /// Whether this is the round icon variant.
  final bool round; // internal: text=false, icon=true
  /// Entries that populate the popup menu.
  final List<CNPopupMenuEntry> items;

  /// Called with the selected index when the user makes a selection.
  final ValueChanged<int> onSelected;

  /// Called with the structural path to the selected item.
  ///
  /// This is especially useful for nested menus, where the flat legacy index
  /// provided to [onSelected] is deterministic but less descriptive than the
  /// item path, for example `[2, 1]`.
  final ValueChanged<List<int>>? onSelectedPath;

  /// Tint color for the control.
  final Color? tint;

  /// Control height; icon mode uses diameter semantics.
  final double height;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply to the button.
  final CNButtonStyle buttonStyle;

  /// When true, items maintain top-to-bottom order even when menu opens upward.
  ///
  /// By default (false), iOS native behavior keeps the first item closest to
  /// the button. When the menu opens upward, this means item 1 appears at the
  /// bottom. Set to true to always display items 1,2,3,4 from top to bottom.
  final bool preserveTopToBottomOrder;

  /// Whether this instance is configured as an icon button variant.
  bool get isIconButton =>
      buttonIcon != null ||
      buttonCustomIcon != null ||
      buttonImageAsset != null;

  @override
  State<CNPopupMenuButton> createState() => _CNPopupMenuButtonState();
}

class _CNPopupMenuButtonState extends State<CNPopupMenuButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastTitle;
  String? _lastIconName;
  double? _lastIconSize;
  int? _lastIconColor;
  double? _intrinsicWidth;
  CNButtonStyle? _lastStyle;
  Offset? _downPosition;
  bool _pressed = false;

  bool get _isDark => ThemeHelper.isDark(context);
  Color? get _effectiveTint =>
      widget.tint ?? ThemeHelper.getPrimaryColor(context);

  @override
  void didUpdateWidget(covariant CNPopupMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we should use native platform view
    final isIOSOrMacOS =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final shouldUseNative =
        isIOSOrMacOS && PlatformVersion.shouldUseNativeGlass;

    // Fallback to Flutter widgets for non-iOS/macOS or iOS/macOS < 26
    if (!shouldUseNative) {
      // For both non-iOS/macOS and iOS/macOS < 26, use CupertinoActionSheet
      return _buildCupertinoFallback(context);
    }

    // Priority: imageAsset > customIcon > icon

    // Check if we need to render custom icons or image assets
    final hasCustomButtonIcon = widget.buttonCustomIcon != null;
    final hasButtonImageAsset = widget.buttonImageAsset != null;
    final hasCustomMenuIcons = _walkMenuEntries(
      widget.items,
    ).any((e) => _menuEntryCustomIcon(e) != null);
    final hasMenuImageAssets = _walkMenuEntries(
      widget.items,
    ).any((e) => _menuEntryImageAsset(e) != null);

    if (hasCustomButtonIcon ||
        hasCustomMenuIcons ||
        hasButtonImageAsset ||
        hasMenuImageAssets) {
      // Create a key that changes when button or menu icons change
      final buttonIconKey =
          '${widget.buttonImageAsset?.assetPath}_${widget.buttonImageAsset?.imageData?.length ?? 0}_${widget.buttonCustomIcon?.hashCode ?? 0}_${widget.buttonCustomIconColor?.toARGB32() ?? 0}';
      final menuIconsKey = _walkMenuEntries(widget.items)
          .map((e) {
            final imageAsset = _menuEntryImageAsset(e);
            final customIcon = _menuEntryCustomIcon(e);
            final customIconColor = _menuEntryCustomIconColor(e);
            return '${imageAsset?.assetPath}_${imageAsset?.imageData?.length ?? 0}_${customIcon?.hashCode ?? 0}_${customIconColor?.toARGB32() ?? 0}';
          })
          .join('|');
      return FutureBuilder<Map<String, dynamic>>(
        key: ValueKey('popupMenu_icons_$buttonIconKey|$menuIconsKey'),
        future: _renderCustomIcons(context),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(height: widget.height, width: widget.width);
          }
          return FutureBuilder<Widget>(
            future: _buildNativePopupMenu(
              context,
              customIconData: snapshot.data,
            ),
            builder: (context, widgetSnapshot) {
              if (!widgetSnapshot.hasData) {
                return SizedBox(height: widget.height, width: widget.width);
              }
              return widgetSnapshot.data!;
            },
          );
        },
      );
    }

    return FutureBuilder<Widget>(
      future: _buildNativePopupMenu(context, customIconData: null),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(height: widget.height, width: widget.width);
        }
        return snapshot.data!;
      },
    );
  }

  Future<Map<String, dynamic>> _renderCustomIcons(BuildContext context) async {
    Uint8List? buttonIconBytes;
    final menuIconBytes = await _renderMenuEntryCustomIcons(
      context,
      widget.items,
    );

    // Handle button icon - imageAsset takes precedence over customIcon
    if (widget.buttonImageAsset != null) {
      // ImageAsset doesn't need async rendering, it's already data
      buttonIconBytes = null; // Will be handled in _buildNativePopupMenu
    } else if (widget.buttonCustomIcon != null) {
      buttonIconBytes = await iconDataToImageBytes(
        widget.buttonCustomIcon!,
        size: widget.buttonIcon?.size ?? 20.0,
        color: widget.buttonCustomIconColor ?? CupertinoColors.white,
      );
    }

    return {'buttonIconBytes': buttonIconBytes, 'menuIconBytes': menuIconBytes};
  }

  Future<List<Uint8List?>> _renderMenuEntryCustomIcons(
    BuildContext context,
    List<CNPopupMenuEntry> entries,
  ) async {
    final rendered = <Uint8List?>[];
    for (final entry in _walkMenuEntries(entries)) {
      final imageAsset = _menuEntryImageAsset(entry);
      final customIcon = _menuEntryCustomIcon(entry);
      final symbol = _menuEntrySymbol(entry);
      final customIconColor = _menuEntryCustomIconColor(entry);
      if (imageAsset != null || customIcon == null) {
        continue;
      }
      rendered.add(
        await iconDataToImageBytes(
          customIcon,
          size: symbol?.size ?? 20.0,
          color: customIconColor ?? CupertinoColors.label,
        ),
      );
    }
    return rendered;
  }

  Future<Widget> _buildNativePopupMenu(
    BuildContext context, {
    Map<String, dynamic>? customIconData,
  }) async {
    const viewType = 'CupertinoNativePopupMenuButton';

    // Capture all context-derived values before any async operations
    final capturedIsDark = _isDark;
    final capturedStyle = encodeStyle(context, tint: _effectiveTint);
    final capturedButtonIconColor = resolveColorToArgb(
      widget.buttonImageAsset?.color ??
          widget.buttonCustomIconColor ??
          widget.buttonIcon?.color,
      context,
    );
    final capturedButtonPaletteColors = widget.buttonIcon?.paletteColors
        ?.map((c) => resolveColorToArgb(c, context))
        .toList();
    // Pre-capture menu item colors
    final capturedMenuItemColors = <int?>[];
    final capturedMenuItemIconColors = <int?>[];
    final capturedMenuItemPalettes = <List<int?>?>[];
    for (final item in widget.items) {
      if (item is CNPopupMenuItem) {
        capturedMenuItemIconColors.add(
          resolveColorToArgb(item.iconColor, context),
        );
        capturedMenuItemColors.add(
          resolveColorToArgb(
            item.imageAsset?.color ?? item.icon?.color,
            context,
          ),
        );
        capturedMenuItemPalettes.add(
          item.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
      } else if (item is CNPopupMenuSubmenu) {
        capturedMenuItemIconColors.add(
          resolveColorToArgb(item.iconColor, context),
        );
        capturedMenuItemColors.add(
          resolveColorToArgb(
            item.imageAsset?.color ?? item.icon?.color,
            context,
          ),
        );
        capturedMenuItemPalettes.add(
          item.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
      } else {
        capturedMenuItemIconColors.add(null);
        capturedMenuItemColors.add(null);
        capturedMenuItemPalettes.add(null);
      }
    }

    // Resolve button image asset path if present
    String? resolvedButtonAssetPath;
    if (widget.buttonImageAsset != null &&
        widget.buttonImageAsset!.assetPath.isNotEmpty) {
      resolvedButtonAssetPath = await resolveAssetPathForPixelRatio(
        widget.buttonImageAsset!.assetPath,
      );
    }
    if (!mounted) return const SizedBox();

    // Resolve menu item image assets concurrently
    final resolvedMenuPaths = await Future.wait(
      widget.items.map((e) async {
        if (e is CNPopupMenuItem && e.imageAsset != null) {
          return await resolveAssetPathForPixelRatio(e.imageAsset!.assetPath);
        }
        return null;
      }),
    );
    if (!mounted) return const SizedBox();

    final buttonIconBytes = customIconData?['buttonIconBytes'] as Uint8List?;
    final menuIconBytes =
        customIconData?['menuIconBytes'] as List<Uint8List?>? ?? [];
    if (!context.mounted) return const SizedBox();
    final itemTree = await _serializeMenuEntries(
      context,
      widget.items,
      customIconBytes: menuIconBytes,
    );

    // Flatten entries into parallel arrays for the platform view.
    final labels = <String>[];
    final symbols = <String>[];
    final customIconBytesArray = <Uint8List?>[];
    final customIconColors = <int?>[];
    final imageAssetPaths = <String>[];
    final imageAssetData = <Uint8List?>[];
    final imageAssetFormats = <String>[];
    final isDivider = <bool>[];
    final enabled = <bool>[];
    final checked = <bool>[];
    final sizes = <double?>[];
    final colors = <int?>[];
    final modes = <String?>[];
    final palettes = <List<int?>?>[];
    final gradients = <bool?>[];

    for (var i = 0; i < widget.items.length; i++) {
      final e = widget.items[i];
      if (e is CNPopupMenuDivider) {
        labels.add('');
        symbols.add('');
        customIconBytesArray.add(null);
        customIconColors.add(null);
        imageAssetPaths.add('');
        imageAssetData.add(null);
        imageAssetFormats.add('');
        isDivider.add(true);
        enabled.add(false);
        checked.add(false);
        sizes.add(null);
        colors.add(null);
        modes.add(null);
        palettes.add(null);
        gradients.add(null);
      } else if (e is CNPopupMenuItem) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        customIconBytesArray.add(null);
        customIconColors.add(capturedMenuItemIconColors[i]);

        // Handle imageAsset for menu items
        if (e.imageAsset != null) {
          // Use pre-resolved path
          final resolvedPath = resolvedMenuPaths[i]!;
          imageAssetPaths.add(resolvedPath);
          imageAssetData.add(e.imageAsset!.imageData);
          // Auto-detect format if not provided (use resolved path)
          imageAssetFormats.add(
            e.imageAsset!.imageFormat ??
                detectImageFormat(resolvedPath, e.imageAsset!.imageData) ??
                '',
          );
        } else {
          imageAssetPaths.add('');
          imageAssetData.add(null);
          imageAssetFormats.add('');
        }

        isDivider.add(false);
        enabled.add(e.enabled);
        checked.add(e.checked);
        sizes.add(e.imageAsset?.size ?? e.icon?.size);
        colors.add(capturedMenuItemColors[i]);
        modes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        palettes.add(capturedMenuItemPalettes[i]);
        gradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);
      } else if (e is CNPopupMenuSubmenu) {
        labels.add(e.label);
        symbols.add(e.icon?.name ?? '');
        customIconBytesArray.add(null);
        customIconColors.add(capturedMenuItemIconColors[i]);

        if (e.imageAsset != null) {
          final resolvedPath = await resolveAssetPathForPixelRatio(
            e.imageAsset!.assetPath,
          );
          imageAssetPaths.add(resolvedPath);
          imageAssetData.add(e.imageAsset!.imageData);
          imageAssetFormats.add(
            e.imageAsset!.imageFormat ??
                detectImageFormat(resolvedPath, e.imageAsset!.imageData) ??
                '',
          );
        } else {
          imageAssetPaths.add('');
          imageAssetData.add(null);
          imageAssetFormats.add('');
        }

        isDivider.add(false);
        enabled.add(e.enabled);
        checked.add(false);
        sizes.add(e.imageAsset?.size ?? e.icon?.size);
        colors.add(capturedMenuItemColors[i]);
        modes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        palettes.add(capturedMenuItemPalettes[i]);
        gradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);
      }
    }

    final creationParams = <String, dynamic>{
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (buttonIconBytes != null) 'buttonCustomIconBytes': buttonIconBytes,
      if (widget.buttonImageAsset != null) ...{
        // Use resolved asset path
        if (resolvedButtonAssetPath != null)
          'buttonAssetPath': resolvedButtonAssetPath,
        if (widget.buttonImageAsset!.imageData != null)
          'buttonImageData': widget.buttonImageAsset!.imageData,
        // Auto-detect format if not provided (use resolved path)
        'buttonImageFormat':
            widget.buttonImageAsset!.imageFormat ??
            detectImageFormat(
              resolvedButtonAssetPath ?? widget.buttonImageAsset!.assetPath,
              widget.buttonImageAsset!.imageData,
            ),
      },
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      'buttonIconSize':
          widget.buttonImageAsset?.size ?? widget.buttonIcon?.size ?? 20.0,
      if (capturedButtonIconColor != null)
        'buttonIconColor': capturedButtonIconColor,
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'labels': labels,
      'sfSymbols': symbols,
      'customIconBytes': customIconBytesArray,
      'customIconColors': customIconColors,
      'imageAssetPaths': imageAssetPaths,
      'imageAssetData': imageAssetData,
      'imageAssetFormats': imageAssetFormats,
      'isDivider': isDivider,
      'enabled': enabled,
      'checked': checked,
      'sfSymbolSizes': sizes,
      'sfSymbolColors': colors,
      'sfSymbolRenderingModes': modes,
      'sfSymbolPaletteColors': palettes,
      'sfSymbolGradientEnabled': gradients,
      'itemTree': itemTree,
      'isDark': capturedIsDark,
      'style': capturedStyle,
      if (widget.buttonIcon?.mode != null)
        'buttonIconRenderingMode': widget.buttonIcon!.mode!.name,
      if (capturedButtonPaletteColors != null)
        'buttonIconPaletteColors': capturedButtonPaletteColors,
      if (widget.buttonIcon?.gradient != null)
        'buttonIconGradientEnabled': widget.buttonIcon!.gradient,
      'preserveTopToBottomOrder': widget.preserveTopToBottomOrder,
    };

    // Create a comprehensive key that includes all parameters affecting platform view creation
    final buttonIconKey =
        '${widget.buttonLabel}_${widget.buttonIcon?.name}_${widget.buttonImageAsset?.assetPath}_${widget.buttonImageAsset?.imageData?.length ?? 0}_${widget.buttonCustomIcon?.hashCode ?? 0}';
    final itemsKey = widget.items
        .map(_menuEntryCacheKey)
        .join('|');
    final viewKey = ValueKey(
      'popupMenu_'
      '$buttonIconKey|'
      '$itemsKey|'
      '${widget.buttonStyle.name}_'
      '${widget.height}_'
      '${widget.width}_'
      '${widget.tint?.toARGB32()}_'
      '${widget.buttonCustomIconColor?.toARGB32()}_'
      '$_isDark',
    );

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            key: viewKey,
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            key: viewKey,
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        // If shrinkWrap or width is unbounded (e.g. inside a Row), prefer intrinsic width.
        final preferIntrinsic = widget.shrinkWrap || !hasBoundedWidth;
        double? width;
        if (widget.isIconButton) {
          // Fixed circle size for icon buttons
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 80.0;
        }
        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: ClipRect(
            child: SizedBox(
              height: widget.height,
              width: width,
              child: platformView,
            ),
          ),
        );
      },
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePopupMenuButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.buttonLabel;
    _lastIconName = widget.buttonIcon?.name;
    _lastIconSize = widget.buttonIcon?.size;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.buttonStyle;
    if (!widget.isIconButton) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'itemSelected') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      final selectionPath = (args?['selectionPath'] as List?)
          ?.map((value) => (value as num).toInt())
          .toList(growable: false);
      if (selectionPath != null) {
        widget.onSelectedPath?.call(selectionPath);
      }
      if (idx != null) widget.onSelected(idx);
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      if (w != null && mounted) {
        setState(() => _intrinsicWidth = w);
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Prepare popup items upfront to avoid using BuildContext after awaits.
    final updLabels = <String>[];
    final updSymbols = <String>[];
    final updIsDivider = <bool>[];
    final updEnabled = <bool>[];
    final updChecked = <bool>[];
    final updSizes = <double?>[];
    final updColors = <int?>[];
    final updModes = <String?>[];
    final updPalettes = <List<int?>?>[];
    final updGradients = <bool?>[];
    final updImageAssetPaths = <String>[];
    final updImageAssetData = <Uint8List?>[];
    final updImageAssetFormats = <String>[];
    final buildContext = context;
    final tint = resolveColorToArgb(_effectiveTint, context);
    final preIconName = widget.buttonIcon?.name;
    final preIconSize = widget.buttonIcon?.size;
    final preIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    for (final e in widget.items) {
      if (e is CNPopupMenuDivider) {
        updLabels.add('');
        updSymbols.add('');
        updIsDivider.add(true);
        updEnabled.add(false);
        updChecked.add(false);
        updSizes.add(null);
        updColors.add(null);
        updModes.add(null);
        updPalettes.add(null);
        updGradients.add(null);
        updImageAssetPaths.add('');
        updImageAssetData.add(null);
        updImageAssetFormats.add('');
      } else if (e is CNPopupMenuItem) {
        updLabels.add(e.label);
        updSymbols.add(e.icon?.name ?? '');
        updIsDivider.add(false);
        updEnabled.add(e.enabled);
        updChecked.add(e.checked);
        updSizes.add(e.imageAsset?.size ?? e.icon?.size);
        updColors.add(
          resolveColorToArgb(e.imageAsset?.color ?? e.icon?.color, context),
        );
        updModes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        updPalettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        updGradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);

        // Handle imageAsset for menu items
        if (e.imageAsset != null) {
          updImageAssetPaths.add(e.imageAsset!.assetPath);
          updImageAssetData.add(e.imageAsset!.imageData);
          // Auto-detect format if not provided
          updImageAssetFormats.add(
            e.imageAsset!.imageFormat ??
                detectImageFormat(
                  e.imageAsset!.assetPath,
                  e.imageAsset!.imageData,
                ) ??
                '',
          );
        } else {
          updImageAssetPaths.add('');
          updImageAssetData.add(null);
          updImageAssetFormats.add('');
        }
      } else if (e is CNPopupMenuSubmenu) {
        updLabels.add(e.label);
        updSymbols.add(e.icon?.name ?? '');
        updIsDivider.add(false);
        updEnabled.add(e.enabled);
        updChecked.add(false);
        updSizes.add(e.imageAsset?.size ?? e.icon?.size);
        updColors.add(
          resolveColorToArgb(
            e.imageAsset?.color ?? e.icon?.color,
            context,
          ),
        );
        updModes.add(e.imageAsset?.mode?.name ?? e.icon?.mode?.name);
        updPalettes.add(
          e.icon?.paletteColors
              ?.map((c) => resolveColorToArgb(c, context))
              .toList(),
        );
        updGradients.add(e.imageAsset?.gradient ?? e.icon?.gradient);

        if (e.imageAsset != null) {
          updImageAssetPaths.add(e.imageAsset!.assetPath);
          updImageAssetData.add(e.imageAsset!.imageData);
          updImageAssetFormats.add(
            e.imageAsset!.imageFormat ??
                detectImageFormat(
                  e.imageAsset!.assetPath,
                  e.imageAsset!.imageData,
                ) ??
                '',
          );
        } else {
          updImageAssetPaths.add('');
          updImageAssetData.add(null);
          updImageAssetFormats.add('');
        }
      }
    }
    final updMenuIconBytes = await _renderMenuEntryCustomIcons(
      context,
      widget.items,
    );
    if (!context.mounted) return;
    final updItemTree = await _serializeMenuEntries(
      buildContext,
      widget.items,
      customIconBytes: updMenuIconBytes,
    );
    if (!context.mounted) return;
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
    if (_lastTitle != widget.buttonLabel && widget.buttonLabel != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.buttonLabel});
      _lastTitle = widget.buttonLabel;
      _requestIntrinsicSize();
    }

    if (widget.isIconButton) {
      final iconName = preIconName;
      final iconSize = preIconSize;
      final iconColor = preIconColor;
      final updates = <String, dynamic>{};

      // Handle button imageAsset (takes precedence over SF Symbol)
      if (widget.buttonImageAsset != null) {
        // Resolve asset path based on device pixel ratio
        final resolvedAssetPath = await resolveAssetPathForPixelRatio(
          widget.buttonImageAsset!.assetPath,
        );
        updates['buttonAssetPath'] = resolvedAssetPath;
        updates['buttonImageData'] = widget.buttonImageAsset!.imageData;
        // Auto-detect format if not provided (use resolved path)
        updates['buttonImageFormat'] =
            widget.buttonImageAsset!.imageFormat ??
            detectImageFormat(
              resolvedAssetPath,
              widget.buttonImageAsset!.imageData,
            );
        updates['buttonIconSize'] = widget.buttonImageAsset!.size;
        if (widget.buttonImageAsset!.color != null) {
          if (mounted) {
            updates['buttonIconColor'] = resolveColorToArgb(
              widget.buttonImageAsset!.color,
              context,
            );
          }
        }
        if (widget.buttonImageAsset!.mode != null) {
          updates['buttonIconRenderingMode'] =
              widget.buttonImageAsset!.mode!.name;
        }
        if (widget.buttonImageAsset!.gradient != null) {
          updates['buttonIconGradientEnabled'] =
              widget.buttonImageAsset!.gradient;
        }
      } else {
        // Fallback to SF Symbol
        if (_lastIconName != iconName && iconName != null) {
          updates['buttonIconName'] = iconName;
          _lastIconName = iconName;
        }
        if (_lastIconSize != iconSize && iconSize != null) {
          updates['buttonIconSize'] = iconSize;
          _lastIconSize = iconSize;
        }
        if (_lastIconColor != iconColor && iconColor != null) {
          updates['buttonIconColor'] = iconColor;
          _lastIconColor = iconColor;
        }
        if (widget.buttonIcon?.mode != null) {
          updates['buttonIconRenderingMode'] = widget.buttonIcon!.mode!.name;
        }
        if (widget.buttonIcon?.paletteColors != null) {
          updates['buttonIconPaletteColors'] = widget.buttonIcon!.paletteColors!
              .map((c) => resolveColorToArgb(c, context))
              .toList();
        }
        if (widget.buttonIcon?.gradient != null) {
          updates['buttonIconGradientEnabled'] = widget.buttonIcon!.gradient;
        }
      }

      if (updates.isNotEmpty) {
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }

    await ch.invokeMethod('setItems', {
      'labels': updLabels,
      'sfSymbols': updSymbols,
      'isDivider': updIsDivider,
      'enabled': updEnabled,
      'checked': updChecked,
      'sfSymbolSizes': updSizes,
      'sfSymbolColors': updColors,
      'sfSymbolRenderingModes': updModes,
      'sfSymbolPaletteColors': updPalettes,
      'sfSymbolGradientEnabled': updGradients,
      'imageAssetPaths': updImageAssetPaths,
      'imageAssetData': updImageAssetData,
      'imageAssetFormats': updImageAssetFormats,
      'itemTree': updItemTree,
    });
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture values before awaiting
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }

  Widget _buildCupertinoFallback(BuildContext context) {
    // For iOS/macOS < 26 and non-iOS/macOS, use CupertinoActionSheet
    return SizedBox(
      height: widget.height,
      width: widget.isIconButton && widget.round
          ? (widget.width ?? widget.height)
          : null,
      child: CupertinoButton(
        padding: widget.isIconButton
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onPressed: () async {
          final selection = await _showFallbackMenu(
            context,
            items: widget.items,
            title: widget.buttonLabel,
          );
          if (selection != null) {
            widget.onSelectedPath?.call(selection.selectionPath);
            widget.onSelected(selection.legacyIndex);
          }
        },
        child: widget.isIconButton
            ? (widget.buttonIcon != null
                  ? CNIcon(
                      symbol: widget.buttonIcon,
                      size: widget.buttonIcon!.size,
                      color: widget.buttonIcon!.color,
                    )
                  : const SizedBox.shrink())
            : Text(widget.buttonLabel ?? ''),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _serializeMenuEntries(
    BuildContext context,
    List<CNPopupMenuEntry> entries, {
    required List<Uint8List?> customIconBytes,
    _CNPopupMenuSerializationCursor? cursor,
    List<int> parentPath = const [],
  }) async {
    final activeCursor = cursor ?? _CNPopupMenuSerializationCursor();
    final serialized = <Map<String, dynamic>>[];

    for (var index = 0; index < entries.length; index++) {
      if (!context.mounted) return serialized;
      final entry = entries[index];
      final entryPath = [...parentPath, index];
      final legacyIndex = activeCursor.legacyIndex++;
      if (entry is CNPopupMenuDivider) {
        serialized.add({'type': 'divider'});
        continue;
      }

      final symbol = _menuEntrySymbol(entry);
      final imageAsset = _menuEntryImageAsset(entry);
      final customIconColor = _menuEntryCustomIconColor(entry);

      final visuals = await _serializeMenuEntryVisuals(
        entry,
        customIconBytes: customIconBytes,
        cursor: activeCursor,
        resolvedCustomIconColor: resolveColorToArgb(customIconColor, context),
        resolvedSymbolColor: resolveColorToArgb(
          imageAsset?.color ?? symbol?.color,
          context,
        ),
        resolvedPaletteColors: symbol?.paletteColors
            ?.map((color) => resolveColorToArgb(color, context))
            .toList(),
        resolvedRenderingMode: imageAsset?.mode?.name ?? symbol?.mode?.name,
        resolvedGradient: imageAsset?.gradient ?? symbol?.gradient,
      );
      if (!context.mounted) return serialized;

      if (entry is CNPopupMenuItem) {
        serialized.add({
          'type': 'item',
          'label': entry.label,
          'enabled': entry.enabled,
          'checked': entry.checked,
          'legacyIndex': legacyIndex,
          'selectionPath': entryPath,
          ...visuals,
        });
      } else if (entry is CNPopupMenuSubmenu) {
        serialized.add({
          'type': 'submenu',
          'label': entry.label,
          'enabled': entry.enabled,
          'children': await _serializeMenuEntries(
            context,
            entry.items,
            customIconBytes: customIconBytes,
            cursor: activeCursor,
            parentPath: entryPath,
          ),
          ...visuals,
        });
      }
    }

    return serialized;
  }

  Future<Map<String, dynamic>> _serializeMenuEntryVisuals(
    CNPopupMenuEntry entry, {
    required List<Uint8List?> customIconBytes,
    required _CNPopupMenuSerializationCursor cursor,
    required int? resolvedCustomIconColor,
    required int? resolvedSymbolColor,
    required List<int?>? resolvedPaletteColors,
    required String? resolvedRenderingMode,
    required bool? resolvedGradient,
  }) async {
    final symbol = _menuEntrySymbol(entry);
    final customIcon = _menuEntryCustomIcon(entry);
    final imageAsset = _menuEntryImageAsset(entry);

    Uint8List? renderedCustomIconBytes;
    if (imageAsset == null && customIcon != null) {
      if (cursor.customIconIndex < customIconBytes.length) {
        renderedCustomIconBytes = customIconBytes[cursor.customIconIndex];
      }
      cursor.customIconIndex++;
    }

    String? resolvedAssetPath;
    if (imageAsset != null && imageAsset.assetPath.isNotEmpty) {
      resolvedAssetPath = await resolveAssetPathForPixelRatio(
        imageAsset.assetPath,
      );
    }

    return {
      'sfSymbol': symbol?.name ?? '',
      'customIconBytes': renderedCustomIconBytes,
      'customIconColor': resolvedCustomIconColor,
      'imageAssetPath': resolvedAssetPath ?? '',
      'imageAssetData': imageAsset?.imageData,
      'imageAssetFormat': imageAsset == null
          ? ''
          : imageAsset.imageFormat ??
                detectImageFormat(
                  resolvedAssetPath ?? imageAsset.assetPath,
                  imageAsset.imageData,
                ) ??
                '',
      'sfSymbolSize': imageAsset?.size ?? symbol?.size,
      'sfSymbolColor': resolvedSymbolColor,
      'sfSymbolRenderingMode': resolvedRenderingMode,
      'sfSymbolPaletteColors': resolvedPaletteColors,
      'sfSymbolGradientEnabled': resolvedGradient,
    };
  }

  Future<_CNPopupFallbackSelection?> _showFallbackMenu(
    BuildContext context, {
    required List<CNPopupMenuEntry> items,
    required String? title,
    List<int> parentPath = const [],
  }) async {
    final result = await showCupertinoModalPopup<_CNPopupFallbackResult>(
      context: context,
      builder: (ctx) {
        return CupertinoActionSheet(
          title: title != null ? Text(title) : null,
          actions: [
            for (var i = 0; i < items.length; i++)
              ...switch (items[i]) {
                CNPopupMenuDivider() => [const SizedBox(height: 8)],
                CNPopupMenuItem item => [
                  CupertinoActionSheetAction(
                    onPressed: item.enabled
                        ? () {
                            Navigator.of(ctx).pop(
                              _CNPopupFallbackSelection(
                                legacyIndex: _legacyIndexForPath(
                                      widget.items,
                                      [...parentPath, i],
                                    ) ??
                                    0,
                                selectionPath: [...parentPath, i],
                              ),
                            );
                          }
                        : () {},
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: item.enabled
                            ? null
                            : CupertinoColors.inactiveGray,
                      ),
                      child: Text(
                        item.checked ? '✓ ${item.label}' : item.label,
                      ),
                    ),
                  ),
                ],
                CNPopupMenuSubmenu submenu => [
                  CupertinoActionSheetAction(
                    onPressed: submenu.enabled
                        ? () {
                            Navigator.of(ctx).pop(
                              _CNPopupFallbackOpenSubmenu(
                                submenu: submenu,
                                path: [...parentPath, i],
                              ),
                            );
                          }
                        : () {},
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        color: submenu.enabled
                            ? null
                            : CupertinoColors.inactiveGray,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text(submenu.label)),
                          const Icon(CupertinoIcons.chevron_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
                _ => const <Widget>[],
              },
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    );

    if (result is _CNPopupFallbackSelection) {
      return result;
    }
    if (result is _CNPopupFallbackOpenSubmenu) {
      if (!context.mounted) {
        return null;
      }
      return _showFallbackMenu(
        context,
        items: result.submenu.items,
        title: result.submenu.label,
        parentPath: result.path,
      );
    }
    return null;
  }

  int? _legacyIndexForPath(
    List<CNPopupMenuEntry> entries,
    List<int> targetPath, {
    List<int> parentPath = const [],
    int startIndex = 0,
  }) {
    var currentIndex = startIndex;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final currentPath = [...parentPath, i];
      final entryIndex = currentIndex;
      currentIndex++;

      if (_pathsEqual(currentPath, targetPath)) {
        return entry is CNPopupMenuItem ? entryIndex : null;
      }

      if (entry is CNPopupMenuSubmenu) {
        final childResult = _legacyIndexForPath(
          entry.items,
          targetPath,
          parentPath: currentPath,
          startIndex: currentIndex,
        );
        if (childResult != null) {
          return childResult;
        }
        currentIndex = _legacyTraversalCount(entry.items, currentIndex);
      }
    }
    return null;
  }

  int _legacyTraversalCount(List<CNPopupMenuEntry> entries, int startIndex) {
    var currentIndex = startIndex;
    for (final entry in entries) {
      currentIndex++;
      if (entry is CNPopupMenuSubmenu) {
        currentIndex = _legacyTraversalCount(entry.items, currentIndex);
      }
    }
    return currentIndex;
  }

  bool _pathsEqual(List<int> lhs, List<int> rhs) {
    if (lhs.length != rhs.length) return false;
    for (var i = 0; i < lhs.length; i++) {
      if (lhs[i] != rhs[i]) return false;
    }
    return true;
  }

  Iterable<CNPopupMenuEntry> _walkMenuEntries(List<CNPopupMenuEntry> entries) sync* {
    for (final entry in entries) {
      yield entry;
      if (entry is CNPopupMenuSubmenu) {
        yield* _walkMenuEntries(entry.items);
      }
    }
  }

  CNSymbol? _menuEntrySymbol(CNPopupMenuEntry entry) {
    if (entry is CNPopupMenuItem) return entry.icon;
    if (entry is CNPopupMenuSubmenu) return entry.icon;
    return null;
  }

  IconData? _menuEntryCustomIcon(CNPopupMenuEntry entry) {
    if (entry is CNPopupMenuItem) return entry.customIcon;
    if (entry is CNPopupMenuSubmenu) return entry.customIcon;
    return null;
  }

  CNImageAsset? _menuEntryImageAsset(CNPopupMenuEntry entry) {
    if (entry is CNPopupMenuItem) return entry.imageAsset;
    if (entry is CNPopupMenuSubmenu) return entry.imageAsset;
    return null;
  }

  Color? _menuEntryCustomIconColor(CNPopupMenuEntry entry) {
    if (entry is CNPopupMenuItem) return entry.iconColor;
    if (entry is CNPopupMenuSubmenu) return entry.iconColor;
    return null;
  }

  String _menuEntryCacheKey(CNPopupMenuEntry entry) {
    if (entry is CNPopupMenuDivider) {
      return 'divider';
    }
    if (entry is CNPopupMenuItem) {
      return 'item:${entry.label}_${entry.icon?.name}_${entry.imageAsset?.assetPath}_${entry.imageAsset?.imageData?.length ?? 0}_${entry.customIcon?.hashCode ?? 0}_${entry.enabled}_${entry.checked}';
    }
    if (entry is CNPopupMenuSubmenu) {
      final childKey = entry.items.map(_menuEntryCacheKey).join('|');
      return 'submenu:${entry.label}_${entry.icon?.name}_${entry.imageAsset?.assetPath}_${entry.imageAsset?.imageData?.length ?? 0}_${entry.customIcon?.hashCode ?? 0}_${entry.enabled}[$childKey]';
    }
    return 'unknown';
  }
}

class _CNPopupMenuSerializationCursor {
  int customIconIndex = 0;
  int legacyIndex = 0;
}

sealed class _CNPopupFallbackResult {
  const _CNPopupFallbackResult();
}

class _CNPopupFallbackSelection extends _CNPopupFallbackResult {
  const _CNPopupFallbackSelection({
    required this.legacyIndex,
    required this.selectionPath,
  });

  final int legacyIndex;
  final List<int> selectionPath;
}

class _CNPopupFallbackOpenSubmenu extends _CNPopupFallbackResult {
  const _CNPopupFallbackOpenSubmenu({
    required this.submenu,
    required this.path,
  });

  final CNPopupMenuSubmenu submenu;
  final List<int> path;
}
