import FlutterMacOS
import Cocoa

class CupertinoPopupMenuButtonNSView: NSView {
  private let channel: FlutterMethodChannel
  private let button: NSButton
  private var popupMenu: NSMenu = NSMenu()
  private var labels: [String] = []
  private var symbols: [String] = []
  private var dividers: [Bool] = []
  private var enabled: [Bool] = []
  private var defaultSizes: [NSNumber] = []
  private var defaultColors: [NSNumber] = []
  private var defaultModes: [String?] = []
  private var defaultPalettes: [[NSNumber]] = []
  private var defaultGradients: [NSNumber?] = []
  private var itemTree: [[String: Any]] = []

  init(viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(name: "CupertinoNativePopupMenuButton_\(viewId)", binaryMessenger: messenger)
    self.button = NSButton(title: "", target: nil, action: nil)
    super.init(frame: .zero)

    var title: String? = nil
    var iconName: String? = nil
    var iconSize: CGFloat? = nil
    var iconColor: NSColor? = nil
    var makeRound: Bool = false
    var buttonStyle: String = "automatic"
    var isDark: Bool = false
    var tint: NSColor? = nil
    var labels: [String] = []
    var symbols: [String] = []
    var dividers: [NSNumber] = []
    var enabled: [NSNumber] = []
    var sizes: [NSNumber] = []
    var colors: [NSNumber] = []
    var buttonIconMode: String? = nil
    var buttonIconPalette: [NSNumber] = []

    if let dict = args as? [String: Any] {
      if let t = dict["buttonTitle"] as? String { title = t }
      if let s = dict["buttonIconName"] as? String { iconName = s }
      if let s = dict["buttonIconSize"] as? NSNumber { iconSize = CGFloat(truncating: s) }
      if let c = dict["buttonIconColor"] as? NSNumber { iconColor = Self.colorFromARGB(c.intValue) }
      if let r = dict["round"] as? NSNumber { makeRound = r.boolValue }
      if let bs = dict["buttonStyle"] as? String { buttonStyle = bs }
      if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
      if let style = dict["style"] as? [String: Any], let n = style["tint"] as? NSNumber { tint = Self.colorFromARGB(n.intValue) }
      labels = (dict["labels"] as? [String]) ?? []
      symbols = (dict["sfSymbols"] as? [String]) ?? []
      dividers = (dict["isDivider"] as? [NSNumber]) ?? []
      enabled = (dict["enabled"] as? [NSNumber]) ?? []
      if let modes = dict["sfSymbolRenderingModes"] as? [String?] { self.defaultModes = modes }
      if let palettes = dict["sfSymbolPaletteColors"] as? [[NSNumber]] { self.defaultPalettes = palettes }
      if let gradients = dict["sfSymbolGradientEnabled"] as? [NSNumber?] { self.defaultGradients = gradients }
      if let tree = dict["itemTree"] as? [[String: Any]] { self.itemTree = tree }
      if let m = dict["buttonIconRenderingMode"] as? String { buttonIconMode = m }
      if let pal = dict["buttonIconPaletteColors"] as? [NSNumber] { buttonIconPalette = pal }
      sizes = (dict["sfSymbolSizes"] as? [NSNumber]) ?? []
      colors = (dict["sfSymbolColors"] as? [NSNumber]) ?? []
    }

    wantsLayer = true
    layer?.backgroundColor = NSColor.clear.cgColor
    appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)

