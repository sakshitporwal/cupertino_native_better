import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';

class PopupMenuButtonDemoPage extends StatefulWidget {
  const PopupMenuButtonDemoPage({super.key});

  @override
  State<PopupMenuButtonDemoPage> createState() =>
      _PopupMenuButtonDemoPageState();
}

class _PopupMenuButtonDemoPageState extends State<PopupMenuButtonDemoPage> {
  int? _lastSelected;
  List<int>? _lastSelectedPath;
  bool _useAlternateSvgIcons = false;

  @override
  Widget build(BuildContext context) {
    final items = [
      CNPopupMenuItem(label: 'New File', icon: const CNSymbol('doc', size: 18)),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol('folder', size: 18),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Rename',
        icon: const CNSymbol('rectangle.and.pencil.and.ellipsis', size: 18),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol('trash', size: 18),
        enabled: false,
      ),
    ];

    // Items with colored icons
    final coloredItems = [
      CNPopupMenuItem(
        label: 'New File',
        icon: const CNSymbol(
          'doc.fill',
          size: 18,
          color: CupertinoColors.systemBlue,
        ),
      ),
      CNPopupMenuItem(
        label: 'New Folder',
        icon: const CNSymbol(
          'folder.fill',
          size: 18,
          color: CupertinoColors.systemYellow,
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Share',
        icon: const CNSymbol(
          'square.and.arrow.up',
          size: 18,
          color: CupertinoColors.systemGreen,
        ),
      ),
      CNPopupMenuItem(
        label: 'Delete',
        icon: const CNSymbol(
          'trash.fill',
          size: 18,
          color: CupertinoColors.systemRed,
        ),
      ),
    ];

    final customIconItems = [
      CNPopupMenuItem(
        label: 'Home',
        customIcon: CupertinoIcons.home, // Custom IconData!
        iconColor: CupertinoColors.systemBlue, // Tint the custom icon blue!
      ),
      CNPopupMenuItem(
        label: 'Profile',
        icon: const CNSymbol(
          'person',
          size: 18,
          color: CupertinoColors.systemPurple,
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Settings',
        customIcon: CupertinoIcons.settings,
        iconColor: CupertinoColors
            .systemOrange, // Different icon with different color!
      ),
    ];

    final svgItems = [
      CNPopupMenuItem(
        label: 'Home',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/profile.svg'
              : 'assets/icons/home.svg',
          size: 18,
        ),
      ),
      CNPopupMenuItem(
        label: 'Search',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/chat.svg'
              : 'assets/icons/search.svg',
          size: 18,
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Profile',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/home.svg'
              : 'assets/icons/profile.svg',
          size: 18,
        ),
      ),
      CNPopupMenuItem(
        label: 'Chat',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/search.svg'
              : 'assets/icons/chat.svg',
          size: 18,
        ),
      ),
    ];

    final coloredSvgItems = [
      CNPopupMenuItem(
        label: 'Home',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/profile.svg'
              : 'assets/icons/home.svg',
          size: 18,
          color: CupertinoColors.systemBlue,
        ),
      ),
      CNPopupMenuItem(
        label: 'Search',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/chat.svg'
              : 'assets/icons/search.svg',
          size: 18,
          color: CupertinoColors.systemGreen,
        ),
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuItem(
        label: 'Profile',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/home.svg'
              : 'assets/icons/profile.svg',
          size: 18,
          color: CupertinoColors.systemPurple,
        ),
      ),
      CNPopupMenuItem(
        label: 'Chat',
        imageAsset: CNImageAsset(
          _useAlternateSvgIcons
              ? 'assets/icons/search.svg'
              : 'assets/icons/chat.svg',
          size: 18,
          color: CupertinoColors.systemRed,
        ),
      ),
    ];

    final nestedItems = [
      CNPopupMenuItem(
        label: 'Open',
        icon: const CNSymbol('arrow.up.right.square', size: 18),
      ),
      CNPopupMenuSubmenu(
        label: 'Share',
        icon: const CNSymbol('square.and.arrow.up', size: 18),
        items: [
          CNPopupMenuItem(
            label: 'Messages',
            icon: const CNSymbol('message', size: 18),
          ),
          CNPopupMenuItem(
            label: 'Mail',
            icon: const CNSymbol('envelope', size: 18),
          ),
          CNPopupMenuSubmenu(
            label: 'More Apps',
            icon: const CNSymbol('ellipsis.circle', size: 18),
            items: [
              CNPopupMenuItem(
                label: 'Notes',
                icon: const CNSymbol('note.text', size: 18),
              ),
              CNPopupMenuItem(
                label: 'Reminders',
                icon: const CNSymbol('list.bullet', size: 18),
              ),
            ],
          ),
        ],
      ),
      const CNPopupMenuDivider(),
      CNPopupMenuSubmenu(
        label: 'Move To',
        icon: const CNSymbol('folder', size: 18),
        items: [
          CNPopupMenuItem(
            label: 'Downloads',
            icon: const CNSymbol('arrow.down.circle', size: 18),
          ),
          CNPopupMenuItem(
            label: 'Archive',
            icon: const CNSymbol('archivebox', size: 18),
          ),
          CNPopupMenuSubmenu(
            label: 'Tags',
            icon: const CNSymbol('tag', size: 18),
            items: [
              CNPopupMenuItem(
                label: 'Personal',
                icon: const CNSymbol('person', size: 18),
              ),
              CNPopupMenuItem(
                label: 'Work',
                icon: const CNSymbol('briefcase', size: 18),
                checked: true,
              ),
            ],
          ),
        ],
      ),
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Popup Menu Button'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Text button'),
                Spacer(),
                CNPopupMenuButton(
                  buttonLabel: 'Actions',
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.plain,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  size: 44,
                  items: items,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Colored icons'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol(
                    'paintbrush.fill',
                    size: 18,
                    color: CupertinoColors.systemPink,
                  ),
                  size: 44,
                  items: coloredItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.bordered,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Nested menu'),
                const Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis.circle', size: 18),
                  size: 44,
                  items: nestedItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  onSelectedPath: (path) {
                    setState(() => _lastSelectedPath = path);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Custom icon button'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonCustomIcon:
                      CupertinoIcons.ellipsis_circle, // Custom IconData!
                  size: 44,
                  items: customIconItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.tinted,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SVG menu items'),
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _useAlternateSvgIcons = !_useAlternateSvgIcons;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CupertinoColors.systemBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _useAlternateSvgIcons ? 'Reset' : 'Switch',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/profile.svg'
                        : 'assets/icons/home.svg',
                    size: 18,
                  ),
                  size: 44,
                  items: svgItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Colored SVG items'),
                Spacer(),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    _useAlternateSvgIcons
                        ? 'assets/icons/chat.svg'
                        : 'assets/icons/search.svg',
                    size: 18,
                    color: CupertinoColors.systemBlue,
                  ),
                  size: 44,
                  items: coloredSvgItems,
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'PNG Menu Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 18,
                  ),
                  size: 44,
                  items: [
                    CNPopupMenuItem(
                      label: 'Check',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 18,
                      ),
                    ),
                    CNPopupMenuItem(
                      label: 'Clock',
                      imageAsset: CNImageAsset(
                        'assets/icons/clock.png',
                        size: 18,
                      ),
                    ),
                    const CNPopupMenuDivider(),
                    CNPopupMenuItem(
                      label: 'Close',
                      imageAsset: CNImageAsset(
                        'assets/icons/close.png',
                        size: 18,
                      ),
                    ),
                    CNPopupMenuItem(
                      label: 'Coins',
                      imageAsset: CNImageAsset(
                        'assets/icons/coins.png',
                        size: 18,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'PNG Menu Items with Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('ellipsis', size: 18),
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 18,
                    color: CupertinoColors.systemBlue,
                  ),
                  size: 44,
                  items: [
                    CNPopupMenuItem(
                      label: 'Check',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 18,
                        color: CupertinoColors.systemGreen,
                      ),
                    ),
                    CNPopupMenuItem(
                      label: 'Clock',
                      imageAsset: CNImageAsset(
                        'assets/icons/clock.png',
                        size: 18,
                        color: CupertinoColors.systemOrange,
                      ),
                    ),
                    const CNPopupMenuDivider(),
                    CNPopupMenuItem(
                      label: 'Close',
                      imageAsset: CNImageAsset(
                        'assets/icons/close.png',
                        size: 18,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                    CNPopupMenuItem(
                      label: 'Coins',
                      imageAsset: CNImageAsset(
                        'assets/icons/coins.png',
                        size: 18,
                        color: CupertinoColors.systemYellow,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.borderedProminent,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'PNG Button Icons - Different Sizes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                CNPopupMenuButton.icon(
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 12,
                  ),
                  size: 32,
                  items: [
                    CNPopupMenuItem(
                      label: 'Small',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 12,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
                CNPopupMenuButton.icon(
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 16,
                  ),
                  size: 36,
                  items: [
                    CNPopupMenuItem(
                      label: 'Medium',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 16,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
                CNPopupMenuButton.icon(
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 20,
                  ),
                  size: 44,
                  items: [
                    CNPopupMenuItem(
                      label: 'Large',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 20,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
                CNPopupMenuButton.icon(
                  buttonImageAsset: CNImageAsset(
                    'assets/icons/checkcircle.png',
                    size: 24,
                  ),
                  size: 48,
                  items: [
                    CNPopupMenuItem(
                      label: 'XLarge',
                      imageAsset: CNImageAsset(
                        'assets/icons/checkcircle.png',
                        size: 24,
                      ),
                    ),
                  ],
                  onSelected: (index) {
                    setState(() => _lastSelected = index);
                  },
                  buttonStyle: CNButtonStyle.glass,
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSelected != null)
              Center(
                child: Text(
                  _lastSelectedPath == null
                      ? 'Selected index: $_lastSelected'
                      : 'Selected index: $_lastSelected, path: ${_lastSelectedPath!.join(' > ')}',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
