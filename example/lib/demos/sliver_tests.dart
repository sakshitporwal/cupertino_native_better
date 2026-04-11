import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/cupertino.dart';

class SliverTestsPage extends StatefulWidget {
  const SliverTestsPage({super.key});

  @override
  State<SliverTestsPage> createState() => _SliverTestsPageState();
}

class _SliverTestsPageState extends State<SliverTestsPage> {
  int _segmentedIndex = 0;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Sliver Tests')),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList.list(
                children: [
                  _buildIntroCard(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, 'CNSegmentedControl in Sliver'),
                  const SizedBox(height: 12),
                  CNSegmentedControl(
                    labels: const ['Overview', 'Details', 'Activity'],
                    selectedIndex: _segmentedIndex,
                    onValueChanged: (index) {
                      setState(() => _segmentedIndex = index);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildStatusCard(
                    context,
                    title: 'Selected segment',
                    subtitle: 'Current value: ${_segmentedIndex + 1}',
                    symbol: 'line.3.horizontal.decrease.circle',
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    context,
                    'Scrollable content before tab bar',
                  ),
                  const SizedBox(height: 12),
                  for (var index = 0; index < 6; index++) ...[
                    _buildContentCard(context, index),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle(context, 'CNTabBar in Sliver'),
                  const SizedBox(height: 12),
                  CNTabBar(
                    items: const [
                      CNTabBarItem(
                        label: 'Home',
                        icon: CNSymbol('house'),
                        activeIcon: CNSymbol('house.fill'),
                      ),
                      CNTabBarItem(
                        label: 'Browse',
                        icon: CNSymbol('square.grid.2x2'),
                        activeIcon: CNSymbol('square.grid.2x2.fill'),
                      ),
                      CNTabBarItem(
                        label: 'Library',
                        icon: CNSymbol('books.vertical'),
                        activeIcon: CNSymbol('books.vertical.fill'),
                      ),
                    ],
                    currentIndex: _tabIndex,
                    onTap: (index) {
                      setState(() => _tabIndex = index);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildStatusCard(
                    context,
                    title: 'Selected tab',
                    subtitle: _tabLabelFor(_tabIndex),
                    symbol: 'dock.rectangle',
                  ),
                  const SizedBox(height: 28),
                  _buildSectionTitle(
                    context,
                    'Scrollable content after tab bar',
                  ),
                  const SizedBox(height: 12),
                  for (var index = 6; index < 12; index++) ...[
                    _buildContentCard(context, index),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Scroll this page up and down to verify native platform views keep rendering when hosted inside slivers.',
        style: TextStyle(color: CupertinoColors.label.resolveFrom(context)),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String symbol,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CNIcon(
            symbol: CNSymbol(
              symbol,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scroll item ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Use this filler content to push the native controls off-screen and back into view while they stay inside the sliver list.',
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }

  String _tabLabelFor(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Browse';
      case 2:
        return 'Library';
      default:
        return 'Unknown';
    }
  }
}
