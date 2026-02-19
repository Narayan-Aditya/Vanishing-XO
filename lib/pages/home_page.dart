import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logic/game_logic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GameState _game = GameState();
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setOrientation();
    });
  }

  void _setOrientation() {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide >= 600) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vanishing XO"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => _game.resetAll()),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Scores',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return _buildWideLayout(constraints, colorScheme);
            } else {
              return _buildNarrowLayout(constraints, colorScheme);
            }
          },
        ),
      ),
    );
  }

  Widget _buildNarrowLayout(
    BoxConstraints constraints,
    ColorScheme colorScheme,
  ) {
    final gridSize = constraints.maxWidth - 32;
    final fontSize = (gridSize / 7).clamp(28.0, 56.0);
    final scoreFontSize = (constraints.maxWidth / 16).clamp(18.0, 28.0);

    return Column(
      children: [
        const SizedBox(height: 12),
        _buildScoreboard(colorScheme, scoreFontSize),
        const SizedBox(height: 8),
        _buildTurnIndicator(colorScheme, scoreFontSize * 0.75),
        const SizedBox(height: 12),
        _buildGrid(gridSize, fontSize, colorScheme),
        const Spacer(),
        _buildBottomControls(colorScheme),
      ],
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints, ColorScheme colorScheme) {
    final gridSize = (constraints.maxHeight * 0.75).clamp(200.0, 500.0);
    final fontSize = (gridSize / 7).clamp(28.0, 56.0);
    final scoreFontSize = (constraints.maxWidth / 30).clamp(18.0, 30.0);

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreboard(colorScheme, scoreFontSize),
                const SizedBox(height: 16),
                _buildTurnIndicator(colorScheme, scoreFontSize * 0.75),
                const SizedBox(height: 24),
                _buildBottomControls(colorScheme),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildGrid(gridSize, fontSize, colorScheme),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreboard(ColorScheme colorScheme, double fontSize) {
    final scoreStyle = TextStyle(
      color: colorScheme.onSurface,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreCard(
          _game.soloMode ? "You" : "Player O",
          _game.ohScore,
          scoreStyle,
          _game.ohTurn,
          colorScheme,
        ),
        SizedBox(width: fontSize),
        _buildScoreCard(
          _game.soloMode ? "AI" : "Player X",
          _game.exScore,
          scoreStyle,
          !_game.ohTurn,
          colorScheme,
        ),
      ],
    );
  }

  Widget _buildTurnIndicator(ColorScheme colorScheme, double fontSize) {
    return Text(
      _game.ohTurn
          ? (_game.soloMode ? "Your Turn" : "O's Turn")
          : (_game.soloMode ? "AI Thinking..." : "X's Turn"),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildGrid(double size, double fontSize, ColorScheme colorScheme) {
    return SizedBox(
      width: size,
      height: size,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          final markOpacity = _game.markOpacity(index);
          final isOldest = _game.isOldestMark(index);
          return GestureDetector(
            onTap: () => _tapped(index),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: markOpacity,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _game.displayExoh[index],
                      style: TextStyle(
                        color: _game.displayExoh[index] == 'O'
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (isOldest)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: FadeTransition(
                        opacity: _blinkController,
                        child: Container(
                          width: fontSize * 0.18,
                          height: fontSize * 0.18,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _game.soloMode ? Icons.smart_toy : Icons.people,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              _game.soloMode ? 'Solo' : 'With Friend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: _game.soloMode,
              onChanged: (value) {
                setState(() => _game.toggleSoloMode(value));
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: _showHowToPlay,
          icon: const Icon(Icons.help_outline),
          label: const Text('How to Play'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScoreCard(
    String label,
    int score,
    TextStyle style,
    bool isActive,
    ColorScheme colorScheme,
  ) {
    final labelSize = style.fontSize! * 0.55;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: style.fontSize! * 0.7,
        vertical: style.fontSize! * 0.4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? colorScheme.surfaceContainerHighest
            : Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(score.toString(), style: style),
        ],
      ),
    );
  }

  void _tapped(int index) {
    if (!_game.canTap(index)) return;

    setState(() => _game.placeMark(index));

    if (_handleWinCheck()) return;

    if (_game.soloMode && !_game.ohTurn) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() => _game.aiMove());
        _handleWinCheck();
      });
    }
  }

  bool _handleWinCheck() {
    final winner = _game.checkWinner();
    if (winner != null) {
      setState(() => _game.recordWin(winner));
      _showWinDialog(winner);
      return true;
    }
    return false;
  }

  void _showWinDialog(String winner) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Winner is [ $winner ] \u{1F38A}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _game.clearBoard());
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _showHowToPlay() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.onSurface),
              const SizedBox(width: 8),
              const Text('How to Play'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Goal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Get 3 of your marks in a row (horizontal, vertical, or diagonal) to win.',
                ),
                SizedBox(height: 16),
                Text(
                  'Vanishing Rule',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Each player can only have 3 marks on the board at a time. When you place your 4th mark, your oldest mark vanishes.',
                ),
                SizedBox(height: 16),
                Text(
                  'Visual Hints',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('\u2022 Your oldest mark appears faded (30% opacity)'),
                Text(
                  '\u2022 Your second oldest mark is slightly faded (70% opacity)',
                ),
                Text(
                  '\u2022 A blinking red dot marks the one that will vanish next',
                ),
                SizedBox(height: 16),
                Text(
                  'Game Modes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  '\u2022 With Friend \u2014 two players take turns on the same device',
                ),
                Text('\u2022 Solo \u2014 play against an offline AI opponent'),
                SizedBox(height: 16),
                Text(
                  'Controls',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text('\u2022 Tap an empty cell to place your mark'),
                Text(
                  '\u2022 Use the switch at the bottom to toggle Solo / Friend mode',
                ),
                Text('\u2022 Tap the refresh icon to reset scores'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }
}
