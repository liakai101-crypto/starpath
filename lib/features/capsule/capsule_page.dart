import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/starpath_copy.dart';
import '../../core/starpath_style.dart';
import '../orbit/models/friend_planet.dart';
import 'models/capsule_memory.dart';

class CapsulePage extends StatelessWidget {
  const CapsulePage({
    required this.memories,
    required this.planets,
    required this.copy,
    required this.singularityMedalUnlocked,
    super.key,
  });

  final List<CapsuleMemory> memories;
  final List<FriendPlanet> planets;
  final StarPathCopy copy;
  final bool singularityMedalUnlocked;

  @override
  Widget build(BuildContext context) {
    final int unlockedCount = memories
        .where((memory) => memory.unlocked)
        .length;
    final int badgeCount = [
      if (singularityMedalUnlocked) 1,
      if (memories.any((memory) => memory.unlocked)) 1,
      1,
    ].length;

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _CapsuleBackdrop(),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool wide = constraints.maxWidth >= 1040;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          copy: copy,
                          unlockedCount: unlockedCount,
                          totalCount: memories.length,
                          singularityMedalUnlocked: singularityMedalUnlocked,
                        ),
                        const SizedBox(height: 16),
                        _OverviewStrip(
                          copy: copy,
                          unlockedCount: unlockedCount,
                          totalCount: memories.length,
                          singularityMedalUnlocked: singularityMedalUnlocked,
                        ),
                        const SizedBox(height: 16),
                        _GalaxyHero(copy: copy),
                        const SizedBox(height: 16),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionHeader(
                                      title: copy.isZh ? '記憶牆' : 'Memory Wall',
                                      subtitle: copy.isZh
                                          ? '像相簿頁一樣釘住重要記憶，像標本一樣保存。'
                                          : 'Pinned like an album, archived like a specimen.',
                                    ),
                                    const SizedBox(height: 10),
                                    _PinnedGrid(copy: copy, memories: memories),
                                    const SizedBox(height: 16),
                                    _SectionHeader(
                                      title: copy.isZh
                                          ? '相簿檔案庫'
                                          : 'Album Archive',
                                      subtitle: copy.isZh
                                          ? '每位好友都變成可以翻頁瀏覽的檔案。'
                                          : 'Each friend becomes a card you can browse like a page.',
                                    ),
                                    const SizedBox(height: 10),
                                    _AlbumShelf(planets: planets),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 18),
                              SizedBox(
                                width: 360,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ShareSection(
                                      copy: copy,
                                      singularityMedalUnlocked:
                                          singularityMedalUnlocked,
                                      unlockedCount: unlockedCount,
                                    ),
                                    const SizedBox(height: 16),
                                    _SectionHeader(
                                      title: copy.isZh ? '勳章牆' : 'Badge Wall',
                                      subtitle: copy.isZh
                                          ? '像裝框的收藏品一樣展出。'
                                          : 'Displayed like framed keepsakes.',
                                      trailing: _MiniCounter(value: badgeCount),
                                    ),
                                    const SizedBox(height: 10),
                                    _BadgeWall(
                                      copy: copy,
                                      singularityMedalUnlocked:
                                          singularityMedalUnlocked,
                                    ),
                                    const SizedBox(height: 16),
                                    _SectionHeader(
                                      title: copy.isZh ? '時間軸' : 'Timeline',
                                      subtitle: copy.isZh
                                          ? '只保留重要節點，像相片頁上的註記。'
                                          : 'Only the important nodes, like notes on a photo page.',
                                    ),
                                    const SizedBox(height: 10),
                                    _TimelineRail(memories: memories),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _SectionHeader(
                            title: copy.isZh ? '記憶牆' : 'Memory Wall',
                            subtitle: copy.isZh
                                ? '像相簿頁一樣釘住重要記憶，像標本一樣保存。'
                                : 'Pinned like an album, archived like a specimen.',
                          ),
                          const SizedBox(height: 10),
                          _PinnedGrid(copy: copy, memories: memories),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: copy.isZh ? '相簿檔案庫' : 'Album Archive',
                            subtitle: copy.isZh
                                ? '每位好友都變成可以翻頁瀏覽的檔案。'
                                : 'Each friend becomes a card you can browse like a page.',
                          ),
                          const SizedBox(height: 10),
                          _AlbumShelf(planets: planets),
                          const SizedBox(height: 16),
                          _ShareSection(
                            copy: copy,
                            singularityMedalUnlocked: singularityMedalUnlocked,
                            unlockedCount: unlockedCount,
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: copy.isZh ? '勳章牆' : 'Badge Wall',
                            subtitle: copy.isZh
                                ? '像裝框的收藏品一樣展出。'
                                : 'Displayed like framed keepsakes.',
                          ),
                          const SizedBox(height: 10),
                          _BadgeWall(
                            copy: copy,
                            singularityMedalUnlocked: singularityMedalUnlocked,
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(
                            title: copy.isZh ? '時間軸' : 'Timeline',
                            subtitle: copy.isZh
                                ? '只保留重要節點，像相片頁上的註記。'
                                : 'Only the important nodes, like notes on a photo page.',
                          ),
                          const SizedBox(height: 10),
                          _TimelineRail(memories: memories),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.copy,
    required this.unlockedCount,
    required this.totalCount,
    required this.singularityMedalUnlocked,
  });

  final StarPathCopy copy;
  final int unlockedCount;
  final int totalCount;
  final bool singularityMedalUnlocked;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF101326).withValues(alpha: 0.72),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8AE6FF), Color(0xFFB56CFF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9C7CFF).withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.folder_copy_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.isZh ? '膠囊' : 'Capsule',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  copy.isZh ? '一個小小的銀河記憶庫' : 'A small galaxy of memories',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _StatPill(
            label: copy.isZh ? '已解鎖' : 'Unlocked',
            value: '$unlockedCount / $totalCount',
            highlight: const Color(0xFF8EEBFF),
          ),
          const SizedBox(width: 10),
          _StatPill(
            label: copy.isZh ? '奇點' : 'Singularity',
            value: singularityMedalUnlocked
                ? (copy.isZh ? '點亮' : 'Lit')
                : (copy.isZh ? '鎖定' : 'Locked'),
            highlight: singularityMedalUnlocked
                ? const Color(0xFFFFC96B)
                : const Color(0xFFBFA7FF),
          ),
        ],
      ),
    );
  }
}

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({
    required this.copy,
    required this.unlockedCount,
    required this.totalCount,
    required this.singularityMedalUnlocked,
  });

  final StarPathCopy copy;
  final int unlockedCount;
  final int totalCount;
  final bool singularityMedalUnlocked;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF121833).withValues(alpha: 0.68),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: copy.isZh ? '總記憶數' : 'Total memories',
              value: '$totalCount',
              detail: copy.isZh ? '收納在檔案雲中' : 'Stored in the archive cloud',
            ),
          ),
          Expanded(
            child: _MiniStat(
              label: copy.isZh ? '已解鎖' : 'Unlocked',
              value: '$unlockedCount',
              detail: copy.isZh ? '會在星圖中可見' : 'Visible in the star map',
            ),
          ),
          Expanded(
            child: _MiniStat(
              label: copy.isZh ? '奇點核心' : 'Singularity core',
              value: singularityMedalUnlocked ? '1' : '0',
              detail: singularityMedalUnlocked
                  ? (copy.isZh ? '永久點亮' : 'Permanently lit')
                  : (copy.isZh ? '休眠中' : 'Dormant'),
              highlight: singularityMedalUnlocked,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalaxyHero extends StatelessWidget {
  const _GalaxyHero({required this.copy});

  final StarPathCopy copy;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF0C1020).withValues(alpha: 0.70),
      padding: const EdgeInsets.all(0),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _GalaxyHeroPainter())),
            Positioned(
              left: 22,
              top: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    copy.isZh ? '檔案星場' : 'Archive field',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    copy.isZh
                        ? '已解鎖的頁面會發亮，未解鎖的頁面留在暗處。'
                        : 'Unlocked pages glow. Locked pages stay in the dark.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              bottom: 18,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _CosmicChip(
                    label: copy.isZh ? '記憶星座' : 'Constellation of memories',
                  ),
                  _CosmicChip(label: copy.isZh ? '環繞卡片' : 'Orbiting cards'),
                  _CosmicChip(label: copy.isZh ? '深層檔案庫' : 'Deep archive'),
                ],
              ),
            ),
            const Center(child: _GalaxyCore()),
          ],
        ),
      ),
    );
  }
}

