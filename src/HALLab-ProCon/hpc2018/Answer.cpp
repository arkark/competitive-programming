/*            _____                   _______                  _______                   _____                    _____                    _____
 *           /\    \                 /::\    \                /::\    \                 /\    \                  /\    \                  /\    \
 *          /::\    \               /::::\    \              /::::\    \               /::\____\                /::\    \                /::\    \
 *         /::::\    \             /::::::\    \            /::::::\    \             /:::/    /                \:::\    \              /::::\    \
 *        /::::::\    \           /::::::::\    \          /::::::::\    \           /:::/    /                  \:::\    \            /::::::\    \
 *       /:::/\:::\    \         /:::/~~\:::\    \        /:::/~~\:::\    \         /:::/    /                    \:::\    \          /:::/\:::\    \
 *      /:::/  \:::\    \       /:::/    \:::\    \      /:::/    \:::\    \       /:::/____/                      \:::\    \        /:::/__\:::\    \
 *     /:::/    \:::\    \     /:::/    / \:::\    \    /:::/    / \:::\    \     /::::\    \                      /::::\    \      /::::\   \:::\    \
 *    /:::/    / \:::\    \   /:::/____/   \:::\____\  /:::/____/   \:::\____\   /::::::\____\________    ____    /::::::\    \    /::::::\   \:::\    \
 *   /:::/    /   \:::\    \ |:::|    |     |:::|    ||:::|    |     |:::|    | /:::/\:::::::::::\    \  /\   \  /:::/\:::\    \  /:::/\:::\   \:::\    \
 *  /:::/____/     \:::\____\|:::|____|     |:::|    ||:::|____|     |:::|    |/:::/  |:::::::::::\____\/::\   \/:::/  \:::\____\/:::/__\:::\   \:::\____\
 *  \:::\    \      \::/    / \:::\    \   /:::/    /  \:::\    \   /:::/    / \::/   |::|~~~|~~~~~     \:::\  /:::/    \::/    /\:::\   \:::\   \::/    /
 *   \:::\    \      \/____/   \:::\    \ /:::/    /    \:::\    \ /:::/    /   \/____|::|   |           \:::\/:::/    / \/____/  \:::\   \:::\   \/____/
 *    \:::\    \                \:::\    /:::/    /      \:::\    /:::/    /          |::|   |            \::::::/    /            \:::\   \:::\    \
 *     \:::\    \                \:::\__/:::/    /        \:::\__/:::/    /           |::|   |             \::::/____/              \:::\   \:::\____\
 *      \:::\    \                \::::::::/    /          \::::::::/    /            |::|   |              \:::\    \               \:::\   \::/    /
 *       \:::\    \                \::::::/    /            \::::::/    /             |::|   |               \:::\    \               \:::\   \/____/
 *        \:::\    \                \::::/    /              \::::/    /              |::|   |                \:::\    \               \:::\    \
 *         \:::\____\                \::/____/                \::/____/               \::|   |                 \:::\____\               \:::\____\
 *          \::/    /                 ~~                       ~~                      \:|   |                  \::/    /                \::/    /
 *           \/____/                                                                    \|___|                   \/____/                  \/___*/


#include "Answer.hpp"

#include <vector>
#include <array>
#include <algorithm>
#include <numeric>
#include <limits>
#include <functional>
#include <bitset>
#include <cstring>

// 便利なものたち

#define REP(i, n) for(int (i)=0; (i) < static_cast<int>(n); (i)++)
#define FOR(i, l, r) for(int (i)=static_cast<int>(l); (i) < static_cast<int>(r); (i)++)
#define FOR_R(i, l, r) for(int (i)=static_cast<int>((r)-1); (i) >= static_cast<int>(l); (i)--)
#define ALL(xs) (xs).begin(), (xs).end()

// E.g. DUMP("%d, %d", x, y)
//   $ ./hpc2018.exe -j > output.json
//   を実行してもコンソールに出力されるように標準エラー出力をする
#ifdef LOCAL
  #define DUMP(fmt, ...) \
    std::fprintf(stderr, "[%s:%u] " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__)
#else
  #define DUMP(fmt, ...)
#endif

