import 'package:flutter/material.dart';

class CaroGameScreen extends StatefulWidget {
  const CaroGameScreen({Key? key}) : super(key: key);

  @override
  State<CaroGameScreen> createState() => _CaroGameScreenState();
}

class _CaroGameScreenState extends State<CaroGameScreen> {
  // Kích thước bàn cờ (có thể thay đổi)
  static const int boardSize = 25;

  // Mảng 2 chiều lưu trạng thái bàn cờ
  late List<List<String?>> board;

  // Người chơi hiện tại ('X' hoặc 'O')
  late String currentPlayer;

  // Trạng thái game
  late bool gameOver;
  late String? winner;

  // Lịch sử nước đi để hỗ trợ đi lại
  late List<Move> moveHistory;

  // Hệ số phóng to
  double _zoomLevel = 1.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 2.5;
  final double _zoomStep = 0.1;

  // TransformationController để điều khiển việc phóng to/thu nhỏ và di chuyển
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  // Khởi tạo trò chơi
  void _initializeGame() {
    // Tạo bàn cờ trống
    board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => null),
    );

    // Người chơi X đi trước
    currentPlayer = 'X';

    // Game chưa kết thúc
    gameOver = false;
    winner = null;

    // Xóa lịch sử nước đi
    moveHistory = [];
  }

  // Xử lý khi người chơi đánh vào một ô
  void _makeMove(int row, int col) {
    if (gameOver || board[row][col] != null) {
      return; // Không cho phép đánh vào ô đã có quân hoặc game đã kết thúc
    }

    setState(() {
      // Đánh dấu ô được chọn
      board[row][col] = currentPlayer;

      // Thêm nước đi vào lịch sử
      moveHistory.add(Move(row, col, currentPlayer));

      // Kiểm tra người chơi hiện tại đã chiến thắng chưa
      if (_checkWin(row, col)) {
        gameOver = true;
        winner = currentPlayer;
      } else {
        // Chuyển lượt cho người chơi tiếp theo
        currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
      }
    });
  }

  // Đi lại nước đi trước đó
  void _undoMove() {
    if (moveHistory.isEmpty || gameOver) {
      return; // Không thể đi lại nếu không có nước đi hoặc game đã kết thúc
    }

    setState(() {
      // Lấy nước đi cuối cùng
      Move lastMove = moveHistory.removeLast();

      // Xóa quân cờ trên bàn
      board[lastMove.row][lastMove.col] = null;

      // Chuyển lượt về người chơi trước đó
      currentPlayer = lastMove.player;
    });
  }

  // Kiểm tra chiến thắng
  bool _checkWin(int row, int col) {
    // Số quân liên tiếp cần có để chiến thắng
    const int winCondition = 5;
    final String? player = board[row][col];

    // Các hướng kiểm tra: ngang, dọc, chéo chính, chéo phụ
    final List<List<int>> directions = [
      [0, 1], // Ngang
      [1, 0], // Dọc
      [1, 1], // Chéo chính (\)
      [1, -1], // Chéo phụ (/)
    ];

    for (var direction in directions) {
      int dr = direction[0];
      int dc = direction[1];

      int count = 1; // Đếm số quân liên tiếp (bao gồm quân vừa đặt)
      bool openStart = false; // Đầu mút đầu tiên có mở không
      bool openEnd = false; // Đầu mút thứ hai có mở không

      // Kiểm tra về phía trước
      int r = row - dr;
      int c = col - dc;
      while (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == player) {
        count++;
        r -= dr;
        c -= dc;
      }

      // Kiểm tra nếu đầu mút đầu tiên có mở không
      if (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == null) {
        openStart = true;
      }

      // Kiểm tra về phía sau
      r = row + dr;
      c = col + dc;
      while (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == player) {
        count++;
        r += dr;
        c += dc;
      }

      // Kiểm tra nếu đầu mút thứ hai có mở không
      if (r >= 0 &&
          r < boardSize &&
          c >= 0 &&
          c < boardSize &&
          board[r][c] == null) {
        openEnd = true;
      }

      // Thắng nếu có 5 quân liên tiếp và ít nhất một đầu mút mở
      if (count >= winCondition && (openStart || openEnd)) {
        return true;
      }
    }

    return false;
  }

  // Tăng mức zoom
  void _zoomIn() {
    if (_zoomLevel < _maxZoom) {
      setState(() {
        _zoomLevel += _zoomStep;
        _updateTransformController();
      });
    }
  }

  // Giảm mức zoom
  void _zoomOut() {
    if (_zoomLevel > _minZoom) {
      setState(() {
        _zoomLevel -= _zoomStep;
        _updateTransformController();
      });
    }
  }

  // Reset mức zoom về 100%
  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _transformationController.value = Matrix4.identity();
    });
  }

  // Cập nhật TransformationController theo mức zoom hiện tại
  void _updateTransformController() {
    final Matrix4 matrix =
        Matrix4.identity()..scale(_zoomLevel, _zoomLevel, 1.0);
    _transformationController.value = matrix;
  }

  // Làm mới trò chơi
  void _resetGame() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Caro'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hiển thị thông tin người chơi hiện tại hoặc người chiến thắng
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                gameOver
                    ? 'Người chơi $winner chiến thắng!'
                    : 'Lượt của người chơi $currentPlayer',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color:
                      gameOver
                          ? Colors.green
                          : (currentPlayer == 'X' ? Colors.blue : Colors.red),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Điều khiển zoom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút zoom out
                IconButton(
                  onPressed: _zoomOut,
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Thu nhỏ',
                  color: Colors.deepPurple,
                ),

                // Hiển thị mức zoom hiện tại
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${(_zoomLevel * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),

                // Nút zoom in
                IconButton(
                  onPressed: _zoomIn,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Phóng to',
                  color: Colors.deepPurple,
                ),

                // Nút reset zoom
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.fit_screen),
                  tooltip: 'Khôi phục kích thước',
                  color: Colors.deepPurple,
                ),
              ],
            ),
          ),

          // Bàn cờ có thể zoom và pan
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: _minZoom,
                    maxScale: _maxZoom,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: boardSize,
                        ),
                        itemCount: boardSize * boardSize,
                        itemBuilder: (context, index) {
                          final int row = index ~/ boardSize;
                          final int col = index % boardSize;

                          return GestureDetector(
                            onTap: () => _makeMove(row, col),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                                color:
                                    (row + col) % 2 == 0
                                        ? Colors.grey[50]
                                        : Colors.grey[100],
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child:
                                      board[row][col] != null
                                          ? _buildGamePiece(board[row][col]!)
                                          : const SizedBox(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Các nút điều khiển
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút đi lại
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: moveHistory.isEmpty ? null : _undoMove,
                    icon: const Icon(Icons.undo),
                    label: const Text('Đi lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      disabledBackgroundColor: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Nút làm mới trò chơi
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Chơi lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thông tin luật chơi
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Text(
                'Luật chơi: 5 quân liên tiếp và ít nhất một đầu không bị chặn sẽ thắng',
                style: TextStyle(fontSize: 14, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp lưu thông tin nước đi
class Move {
  final int row;
  final int col;
  final String player;

  Move(this.row, this.col, this.player);
}

// Widget hiển thị quân cờ X hoặc O
Widget _buildGamePiece(String piece) {
  final isX = piece == 'X';
  final color = isX ? Colors.blue : Colors.red;

  // Sử dụng Container để đảm bảo căn giữa
  return Container(
    key: ValueKey(piece),
    width: double.infinity,
    height: double.infinity,
    child: FittedBox(
      fit: BoxFit.contain,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child:
            isX
                ? Icon(Icons.close, color: color)
                : Icon(Icons.circle_outlined, color: color),
      ),
    ),
  );
}

// Helper class for math operations
class Math {
  static int min(int a, int b) {
    return a < b ? a : b;
  }
}
