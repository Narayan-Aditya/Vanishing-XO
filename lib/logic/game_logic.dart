import 'ai_player.dart';

class GameState {
  bool ohTurn = true;
  bool soloMode = false;

  List<String> displayExoh = List.filled(9, '');
  List<int> oMoves = [];
  List<int> xMoves = [];

  int ohScore = 0;
  int exScore = 0;

  bool canTap(int index) {
    if (displayExoh[index] != '') return false;
    if (soloMode && !ohTurn) return false;
    return true;
  }

  bool isOldestMark(int index) {
    if (ohTurn &&
        displayExoh[index] == 'O' &&
        oMoves.length == 3 &&
        oMoves[0] == index) {
      return true;
    }
    if (!ohTurn &&
        displayExoh[index] == 'X' &&
        xMoves.length == 3 &&
        xMoves[0] == index) {
      return true;
    }
    return false;
  }

  double markOpacity(int index) {
    final moves = displayExoh[index] == 'O'
        ? oMoves
        : displayExoh[index] == 'X'
        ? xMoves
        : null;
    if (moves == null || moves.length < 3) return 1.0;
    if (moves[0] == index) return 0.3;
    if (moves[1] == index) return 0.7;
    return 1.0;
  }

  void placeMark(int index) {
    if (ohTurn) {
      if (oMoves.length == 3) {
        displayExoh[oMoves.removeAt(0)] = '';
      }
      displayExoh[index] = 'O';
      oMoves.add(index);
      ohTurn = false;
    } else {
      if (xMoves.length == 3) {
        displayExoh[xMoves.removeAt(0)] = '';
      }
      displayExoh[index] = 'X';
      xMoves.add(index);
      ohTurn = true;
    }
  }

  String? checkWinner() {
    const winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (final pattern in winPatterns) {
      if (displayExoh[pattern[0]] != '' &&
          displayExoh[pattern[0]] == displayExoh[pattern[1]] &&
          displayExoh[pattern[0]] == displayExoh[pattern[2]]) {
        return displayExoh[pattern[0]];
      }
    }
    return null;
  }

  void recordWin(String winner) {
    if (winner == 'O') {
      ohScore++;
    } else {
      exScore++;
    }
  }

  void clearBoard() {
    displayExoh = List.filled(9, '');
    oMoves.clear();
    xMoves.clear();
  }

  void resetAll() {
    ohScore = 0;
    exScore = 0;
    clearBoard();
    ohTurn = true;
  }

  void toggleSoloMode(bool value) {
    soloMode = value;
    clearBoard();
    ohScore = 0;
    exScore = 0;
    ohTurn = true;
  }

  void aiMove() {
    final hasEmpty = displayExoh.any((c) => c == '');
    if (!hasEmpty) return;

    final move = AiPlayer.chooseMove(
      board: displayExoh,
      xMoves: xMoves,
      oMoves: oMoves,
    );
    placeMark(move);
  }
}
