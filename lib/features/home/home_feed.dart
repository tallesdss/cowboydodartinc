import 'package:cowboydodartinc/components/kasy_app_bar.dart';
import 'package:cowboydodartinc/components/kasy_card.dart';
import 'package:cowboydodartinc/core/haptics/kasy_haptics.dart';
import 'package:cowboydodartinc/core/theme/theme.dart';
import 'package:cowboydodartinc/features/home/home_image_grid.dart';
import 'package:flutter/material.dart';

/// A browseable image category. Selecting one filters the feed below.
enum HomeCategory { productDesign, background, animated, icons3d, gradients }

class _CategoryData {
  final String title;
  final String subtitle;

  /// Thumbnail shown inside the filter card.
  final String thumbnailId;

  /// Unsplash photo ids returned in the feed for this category.
  final List<String> photoIds;

  const _CategoryData({
    required this.title,
    required this.subtitle,
    required this.thumbnailId,
    required this.photoIds,
  });
}

const Map<HomeCategory, _CategoryData> _categories = <HomeCategory, _CategoryData>{
  HomeCategory.productDesign: _CategoryData(
    title: 'Product Design',
    subtitle: 'Sleek, abstract objects',
    thumbnailId: '1556228720-195a672e8a03',
    photoIds: <String>[
      '1556228720-195a672e8a03',
      '1542291026-7eec264c27ff',
      '1505740420928-5e560c06d30e',
      '1522338242992-e1a54906a8da',
      '1523275335684-37898b6baf30',
      '1572635196237-14b3f281503f',
      '1526170375885-4d8ecf77b99f',
      '1560769629-975ec94e6a86',
      '1491553895911-0055eca6402d',
      '1525966222134-fcfa99b8ae77',
      '1484704849700-f032a568e944',
      '1542219550-37153d387c27',
      '1634986666676-ec8fd927c23d',
      '1633899306328-c5e70574aaa2',
      '1634017839464-5c339ebe3cb4',
      '1618005182384-a83a8bd57fbe',
      '1635776062127-d379bfcba9f8',
      '1618556450994-a6a128ef0d9d',
      '1644143379190-08a5f055de1d',
      '1617791160505-6f00504e3519',
    ],
  ),
  HomeCategory.background: _CategoryData(
    title: 'Background',
    subtitle: 'Dreamy, scenic vibes',
    thumbnailId: '1501854140801-50d01698950b',
    photoIds: <String>[
      '1506905925346-21bda4d32df4',
      '1469474968028-56623f02e42e',
      '1441974231531-c6227db76b6e',
      '1472214103451-9374bd1c798e',
      '1447752875215-b2761acb3c5d',
      '1426604966848-d7adac402bff',
      '1433086966358-54859d0ed716',
      '1418985991508-e47386d96a71',
      '1505765050516-f72dcac9c60e',
      '1454496522488-7a8e488e8606',
      '1439066615861-d1af74d74000',
      '1470071459604-3b5ec3a7fe05',
      '1502691876148-a84978e59af8',
      '1574169208507-84376144848b',
      '1518837695005-2083093ee35b',
      '1534796636912-3b95b3ab5986',
      '1508614999368-9260051292e5',
      '1554189097-ffe88e998a2b',
      '1557683316-973673baf926',
      '1557682224-5b8590cd9ec5',
    ],
  ),
  HomeCategory.animated: _CategoryData(
    title: 'Animated',
    subtitle: 'Minimalist, soft',
    thumbnailId: '1502691876148-a84978e59af8',
    photoIds: <String>[
      '1541701494587-cb58502866ab',
      '1559827260-dc66d52bef19',
      '1462331940025-496dfbfc7564',
      '1534796636912-3b95b3ab5986',
      '1518837695005-2083093ee35b',
      '1502691876148-a84978e59af8',
      '1574169208507-84376144848b',
      '1620641788421-7a1c342ea42e',
      '1550859492-d5da9d8e45f3',
      '1579546929518-9e396f3cc809',
      '1614851099175-e5b30eb6f696',
      '1557672172-298e090bd0f1',
      '1469474968028-56623f02e42e',
      '1472214103451-9374bd1c798e',
      '1447752875215-b2761acb3c5d',
      '1426604966848-d7adac402bff',
      '1554189097-ffe88e998a2b',
      '1508614999368-9260051292e5',
      '1557683316-973673baf926',
      '1557682224-5b8590cd9ec5',
    ],
  ),
  HomeCategory.icons3d: _CategoryData(
    title: '3D Icons',
    subtitle: 'Clean, rounded icons',
    thumbnailId: '1639762681485-074b7f938ba0',
    photoIds: <String>[
      '1634986666676-ec8fd927c23d',
      '1639762681485-074b7f938ba0',
      '1633899306328-c5e70574aaa2',
      '1634017839464-5c339ebe3cb4',
      '1644143379190-08a5f055de1d',
      '1617791160505-6f00504e3519',
      '1618005182384-a83a8bd57fbe',
      '1635776062127-d379bfcba9f8',
      '1618556450994-a6a128ef0d9d',
      '1620207418302-439b387441b0',
      '1604079628040-94301bb21b91',
      '1557682250-33bd709cbe85',
      '1556228720-195a672e8a03',
      '1542291026-7eec264c27ff',
      '1522338242992-e1a54906a8da',
      '1572635196237-14b3f281503f',
      '1526170375885-4d8ecf77b99f',
      '1560769629-975ec94e6a86',
      '1525966222134-fcfa99b8ae77',
      '1542219550-37153d387c27',
    ],
  ),
  HomeCategory.gradients: _CategoryData(
    title: 'Gradients',
    subtitle: 'Smooth, vivid color',
    thumbnailId: '1557672172-298e090bd0f1',
    photoIds: <String>[
      '1557672172-298e090bd0f1',
      '1557683316-973673baf926',
      '1579546929518-9e396f3cc809',
      '1620207418302-439b387441b0',
      '1614851099175-e5b30eb6f696',
      '1550859492-d5da9d8e45f3',
      '1557682250-33bd709cbe85',
      '1557682224-5b8590cd9ec5',
      '1604079628040-94301bb21b91',
      '1508614999368-9260051292e5',
      '1554189097-ffe88e998a2b',
      '1620641788421-7a1c342ea42e',
      '1518837695005-2083093ee35b',
      '1534796636912-3b95b3ab5986',
      '1462331940025-496dfbfc7564',
      '1559827260-dc66d52bef19',
      '1541701494587-cb58502866ab',
      '1574169208507-84376144848b',
      '1502691876148-a84978e59af8',
      '1469474968028-56623f02e42e',
    ],
  ),
};