class _ShareSection extends StatelessWidget {
  const _ShareSection({
    required this.copy,
    required this.singularityMedalUnlocked,
    required this.unlockedCount,
  });

  final StarPathCopy copy;
  final bool singularityMedalUnlocked;
  final int unlockedCount;

  String get _shareText => [
    copy.isZh ? 'StarPath 膠囊' : 'StarPath Capsule',
    copy.isZh ? '已解鎖記憶：$unlockedCount' : 'Unlocked memories: $unlockedCount',
    copy.isZh
        ? '奇點核心：${singularityMedalUnlocked ? '已解鎖' : '未解鎖'}'
        : 'Singularity core: ${singularityMedalUnlocked ? 'Unlocked' : 'Locked'}',
    copy.isZh ? 'Instagram 個人名片' : 'Instagram Link-in-Bio',
  ].join('\n');

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(copy.isZh ? '已複製到剪貼簿' : 'Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF121935).withValues(alpha: 0.62),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8AE6FF), Color(0xFFB56CFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8AE6FF).withValues(alpha: 0.35),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.ios_share_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.isZh ? '分享卡' : 'Share card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      copy.isZh ? '複製成個人名片' : 'Copy as a profile card',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PreviewCard(shareText: _shareText),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _copy(context, _shareText),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(copy.isZh ? '複製名片' : 'Copy card'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copy(
                    context,
                    copy.isZh ? 'Instagram 個人名片' : 'Instagram Link-in-Bio',
                  ),
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: Text(copy.isZh ? '個人名片' : 'Link-in-Bio'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.shareText});

  final String shareText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E142B).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8AE6FF).withValues(alpha: 0.16),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8AE6FF).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  shareText,
                  style: const TextStyle(
                    color: Colors.white70,
                    height: 1.45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const RadialGradient(
                colors: [Color(0xFFB56CFF), Color(0xFF0E142B)],
              ),
              border: Border.all(
                color: const Color(0xFF8AE6FF).withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.album_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeWall extends StatelessWidget {
  const _BadgeWall({
    required this.copy,
    required this.singularityMedalUnlocked,
  });

  final StarPathCopy copy;
  final bool singularityMedalUnlocked;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF11172E).withValues(alpha: 0.58),
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _Badge(
            label: copy.isZh ? '奇點核心' : 'Singularity Core',
            detail: singularityMedalUnlocked
                ? (copy.isZh ? '永久點亮' : 'Permanently lit')
                : (copy.isZh ? '鎖定' : 'Locked'),
            active: singularityMedalUnlocked,
            featured: true,
          ),
          _Badge(
            label: copy.isZh ? '第一軌跡' : 'First orbit',
            detail: copy.isZh ? '已記錄' : 'Recorded',
            active: true,
          ),
          _Badge(
            label: copy.isZh ? '個人名片' : 'Link-in-Bio',
            detail: copy.isZh ? '可直接分享' : 'Profile ready',
            active: singularityMedalUnlocked,
          ),
        ],
      ),
    );
  }
}

