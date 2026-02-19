import 'dart:math';

class AiPlayer {
  static const _winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  static int chooseMove({
    required List<String> board,
    required List<int> xMoves,
    required List<int> oMoves,
  }) {
    final emptyCells = <int>[];
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') emptyCells.add(i);
    }

    List<String> simBoard(int move) {
      final sim = List<String>.from(board);
      if (xMoves.length == 3) {
        sim[xMoves[0]] = '';
      }
      sim[move] = 'X';
      return sim;
    }

    int? findWinningMove(String mark, List<int> moves) {
      for (final cell in emptyCells) {
        final sim = (mark == 'X') ? simBoard(cell) : List<String>.from(board);
        if (mark == 'O') {
          if (oMoves.length == 3) sim[oMoves[0]] = '';
          sim[cell] = 'O';
        }
        for (final p in _winPatterns) {
          if (sim[p[0]] == mark && sim[p[1]] == mark && sim[p[2]] == mark) {
            return cell;
          }
        }
      }
      return null;
    }

    //to win
    final winMove = findWinningMove('X', xMoves);
    if (winMove != null) return winMove;

    //to block
    final blockMove = findWinningMove('O', oMoves);
    if (blockMove != null) return blockMove;

    //to take center
    if (emptyCells.contains(4)) return 4;

    //to random move
    return emptyCells[Random().nextInt(emptyCells.length)];
  }
}