// Author / timestamp pools — varied per photo by index so captions feel real
// without hand-authoring metadata for every image.
const List<String> _authors = <String>[
  'Elena Park', 'Marcus Vale', 'Liang Wu', 'Sofia Reis', 'Noah Fields',
  'Aya Tanaka', 'Hugo Brandt', 'Petra Nilsson', 'Diego Sol', 'Mara Lopez',
  'Theo Klein', 'Ines Costa', 'Omar Aziz', 'Lena Fox',
];
const List<String> _agos = <String>[
  '1 day ago', '2 days ago', '3 days ago', '5 days ago',
  '6 days ago', '1 week ago', '2 weeks ago', '4 days ago',
];

List<HomePhoto> _photosFor(HomeCategory category) {
  final List<String> ids = _categories[category]!.photoIds;
  return <HomePhoto>[
    for (int i = 0; i < ids.length; i++)
      HomePhoto(
        id: ids[i],
        author: _authors[i % _authors.length],
        ago: _agos[i % _agos.length],
      ),
  ];
}

/// Category chip thumbs are ~48–64 logical px; request 2–3× for retina.
String _thumbUrl(String id) =>
    'https://images.unsplash.com/photo-$id?w=320&h=320&fit=crop&q=85&auto=format&dpr=2';

/// Home content: a selectable category filter row over a masonry image feed.
class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