class _PinnedGrid extends StatelessWidget {
  const _PinnedGrid({required this.copy, required this.memories});

  final StarPathCopy copy;
  final List<CapsuleMemory> memories;

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = MediaQuery.sizeOf(context).width >= 1080 ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        final CapsuleMemory memory = memories[index];
        return _PinnedMemoryCard(copy: copy, memory: memory);
      },
    );
  }
}

class _PinnedMemoryCard extends StatelessWidget {
  const _PinnedMemoryCard({required this.copy, required this.memory});

  final StarPathCopy copy;
  final CapsuleMemory memory;

  @override
  Widget build(BuildContext context) {
    final Color accent = memory.color;
    final String caption = memory.unlocked
        ? memory.caption
        : (copy.isZh ? '等待更多引力累積。' : 'Locked until more gravity builds.');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10162A).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: accent.withValues(alpha: 0.24), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.36),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.60),
                      width: 1.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, size: 6, color: Colors.white),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF18213B).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.2, -0.3),
                            radius: 1.0,
                            colors: [
                              accent.withValues(alpha: 0.20),
                              const Color(0xFF18213B),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: accent.withValues(alpha: 0.14),
                            ),
                            child: Center(
                              child: Icon(
                                memory.unlocked
                                    ? Icons.image_rounded
                                    : Icons.lock_rounded,
                                color: memory.unlocked
                                    ? Colors.white
                                    : Colors.white54,
                                size: 34,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            memory.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumShelf extends StatelessWidget {
  const _AlbumShelf({required this.planets});

  final List<FriendPlanet> planets;

  @override
  Widget build(BuildContext context) {
    final List<FriendPlanet> items = planets.take(6).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.sizeOf(context).width >= 1080 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) {
        final FriendPlanet planet = items[index];
        return _AlbumCard(planet: planet);
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.planet});

  final FriendPlanet planet;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172D).withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: planet.color.withValues(alpha: 0.18),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF18213B).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.2, -0.2),
                            radius: 0.95,
                            colors: [
                              planet.color.withValues(alpha: 0.22),
                              const Color(0xFF18213B),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: planet.color.withValues(alpha: 0.22),
                          border: Border.all(
                            color: planet.color.withValues(alpha: 0.34),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            planet.name.isNotEmpty
                                ? planet.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.78),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: planet.color.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              planet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${planet.memoryCount} memories',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.memories});

  final List<CapsuleMemory> memories;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      tint: const Color(0xFF11182E).withValues(alpha: 0.70),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          for (int i = 0; i < memories.length; i++) ...[
            _TimelineRow(memory: memories[i], isLast: i == memories.length - 1),
            if (i != memories.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.memory, required this.isLast});

  final CapsuleMemory memory;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: memory.unlocked ? memory.color : Colors.black26,
                boxShadow: [
                  if (memory.unlocked)
                    BoxShadow(
                      color: memory.color.withValues(alpha: 0.55),
                      blurRadius: 10,
                    ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: Colors.white.withValues(alpha: 0.10),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  memory.unlocked ? memory.caption : 'Locked',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[trailing!],
      ],
    );
  }
}

