import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';

import 'bottom_nav_custom_icons_test.dart';
import 'bottom_nav_indexed_test.dart';
import 'bottom_nav_test.dart';

class TabBarDemoPage extends StatelessWidget {
  const TabBarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Tab Bar')),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              sliver: SliverList.list(
                children: [
                  const _IntroCard(),
                  CupertinoListSection.insetGrouped(
                    header: const Text('Navigation Patterns'),
                    children: [
                      _DemoTile(
                        title: 'Basic Bottom Navigation',
                        subtitle:
                            'Screen switching with SF Symbols and active icons.',
                        onTap: () => _open(context, const BottomNavTestPage()),
                      ),
                      _DemoTile(
                        title: 'Preserve State With IndexedStack',
                        subtitle:
                            'Keep tab screens alive while still using CNTabBar.',
                        onTap: () =>
                            _open(context, const BottomNavIndexedTestPage()),
                      ),
                    ],
                  ),
                  CupertinoListSection.insetGrouped(
                    header: const Text('Styling Patterns'),
                    children: [
                      _DemoTile(
                        title: 'Label-Only, Height, and Font Size',
                        subtitle:
                            'Examples without icons, plus custom label sizing and bar height.',
                        onTap: () =>
                            _open(context, const TabBarVariantsDemoPage()),
                      ),
                      _DemoTile(
                        title: 'Custom SVG Icons',
                        subtitle:
                            'Use CNImageAsset icons and verify iconSize behavior.',
                        onTap: () =>
                            _open(context, const BottomNavCustomIconsTestPage()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }
}

class TabBarVariantsDemoPage extends StatefulWidget {
  const TabBarVariantsDemoPage({super.key});

  @override
  State<TabBarVariantsDemoPage> createState() => _TabBarVariantsDemoPageState();
}

class _TabBarVariantsDemoPageState extends State<TabBarVariantsDemoPage> {
  int _labelOnlyIndex = 0;
  int _splitIndex = 0;
  int _badgeIndex = 1;

  static const _labelOnlyTitles = ['Flights', 'Hotels', 'Trips'];
  static const _splitTitles = ['Today', 'Trips', 'Inbox', 'Profile'];
  static const _badgeTitles = ['Home', 'Orders', 'Inbox'];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Tab Bar Use Cases'),
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverList.list(
                children: [
                  _UseCaseCard(
                    title: 'Label-Only Tabs',
                    description:
                        'A compact content switcher without icons. This uses only labels, a taller bar, and a larger font size.',
                    selection: _labelOnlyTitles[_labelOnlyIndex],
                    child: CNTabBar(
                      items: const [
                        CNTabBarItem(label: 'Flights'),
                        CNTabBarItem(label: 'Hotels'),
                        CNTabBarItem(label: 'Trips'),
                      ],
                      currentIndex: _labelOnlyIndex,
                      onTap: (index) => setState(() => _labelOnlyIndex = index),
                      height: 68,
                      labelFontSize: 14,
                      tint: CupertinoColors.systemIndigo,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _UseCaseCard(
                    title: 'Split Layout',
                    description:
                        'Pin a trailing action or profile tab on the right while keeping the main destinations grouped on the left.',
                    selection: _splitTitles[_splitIndex],
                    child: CNTabBar(
                      items: const [
                        CNTabBarItem(
                          label: 'Today',
                          icon: CNSymbol('sun.max'),
                          activeIcon: CNSymbol('sun.max.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Trips',
                          icon: CNSymbol('airplane'),
                          activeIcon: CNSymbol('airplane.circle.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Inbox',
                          icon: CNSymbol('tray'),
                          activeIcon: CNSymbol('tray.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Profile',
                          icon: CNSymbol('person'),
                          activeIcon: CNSymbol('person.fill'),
                        ),
                      ],
                      currentIndex: _splitIndex,
                      onTap: (index) => setState(() => _splitIndex = index),
                      split: true,
                      rightCount: 1,
                      splitSpacing: 18,
                      tint: CupertinoColors.systemTeal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _UseCaseCard(
                    title: 'Badges and Custom Tint',
                    description:
                        'Surface unread or pending counts while keeping the selected tab prominent.',
                    selection: _badgeTitles[_badgeIndex],
                    child: CNTabBar(
                      items: const [
                        CNTabBarItem(
                          label: 'Home',
                          icon: CNSymbol('house'),
                          activeIcon: CNSymbol('house.fill'),
                        ),
                        CNTabBarItem(
                          label: 'Orders',
                          icon: CNSymbol('bag'),
                          activeIcon: CNSymbol('bag.fill'),
                          badge: '2',
                        ),
                        CNTabBarItem(
                          label: 'Inbox',
                          icon: CNSymbol('bubble.left.and.bubble.right'),
                          activeIcon: CNSymbol(
                            'bubble.left.and.bubble.right.fill',
                          ),
                          badge: '9+',
                        ),
                      ],
                      currentIndex: _badgeIndex,
                      onTap: (index) => setState(() => _badgeIndex = index),
                      tint: CupertinoColors.systemOrange,
                      backgroundColor: CupertinoColors.tertiarySystemFill,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CNTabBar Examples',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Open a focused example to see common navigation patterns and styling options, including label-only tabs and custom heights.',
          ),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const CupertinoListTileChevron(),
      onTap: onTap,
    );
  }
}

class _UseCaseCard extends StatelessWidget {
  const _UseCaseCard({
    required this.title,
    required this.description,
    required this.selection,
    required this.child,
  });

  final String title;
  final String description;
  final String selection;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
          context,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                selection,
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