class _HomeFeedState extends State<HomeFeed> {
  HomeCategory _selected = HomeCategory.productDesign;

  void _select(HomeCategory category) {
    if (category == _selected) return;
    KasyHaptics.light(context);
    setState(() => _selected = category);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // App bar inset lives INSIDE the scroll so it scrolls away and the
          // feed slides under the frosted bar (overlay pattern).
          SizedBox(
            height: kasyAppBarBodyTopOverlap(context) +
                KasySpacing.belowChromeContentGap,
          ),
          _FilterRow(selected: _selected, onSelect: _select),
          const SizedBox(height: KasySpacing.lg),
          Padding(
            // Reserve the floating bar's height (injected as the bottom inset by
            // the host Scaffold's extendBody) so the last row settles above it.
            padding: EdgeInsets.fromLTRB(
              KasySpacing.md,
              0,
              KasySpacing.md,
              KasySpacing.lg + MediaQuery.paddingOf(context).bottom,
            ),
            child: HomeImageGrid(photos: _photosFor(_selected)),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final HomeCategory selected;
  final ValueChanged<HomeCategory> onSelect;

  const _FilterRow({required this.selected, required this.onSelect});

  // Breathing room around the row so the keyboard focus ring (which paints a
  // few px outside the card) is never clipped by the horizontal list's edges.
  static const double _ringInset = 8;

  @override
  Widget build(BuildContext context) {
    const List<HomeCategory> all = HomeCategory.values;

    // Cards scale fluidly with the screen width instead of snapping at a single
    // breakpoint: smallest/densest on phones, growing smoothly to full size by
    // the time we reach a desktop-width viewport.
    const double minWidth = 360; // small phone
    const double maxWidth = 1024; // desktop — cards at full size from here up
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double t = ((screenWidth - minWidth) / (maxWidth - minWidth)).clamp(
      0.0,
      1.0,
    );
    final double thumbSize = 44 + (79 - 44) * t;
    final double cardWidth = 196 + (302 - 196) * t;
    final double cardHeight = thumbSize + KasySpacing.md * 2;

    return SizedBox(
      height: cardHeight + _ringInset * 2,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: KasySpacing.md,
          vertical: _ringInset,
        ),
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(width: KasySpacing.md),
        itemBuilder: (BuildContext context, int i) => SizedBox(
          width: cardWidth,
          child: _FilterCard(
            category: all[i],
            selected: all[i] == selected,
            thumbSize: thumbSize,
            onTap: () => onSelect(all[i]),
          ),
        ),
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final HomeCategory category;
  final bool selected;
  final double thumbSize;
  final VoidCallback onTap;

  const _FilterCard({
    required this.category,
    required this.selected,
    required this.thumbSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final KasyColors c = context.colors;
    final _CategoryData data = _categories[category]!;

    return KasyCard(
      onTap: onTap,
      semanticLabel: data.title,
      variant: selected ? KasyCardVariant.elevated : KasyCardVariant.filled,
      borderColor: selected ? c.primary : null,
      padding: const EdgeInsets.all(KasySpacing.md),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(KasyRadius.lg),
            child: SizedBox(
              width: thumbSize,
              height: thumbSize,
              child: KasyNetworkImage(url: _thumbUrl(data.thumbnailId)),
            ),
          ),
          const SizedBox(width: KasySpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.kasyTextTheme.cardTitle.copyWith(
                    color: selected ? c.primary : c.onSurface,
                  ),
                ),
                const SizedBox(height: KasySpacing.xs),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.kasyTextTheme.cardSubtitle.copyWith(
                    color: c.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