class _MiniCounter extends StatelessWidget {
  const _MiniCounter({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF8AE6FF).withValues(alpha: 0.14),
        border: Border.all(
          color: const Color(0xFF8AE6FF).withValues(alpha: 0.30),
        ),
      ),
      child: Center(
        child: Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    required this.tint,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final Color tint;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withValues(alpha: 0.86),
                tint.withValues(alpha: 0.72),
                StarPathStyle.backgroundDeep.withValues(alpha: 0.78),
              ],
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final Color highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 122),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: StarPathStyle.surfaceMuted.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: highlight.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: highlight.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight.withValues(alpha: 0.92),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.detail,
    this.highlight = false,
  });

  final String label;
  final String value;
  final String detail;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight
                  ? StarPathStyle.accent
                  : StarPathStyle.textTertiary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(
              color: StarPathStyle.textSecondary,
              fontSize: 11.2,
              height: 1.28,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.detail,
    required this.active,
    this.featured = false,
  });

  final String label;
  final String detail;
  final bool active;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: featured ? 168 : 150,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: active
            ? StarPathStyle.surfaceStrong.withValues(alpha: 0.96)
            : StarPathStyle.surfaceMuted.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active
              ? StarPathStyle.accent.withValues(alpha: 0.30)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          if (active)
            BoxShadow(
              color: StarPathStyle.accent.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (active ? StarPathStyle.surfaceStrong : StarPathStyle.surfaceMuted)
                .withValues(alpha: active ? 0.98 : 0.84),
            StarPathStyle.backgroundDeep.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active ? Icons.auto_awesome : Icons.lock_outline,
            color: active ? StarPathStyle.accent : StarPathStyle.textTertiary,
            size: 20,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(
              color: StarPathStyle.textSecondary,
              fontSize: 11.2,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleBackdrop extends StatelessWidget {
  const _CapsuleBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                StarPathStyle.backgroundDeep,
                StarPathStyle.background,
                StarPathStyle.backgroundDeep,
              ],
            ),
          ),
        ),
        IgnorePointer(child: CustomPaint(painter: _CapsuleOrbitPainter())),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _CapsuleDustPainter()),
          ),
        ),
      ],
    );
  }
}

