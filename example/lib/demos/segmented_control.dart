import 'package:flutter/cupertino.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';

class SegmentedControlDemoPage extends StatefulWidget {
  const SegmentedControlDemoPage({super.key});

  @override
  State<SegmentedControlDemoPage> createState() =>
      _SegmentedControlDemoPageState();
}

class _SegmentedControlDemoPageState extends State<SegmentedControlDemoPage> {
  int _basicSegmentedControlIndex = 0;
  int _coloredSegmentedControlIndex = 1;
  int _shrinkWrappedSegmentedControlIndex = 0;
  int _iconSegmentedControlIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(middle: Text('Segmented Control')),
          SliverSafeArea(
            top: false,
            sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              sliver: SliverList.list(
                children: [
                  _buildSectionHeader(
                    'Basic',
                    'Selected: ${_basicSegmentedControlIndex + 1}',
                  ),
                  const SizedBox(height: 12),
                  CNSegmentedControl(
                    labels: const ['One', 'Two', 'Three'],
                    selectedIndex: _basicSegmentedControlIndex,
                    onValueChanged: (i) =>
                        setState(() => _basicSegmentedControlIndex = i),
                  ),
                  const SizedBox(height: 48),
                  _buildSectionHeader(
                    'Colored',
                    'Selected: ${_shrinkWrappedSegmentedControlIndex + 1}',
                  ),
                  const SizedBox(height: 12),
                  CNSegmentedControl(
                    labels: const ['One', 'Two', 'Three'],
                    selectedIndex: _shrinkWrappedSegmentedControlIndex,
                    color: CupertinoColors.systemPink,
                    onValueChanged: (i) =>
                        setState(() => _shrinkWrappedSegmentedControlIndex = i),
                  ),
                  const SizedBox(height: 48),
                  _buildSectionHeader(
                    'Shrink wrap',
                    'Selected: ${_coloredSegmentedControlIndex + 1}',
                  ),
                  const SizedBox(height: 12),
                  CNSegmentedControl(
                    labels: const ['One', 'Two', 'Three'],
                    selectedIndex: _coloredSegmentedControlIndex,
                    onValueChanged: (i) =>
                        setState(() => _coloredSegmentedControlIndex = i),
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 48),
                  _buildSectionHeader(
                    'Icons',
                    'Selected: ${_iconSegmentedControlIndex + 1}',
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: CNSegmentedControl(
                      labels: const [],
                      sfSymbols: const [
                        CNSymbol('list.clipboard'),
                        CNSymbol('leaf.arrow.trianglehead.clockwise'),
                        CNSymbol('figure.walk.diamond'),
                      ],
                      selectedIndex: _iconSegmentedControlIndex,
                      iconColor: CupertinoColors.systemBlue,
                      iconRenderingMode: CNSymbolRenderingMode.hierarchical,
                      shrinkWrap: true,
                      onValueChanged: (i) =>
                          setState(() => _iconSegmentedControlIndex = i),
                      height: 48,
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

  Widget _buildSectionHeader(String title, String selection) {
    return Row(children: [Text(title), const Spacer(), Text(selection)]);
  }
}
