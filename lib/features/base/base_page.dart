import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/starpath_copy.dart';
import '../../core/starpath_style.dart';
import '../orbit/models/friend_planet.dart';
import 'models/relationship_quest.dart';
import 'models/signal_record.dart';

class BasePage extends StatefulWidget {
  const BasePage({
    required this.planets,
    required this.signals,
    required this.aiSuggestion,
    required this.copy,
    required this.formations,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.onAddFormation,
    this.primaryQuestBuilder,
    super.key,
  });

  final List<FriendPlanet> planets;
  final List<SignalRecord> signals;
  final String aiSuggestion;
  final StarPathCopy copy;
  final List<String> formations;
  final String selectedFormation;
  final ValueChanged<String> onFormationChanged;
  final VoidCallback onAddFormation;
  final RelationshipQuest? Function(FriendPlanet planet)? primaryQuestBuilder;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sceneController;
  final TextEditingController _searchController = TextEditingController();
  final Random _random = Random(7);

  Timer? _hubbleTimer;
  String _searchQuery = '';
  int _selectedSignalIndex = 0;
  bool _detailsExpanded = true;
  double _hubbleTargetX = 0.42;
  double _hubbleTargetY = 0.86;
  bool _hubbleFacingRight = true;
  bool _hubblePaused = false;

  @override
  void initState() {
    super.initState();
    _sceneController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _scheduleHubbleWalk(initial: true);
  }