class _CapsuleOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final Path arc = Path();
    final Rect orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.50, size.height * 0.42),
      width: size.width * 1.15,
      height: size.height * 0.78,
    );
    arc.addOval(orbitRect);
    canvas.save();
    canvas.rotate(-0.05);
    ring.color = const Color(0xFF8AE6FF).withValues(alpha: 0.08);
    canvas.drawPath(arc, ring);
    ring.color = const Color(0xFFB56CFF).withValues(alpha: 0.06);
    canvas.drawPath(arc.shift(const Offset(0, 28)), ring);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CapsuleOrbitPainter oldDelegate) => false;
}

class _CapsuleDustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Random random = Random(6);

    final Paint dot = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 120; i++) {
      final bool bright = i % 4 == 0;
      dot.color = (bright ? const Color(0xFFBEEBFF) : const Color(0xFF7557D8))
          .withValues(alpha: bright ? 0.36 : 0.10);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        bright ? 1.6 : 0.8,
        dot,
      );
    }

    final Paint nebula = Paint()..style = PaintingStyle.fill;
    final List<Offset> centers = <Offset>[
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.68, size.height * 0.72),
    ];
    final List<Color> colors = <Color>[
      const Color(0xFF7B4DFF).withValues(alpha: 0.14),
      const Color(0xFF2DD8FF).withValues(alpha: 0.12),
      const Color(0xFFFF8ACB).withValues(alpha: 0.08),
    ];
    for (int i = 0; i < centers.length; i++) {
      nebula.color = colors[i];
      canvas.drawCircle(centers[i], 80 + i * 36, nebula);
      nebula.color = colors[i].withValues(alpha: 0.045);
      canvas.drawCircle(centers[i] + Offset(20, 18), 120 + i * 44, nebula);
    }
  }

  @override
  bool shouldRepaint(covariant _CapsuleDustPainter oldDelegate) => false;
}

class _GalaxyHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()..style = PaintingStyle.fill;
    glow.color = const Color(0xFF8AE6FF).withValues(alpha: 0.14);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.48), 92, glow);
    glow.color = const Color(0xFFB56CFF).withValues(alpha: 0.14);
    canvas.drawCircle(Offset(size.width * 0.40, size.height * 0.58), 108, glow);
    glow.color = const Color(0xFFFF8ACB).withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.70, size.height * 0.36), 74, glow);

    final Paint stars = Paint()..style = PaintingStyle.fill;
    final Random random = Random(14);
    for (int i = 0; i < 60; i++) {
      final bool bright = i % 5 == 0;
      stars.color = (bright ? const Color(0xFFF5FBFF) : const Color(0xFF8AE6FF))
          .withValues(alpha: bright ? 0.55 : 0.18);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        bright ? 1.8 : 0.9,
        stars,
      );
    }

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF8AE6FF).withValues(alpha: 0.28);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.52),
        width: size.width * 0.34,
        height: size.height * 0.78,
      ),
      -0.7,
      2.1,
      false,
      ring,
    );
    ring.color = const Color(0xFFB56CFF).withValues(alpha: 0.18);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.50),
        width: size.width * 0.52,
        height: size.height * 0.62,
      ),
      0.65,
      2.0,
      false,
      ring,
    );
  }

  @override
  bool shouldRepaint(covariant _GalaxyHeroPainter oldDelegate) => false;
}

class _GalaxyCore extends StatelessWidget {
  const _GalaxyCore();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            const Color(0xFFF9FDFF).withValues(alpha: 0.98),
            const Color(0xFF8AE6FF).withValues(alpha: 0.65),
            const Color(0xFFB56CFF).withValues(alpha: 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.36, 0.68, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8AE6FF).withValues(alpha: 0.30),
            blurRadius: 42,
          ),
          BoxShadow(
            color: const Color(0xFFB56CFF).withValues(alpha: 0.24),
            blurRadius: 58,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 42),
      ),
    );
  }
}

class _CosmicChip extends StatelessWidget {
  const _CosmicChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