    if let t = title { button.title = t }
    if let name = iconName, var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
      if #available(macOS 12.0, *), let sz = iconSize {
        let cfg = NSImage.SymbolConfiguration(pointSize: sz, weight: .regular)
        image = image.withSymbolConfiguration(cfg) ?? image
      }
      if let mode = buttonIconMode {
        switch mode {
        case "hierarchical":
          if #available(macOS 12.0, *), let c = iconColor {
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "palette":
          if #available(macOS 12.0, *), !buttonIconPalette.isEmpty {
            let cols = buttonIconPalette.map { Self.colorFromARGB($0.intValue) }
            let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        case "multicolor":
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
            image = image.withSymbolConfiguration(cfg) ?? image
          }
        default:
          break
        }
      } else if let c = iconColor {
        image = image.tinted(with: c)
      }
      button.image = image
      button.imagePosition = .imageOnly
    }
    // Map CNButtonStyle to AppKit bezel styles (best-effort)
    switch buttonStyle {
    case "plain":
      button.bezelStyle = .texturedRounded
      button.isBordered = false
    case "gray": button.bezelStyle = .texturedRounded
    case "tinted": button.bezelStyle = .texturedRounded
    case "bordered": button.bezelStyle = .rounded
    case "borderedProminent": button.bezelStyle = .rounded
    case "filled": button.bezelStyle = .rounded
    case "glass": button.bezelStyle = .texturedRounded
    case "prominentGlass": button.bezelStyle = .texturedRounded
    default: button.bezelStyle = .rounded
    }
    if makeRound { button.bezelStyle = .circular }
    button.setButtonType(.momentaryPushIn)
    if #available(macOS 10.14, *), let c = tint {
      if ["filled", "borderedProminent", "prominentGlass"].contains(buttonStyle) {
        button.bezelColor = c
        button.contentTintColor = .white
      } else {
        button.contentTintColor = c
      }
    }

    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    self.labels = labels
    self.symbols = symbols
    self.dividers = dividers.map { $0.boolValue }
    self.enabled = enabled.map { $0.boolValue }
    self.defaultSizes = sizes
    self.defaultColors = colors
    rebuildMenu(defaultSizes: sizes, defaultColors: colors)

    button.target = self
    button.action = #selector(onButtonPressed(_:))

    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "getIntrinsicSize":
        let s = self.button.intrinsicContentSize
        result(["width": Double(s.width), "height": Double(s.height)])
      case "setItems":
        if let args = call.arguments as? [String: Any] {
          self.labels = (args["labels"] as? [String]) ?? []
          self.symbols = (args["sfSymbols"] as? [String]) ?? []
          self.dividers = ((args["isDivider"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.enabled = ((args["enabled"] as? [NSNumber]) ?? []).map { $0.boolValue }
          self.defaultSizes = (args["sfSymbolSizes"] as? [NSNumber]) ?? []
          self.defaultColors = (args["sfSymbolColors"] as? [NSNumber]) ?? []
          self.defaultModes = (args["sfSymbolRenderingModes"] as? [String?]) ?? []
          self.defaultPalettes = (args["sfSymbolPaletteColors"] as? [[NSNumber]]) ?? []
          self.defaultGradients = (args["sfSymbolGradientEnabled"] as? [NSNumber?]) ?? []
          self.itemTree = (args["itemTree"] as? [[String: Any]]) ?? []
          self.rebuildMenu(defaultSizes: self.defaultSizes, defaultColors: self.defaultColors)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing items", details: nil)) }
      case "setStyle":
        if let args = call.arguments as? [String: Any] {
          if #available(macOS 10.14, *), let n = args["tint"] as? NSNumber {
            let color = Self.colorFromARGB(n.intValue)
            if ["filled", "borderedProminent", "prominentGlass"].contains(buttonStyle) {
              self.button.bezelColor = color
              self.button.contentTintColor = .white
            } else {
              self.button.contentTintColor = color
            }
          }
          if let bs = args["buttonStyle"] as? String {
            switch bs {
            case "plain":
              self.button.bezelStyle = .texturedRounded
              self.button.isBordered = false
            case "gray": self.button.bezelStyle = .texturedRounded
            case "tinted": self.button.bezelStyle = .texturedRounded
            case "bordered": self.button.bezelStyle = .rounded
            case "borderedProminent": self.button.bezelStyle = .rounded
            case "filled": self.button.bezelStyle = .rounded
            case "glass": self.button.bezelStyle = .texturedRounded
            case "prominentGlass": self.button.bezelStyle = .texturedRounded
            default: self.button.bezelStyle = .rounded
            }
            if bs != "plain" { self.button.isBordered = true }
          }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing style", details: nil)) }
      case "setButtonIcon":
        if let args = call.arguments as? [String: Any] {
          if let name = args["buttonIconName"] as? String, var image = NSImage(systemSymbolName: name, accessibilityDescription: nil) {
            if #available(macOS 12.0, *), let sz = args["buttonIconSize"] as? NSNumber {
              let cfg = NSImage.SymbolConfiguration(pointSize: CGFloat(truncating: sz), weight: .regular)
              image = image.withSymbolConfiguration(cfg) ?? image
            }
            if let mode = args["buttonIconRenderingMode"] as? String {
              switch mode {
              case "hierarchical":
                if #available(macOS 12.0, *), let c = args["buttonIconColor"] as? NSNumber {
                  let cfg = NSImage.SymbolConfiguration(hierarchicalColor: Self.colorFromARGB(c.intValue))
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              case "palette":
                if #available(macOS 12.0, *), let pal = args["buttonIconPaletteColors"] as? [NSNumber] {
                  let cols = pal.map { Self.colorFromARGB($0.intValue) }
                  let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              case "multicolor":
                if #available(macOS 12.0, *) {
                  let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
                  image = image.withSymbolConfiguration(cfg) ?? image
                }
              default:
                break
              }
            } else if let c = args["buttonIconColor"] as? NSNumber {
              image = image.tinted(with: Self.colorFromARGB(c.intValue))
            }
            self.button.image = image
            self.button.imagePosition = .imageOnly
          }
          if let r = args["round"] as? NSNumber, r.boolValue { self.button.bezelStyle = .circular }
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing icon args", details: nil)) }
      case "setBrightness":
        if let args = call.arguments as? [String: Any], let isDark = (args["isDark"] as? NSNumber)?.boolValue {
          self.appearance = NSAppearance(named: isDark ? .darkAqua : .aqua)
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil)) }
      case "setButtonTitle":
        if let args = call.arguments as? [String: Any], let t = args["title"] as? String {
          self.button.title = t
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing title", details: nil)) }
      case "setPressed":
        if let args = call.arguments as? [String: Any], let p = args["pressed"] as? NSNumber {
          self.alphaValue = p.boolValue ? 0.7 : 1.0
          result(nil)
        } else { result(FlutterError(code: "bad_args", message: "Missing pressed", details: nil)) }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  required init?(coder: NSCoder) { return nil }

  @objc private func onButtonPressed(_ sender: NSButton) {
    let location = NSPoint(x: 0, y: sender.bounds.height)
    popupMenu.popUp(positioning: nil, at: location, in: sender)
  }

  private func rebuildMenu(defaultSizes: [NSNumber]? = nil, defaultColors: [NSNumber]? = nil) {
    popupMenu = NSMenu()
    if !itemTree.isEmpty {
      populate(menu: popupMenu, with: itemTree)
      return
    }
    let count = max(labels.count, max(symbols.count, dividers.count))
    for i in 0..<count {
      if i < dividers.count, dividers[i] {
        popupMenu.addItem(.separator())
        continue
      }
      let title = i < labels.count ? labels[i] : ""
      let mi = NSMenuItem(title: title, action: #selector(onSelectMenuItem(_:)), keyEquivalent: "")
      mi.target = self
      mi.tag = i
      if i < enabled.count { mi.isEnabled = enabled[i] }
      if i < symbols.count, !symbols[i].isEmpty {
        if var img = NSImage(systemSymbolName: symbols[i], accessibilityDescription: nil) {
          if #available(macOS 12.0, *), let sizes = defaultSizes, i < sizes.count {
            let s = CGFloat(truncating: sizes[i])
            if s > 0 {
              let cfg = NSImage.SymbolConfiguration(pointSize: s, weight: .regular)
              img = img.withSymbolConfiguration(cfg) ?? img
            }
          }
          if #available(macOS 12.0, *), i < defaultModes.count, let mode = defaultModes[i] {
            switch mode {
            case "hierarchical":
              if let colors = defaultColors, i < colors.count {
                let c = Self.colorFromARGB(colors[i].intValue)
                let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
                img = img.withSymbolConfiguration(cfg) ?? img
              }
            case "palette":
              if i < defaultPalettes.count, !defaultPalettes[i].isEmpty {
                let cols = defaultPalettes[i].map { Self.colorFromARGB($0.intValue) }
                let cfg = NSImage.SymbolConfiguration(paletteColors: cols)
                img = img.withSymbolConfiguration(cfg) ?? img
              }
            case "multicolor":
              let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
              img = img.withSymbolConfiguration(cfg) ?? img
            case "monochrome":
              if let colors = defaultColors, i < colors.count {
                let c = Self.colorFromARGB(colors[i].intValue)
                img = img.tinted(with: c)
              }
            default:
              break
            }
          } else if #available(macOS 12.0, *), let colors = defaultColors, i < colors.count {
            let c = Self.colorFromARGB(colors[i].intValue)
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: c)
            img = img.withSymbolConfiguration(cfg) ?? img
          }
          mi.image = img
        }
      }
      popupMenu.addItem(mi)
    }
  }

  private func populate(menu: NSMenu, with nodes: [[String: Any]]) {
    for node in nodes {
      let type = (node["type"] as? String) ?? "item"
      if type == "divider" {
        menu.addItem(.separator())
        continue
      }
      if let item = makeMenuItem(from: node) {
        menu.addItem(item)
      }
    }
  }

  private func makeMenuItem(from node: [String: Any]) -> NSMenuItem? {
    let type = (node["type"] as? String) ?? "item"
    let title = (node["label"] as? String) ?? ""
    let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
    item.isEnabled = (node["enabled"] as? NSNumber)?.boolValue ?? true
    item.image = makeMenuImage(from: node)

    if type == "submenu" {
      let submenu = NSMenu(title: title)
      populate(menu: submenu, with: (node["children"] as? [[String: Any]]) ?? [])
      item.submenu = submenu
      return item
    }

    guard type == "item" else { return nil }
    item.target = self
    item.action = #selector(onSelectMenuItem(_:))
    if let index = (node["legacyIndex"] as? NSNumber)?.intValue {
      item.tag = index
    }
    if let path = node["selectionPath"] as? [NSNumber] {
      item.representedObject = path.map { $0.intValue }
    } else if let path = node["selectionPath"] as? [Int] {
      item.representedObject = path
    }
    if (node["checked"] as? NSNumber)?.boolValue ?? false {
      item.state = .on
    }
    return item
  }

  private func makeMenuImage(from node: [String: Any]) -> NSImage? {
    var image: NSImage? = nil

    if let assetPath = node["imageAssetPath"] as? String, !assetPath.isEmpty {
      image = NSImage(contentsOfFile: assetPath)
    } else if let data = (node["imageAssetData"] as? FlutterStandardTypedData)?.data {
      image = NSImage(data: data)
    } else if let data = (node["customIconBytes"] as? FlutterStandardTypedData)?.data {
      image = NSImage(data: data)
      if let colorNum = node["customIconColor"] as? NSNumber {
        image = image?.tinted(with: Self.colorFromARGB(colorNum.intValue))
      }
    } else if let symbolName = node["sfSymbol"] as? String, !symbolName.isEmpty {
      image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
    }

    if let sizeNum = node["sfSymbolSize"] as? NSNumber {
      let size = CGFloat(truncating: sizeNum)
      if size > 0 {
        image?.size = NSSize(width: size, height: size)
      }
    }

    if let symbolName = node["sfSymbol"] as? String,
       !symbolName.isEmpty,
       var symbolImage = image {
      if let sizeNum = node["sfSymbolSize"] as? NSNumber, #available(macOS 12.0, *) {
        let cfg = NSImage.SymbolConfiguration(pointSize: CGFloat(truncating: sizeNum), weight: .regular)
        symbolImage = symbolImage.withSymbolConfiguration(cfg) ?? symbolImage
      }
      if let mode = node["sfSymbolRenderingMode"] as? String {
        switch mode {
        case "hierarchical":
          if #available(macOS 12.0, *), let colorNum = node["sfSymbolColor"] as? NSNumber {
            let cfg = NSImage.SymbolConfiguration(hierarchicalColor: Self.colorFromARGB(colorNum.intValue))
            symbolImage = symbolImage.withSymbolConfiguration(cfg) ?? symbolImage
          }
        case "palette":
          if #available(macOS 12.0, *), let palette = node["sfSymbolPaletteColors"] as? [NSNumber], !palette.isEmpty {
            let cfg = NSImage.SymbolConfiguration(paletteColors: palette.map { Self.colorFromARGB($0.intValue) })
            symbolImage = symbolImage.withSymbolConfiguration(cfg) ?? symbolImage
          }
        case "multicolor":
          if #available(macOS 12.0, *) {
            let cfg = NSImage.SymbolConfiguration.preferringMulticolor()
            symbolImage = symbolImage.withSymbolConfiguration(cfg) ?? symbolImage
          }
        case "monochrome":
          if let colorNum = node["sfSymbolColor"] as? NSNumber {
            symbolImage = symbolImage.tinted(with: Self.colorFromARGB(colorNum.intValue))
          }
        default:
          break
        }
      } else if let colorNum = node["sfSymbolColor"] as? NSNumber {
        symbolImage = symbolImage.tinted(with: Self.colorFromARGB(colorNum.intValue))
      }
      image = symbolImage
    } else if let colorNum = node["sfSymbolColor"] as? NSNumber {
      image = image?.tinted(with: Self.colorFromARGB(colorNum.intValue))
    }

    return image
  }

  @objc private func onSelectMenuItem(_ sender: NSMenuItem) {
    var args: [String: Any] = ["index": sender.tag]
    if let path = sender.representedObject as? [Int] {
      args["selectionPath"] = path
    }
    channel.invokeMethod("itemSelected", arguments: args)
  }

  private static func colorFromARGB(_ argb: Int) -> NSColor {
    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0
    return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
  }
}

private extension NSImage {
  func tinted(with color: NSColor) -> NSImage {
    let img = NSImage(size: size)
    img.lockFocus()
    let rect = NSRect(origin: .zero, size: size)
    color.set()
    rect.fill()
    draw(in: rect, from: .zero, operation: .destinationIn, fraction: 1.0)
    img.unlockFocus()
    return img
  }
}