// E.g. ASSERT(i < n, "%d", i)
#ifdef LOCAL
  #define ASSERT(aExp, fmt, ...) \
    HPC_ASSERT_MSG(aExp, "[%s:%u] Assertion Failed: " fmt, __FILE__, __LINE__, ##__VA_ARGS__)
#else
  #define ASSERT(aExp, fmt, ...)
#endif

//==============================================================================
namespace hpc {

// レーンに置かれているクッキーの数
constexpr int NUM = Parameter::CandidatePieceCount;
// オーブンの横幅=縦幅
constexpr int SIZE = Parameter::OvenWidth;
// 1ステージあたりのターンの総数
constexpr int TURN_LIMIT = Parameter::GameTurnLimit;
// めっちゃ大きい値
constexpr int INF = std::numeric_limits<int>::max();
// めっちゃ小さい値
constexpr float EPS = 1e-6;
// 大きいクッキーの計算のためのマジックナンバー
constexpr int LARGE_T = 5;
// 小さいクッキーの計算のためのマジックナンバー
constexpr int SMALL_T = 1;

// 乱数の初期化
const RandomSeed gSeed(0xfae9037c, 0x3998e156, 0x6eedd717, 0x3f7bd530);
Random gRandom(gSeed);

bool nearlyEqual(float x, float y) {
  return std::abs(x-y) < EPS;
}

// 現在のターン数 (0-based)
int gNowTurn;
// 大きいクッキーの計算の探索空間の大きさに関与する値
int gLargePermMaxDepth;  // 探索の大きさ：_{NUM}P_{gLargePermMaxDepth}
// 小さいクッキーの計算の探索空間の大きさに関与する値
int gSmallPermMaxDepth;  // 探索の大きさ：_{NUM}P_{gSmallPermMaxDepth}

//==============================================================================

/*
  traverse関数群
    - とりあえず量産したので、すべて使用しているわけではない
 */

// {0, ... , SIZE*SIZE} -> Piece -> Vector2i
using Traverse = std::function<Vector2i(int index, const Piece& piece)>;

//  0, 1, 2,...
// 20,21,22,...
// 30,31,32,...
// ...
inline Vector2i traverseYoko1(int index, const Piece& piece) {
  return Vector2i(index%SIZE, index/SIZE);
}

// ...
// 30,31,32,...
// 20,21,22,...
//  0, 1, 2,...
inline Vector2i traverseYoko2(int index, const Piece& piece) {
  return Vector2i(index%SIZE, SIZE - index/SIZE - piece.height());
}

// ..., 2, 1, 0
// ...,22,21,20
// ...,32,31,30
//          ...
inline Vector2i traverseYoko3(int index, const Piece& piece) {
  return Vector2i(SIZE - index%SIZE - piece.width(), index/SIZE);
}

//          ...
// ...,32,31,30
// ...,22,21,20
// ..., 2, 1, 0
inline Vector2i traverseYoko4(int index, const Piece& piece) {
  return Vector2i(SIZE - index%SIZE - piece.width(), SIZE - index/SIZE - piece.height());
}

//  0, 1, 2,...
// 40,41,42,...
// 80,81,82,...
// ...
//          ...
// ...,62,61,60
// ...,62,61,60
// ...,22,21,20
inline Vector2i traverseYoko5(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseYoko1(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseYoko4(index, piece);
  }
}

inline Vector2i traverseYoko6(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseYoko4(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseYoko1(index, piece);
  }
}

inline Vector2i traverseYoko7(int index, const Piece& piece) {
  if (index%2 == 0) {
    return traverseYoko1(index/2, piece);
  } else {
    return traverseYoko2(index/2, piece);
  }
}

// 00,20,40,...
// 01,21,41,...
// 02,22,42,...
// ...
inline Vector2i traverseTate1(int index, const Piece& piece) {
  return Vector2i(index/SIZE, index%SIZE);
}

// ...,40,20,00
// ...,41,21,01
// ...,42,22,02
//          ...
inline Vector2i traverseTate2(int index, const Piece& piece) {
  return Vector2i(SIZE - index/SIZE - piece.width(), index%SIZE);
}

// ...
// 02,22,42,...
// 01,21,41,...
// 00,20,40,...
inline Vector2i traverseTate3(int index, const Piece& piece) {
  return Vector2i(index/SIZE, SIZE - index%SIZE - piece.height());
}

//          ...
// ...,42,22,02
// ...,41,21,01
// ...,40,20,00
inline Vector2i traverseTate4(int index, const Piece& piece) {
  return Vector2i(SIZE - index/SIZE - piece.width(), SIZE - index%SIZE - piece.height());
}

// 00,40,60,...
// 01,41,61,...
// 02,42,62,...
// ...
//          ...
// ...,82,62,22
// ...,81,61,21
// ...,80,60,20
inline Vector2i traverseTate5(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseTate1(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseTate4(index, piece);
  }
}

inline Vector2i traverseTate6(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseTate4(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseTate1(index, piece);
  }
}

inline Vector2i traverseTate7(int index, const Piece& piece) {
  if (index%2 == 0) {
    return traverseTate1(index/2, piece);
  } else {
    return traverseTate2(index/2, piece);
  }
}

// 00,01,03,...
// 02,04,07,...
// 05,08,12,...
// ...
inline Vector2i traverseNaname1(int index, const Piece& piece) {
  static bool isFirst = true;
  static std::array<Vector2i, SIZE*SIZE> vectors;
  if (isFirst) {
    isFirst = false;
    int topX = 0;
    int x = 0;
    int y = 0;
    REP(i, SIZE*SIZE) {
      if (x < 0) {
        x = ++topX;
        y = 0;
      }
      if (x >= SIZE) {
        y += x - (SIZE-1);
        x = SIZE-1;
      }
      vectors[i] = Vector2i(x, y);
      x--;
      y++;
    }
  }
  return vectors[index];
}

//          ...
// ...,12,08,05
// ...,07,04,02
// ...,03,01,00
inline Vector2i traverseNaname2(int index, const Piece& piece) {
  static bool isFirst = true;
  static std::array<Vector2i, SIZE*SIZE> vectors;
  if (isFirst) {
    isFirst = false;
    int bottomX = SIZE-1;
    int x = SIZE-1;
    int y = SIZE-1;
    REP(i, SIZE*SIZE) {
      if (x >= SIZE) {
        x = --bottomX;
        y = SIZE-1;
      }
      if (x < 0) {
        y -= -x;
        x = 0;
      }
      vectors[i] = Vector2i(x, y);
      x++;
      y--;
    }
  }
  const auto& p = vectors[index];
  return Vector2i(p.x - piece.width() + 1, p.y - piece.height() + 1);
}

// 00,02,05,...
// 01,04,08,...
// 03,07,12,...
// ...
inline Vector2i traverseNaname3(int index, const Piece& piece) {
  static bool isFirst = true;
  static std::array<Vector2i, SIZE*SIZE> vectors;
  if (isFirst) {
    isFirst = false;
    int leftY = 0;
    int x = 0;
    int y = 0;
    REP(i, SIZE*SIZE) {
      if (y < 0) {
        x = 0;
        y = ++leftY;
      }
      if (y >= SIZE) {
        x += y - (SIZE-1);
        y = SIZE-1;
      }
      vectors[i] = Vector2i(x, y);
      x++;
      y--;
    }
  }
  return vectors[index];
}

//          ...
// ...,12,07,03
// ...,08,04,01
// ...,05,02,00
inline Vector2i traverseNaname4(int index, const Piece& piece) {
  static bool isFirst = true;
  static std::array<Vector2i, SIZE*SIZE> vectors;
  if (isFirst) {
    isFirst = false;
    int rightY = SIZE-1;
    int x = SIZE-1;
    int y = SIZE-1;
    REP(i, SIZE*SIZE) {
      if (y >= SIZE) {
        x = SIZE-1;
        y = --rightY;
      }
      if (y < 0) {
        x -= -y;
        y = 0;
      }
      vectors[i] = Vector2i(x, y);
      x--;
      y++;
    }
  }
  const auto& p = vectors[index];
  return Vector2i(p.x - piece.width() + 1, p.y - piece.height() + 1);
}

inline Vector2i traverseNaname5(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseNaname1(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseNaname2(index, piece);
  }
}

inline Vector2i traverseNaname6(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseNaname2(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseNaname1(index, piece);
  }
}

inline Vector2i traverseNaname7(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseNaname3(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseNaname4(index, piece);
  }
}

inline Vector2i traverseNaname8(int index, const Piece& piece) {
  if (index/SIZE%2 == 0) {
    index -= index/(2*SIZE)*SIZE;
    return traverseNaname4(index, piece);
  } else {
    index -= index/(2*SIZE)*SIZE + SIZE;
    return traverseNaname3(index, piece);
  }
}

inline Vector2i traverseGuruguru(int index, const Piece& piece) {
  static bool isFirst = true;
  static std::array<Vector2i, SIZE*SIZE> vectors;
  static std::array<int, SIZE> visited;
  if (isFirst) {
    isFirst = false;
    int dx[] = {1, 0, -1, 0};
    int dy[] = {0, 1, 0, -1};
    int x = 0;
    int y = 0;
    int k = 0;
    REP(i, SIZE*SIZE) {
      if (x<0 || x>=SIZE || y<0 || y>=SIZE || (visited[x]>>y&1)) {
        x -= dx[k];
        y -= dy[k];
        k = (k + 1)%4;
        x += dx[k];
        y += dy[k];
      }
      vectors[i] = Vector2i(x, y);
      visited[x] |= 1<<y;
      x += dx[k];
      y += dy[k];
    }
  }
  const auto& p = vectors[index];
  // return Vector2i(p.x - piece.width() + 1, p.y - piece.height() + 1);
  return Vector2i(std::min(SIZE-piece.width(), p.x), std::min(SIZE-piece.height(), p.y));
}

//==============================================================================

/*
  クッキーの配置状態を保持し、配置するための各関数をもったクラス
   - SIZE*SIZEの2次元の時系列として考えるのではなく、SIZE*SIZE*TURN_LIMITの3次元とみなして考える
 */

class Tower {

private:

  // turn -> x -> y -> isPlaced?
  int data[TURN_LIMIT][SIZE];  // bit format

  // x -> y -> maxTurn
  //  - maxTurn := (x, y, _)で置かれたマスのうち最大ターン+1
  //  - 高速化用
  int maxTurnGrid[SIZE][SIZE];

  // 置かれたマスのうち最大ターン
  //  - 高速化用
  int maxChangedTurn = 0;

  inline bool _isPlaced(const int x, const int y, const int turn) const {
    ASSERT(turn>=0 && turn<TURN_LIMIT, "turn: %d", turn);
    ASSERT(x>=0 && x<SIZE, "x: %d", x);
    ASSERT(y>=0 && y<SIZE, "y: %d", y);
    return data[turn][x]>>y&1;
  }

  inline bool _isPlacedWithBits(const int x, const int bitsY, const int turn) const {
    ASSERT(turn>=0 && turn<TURN_LIMIT, "turn: %d", turn);
    ASSERT(x>=0 && x<SIZE, "x: %d", x);
    return data[turn][x] & bitsY;
  }

  inline void _placeWithBits(const int x, const int bitsY, const int turn) {
    ASSERT(turn>=0 && turn<TURN_LIMIT, "turn: %d", turn);
    ASSERT(x>=0 && x<SIZE, "x: %d", x);
    ASSERT(!_isPlacedWithBits(x, bitsY, turn), "");
    data[turn][x] |= bitsY;
  }

public:
  // 初期化
  void clear() {
    std::memset(data, 0, sizeof(data));
    std::memset(maxTurnGrid, 0, sizeof(maxTurnGrid));
  }

  // pieceを gNowTurn+diffTurn ターンにposに挿入することが可能か？
  bool canInsertPiece(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    ASSERT(diffTurn >= 0, "");
    if (pos.x<0 || pos.x + piece.width()>SIZE) return false;
    if (pos.y<0 || pos.y + piece.height()>SIZE) return false;
    int minTurn = gNowTurn + diffTurn;
    int maxTurn = gNowTurn + diffTurn + piece.requiredHeatTurnCount();
    if (minTurn<0 || maxTurn>=TURN_LIMIT) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    FOR(turn, minTurn, std::min(maxTurn, maxChangedTurn) + 1) {
      FOR(x, pos.x, pos.x + piece.width()) {
        if (_isPlacedWithBits(x, bitsY, turn)) return false;
      }
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x-diffLeft, pos.y) に挿入することが可能か？
  //   @require: ∀x, pos.x-diffLeft < x ≦ pos.x ⇒ canInsertPiece(piece, (x, pos.y), diffTurn)
  bool canInsertPieceLeft(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffLeft) const {
    ASSERT(diffLeft >= 0, "");
    int minTurn = gNowTurn + diffTurn;
    int maxTurn = gNowTurn + diffTurn + piece.requiredHeatTurnCount();
    if (pos.x - diffLeft < 0) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    FOR(turn, minTurn, std::min(maxTurn, maxChangedTurn) + 1) {
      if (_isPlacedWithBits(pos.x - diffLeft, bitsY, turn)) return false;
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x+diffRight, pos.y) に挿入することが可能か？
  //   @require: ∀x, pos.x ≦ x < pos.x + diffRight ⇒ canInsertPiece(piece, (x, pos.y), diffTurn)
  bool canInsertPieceRight(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffRight) const {
    ASSERT(diffRight >= 0, "");
    int minTurn = gNowTurn + diffTurn;
    int maxTurn = gNowTurn + diffTurn + piece.requiredHeatTurnCount();
    if (pos.x + piece.width() - 1 + diffRight >= SIZE) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    FOR(turn, minTurn, std::min(maxTurn, maxChangedTurn) + 1) {
      if (_isPlacedWithBits(pos.x + piece.width() - 1 + diffRight, bitsY, turn)) return false;
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x, pos.y-diffUp) に挿入することが可能か？
  //   @require: ∀y, pos.y-diffUp < y ≦ pos.y ⇒ canInsertPiece(piece, (pos.x, y), diffTurn)
  bool canInsertPieceUp(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffUp) const {
    ASSERT(diffUp >= 0, "");
    int minTurn = gNowTurn + diffTurn;
    int maxTurn = gNowTurn + diffTurn + piece.requiredHeatTurnCount();
    if (pos.y - diffUp < 0) return false;
    FOR(turn, minTurn, std::min(maxTurn, maxChangedTurn) + 1) {
      FOR(x, pos.x, pos.x + piece.width()) {
        if (_isPlaced(x, pos.y-diffUp, turn)) return false;
      }
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x, pos.y+diffDown) に挿入することが可能か？
  //   @require: ∀y, pos.y ≦ y < pos.y + diffUp ⇒ canInsertPiece(piece, (pos.x, y), diffTurn)
  bool canInsertPieceDown(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffDown) const {
    ASSERT(diffDown >= 0, "");
    int minTurn = gNowTurn + diffTurn;
    int maxTurn = gNowTurn + diffTurn + piece.requiredHeatTurnCount();
    if (pos.y + piece.height() - 1 + diffDown >= SIZE) return false;
    FOR(turn, minTurn, std::min(maxTurn, maxChangedTurn) + 1) {
      FOR(x, pos.x, pos.x + piece.width()) {
        if (_isPlaced(x, pos.y + piece.height() - 1 + diffDown, turn)) return false;
      }
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに挿入できる最も左の位置へposを平行移動する
  Vector2i moveMostInsertLeft(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffLeft = 0;
    if (
      canInsertPieceLeft(piece, pos, diffTurn, 1) &&
      canInsertPieceRight(piece, pos, diffTurn, 1)
    ) {
      do {
        diffLeft++;
      } while (canInsertPieceLeft(piece, pos, 0, diffLeft + 1));
    }
    return Vector2i(pos.x - diffLeft, pos.y);
  }

  // pieceを gNowTurn+diffTurn ターンに挿入できる最も右の位置へposを平行移動する
  Vector2i moveMostInsertRight(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffRight = 0;
    if (
      canInsertPieceLeft(piece, pos, diffTurn, 1) &&
      canInsertPieceRight(piece, pos, diffTurn, 1)
    ) {
      do {
        diffRight++;
      } while (canInsertPieceRight(piece, pos, 0, diffRight + 1));
    }
    return Vector2i(pos.x + diffRight, pos.y);
  }

  // pieceを gNowTurn+diffTurn ターンに挿入できる最も上の位置へposを平行移動する
  Vector2i moveMostInsertUp(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffUp = 0;
    if (
      canInsertPieceUp(piece, pos, diffTurn, 1) &&
      canInsertPieceDown(piece, pos, diffTurn, 1)
    ) {
      do {
        diffUp++;
      } while (canInsertPieceUp(piece, pos, 0, diffUp + 1));
    }
    return Vector2i(pos.x, pos.y - diffUp);
  }

  // pieceを gNowTurn+diffTurn ターンに挿入できる最も下の位置へposを平行移動する
  Vector2i moveMostInsertDown(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffDown = 0;
    if (
      canInsertPieceUp(piece, pos, diffTurn, 1) &&
      canInsertPieceDown(piece, pos, diffTurn, 1)
    ) {
      do {
        diffDown++;
      } while (canInsertPieceDown(piece, pos, 0, diffDown + 1));
    }
    return Vector2i(pos.x, pos.y + diffDown);
  }

  // pieceを gNowTurn+diffTurn ターンにposに積むことが可能か？
  //   - 高速化のため turn > gNowTurn+diffTurn を満たすturnについてはチェックしない
  bool canStackPiece(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    ASSERT(diffTurn >= 0, "");
    int turn = gNowTurn + diffTurn;
    if (turn < 0 || turn + piece.requiredHeatTurnCount() >= TURN_LIMIT) return false;
    if (pos.x < 0 || pos.x + piece.width() > SIZE) return false;
    if (pos.y < 0 || pos.y + piece.height() > SIZE) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    FOR(x, pos.x, pos.x + piece.width()) {
      if (_isPlacedWithBits(x, bitsY, turn)) return false;
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x-diffLeft, pos.y) に積むことが可能か？
  //   @require: ∀x, pos.x-diffLeft < x ≦ pos.x ⇒ canInsertPiece(piece, (x, pos.y), diffTurn)
  bool canStackPieceLeft(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffLeft) const {
    ASSERT(diffLeft >= 0, "");
    int turn = gNowTurn + diffTurn;
    if (pos.x - diffLeft < 0) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    if (_isPlacedWithBits(pos.x - diffLeft, bitsY, turn)) return false;
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x+diffRight, pos.y) に積むことが可能か？
  //   @require: ∀x, pos.x ≦ x < pos.x + diffRight ⇒ canInsertPiece(piece, (x, pos.y), diffTurn)
  bool canStackPieceRight(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffRight) const {
    ASSERT(diffRight >= 0, "");
    int turn = gNowTurn + diffTurn;
    if (pos.x + piece.width() - 1 + diffRight >= SIZE) return false;
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    if (_isPlacedWithBits(pos.x + piece.width() - 1 + diffRight, bitsY, turn)) return false;
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x, pos.y-diffUp) に積むことが可能か？
  //   @require: ∀y, pos.y-diffUp < y ≦ pos.y ⇒ canInsertPiece(piece, (pos.x, y), diffTurn)
  bool canStackPieceUp(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffUp) const {
    ASSERT(diffUp >= 0, "");
    int turn = gNowTurn + diffTurn;
    if (pos.y - diffUp < 0) return false;
    FOR(x, pos.x, pos.x + piece.width()) {
      if (_isPlaced(x, pos.y-diffUp, turn)) return false;
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに (pos.x, pos.y+diffDown) に積むことが可能か？
  //   @require: ∀y, pos.y ≦ y < pos.y + diffUp ⇒ canInsertPiece(piece, (pos.x, y), diffTurn)
  bool canStackPieceDown(const Piece& piece, const Vector2i& pos, const int diffTurn, const int diffDown) const {
    ASSERT(diffDown >= 0, "");
    int turn = gNowTurn + diffTurn;
    if (pos.y + piece.height() - 1 + diffDown >= SIZE) return false;
    FOR(x, pos.x, pos.x + piece.width()) {
      if (_isPlaced(x, pos.y + piece.height() - 1 + diffDown, turn)) return false;
    }
    return true;
  }

  // pieceを gNowTurn+diffTurn ターンに積むことができる最も左の位置へposを平行移動する
  Vector2i moveMostStackLeft(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffLeft = 0;
    if (
      canStackPieceLeft(piece, pos, diffTurn, 1) &&
      canStackPieceRight(piece, pos, diffTurn, 1)
    ) {
      do {
        diffLeft++;
      } while (canStackPieceLeft(piece, pos, 0, diffLeft + 1));
    }
    return Vector2i(pos.x - diffLeft, pos.y);
  }

  // pieceを gNowTurn+diffTurn ターンに積むことができる最も右の位置へposを平行移動する
  Vector2i moveMostStackRight(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffRight = 0;
    if (
      canStackPieceLeft(piece, pos, diffTurn, 1) &&
      canStackPieceRight(piece, pos, diffTurn, 1)
    ) {
      do {
        diffRight++;
      } while (canStackPieceRight(piece, pos, 0, diffRight + 1));
    }
    return Vector2i(pos.x + diffRight, pos.y);
  }

  // pieceを gNowTurn+diffTurn ターンに積むことができる最も上の位置へposを平行移動する
  Vector2i moveMostStackUp(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffUp = 0;
    if (
      canStackPieceUp(piece, pos, diffTurn, 1) &&
      canStackPieceDown(piece, pos, diffTurn, 1)
    ) {
      do {
        diffUp++;
      } while (canStackPieceUp(piece, pos, 0, diffUp + 1));
    }
    return Vector2i(pos.x, pos.y - diffUp);
  }

  // pieceを gNowTurn+diffTurn ターンに積むことができる最も下の位置へposを平行移動する
  Vector2i moveMostStackDown(const Piece& piece, const Vector2i& pos, const int diffTurn) const {
    int diffDown = 0;
    if (
      canStackPieceUp(piece, pos, diffTurn, 1) &&
      canStackPieceDown(piece, pos, diffTurn, 1)
    ) {
      do {
        diffDown++;
      } while (canStackPieceDown(piece, pos, 0, diffDown + 1));
    }
    return Vector2i(pos.x, pos.y + diffDown);
  }

  // pieceを gNowTurn+diffTurn ターンにposに置く
  void putPiece(const Piece& piece, const Vector2i& pos, const int diffTurn) {
    ASSERT(diffTurn >= 0, "");
    ASSERT(pos.x>=0 || pos.x+piece.width()<=SIZE, "");
    ASSERT(pos.y>=0 || pos.y+piece.height()<=SIZE, "");
    int bits1 = (1<<(pos.y + piece.height())) - 1;
    int bits2 = (1<<pos.y) - 1;
    int bitsY = bits1 ^ bits2;
    FOR(turn, gNowTurn + diffTurn, gNowTurn + diffTurn + piece.requiredHeatTurnCount() + 1) {
      maxChangedTurn = std::max(maxChangedTurn, turn);
      FOR(x, pos.x, pos.x + piece.width()) {
        _placeWithBits(x, bitsY, turn);
      }
    }
    FOR(x, pos.x, pos.x + piece.width()) {
      FOR(y, pos.y, pos.y + piece.height()) {
        maxTurnGrid[x][y] = std::max(
          maxTurnGrid[x][y],
          gNowTurn + diffTurn + piece.requiredHeatTurnCount() + 1
        );
      }
    }
  }

  // gNowTurn+diffTurn ターンにどこかに置けるpieceが存在するか？
  bool existsPieceToPut(const CandidatePieces& pieces, const int diffTurn) const {
    for(const auto& piece : pieces) {
      REP(x, SIZE-piece.width() + 1) REP(y, SIZE-piece.height() + 1) {
        if (canInsertPiece(piece, Vector2i(x, y), diffTurn)) return true;
      }
    }
    return false;
  }

  // piece を gNowTurn+diffTurn ターンにputtedPos に配置することを考えたときに どれだけ"良い"かを point ∈ [0, 4] で返す
  //   4 が最もよく、0 が最も悪い
  float getPointToPut(const Piece& piece, const Vector2i& puttedPos, const int diffTurn) const {
    int turn = gNowTurn + diffTurn + piece.requiredHeatTurnCount() + 1;
    int x = puttedPos.x;
    int y = puttedPos.y;
    if (x<0 || x+piece.width()>SIZE) return false;
    if (y<0 || y+piece.height()>SIZE) return false;

    bool left = true;
    bool right = true;
    bool up = true;
    bool down = true;

    for(int j=0; j<piece.height() && left; j++) {
      left &= x==0 || turn <= maxTurnGrid[x-1][y+j];
    }
    for(int j=0; j<piece.height() && right; j++) {
      right &= x+piece.width()==SIZE || turn <= maxTurnGrid[x+piece.width()][y+j];
    }
    for(int j=0; j<piece.width() && up; j++) {
      up &= y==0 || turn <= maxTurnGrid[x+j][y-1];
    }
    for(int j=0; j<piece.width() && down; j++) {
      down &= y+piece.height()==SIZE || turn <= maxTurnGrid[x+j][y+piece.height()];
    }
    int point =
      static_cast<int>(left) +
      static_cast<int>(right) +
      static_cast<int>(up) +
      static_cast<int>(down);
    if (point==2) {
      if (left && right && piece.height() < 2) return 1.5;
      if (up && down && piece.width() < 2) return 1.5;
      if (left != right) return 1.5;
    }
    return point + EPS;
  }

  // gNowTurn+diffTurn ターン+α にpieceを積める場所が存在するか？
  bool canStackPieceAnywhere(const Piece& piece, const int diffTurn) const {
    REP(t, LARGE_T) {
      if (gNowTurn + diffTurn + t + piece.requiredHeatTurnCount() >= TURN_LIMIT) break;
      REP(x, SIZE-piece.width()+1) REP(y, SIZE-piece.height()+1) {
        if (canStackPiece(piece, Vector2i(x, y), diffTurn + t)) {
          return true;
        }
      }
    }
    return false;
  }

  struct StackPiecesResult {
    float sumScore = 0;
    int firstPieceIndex = -1;
    Vector2i firstPiecePos;
    int firstDiffTurn = -1;
    int lastDiffTurn = -1;
    int puttedCount = 0;
  };

  // for large cookies
  inline void stackPieces(
    const CandidatePieces& pieces,
    const std::vector<int>& indices,
    const Traverse& traverse,
    StackPiecesResult& result
  ) {
    ASSERT(static_cast<int>(indices.size()) == gLargePermMaxDepth, "");
    static std::array<int, SIZE> visited;
    result.sumScore = 0;
    result.puttedCount = 0;
    int diffTurn = 0;
    int largeT = LARGE_T;
    for(const int index : indices) {
      const Piece& piece = pieces[index];
      REP(t, largeT) {
        if (gNowTurn + diffTurn + t + piece.requiredHeatTurnCount() >= TURN_LIMIT) break;
        std::memset(visited.data(), 0, SIZE*sizeof(int));
        REP(i, SIZE*SIZE) {
          const auto& p = traverse(i, piece);
          int x = p.x;
          int y = p.y;
          if (x < 0 || y < 0) continue;
          if (x + piece.width() > SIZE || y + piece.height() > SIZE) continue;
          if (gNowTurn + diffTurn + t < maxTurnGrid[x][y]) continue;
          if (visited[x]>>y&1) continue;
          visited[x] |= 1<<y;
          if (canStackPiece(piece, p, diffTurn + t)) {
            putPiece(piece, p, diffTurn + t);
            if (result.sumScore == 0) {
              result.firstPieceIndex = index;
              result.firstPiecePos = Vector2i(x, y);
              result.firstDiffTurn = diffTurn + t;
            }
            // result.lastDiffTurn = std::max(result.lastDiffTurn, diffTurn + t + piece.requiredHeatTurnCount() + 1);
            result.lastDiffTurn = diffTurn + t + piece.requiredHeatTurnCount() + 1;
            result.sumScore += piece.score() / static_cast<float>(piece.requiredHeatTurnCount()) / static_cast<float>(piece.requiredHeatTurnCount());
            result.puttedCount++;
            diffTurn += t + 1;
            largeT = std::max(1, largeT - 1);
            goto NEXT_PIECE;
          }
        }
      }
      return;
    NEXT_PIECE:
      continue;
    }
  }

  inline void stackPieces(
    const CandidatePieces& pieces,
    const std::vector<int>& indices,
    const Traverse& traverse
  ) {
    StackPiecesResult result;
    stackPieces(pieces, indices, traverse, result);
  }

  // gNowTurn+diffTurn ターン+α にpieceを挿入できる場所が存在するか？
  bool canInsertPieceAnywhere(const Piece& piece, const int diffTurn) const {
    REP(t, SMALL_T) {
      if (gNowTurn + diffTurn + t + piece.requiredHeatTurnCount() >= TURN_LIMIT) break;
      REP(x, SIZE-piece.width()+1) REP(y, SIZE-piece.height()+1) {
        if (canInsertPiece(piece, Vector2i(x, y), diffTurn + t)) {
          return true;
        }
      }
    }
    return false;
  }

  struct InsertPiecesResult {
    int sumScore = 0;
    int firstPieceIndex = -1;
    Vector2i firstPiecePos;
    int firstDiffTurn = -1;
    int lastDiffTurn = -1;
    int puttedCount = 0;
  };

  // for small cookies
  inline void insertPieces(
    const CandidatePieces& pieces,
    const std::vector<int>& indices,
    const Traverse& traverse,
    const int diffTurnLimit,
    InsertPiecesResult& result
  ) {
    ASSERT(static_cast<int>(indices.size()) == gSmallPermMaxDepth, "");
    // static std::array<int, SIZE> visited;
    result.sumScore = 0;
    result.puttedCount = 0;
    int diffTurn = 0;
    for(const int index : indices) {
      const Piece& piece = pieces[index];
      REP(t, SMALL_T) {
        if (gNowTurn + diffTurn + t + piece.requiredHeatTurnCount() >= TURN_LIMIT) break;
        if (diffTurnLimit>=0 && diffTurn + t >= diffTurnLimit) break;
        // std::memset(visited.data(), 0, SIZE*sizeof(int));
        REP(i, SIZE*SIZE) {
          const auto& p = traverse(i, piece);
          const int x = p.x;
          const int y = p.y;
          if (x < 0 || y < 0) continue;
          if (x + piece.width() > SIZE || y + piece.height() > SIZE) continue;
          // if (visited[x]>>y&1) continue;
          // visited[x] |= 1<<y;
          if (canInsertPiece(piece, p, diffTurn + t)) {
            putPiece(piece, p, diffTurn + t);
            if (result.sumScore == 0) {
              result.firstPieceIndex = index;
              result.firstPiecePos = Vector2i(x, y);
              result.firstDiffTurn = diffTurn + t;
            }
            // result.lastDiffTurn = std::max(result.lastDiffTurn, diffTurn + t + piece.requiredHeatTurnCount() + 1);
            result.lastDiffTurn = diffTurn + t + piece.requiredHeatTurnCount() + 1;
            result.sumScore += piece.score();
            result.puttedCount++;
            diffTurn += t + 1;
            goto NEXT_PIECE;
          }
        }
      }
      return;
    NEXT_PIECE:
      continue;
    }
  }

  // pieceを積める場所で、"良い"場所があればそれを返す
  bool canStackOne(
    const Piece& piece,
    const Traverse& traverse,
    const int threshold,
    Vector2i& puttedPos,
    int& maxPoint
  ) const {
    maxPoint = -1;
    REP(i, SIZE*SIZE) {
      const auto& p = traverse(i, piece);
      int x = p.x;
      int y = p.y;
      if (x < 0 || y < 0) continue;
      if (x + piece.width() > SIZE || y + piece.height() > SIZE) continue;
      if (canStackPiece(piece, p, 0)) {
        int point = getPointToPut(piece, p, 0);
        if (point > maxPoint) {
          maxPoint = point;
          puttedPos = p;
        }
      }
    }
    return maxPoint >= threshold;
  }

  // pieceを挿入できる場所で、"良い"場所があればそれを返す
  bool canInsertOne(
    const Piece& piece,
    const Traverse& traverse,
    const int threshold,
    Vector2i& puttedPos
  ) const {
    int maxPoint = -1;
    REP(i, SIZE*SIZE) {
      const auto& p = traverse(i, piece);
      int x = p.x;
      int y = p.y;
      if (x < 0 || y < 0) continue;
      if (x + piece.width() > SIZE || y + piece.height() > SIZE) continue;
      if (canInsertPiece(piece, p, 0)) {
        int point = getPointToPut(piece, p, 0);
        if (point > maxPoint) {
          maxPoint = point;
          puttedPos = p;
        }
      }
    }
    return maxPoint >= threshold;
  }

  // gNowTurn+diffTurn ターンに置かれているマスの割合を返す
  float getPuttedRatio(const int diffTurn) const {
    float count = 0;
    int turn = gNowTurn + diffTurn;
    ASSERT(turn>=0 && turn<TURN_LIMIT, "turn: %d", turn);
    REP(x, SIZE) {
      count += std::bitset<32>(data[turn][x]).count();
    }
    return count / (SIZE * SIZE);
  }

  // this の状態を that に コピーする
  inline void copy(Tower& that) {
    int limit = std::min(TURN_LIMIT, std::max(this->maxChangedTurn, that.maxChangedTurn) + 1);
    std::memcpy(
      that.data + gNowTurn,
      this->data + gNowTurn,
      (limit - gNowTurn) * SIZE * sizeof(int)
    );
    std::memcpy(that.maxTurnGrid, this->maxTurnGrid, sizeof(maxTurnGrid));
    that.maxChangedTurn = this->maxChangedTurn;
  }
};

//==============================================================================

class Solver {

private:
  // 確定したクッキー配置状態
  Tower mDeterminedTower;
  // 大きいクッキーの配置を決めるための一時的な配置状態
  Tower mLargeTempTower;
  // 小さいクッキーの配置を決めるための一時的な配置状態
  Tower mSmallTempTower;

  // 前ターンで最適と推定されたid for large cookies
  int mLargeMaxPreId;
  // 前ターンで最適と推定されたid for small cookies
  int mSmallMaxPreId;

  // 残りターンを考慮して、新たに配置することが可能な大きいクッキーが存在するか？
  bool mCanPutLargePiece;

  // 前ターンにクッキーを配置するアクションを取ったか？
  bool mPrePiecePutted;

  // このステージにおける、大きいクッキーの理論上最大な必要加熱ターン数
  int mLargeMaxRequiredHeatTurn;
  // このステージにおける、大きいクッキーに対するFoldPosRatioの平均値
  float mLargeAverageFoldPosRatio;

  // 大きいクッキー計算用のtraverse配列
  std::vector<Traverse> mLargeTraverses;
  // 小さいクッキー計算用のtraverse配列
  std::vector<Traverse> mSmallTraverses;

  // FoldPosRatioの平均値を返す
  float getAverageFoldPosRatio(const Stage& stage, const CandidateLaneType type) const {
    const auto& recipe = stage.candidateLane(type).recipe();
    return (recipe.foldPosRatioMin() + recipe.foldPosRatioTerm()) / 2.0;
  }

  // 理論上最大の必要加熱ターン数を返す
  int getMaxRequiredHeatTurn(const Stage& stage, const CandidateLaneType type) const {
    const auto& recipe = stage.candidateLane(type).recipe();
    int maxHpm = recipe.maxSampleEdgeLength() * 2;
    int minW = 1;
    int minH = maxHpm - minW;
    int maxPrimalScore = recipe.maxPrimalScore();
    int maxScore = maxPrimalScore * (recipe.scoreCoeffTerm() - 1);
    return maxScore / (minW * minH);
  }

public:
  // ステージに対する初期化
  void init(const Stage& stage) {
    static int stageIndex = 0;
    DUMP("stageIndex: %2d, largeAverageFoldPosRatio: %lf", stageIndex++, getAverageFoldPosRatio(stage, CandidateLaneType_Large));
    mLargeMaxRequiredHeatTurn = getMaxRequiredHeatTurn(stage, CandidateLaneType_Large);
    mLargeAverageFoldPosRatio = getAverageFoldPosRatio(stage, CandidateLaneType_Large);
    mDeterminedTower.clear();
    mLargeTempTower.clear();
    mSmallTempTower.clear();
    mLargeMaxPreId = 0;
    mSmallMaxPreId = 0;
    mCanPutLargePiece = true;
    mPrePiecePutted = true;
    if (mLargeAverageFoldPosRatio < 0.15) {
      // クッキーの形状が縦長
      mLargeTraverses = { traverseYoko7 };
      mSmallTraverses = { traverseYoko1, traverseYoko2 };
    } else if (mLargeAverageFoldPosRatio > 0.85) {
      // クッキーの形状が横長
      mLargeTraverses = { traverseTate7 };
      mSmallTraverses = { traverseTate1, traverseTate2 };
    } else {
      mLargeTraverses = { traverseNaname5, traverseNaname6 };
      mSmallTraverses = { traverseYoko1, traverseYoko4 };
    }
  }

  // 各ターンでアクションを決定する前に呼ぶ関数
  void beforeExec(const Stage& stage) {
    gNowTurn = stage.turn();
    gLargePermMaxDepth = std::max(3, 4 - gNowTurn);
    gSmallPermMaxDepth = 4;
  }

  // 各ターンでアクションを決定する関数
  Action exec(const Stage& stage) {
    // if (
    //   !mPrePiecePutted &&
    //   stage.oven().lastBakedPieces().isEmpty()
    // ) {
    //   return Action::Wait();
    // }

    //------------------ 大きいクッキーの計算 ----------------------------------

    const auto& largePieces = stage.candidateLane(CandidateLaneType_Large).pieces();

    if (mCanPutLargePiece) {
      // 残りターン数的に大きいクッキーが置けなくなっているかチェック
      if (
        std::all_of(ALL(largePieces), [=](const Piece& piece) {
          return gNowTurn + piece.requiredHeatTurnCount() >= TURN_LIMIT;
        })
      ) {
        mCanPutLargePiece = false;
      }
    }

    if (mCanPutLargePiece) {
      // "良い"置き方ができる大きいクッキーがあればそのクッキーを配置する
      float maxValue = -1;
      int maxPieceIndex = -1;
      Vector2i maxPos;
      REP(pieceIndex, NUM) {
        const auto& piece = largePieces[pieceIndex];
        Vector2i pos;
        int point;
        if (mDeterminedTower.canStackOne(piece, mLargeTraverses[0], 2, pos, point)) {
          float value = piece.score();
          if (value > maxValue) {
            maxValue = value;
            maxPieceIndex = pieceIndex;
            maxPos = pos;
          }
        }
      }
      if (maxPieceIndex >= 0) {
        const auto& maxPiece = largePieces[maxPieceIndex];
        mDeterminedTower.putPiece(maxPiece, maxPos, 0);
        ASSERT(stage.oven().isAbleToPut(maxPiece, maxPos), "");
        // DUMP("Yeah! turn: %d", gNowTurn);
        return Action::Put(CandidateLaneType_Large, maxPieceIndex, maxPos);
      }
    }

    Tower::StackPiecesResult largeMaxResult;

    if (mCanPutLargePiece) {
      // 大きいクッキーの配置をなんちゃって全探索して最適な配置方法を求める

      float largeMaxValue = -1;
      float largeMaxFirstValue = -1;
      std::vector<int> largeMaxIndices(gLargePermMaxDepth);

      std::vector<int> largeIndices(gLargePermMaxDepth);
      std::array<int, NUM> perm;
      std::iota(perm.begin(), perm.begin() + gLargePermMaxDepth, 0);
      std::fill(perm.begin() + gLargePermMaxDepth, perm.end(), INF);

      int largeMaxTraverseIndex = -1;

      std::array<bool, NUM> canStackPieceList;
      REP(pieceIndex, NUM) {
        const auto& piece = largePieces[pieceIndex];
        canStackPieceList[pieceIndex] = mDeterminedTower.canStackPieceAnywhere(piece, 0);
      }

      int idGen = 0;
      int maxId = 0;
      REP(traverseIndex, mLargeTraverses.size()) {
        const auto& traverse = mLargeTraverses[traverseIndex];
        do {  // next_permutation
          int id = idGen++;
          // 全探索すると間に合わないので確率で探索空間を減らす
          if (id==mLargeMaxPreId || gRandom.randTerm(3*mLargeTraverses.size()) < 2) {
            Tower::StackPiecesResult result;
            REP(index, NUM) {
              if (perm[index] == INF) continue;
              largeIndices[perm[index]] = index;
            }
            if (!canStackPieceList[largeIndices[0]]) continue;
            mDeterminedTower.copy(mLargeTempTower);
            mLargeTempTower.stackPieces(largePieces, largeIndices, traverse, result);
            if (result.firstPieceIndex < 0) continue;
            const auto& firstPiece = largePieces[result.firstPieceIndex];
            float value = result.sumScore / static_cast<float>(result.lastDiffTurn);
            float firstValue = firstPiece.score() / static_cast<float>(firstPiece.requiredHeatTurnCount());
            if (value > largeMaxValue || (nearlyEqual(value, largeMaxValue) && firstValue > largeMaxFirstValue)) {
              largeMaxValue = value;
              largeMaxFirstValue = firstValue;
              largeMaxResult = result;
              largeMaxIndices = largeIndices;
              largeMaxTraverseIndex = traverseIndex;
              maxId = id;
            }
          }
        } while (std::next_permutation(ALL(perm)));
      }
      mLargeMaxPreId = maxId;

      if (largeMaxResult.firstPieceIndex>=0 && largeMaxResult.firstDiffTurn==0) {
        const auto& piece = largePieces[largeMaxResult.firstPieceIndex];
        Vector2i pos = largeMaxResult.firstPiecePos;

        // 端っこに寄せる
        if (pos.x + piece.width()/2 < SIZE/2) {
          pos = mDeterminedTower.moveMostStackLeft(piece, pos, 0);
        } else {
          pos = mDeterminedTower.moveMostStackRight(piece, pos, 0);
        }
        if (pos.y + piece.height()/2 < SIZE/2) {
          pos = mDeterminedTower.moveMostStackUp(piece, pos, 0);
        } else {
          pos = mDeterminedTower.moveMostStackDown(piece, pos, 0);
        }

        mDeterminedTower.putPiece(piece, pos, 0);
        ASSERT(stage.oven().isAbleToPut(piece, pos), "");
        return Action::Put(CandidateLaneType_Large, largeMaxResult.firstPieceIndex, pos);
      }

      mDeterminedTower.copy(mLargeTempTower);
      if (largeMaxResult.firstPieceIndex >= 0) {
        mLargeTempTower.stackPieces(largePieces, largeMaxIndices, mLargeTraverses[largeMaxTraverseIndex]);
      }
    } else {
      mDeterminedTower.copy(mLargeTempTower);
    }

    //------------------ 小さいクッキーの計算 ----------------------------------

    const auto& smallPieces = stage.candidateLane(CandidateLaneType_Small).pieces();
    // const float smallPuttedRatio = mLargeTempTower.getPuttedRatio(0);

    {
      // "良い"置き方ができる小さいクッキーがあればそのクッキーを配置する
      int maxScore = -1;
      int maxPieceIndex = -1;
      Vector2i maxPos;
      REP(pieceIndex, NUM) {
        const auto& piece = smallPieces[pieceIndex];
        Vector2i pos;
        if (mLargeTempTower.canInsertOne(piece, mSmallTraverses[0], 2, pos)) {
          if (piece.score() > maxScore) {
            maxScore = piece.score();
            maxPieceIndex = pieceIndex;
            maxPos = pos;
          }
        }
      }
      if (maxPieceIndex >= 0) {
        const auto& maxPiece = smallPieces[maxPieceIndex];
        mDeterminedTower.putPiece(maxPiece, maxPos, 0);
        ASSERT(stage.oven().isAbleToPut(maxPiece, maxPos), "");
        return Action::Put(CandidateLaneType_Small, maxPieceIndex, maxPos);
      }
    }

    if (mLargeTempTower.existsPieceToPut(smallPieces, 0)) {
      // 小さいクッキーの配置をなんちゃって全探索して最適な配置方法を求める

      Tower::InsertPiecesResult smallMaxResult;
      float smallMaxValue = -1;
      float smallMaxFirstValue = -1;

      std::vector<int> smallIndices(gSmallPermMaxDepth);
      std::array<int, NUM> perm;
      std::iota(perm.begin(), perm.begin() + gSmallPermMaxDepth, 0);
      std::fill(perm.begin() + gSmallPermMaxDepth, perm.end(), INF);

      // int smallMaxTraverseIndex = -1;

      std::array<bool, NUM> canInsertPieceList;
      REP(pieceIndex, NUM) {
        const auto& piece = smallPieces[pieceIndex];
        canInsertPieceList[pieceIndex] = mLargeTempTower.canInsertPieceAnywhere(piece, 0);
      }

      int idGen = 0;
      int maxId = 0;
      REP(traverseIndex, mSmallTraverses.size()) {
        const auto& traverse = mSmallTraverses[traverseIndex];
        do {  // next_permutation
          int id = idGen++;
          // 全探索すると間に合わないので確率で探索空間を減らす
          if (id==mSmallMaxPreId || gRandom.randTerm(3*mSmallTraverses.size()) < 2) {
            mLargeTempTower.copy(mSmallTempTower);
            Tower::InsertPiecesResult result;
            REP(index, NUM) {
              if (perm[index] == INF) continue;
              smallIndices[perm[index]] = index;
            }
            if (!canInsertPieceList[smallIndices[0]]) continue;
            mSmallTempTower.insertPieces(smallPieces, smallIndices, traverse, largeMaxResult.firstDiffTurn, result);
            if (result.firstPieceIndex < 0) continue;
            const auto& firstPiece = smallPieces[result.firstPieceIndex];
            float value;
            if (mCanPutLargePiece && largeMaxResult.firstDiffTurn>=0 && largeMaxResult.firstDiffTurn<gSmallPermMaxDepth) {
              value = result.sumScore;
            } else if (mCanPutLargePiece) {
              value = result.sumScore / static_cast<float>(result.lastDiffTurn) / static_cast<float>(result.lastDiffTurn);
            } else {
              value = firstPiece.score();
            }
            float firstValue = firstPiece.score() / static_cast<float>(firstPiece.requiredHeatTurnCount());
            if (value > smallMaxValue || (nearlyEqual(value, smallMaxValue) && firstValue > smallMaxFirstValue)) {
              smallMaxValue = value;
              smallMaxFirstValue = firstValue;
              smallMaxResult = result;
              // smallMaxTraverseIndex = traverseIndex;
              maxId = id;
            }
          }
        } while (std::next_permutation(ALL(perm)));
      }
      mSmallMaxPreId = maxId;

      if (smallMaxResult.firstPieceIndex>=0 && smallMaxResult.firstDiffTurn==0) {
        const auto& piece = smallPieces[smallMaxResult.firstPieceIndex];
        Vector2i pos = smallMaxResult.firstPiecePos;

        // 端っこに寄せる
        if (pos.x + piece.width()/2 < SIZE/2) {
          pos = mLargeTempTower.moveMostInsertLeft(piece, pos, 0);
        } else {
          pos = mLargeTempTower.moveMostInsertRight(piece, pos, 0);
        }
        if (pos.y + piece.height()/2 < SIZE/2) {
          pos = mLargeTempTower.moveMostInsertUp(piece, pos, 0);
        } else {
          pos = mLargeTempTower.moveMostInsertDown(piece, pos, 0);
        }

        mDeterminedTower.putPiece(piece, pos, 0);
        ASSERT(stage.oven().isAbleToPut(piece, pos), "");
        return Action::Put(CandidateLaneType_Small, smallMaxResult.firstPieceIndex, pos);
      }
    }

    // -------------------------------------------------------------------------

    // 配置できなかった場合は待機
    return Action::Wait();
  }

  // 各ターンでアクションを決定したあとに呼ぶ関数
  void afterExec(const Stage& stage, const Action& action) {
    mPrePiecePutted = action.type() == ActionType_Put;
  }
} gSolver;

//==============================================================================

Answer::Answer() {
}
Answer::~Answer() {
}
void Answer::init(const Stage& aStage) {
  gSolver.init(aStage);
}
Action Answer::decideNextAction(const Stage& aStage) {
  gSolver.beforeExec(aStage);
  Action action = gSolver.exec(aStage);
  gSolver.afterExec(aStage, action);
  return action;
}
void Answer::finalize(const Stage& aStage) {
}

}   // namespace hpc
// EOF