  @override
  void dispose() {
    _hubbleTimer?.cancel();
    _sceneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleHubbleWalk({bool initial = false}) {
    _hubbleTimer?.cancel();
    final int pauseMs = initial ? 300 : 900 + _random.nextInt(1800);
    _hubblePaused = true;
    _hubbleTimer = Timer(Duration(milliseconds: pauseMs), () {
      if (!mounted) {
        return;
      }
      final double nextX = 0.16 + _random.nextDouble() * 0.54;
      final double nextY = 0.82 + _random.nextDouble() * 0.08;
      setState(() {
        _hubbleFacingRight = nextX >= _hubbleTargetX;
        _hubbleTargetX = nextX;
        _hubbleTargetY = nextY;
        _hubblePaused = false;
      });
      _hubbleTimer = Timer(
        Duration(milliseconds: 2200 + _random.nextInt(2600)),
        () {
          if (!mounted) {
            return;
          }
          setState(() {
            _hubblePaused = true;
          });
          _scheduleHubbleWalk();
        },
      );
    });
  }

  List<FriendPlanet> get _filteredPlanets {
    final Iterable<FriendPlanet> base = widget.selectedFormation == 'All'
        ? widget.planets
        : widget.planets.where(
            (planet) => planet.formation == widget.selectedFormation,
          );
    if (_searchQuery.isEmpty) {
      return base.toList();
    }
    final String query = _searchQuery.toLowerCase();
    return base
        .where(
          (planet) =>
              planet.name.toLowerCase().contains(query) ||
              planet.relationshipLabel.toLowerCase().contains(query) ||
              planet.nextAction.toLowerCase().contains(query),
        )
        .toList();
  }

  List<SignalRecord> get _filteredSignals {
    final Iterable<SignalRecord> base = widget.selectedFormation == 'All'
        ? widget.signals
        : widget.signals.where((signal) {
            final FriendPlanet? planet = _planetFor(signal.friendName);
            return planet == null ||
                planet.formation == widget.selectedFormation;
          });
    if (_searchQuery.isEmpty) {
      return base.toList();
    }
    final String query = _searchQuery.toLowerCase();
    return base
        .where(
          (signal) =>
              signal.title.toLowerCase().contains(query) ||
              signal.summary.toLowerCase().contains(query) ||
              signal.friendName.toLowerCase().contains(query),
        )
        .toList();
  }

  SignalRecord? get _selectedSignal {
    final List<SignalRecord> signals = _filteredSignals;
    if (signals.isEmpty) {
      return null;
    }
    final int safeIndex = _selectedSignalIndex.clamp(0, signals.length - 1);
    return signals[safeIndex];
  }

  FriendPlanet? _planetFor(String friendName) {
    for (final FriendPlanet planet in widget.planets) {
      if (planet.name == friendName || planet.name.contains(friendName)) {
        return planet;
      }
    }
    return null;
  }

  String _statusLine(FriendPlanet? planet) {
    if (planet == null) {
      return widget.copy.waitingForGravity;
    }
    return planet.unlocked
        ? (widget.copy.isZh
              ? '雙向引力穩定，適合往下推進。'
              : 'Mutual gravity is stable. Good moment to move deeper.')
        : (widget.copy.isZh
              ? '仍在建立引力視窗，先保持低壓互動。'
              : 'Still building the gravity window. Keep the interaction light.');
  }

  String _baseLead() {
    return widget.copy.isZh
        ? '基地艙現在優先處理真正在發生的聯繫，不再把注意力分散在大量控制項。'
        : 'Base now prioritizes live social context instead of spreading attention across control surfaces.';
  }

  @override
  Widget build(BuildContext context) {
    final List<SignalRecord> signals = _filteredSignals;
    final List<FriendPlanet> planets = _filteredPlanets;
    final SignalRecord? selectedSignal = _selectedSignal;
    final FriendPlanet? selectedPlanet = selectedSignal == null
        ? (planets.isEmpty ? null : planets.first)
        : _planetFor(selectedSignal.friendName);
    final RelationshipQuest? activeQuest = selectedPlanet == null
        ? null
        : widget.primaryQuestBuilder?.call(selectedPlanet);

    return Scaffold(
      backgroundColor: StarPathStyle.backgroundDeep,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _sceneController,
          builder: (context, child) {
            return Stack(
              children: [
                const Positioned.fill(child: _BaseBackdrop()),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _AmbientOverlayPainter(
                      progress: _sceneController.value,
                      accent: selectedPlanet?.color ?? Colors.cyanAccent,
                    ),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool compact = constraints.maxWidth < 1100;
                    return Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          SizedBox(
                            width: compact ? 328 : 360,
                            child: _LeftConversationRail(
                              copy: widget.copy,
                              searchController: _searchController,
                              searchHint: widget.copy.isZh
                                  ? '\u641c\u5c0b\u597d\u53cb\u3001\u8a0a\u865f\u6216\u4e0b\u4e00\u6b65'
                                  : 'Search friends, signals, or next actions',
                              formations: widget.formations,
                              selectedFormation: widget.selectedFormation,
                              onFormationChanged: widget.onFormationChanged,
                              onAddFormation: widget.onAddFormation,
                              onSearchChanged: (value) {
                                setState(() {
                                  _searchQuery = value.trim();
                                  _selectedSignalIndex = 0;
                                });
                              },
                              signals: signals,
                              selectedIndex: _selectedSignalIndex.clamp(
                                0,
                                max(signals.length - 1, 0),
                              ),
                              onSelectSignal: (index) {
                                setState(() {
                                  _selectedSignalIndex = index;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _CenterConversationStage(
                              copy: widget.copy,
                              progress: _sceneController.value,
                              selectedSignal: selectedSignal,
                              selectedPlanet: selectedPlanet,
                              aiSuggestion: widget.aiSuggestion,
                              lead: _baseLead(),
                              statusLine: _statusLine(selectedPlanet),
                              hubblePaused: _hubblePaused,
                              hubbleFacingRight: _hubbleFacingRight,
                              hubbleTargetX: _hubbleTargetX,
                              hubbleTargetY: _hubbleTargetY,
                            ),
                          ),
                          const SizedBox(width: 18),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            width: _detailsExpanded
                                ? (compact ? 250 : 300)
                                : 56,
                            child: _RightDetailsWall(
                              copy: widget.copy,
                              expanded: _detailsExpanded,
                              onToggle: () {
                                setState(() {
                                  _detailsExpanded = !_detailsExpanded;
                                });
                              },
                              signal: selectedSignal,
                              planet: selectedPlanet,
                              activeQuest: activeQuest,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LeftConversationRail extends StatelessWidget {
  const _LeftConversationRail({
    required this.copy,
    required this.searchController,
    required this.searchHint,
    required this.formations,
    required this.selectedFormation,
    required this.onFormationChanged,
    required this.onAddFormation,
    required this.onSearchChanged,
    required this.signals,
    required this.selectedIndex,
    required this.onSelectSignal,
  });

  final StarPathCopy copy;
  final TextEditingController searchController;
  final String searchHint;
  final List<String> formations;
  final String selectedFormation;
  final ValueChanged<String> onFormationChanged;
  final VoidCallback onAddFormation;
  final ValueChanged<String> onSearchChanged;
  final List<SignalRecord> signals;
  final int selectedIndex;
  final ValueChanged<int> onSelectSignal;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.24),
                  ),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 22,
                  color: Colors.cyanAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.base,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      copy.relationshipWorkbench,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleIconButton(
                icon: Icons.add,
                tooltip: copy.addFormation,
                onTap: onAddFormation,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SearchField(
            controller: searchController,
            hintText: searchHint,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: formations.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == formations.length) {
                  return _FormationChip(
                    label: '+',
                    selected: false,
                    onTap: onAddFormation,
                  );
                }
                final formation = formations[index];
                return _FormationChip(
                  label: formation == 'All'
                      ? copy.allBands
                      : copy.formation(formation),
                  selected: formation == selectedFormation,
                  onTap: () => onFormationChanged(formation),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.radar_rounded,
                  color: Colors.cyanAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  copy.isZh ? '\u8a0a\u865f\u5217\u8868' : 'Signal list',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${signals.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: signals.isEmpty
                ? Center(
                    child: Text(
                      copy.noNewSignals,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: signals.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final signal = signals[index];
                      return _SignalListTile(
                        signal: signal,
                        selected: index == selectedIndex,
                        onTap: () => onSelectSignal(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CenterConversationStage extends StatelessWidget {
  const _CenterConversationStage({
    required this.copy,
    required this.progress,
    required this.selectedSignal,
    required this.selectedPlanet,
    required this.aiSuggestion,
    required this.lead,
    required this.statusLine,
    required this.hubblePaused,
    required this.hubbleFacingRight,
    required this.hubbleTargetX,
    required this.hubbleTargetY,
  });

  final StarPathCopy copy;
  final double progress;
  final SignalRecord? selectedSignal;
  final FriendPlanet? selectedPlanet;
  final String aiSuggestion;
  final String lead;
  final String statusLine;
  final bool hubblePaused;
  final bool hubbleFacingRight;
  final double hubbleTargetX;
  final double hubbleTargetY;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/base/hangar_background.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.26),
                    Colors.black.withValues(alpha: 0.56),
                  ],
                ),
              ),
            ),
            CustomPaint(
              painter: _CenterStagePainter(
                progress: progress,
                accent: selectedPlanet?.color ?? Colors.cyanAccent,
              ),
            ),
            Positioned(
              left: 22,
              top: 18,
              right: 22,
              child: Row(
                children: [
                  _SceneBadge(
                    title: copy.isZh
                        ? '\u8a3a\u65b7\u76e3\u6e2c'
                        : 'Diagnostics',
                    subtitle: copy.isZh ? '\u5f85\u547d' : 'Standby',
                  ),
                  const Spacer(),
                  _SceneBadge(
                    title: copy.isZh
                        ? '\u8a18\u61b6\u9023\u7dda'
                        : 'Memory link',
                    subtitle: copy.isZh ? '\u53ef\u4ea4\u4e92' : 'Interactive',
                    alignEnd: true,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MessageFocusCard(
                    copy: copy,
                    signal: selectedSignal,
                    planet: selectedPlanet,
                    lead: lead,
                    statusLine: statusLine,
                    aiSuggestion: aiSuggestion,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    copy.isZh
                        ? '\u57fa\u5730\u76ee\u524d\u5c08\u6ce8\u65bc\u7576\u524d\u9078\u4e2d\u7684\u95dc\u4fc2\uff0c\u5176\u4ed6\u8cc7\u8a0a\u90fd\u9000\u5230\u5074\u908a\u5f85\u547d\u3002'
                        : 'Base now foregrounds the active relationship. Everything else steps back into the wall.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeInOutCubic,
              left: hubbleTargetX * 1000,
              top: hubbleTargetY * 560,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(
                  hubbleFacingRight ? 1.0 : -1.0,
                  1.0,
                  1.0,
                ),
                child: SizedBox(
                  width: 142,
                  height: 118,
                  child: CustomPaint(
                    painter: _HubbleWalkerPainter(
                      progress: progress,
                      walking: !hubblePaused,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RightDetailsWall extends StatelessWidget {
  const _RightDetailsWall({
    required this.copy,
    required this.expanded,
    required this.onToggle,
    required this.signal,
    required this.planet,
    required this.activeQuest,
  });

  final StarPathCopy copy;
  final bool expanded;
  final VoidCallback onToggle;
  final SignalRecord? signal;
  final FriendPlanet? planet;
  final RelationshipQuest? activeQuest;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        copy.relationshipWorkbench,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _CircleIconButton(
                      icon: Icons.chevron_right,
                      tooltip: copy.isZh
                          ? '\u6536\u5408\u9762\u677f'
                          : 'Collapse panel',
                      onTap: onToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DetailBlock(
                  title: copy.focusFriend,
                  body: planet?.name ?? copy.noFriendSelected,
                ),
                const SizedBox(height: 10),
                _DetailBlock(
                  title: copy.linkStatus,
                  body: planet == null
                      ? copy.waitingForGravity
                      : planet!.unlocked
                      ? copy.unlocked
                      : copy.locked,
                ),
                const SizedBox(height: 10),
                _DetailBlock(
                  title: copy.recentUpdate,
                  body: signal?.summary ?? copy.waitingForGravity,
                ),
                if (activeQuest != null) ...[
                  const SizedBox(height: 10),
                  _QuestDetailBlock(quest: activeQuest!),
                ],
                const SizedBox(height: 14),
                Text(
                  copy.icebreakerSignal,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (signal != null)
                  _SelectedSignalSummary(signal: signal!)
                else
                  Text(
                    copy.noNewSignals,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                const Spacer(),
                _StatusLampBar(accent: planet?.color ?? Colors.cyanAccent),
              ],
            )
          : Center(
              child: Column(
                children: [
                  _CircleIconButton(
                    icon: Icons.chevron_left,
                    tooltip: copy.isZh
                        ? '\u5c55\u958b\u9762\u677f'
                        : 'Expand panel',
                    onTap: onToggle,
                  ),
                  const SizedBox(height: 18),
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      copy.isZh ? '\u901a\u8a0a\u7246' : 'Console',
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: planet?.color ?? Colors.cyanAccent,
                      boxShadow: [
                        BoxShadow(
                          color: (planet?.color ?? Colors.cyanAccent)
                              .withValues(alpha: 0.50),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _QuestDetailBlock extends StatelessWidget {
  const _QuestDetailBlock({required this.quest});

  final RelationshipQuest quest;

  @override
  Widget build(BuildContext context) {
    final String progressLabel =
        '${quest.currentValue.toStringAsFixed(2)} / ${quest.targetValue.toStringAsFixed(2)}';
    return Container(
      key: const ValueKey('active-quest-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StarPathStyle.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: StarPathStyle.accent.withValues(alpha: 0.20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StarPathStyle.surfaceRaised.withValues(alpha: 0.92),
            StarPathStyle.surfaceMuted.withValues(alpha: 0.72),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active quest',
            style: TextStyle(
              color: StarPathStyle.textSecondary.withValues(alpha: 0.82),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quest.title,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quest.description,
            style: const TextStyle(
              color: StarPathStyle.textSecondary,
              fontSize: 11.8,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: quest.progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(
              StarPathStyle.accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressLabel,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageFocusCard extends StatelessWidget {
  const _MessageFocusCard({
    required this.copy,
    required this.signal,
    required this.planet,
    required this.lead,
    required this.statusLine,
    required this.aiSuggestion,
  });

  final StarPathCopy copy;
  final SignalRecord? signal;
  final FriendPlanet? planet;
  final String lead;
  final String statusLine;
  final String aiSuggestion;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (planet?.color ?? Colors.cyanAccent).withValues(
                        alpha: 0.14,
                      ),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          copy.yourMessages,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          planet?.name ?? copy.noFriendSelected,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                lead,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                signal?.summary ?? copy.privateMessages,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ThinPill(label: statusLine),
                  if (planet != null)
                    _ThinPill(
                      label:
                          '${copy.formation(planet!.formation)} / ${(planet!.energy * 100).round()}%',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                aiSuggestion,
                style: TextStyle(
                  color: Colors.cyanAccent.withValues(alpha: 0.92),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedSignalSummary extends StatelessWidget {
  const _SelectedSignalSummary({required this.signal});

  final SignalRecord signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: signal.color.withValues(alpha: 0.10),
        border: Border.all(color: signal.color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: signal.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  signal.friendName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${signal.energyDelta >= 0 ? '+' : ''}${signal.energyDelta.round()}%',
                style: TextStyle(
                  color: signal.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            signal.summary,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalListTile extends StatelessWidget {
  const _SignalListTile({
    required this.signal,
    required this.selected,
    required this.onTap,
  });

  final SignalRecord signal;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? signal.color.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected
                ? signal.color.withValues(alpha: 0.26)
                : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: signal.color.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: signal.color,
                boxShadow: [
                  BoxShadow(
                    color: signal.color.withValues(alpha: 0.46),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    signal.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.66),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '${signal.energyDelta >= 0 ? '+' : ''}${signal.energyDelta.round()}%',
              style: TextStyle(
                color: signal.color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BaseBackdrop extends StatelessWidget {
  const _BaseBackdrop();

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
              colors: [Color(0xFF01040A), Color(0xFF07111F), Color(0xFF02050A)],
            ),
          ),
        ),
        Opacity(
          opacity: 0.18,
          child: Image.asset(
            'assets/base/hangar_background.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ],
    );
  }
}

class _AmbientOverlayPainter extends CustomPainter {
  const _AmbientOverlayPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: 0.12),
              accent.withValues(alpha: 0.04),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.55, size.height * 0.30),
              width: size.width * 0.72,
              height: size.height * 0.52,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.30),
        width: size.width * 0.72,
        height: size.height * 0.52,
      ),
      glow,
    );

    final Paint sweep = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(
              size.width * (0.08 + progress * 0.54),
              size.height * 0.08,
              size.width * 0.05,
              size.height * 0.84,
            ),
          );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * (0.08 + progress * 0.54),
        size.height * 0.08,
        size.width * 0.05,
        size.height * 0.84,
      ),
      sweep,
    );

    final Paint dust = Paint()..style = PaintingStyle.fill;
    final Random random = Random(17);
    for (int i = 0; i < 50; i++) {
      dust.color = (i.isEven ? Colors.cyanAccent : Colors.white).withValues(
        alpha: 0.04 + (i % 4) * 0.01,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        i % 5 == 0 ? 1.4 : 0.8,
        dust,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _CenterStagePainter extends CustomPainter {
  const _CenterStagePainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint halo = Paint()
      ..shader =
          RadialGradient(
            colors: [
              accent.withValues(alpha: 0.14),
              const Color(0xFF1A1A35).withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.52, size.height * 0.48),
              width: size.width * 0.56,
              height: size.height * 0.26,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.48),
        width: size.width * 0.56,
        height: size.height * 0.26,
      ),
      halo,
    );

    final Paint guide = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final Path beam = Path()
      ..moveTo(size.width * 0.08, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * (0.62 + sin(progress * pi * 2) * 0.01),
        size.width * 0.92,
        size.height * 0.70,
      );
    canvas.drawPath(beam, guide);
  }

  @override
  bool shouldRepaint(covariant _CenterStagePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: StarPathStyle.glassPanel(
            radius: 30,
            tint: StarPathStyle.surface,
            opacity: 0.88,
            borderOpacity: 0.14,
            blur: 28,
            shadowOffset: const Offset(0, 20),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _SceneBadge extends StatelessWidget {
  const _SceneBadge({
    required this.title,
    required this.subtitle,
    this.alignEnd = false,
  });

  final String title;
  final String subtitle;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: StarPathStyle.surfaceMuted.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                StarPathStyle.surfaceRaised.withValues(alpha: 0.78),
                StarPathStyle.surfaceMuted.withValues(alpha: 0.58),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: alignEnd
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: StarPathStyle.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLampBar extends StatelessWidget {
  const _StatusLampBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.28),
                  Colors.white.withValues(alpha: 0.18),
                  StarPathStyle.accentSoft.withValues(alpha: 0.20),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        for (final color in [
          Colors.cyanAccent,
          Colors.greenAccent,
          Colors.white54,
        ])
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.42), blurRadius: 10),
              ],
            ),
          ),
      ],
    );
  }
}

class _ThinPill extends StatelessWidget {
  const _ThinPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StarPathStyle.surfaceMuted.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            StarPathStyle.surfaceRaised.withValues(alpha: 0.90),
            StarPathStyle.surfaceMuted.withValues(alpha: 0.66),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: StarPathStyle.textSecondary.withValues(alpha: 0.82),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              color: StarPathStyle.textPrimary,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        color: StarPathStyle.textPrimary,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: StarPathStyle.textTertiary),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: StarPathStyle.accent,
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 48),
        filled: true,
        fillColor: StarPathStyle.surfaceMuted.withValues(alpha: 0.84),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: StarPathStyle.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: StarPathStyle.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: StarPathStyle.accent.withValues(alpha: 0.40),
          ),
        ),
      ),
    );
  }
}

class _FormationChip extends StatelessWidget {
  const _FormationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? StarPathStyle.accent.withValues(alpha: 0.16)
              : StarPathStyle.surfaceMuted.withValues(alpha: 0.74),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? StarPathStyle.accent.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: StarPathStyle.accent.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? StarPathStyle.accent
                : StarPathStyle.textSecondary,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: StarPathStyle.surfaceMuted.withValues(alpha: 0.80),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, size: 18, color: StarPathStyle.accent),
        ),
      ),
    );
  }
}

class _HubbleWalkerPainter extends CustomPainter {
  const _HubbleWalkerPainter({required this.progress, required this.walking});

  final double progress;
  final bool walking;

  @override
  void paint(Canvas canvas, Size size) {
    final double legPhase = progress * pi * 48;
    final double stride = walking ? sin(legPhase) : 0;
    final double counterStride = walking ? sin(legPhase + pi) : 0;
    final double headBob = walking ? cos(legPhase * 2) * 1.6 : 0;
    final double tailSwing = walking ? sin(legPhase * 1.2) * 0.34 : 0.06;

    final Offset bodyCenter = Offset(size.width * 0.46, size.height * 0.52);
    final Rect bodyRect = Rect.fromCenter(
      center: bodyCenter,
      width: size.width * 0.50,
      height: size.height * 0.34,
    );
    final Rect neckRect = Rect.fromCenter(
      center: Offset(size.width * 0.60, size.height * 0.43 + headBob * 0.12),
      width: size.width * 0.12,
      height: size.height * 0.14,
    );
    final Rect headRect = Rect.fromCenter(
      center: Offset(size.width * 0.70, size.height * 0.35 + headBob * 0.22),
      width: size.width * 0.22,
      height: size.height * 0.18,
    );

    final Paint shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.92),
        width: size.width * 0.34,
        height: size.height * 0.08,
      ),
      shadow,
    );

    void drawLeg({
      required double x,
      required double frontOffset,
      required bool front,
    }) {
      final double step = (front ? stride : counterStride) * frontOffset;
      final Paint legPaint = Paint()
        ..color = const Color(0xFFF5EFE7)
        ..strokeWidth = size.width * 0.036
        ..strokeCap = StrokeCap.round;
      final Paint furPaint = Paint()
        ..color = const Color(0xFFC97A3D)
        ..strokeWidth = size.width * 0.040
        ..strokeCap = StrokeCap.round;

      final Offset top = Offset(x, size.height * 0.63);
      final Offset knee = Offset(x + step * 5, size.height * 0.77);
      final Offset paw = Offset(x - step * 3, size.height * 0.91);
      canvas.drawLine(top, knee, furPaint);
      canvas.drawLine(knee, paw, legPaint);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(paw.dx + size.width * 0.008, paw.dy),
          width: size.width * 0.07,
          height: size.height * 0.03,
        ),
        Paint()..color = const Color(0xFFF8F4ED),
      );
    }

    drawLeg(x: size.width * 0.32, frontOffset: 1, front: false);
    drawLeg(x: size.width * 0.44, frontOffset: -1, front: true);
    drawLeg(x: size.width * 0.58, frontOffset: 1, front: true);
    drawLeg(x: size.width * 0.70, frontOffset: -1, front: false);

    final Paint bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFE2A25C), Color(0xFFC87639), Color(0xFFA85E30)],
      ).createShader(bodyRect);
    canvas.drawOval(bodyRect, bodyPaint);

    final Paint bellyPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFFDF9F3), Color(0xFFF2E8D9)],
          ).createShader(
            Rect.fromCenter(
              center: Offset(size.width * 0.52, size.height * 0.60),
              width: size.width * 0.22,
              height: size.height * 0.24,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.52, size.height * 0.60),
        width: size.width * 0.24,
        height: size.height * 0.25,
      ),
      bellyPaint,
    );

    final Paint backPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.30, size.height * 0.42)
        ..quadraticBezierTo(
          size.width * 0.47,
          size.height * 0.30,
          size.width * 0.66,
          size.height * 0.40,
        )
        ..quadraticBezierTo(
          size.width * 0.48,
          size.height * 0.37,
          size.width * 0.30,
          size.height * 0.42,
        )
        ..close(),
      backPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(neckRect, Radius.circular(size.width * 0.035)),
      Paint()..color = const Color(0xFF7B8896),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        neckRect.deflate(size.width * 0.008),
        Radius.circular(size.width * 0.028),
      ),
      Paint()..color = const Color(0xFF2A3744),
    );

    final Path tail = Path()
      ..moveTo(size.width * 0.18, size.height * 0.46)
      ..quadraticBezierTo(
        size.width * 0.07,
        size.height * (0.34 + tailSwing * 0.08),
        size.width * 0.14,
        size.height * (0.22 + tailSwing * 0.10),
      );
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0xFFE09A59)
        ..strokeWidth = size.width * 0.05
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      tail,
      Paint()
        ..color = const Color(0xFFF7F1E8)
        ..strokeWidth = size.width * 0.018
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final Paint headPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0xFFE6A25D), Color(0xFFD17A3D)],
      ).createShader(headRect);
    canvas.drawOval(headRect, headPaint);

    final Path muzzle = Path()
      ..moveTo(size.width * 0.70, size.height * 0.37 + headBob * 0.22)
      ..quadraticBezierTo(
        size.width * 0.81,
        size.height * 0.40 + headBob * 0.22,
        size.width * 0.80,
        size.height * 0.49 + headBob * 0.20,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.52 + headBob * 0.18,
        size.width * 0.62,
        size.height * 0.47 + headBob * 0.18,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.39 + headBob * 0.20,
        size.width * 0.70,
        size.height * 0.37 + headBob * 0.22,
      )
      ..close();
    canvas.drawPath(muzzle, Paint()..color = const Color(0xFFFDF9F3));

    final Path earFront = Path()
      ..moveTo(size.width * 0.69, size.height * 0.22 + headBob * 0.24)
      ..quadraticBezierTo(
        size.width * 0.71,
        size.height * 0.08 + headBob * 0.16,
        size.width * 0.76,
        size.height * 0.19 + headBob * 0.20,
      )
      ..close();
    final Path earBack = Path()
      ..moveTo(size.width * 0.58, size.height * 0.24 + headBob * 0.24)
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.12 + headBob * 0.18,
        size.width * 0.64,
        size.height * 0.21 + headBob * 0.18,
      )
      ..close();
    canvas.drawPath(earBack, Paint()..color = const Color(0xFFC8773C));
    canvas.drawPath(earFront, Paint()..color = const Color(0xFFC8773C));
    canvas.drawPath(
      earBack,
      Paint()..color = const Color(0xFFF6C0B2).withValues(alpha: 0.75),
    );
    canvas.drawPath(
      earFront,
      Paint()..color = const Color(0xFFF6C0B2).withValues(alpha: 0.75),
    );

    canvas.drawCircle(
      Offset(size.width * 0.73, size.height * 0.40 + headBob * 0.22),
      size.width * 0.012,
      Paint()..color = const Color(0xFF161616),
    );
    canvas.drawCircle(
      Offset(size.width * 0.79, size.height * 0.44 + headBob * 0.22),
      size.width * 0.014,
      Paint()..color = const Color(0xFF161616),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.83, size.height * 0.45 + headBob * 0.20)
        ..quadraticBezierTo(
          size.width * 0.86,
          size.height * 0.48 + headBob * 0.20,
          size.width * 0.83,
          size.height * 0.50 + headBob * 0.18,
        )
        ..quadraticBezierTo(
          size.width * 0.79,
          size.height * 0.48 + headBob * 0.20,
          size.width * 0.83,
          size.height * 0.45 + headBob * 0.20,
        )
        ..close(),
      Paint()..color = const Color(0xFF1D1D1D),
    );

    final Rect helmet = Rect.fromCenter(
      center: Offset(size.width * 0.69, size.height * 0.34 + headBob * 0.18),
      width: size.width * 0.27,
      height: size.height * 0.28,
    );
    canvas.drawOval(
      helmet,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.35),
          colors: [
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(helmet),
    );
    canvas.drawOval(
      helmet,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..color = const Color(0xFFDDE7EE).withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(covariant _HubbleWalkerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.walking != walking;
  }
}
