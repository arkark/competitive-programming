/*
    ハル研究所プログラミングコンテスト2020
    https://www.hallab.co.jp/progcon/2020/
*/

#include "Answer.hpp"

#include <iostream>
#include <chrono>
#include <cmath>
#include <limits>
#include <algorithm>
#include <functional>
#include <array>
#include <vector>
#include <queue>
#include <deque>
#include <map>

namespace hpc {

//==================================================================
// 便利マクロやデバッグ用マクロ
//==================================================================

#define REP(i, n) \
  for(int (i)=0; (i) < static_cast<int>(n); (i)++)
#define REP_R(i, n) \
  for(int (i)=static_cast<int>(n)-1; (i) >= 0; (i)--)
#define FOR(i, l, r) \
  for(int (i)=static_cast<int>(l); (i) < static_cast<int>(r); (i)++)
#define FOR_R(i, l, r) \
  for(int (i)=static_cast<int>(r)-1; (i) >= static_cast<int>(l); (i)--)
#define ALL(xs) \
  (xs).begin(), (xs).end()

// E.g. PRINT("%d, %d", x, y)
//   $ ./hpc2020.exe -j > output.json
//   を実行してもコンソールに出力されるように標準エラー出力をする
#ifdef LOCAL
  #define PRINT(aFmt, ...) \
    do { \
      std::fprintf(stderr, "[%s:%u] " aFmt "\n", __FILE__, __LINE__, ##__VA_ARGS__); \
    } while (false)
#else
  #define PRINT(aFmt, ...)
#endif

#ifdef LOCAL
  #define ASSERT(aExp) \
    do { \
      HPC_ASSERT_MSG(aExp, "[%s:%u] Assertion Failed", __FILE__, __LINE__); \
    } while (false)
#else
  #define ASSERT(aExp)
#endif

// 現在の処理時間を出力
#ifdef LOCAL
  auto startTime = std::chrono::system_clock::now();
  #define TIMESTAMP(prefix) \
    do { \
      auto nowTime = std::chrono::system_clock::now(); \
      auto secs = std::chrono::duration_cast<std::chrono::seconds>(nowTime - startTime).count(); \
      auto msecs = std::chrono::duration_cast<std::chrono::milliseconds>(nowTime - startTime).count(); \
      msecs %= 1000; \
      std::cerr << prefix << ": " << secs << "s " << msecs << "ms" << std::endl; \
    } while(false)
#else
  #define TIMESTAMP(prefix)
#endif

// 各ラベルに対してBEGIN-ENDで囲まれた部分の処理時間の和をPRINT_PROFILINGで出力
// `-DPROFILING`オプションを付加時のみ有効
#ifdef PROFILING
  std::map<std::string, int64_t> gProfilingDuration;
  std::map<std::string, std::chrono::system_clock::time_point> gProfilingBeginTime;
  #define PROFILE_BEGIN(label) \
    do { \
      const auto& nowTime = std::chrono::system_clock::now(); \
      gProfilingBeginTime[label] = nowTime; \
    } while(false)
  #define PROFILE_END(label) \
    do { \
      const auto& beginTime = gProfilingBeginTime[label]; \
      const auto& nowTime = std::chrono::system_clock::now(); \
      auto msecs = std::chrono::duration_cast<std::chrono::milliseconds>(nowTime - beginTime).count(); \
      gProfilingDuration[label] += msecs; \
    } while(false)
  #define PRINT_PROFILING() \
    do { \
      std::cerr << "Profiling:" << std::endl; \
      for (const auto& pair : gProfilingDuration) { \
        auto secs = pair.second / 1000; \
        auto msecs = pair.second % 1000; \
        std::cerr << "- " << pair.first << ": " << secs<< "s " << msecs<< "ms" << std::endl; \
      } \
    } while (false)
#else
  #define PROFILE_BEGIN(label)
  #define PROFILE_END(label)
  #define PRINT_PROFILING()
#endif

// unusedに対する警告を一時的に回避したいときに使用
#ifdef LOCAL
  #define UNUSE(aExp) (void)(aExp)
#else
  #define UNUSE(aExp)
#endif

//==================================================================
// 全体で用いる定数
//==================================================================

constexpr int INT_INF = std::numeric_limits<int>::max()/3;
constexpr float FLOAT_INF = 1e10f;
constexpr float EPS = 1.0e-4f;
constexpr double PI = 3.141592653589793;

//==================================================================
// グローバル変数
//==================================================================

// 現在のステージインデックス管理用
#ifdef LOCAL
  int gStageIndex = 0;
#endif

// gPowers[i]: i個の巻物を取得している時点でのpower
std::array<
  float,
  Parameter::MaxScrollCount
> gPowers;

//==================================================================
// クラスの前方宣言
//==================================================================

class Vec2;
class BeamSearch;
class Tsp;
class Solver;

//==================================================================
// 汎用的な関数
//==================================================================

// std::popcountはC++20からなので
unsigned int popcount(unsigned int x) {
  x = (x & 0x55555555) + (x >>  1 & 0x55555555);
  x = (x & 0x33333333) + (x >>  2 & 0x33333333);
  x = (x & 0x0f0f0f0f) + (x >>  4 & 0x0f0f0f0f);
  x = (x & 0x00ff00ff) + (x >>  8 & 0x00ff00ff);
  x = (x & 0x0000ffff) + (x >> 16 & 0x0000ffff);
  return x;
}

//==================================================================
//  Vec2: Vector2を使いやすく拡張
//==================================================================

class Vec2 {

private:
  Vector2 v;

public:
  Vec2() {
  }

  Vec2(float aX, float aY)
  : v(aX, aY) {
  }

  Vec2(Vector2 a)
  : v(a) {
  }

  inline float x() const {
    return v.x;
  }

  inline float y() const {
    return v.y;
  }

  Vec2 operator+(const Vec2& that) const {
    return Vec2(this->x() + that.x(), this->y() + that.y());
  }

  Vec2 operator-(const Vec2& that) const {
    return Vec2(this->x() - that.x(), this->y() - that.y());
  }

  Vec2 operator*(const Vec2& that) const {
    return Vec2(this->x() * that.x(), this->y() * that.y());
  }

  Vec2 operator/(const Vec2& that) const {
    return Vec2(this->x() / that.x(), this->y() / that.y());
  }

  Vec2 operator+(const float that) const {
    return Vec2(this->x() + that, this->y() + that);
  }

  Vec2 operator-(const float that) const {
    return Vec2(this->x() - that, this->y() - that);
  }

  Vec2 operator*(const float that) const {
    return Vec2(this->x() * that, this->y() * that);
  }

  Vec2 operator/(const float that) const {
    return Vec2(this->x() / that, this->y() / that);
  }

  Vec2 rotate(double theta) const {
    double c = cos(theta);
    double s = sin(theta);
    return Vec2(
      c * this->x() - s * this->y(),
      s * this->x() + c * this->y()
    );
  }

  // sqrtは遅いので、これで代用できるときはこれを使う
  float lengthSq() const {
    return this->x() * this->x() + this->y() * this->y();
  }

  float length() const {
    return sqrt(lengthSq());
  }

  Vec2 normalize() const {
    float len = length();
    if (len < EPS) {
      return *this;
    } else {
      return *this / len;
    }
  }

  float dot(const Vec2& that) const {
    return this->x() * that.x() + this->y() * that.y();
  }

  float cross(const Vec2& that) const {
    return this->x() * that.y() - this->y() * that.x();
  }

  const Vector2& toVector2() const {
    return v;
  }

  static Vec2 polar(float rho, double theta) {
    return Vec2(rho*cos(theta), rho*sin(theta));
  }
};

// aとbが同じ位置に存在するか？
// checkExactlyがfalseのときは同じマスにいるかをチェック
bool samePlace(const Vec2& a, const Vec2& b, bool checkExactly) {
  if (checkExactly) {
    return (b - a).lengthSq() < EPS * EPS;
  } else {
    return static_cast<int>(a.x()) == static_cast<int>(b.x())
      && static_cast<int>(a.y()) == static_cast<int>(b.y());
  }
}

// sからgへ1ターンで移動可能か？
bool canMove(const Vec2& s, const Vec2& g, const Stage& aStage, float power) {
  auto t = aStage.terrain(s.toVector2());
  auto maxLen = Parameter::JumpTerrianCoefficient[(int)t] * power + EPS;
  return (g - s).lengthSq() <= maxLen*maxLen;
  // Vec2 g2 = aStage.getNextPos(s.toVector2(), power, g.toVector2());
  // return (g - g2).lengthSq() < EPS;
}

//==================================================================
// BeamSearch: ビームサーチを行うクラス
//==================================================================

constexpr int BEAM_SEARCH_POOL_SIZE = 1000000;

// cos, sin, powの前計算

// thetaが入力依存でない場合はあらかじめ計算しておく
std::array<
  std::array<
    double,
    30 // index of theta
  >,
  4 // index of BEAM_SEARCH_OPTIONS
> gCosValues;
std::array<
  std::array<
    double,
    30 // index of theta
  >,
  4 // index of BEAM_SEARCH_OPTIONS
> gSinValues;

class BeamSearch {

private:
  // ビームサーチで用いる状態
  struct State {
    Vec2 pos;         // 現在位置
    int dist;         // 目的地点までの距離（推定値）
    Vec2 dir;         // 探索方向の向き
    int depth;        // 初期状態からの状態の繊維回数
    Terrain terrain;  // 現在位置の地形
    State* prevState; // ひとつ前の状態

    // proproty queueで用いる比較関数
    // std::priority_queueは降順なことに注意
    bool operator()(const State* a, const State* b) const {
      return a->dist != b->dist ? a->dist > b->dist : a->terrain > b->terrain;
    }
  };


  // 雑なobject pool
  std::array<State, BEAM_SEARCH_POOL_SIZE> mPool;
  int mPoolIndex;

  // ビームサーチに用いるデータ構造の型
  using PriorityQueue = std::priority_queue<
    State*,
    std::vector<State*>,
    State
  >;

  // ビームサーチの状態を格納する場所
  std::array<
    PriorityQueue,
    Parameter::GameTurnLimit
  > mBeams;

  // popした状態をここに持っていく
  std::array<
    std::vector<State*>,
    Parameter::GameTurnLimit
  > mSavedBeams;

  // 探索の最大到達深さ
  int mBeamLargestDepth = 0;

  // 枝が利用に、最小値を保持
  std::array<
    int,
    Parameter::GameTurnLimit
  > mMinResultDepths;
  int mMinMinResultDepth;

public:
  // ビームサーチ実行時の設定
  struct Option {
    int index;

    int beamWidth;                // ビーム幅
    int numTheta;                 // 探索を広げるときの角度の個数（遷移の個数は2倍程度になる）
    double stepTheta;             // 探索を広げるときの各遷移間の方向ベクトルのずらす角度
    int spreadStep;               // 計算をサボるための値（大きいほど計算が雑になる）
    float ignoredDistThrehold;      // 計算をサボるための値（大きいほど計算が雑になる）
    int resultDepthThresholdDiff; // 計算をサボるための値（0以上）（小さいほど計算が雑になる）
    bool useRotation;             // 遷移計算時に回転処理を行うか（サボる場合はfalse）
    bool checkExactly;            // float上で目的地に到着するパスを探索するか？falseの場合は同じマスに到着するパスを探索する
  };

  BeamSearch() {
    REP(i, Parameter::GameTurnLimit) {
      mMinResultDepths[i] = Parameter::GameTurnLimit;
    }
  }

  // sからgへのパスを探索する
  //// 実際の計算はsolveInternalで行う
  // @return: パスが存在するか
  // @side effect: resultPath: 最適だと思われるパス
  bool solvePath(
    const Vec2& s,
    const Vec2& g,
    const Stage& aStage,
    const int gottenScrollCount,
    const Option& option,
    const int distLimit,
    std::deque<Vec2>& resultPath
  ) {
    State* optState = solveInternal(
      s,
      g,
      aStage,
      gottenScrollCount,
      option,
      distLimit
    );

    resultPath.clear();
    if (optState == nullptr) {
      ASSERT(option.checkExactly || distLimit < INT_INF);
      return false;
    }

    // 存在する場合はパスを復元する
    while(optState->prevState != nullptr) {
      resultPath.push_front(optState->pos);
      optState = optState->prevState;
    }
    ASSERT(!resultPath.empty());
    ASSERT((int)resultPath.size() <= distLimit);
    return true;
  }

  // sからgへのかかるターン数の下界を返す（枝刈り用）
  int calcLowerDist(const Vec2& s, const Vec2& g, int gottenScrollCount) const {
    float power = gPowers[gottenScrollCount];
    float length = (g - s).length();
    return static_cast<int>(length / power);
  }

private:
  // 初期化
  void clear() {
    mPoolIndex = 0;
    REP(i, mBeamLargestDepth + 1) {
      mBeams[i] = PriorityQueue();
      mSavedBeams[i].clear();
    }
    REP(i, mBeamLargestDepth + 1) {
      mMinResultDepths[i] = Parameter::GameTurnLimit;
    }
    mMinMinResultDepth = Parameter::GameTurnLimit;
    mBeamLargestDepth = 0;
  }

  // object poolから取ってくる
  State* gen(const Vec2& pos, const int dist, const Vec2& dir, const int depth, const Terrain terrain, State* prevState) {
    ASSERT(mPoolIndex < BEAM_SEARCH_POOL_SIZE);
    State* state = &mPool[mPoolIndex++];
    state->pos = pos;
    state->dist = dist;
    state->dir = dir;
    state->depth = depth;
    state->terrain = terrain;
    state->prevState = prevState;
    return state;
  }

  // object poolの末尾n個を取り除く
  void removeBackPoolN(const int n) {
    ASSERT(n <= mPoolIndex);
    mPoolIndex -= n;
  }

  // s1はすでに処理済みの状態か？
  bool alreadySaved(const State* s1) const {
    bool saved = false;
    for (const State* s2 : mSavedBeams[s1->depth]) {
      float THRESHOLD = 0.15;
      if ((s2->pos - s1->pos).lengthSq() < THRESHOLD*THRESHOLD) {
        saved = true;
        break;
      }
    }
    return saved;
  }

  // sからgへのパスを探索する
  State* solveInternal(
    const Vec2& s,
    const Vec2& g,
    const Stage& aStage,
    const int gottenScrollCount,
    const Option& option,
    const int distLimit
  ) {
    clear();
    const float power = gPowers[gottenScrollCount];
    const Vec2 dirToG = (g - s).normalize();

    State* firstState = gen(
      s,
      Parameter::GameTurnLimit,
      dirToG,
      0,
      aStage.terrain(s.toVector2()),
      nullptr
    );
    mBeams[0].push(firstState);
    {
      setNextStateChain(firstState, dirToG, g, aStage, option, gottenScrollCount, distLimit, false);
    }

    if (firstState->terrain > Terrain::Plain) {
      auto t1 = firstState->terrain;

      static std::vector<Vec2> dirs;
      if (dirs.empty()) {
        // int N = 16;
        // REP(i, N) {
        //   double theta = 2*PI*i/N;
        //   dirs.push_back(Vec2::polar(1, theta));
        // }
        dirs = {
          Vec2(-1, 0),
          Vec2(1, 0),
          Vec2(0, -1),
          Vec2(0, 1),
          Vec2(1, 1).normalize(),
          Vec2(-1, 1).normalize(),
          Vec2(1, -1).normalize(),
          Vec2(-1, -1).normalize(),
        };
      }

      State* minState = nullptr;
      float minD = FLOAT_INF;

      for(const Vec2& dir : dirs) {
        State* cur = firstState;

        bool ok = false;
        int dist = 0;
        while(dist < 100) {
          cur = getNextState(cur, dir, g, power, aStage, option);
          if (cur == nullptr) break;
          if (samePlace(cur->pos, g, false)) {
            // TODO: 面倒なので無視しても良い
            break;
          }
          if (minState != nullptr && cur->depth > minState->depth) {
            break;
          }
          auto t2 = cur->terrain;
          if (t2 < t1) {
            ok = true;
            break;
          }
          dist++;
        }
        if (ok) {
          ASSERT(minState == nullptr || cur->depth <= minState->depth);
          float d = (g - cur->pos).lengthSq();
          if (
            minState == nullptr ||
            cur->depth < minState->depth ||
            (cur->depth == minState->depth && d < minD)
          ) {
            minState = cur;
            minD = d;
          }
        }
      }

      if (minState != nullptr) {
        State* next = setNextStateChain(minState, minState->dir, g, aStage, option, gottenScrollCount, distLimit, false);
        FOR(j, 1, option.numTheta + 1) {
          double co = gCosValues[option.index][j];
          double si = gSinValues[option.index][j];
          const Vec2& dir = minState->dir;
          // dir.rotate(theta)とdir.rotate(-theta)
          // 2回sin,cosを計算するのは無駄なので、1回で済ます
          {
            // Vec2 nextDir = minState->dir.rotate(theta).normalize();
            Vec2 nextDir = Vec2(
              co*dir.x() - si*dir.y(), si*dir.x() + co*dir.y()
            ).normalize();
            State* next2 = setNextStateChain(minState, nextDir, g, aStage, option, gottenScrollCount, distLimit, false);
            if (next == nullptr && next2 != nullptr) next = next2;
          }
          {
            // Vec2 nextDir = minState->dir.rotate(-theta).normalize();
            Vec2 nextDir = Vec2(
              co*dir.x() + si*dir.y(), -si*dir.x() + co*dir.y()
            ).normalize();
            State* next2 = setNextStateChain(minState, nextDir, g, aStage, option, gottenScrollCount, distLimit, false);
            if (next == nullptr && next2 != nullptr) next = next2;
          }
        }

        if (next != nullptr) {
          State* cur = next;
          while(cur->prevState != firstState) {
            cur->prevState->dist = cur->dist + 1;
            cur = cur->prevState;

            mBeams[cur->depth].push(cur);
            mBeamLargestDepth = std::max(mBeamLargestDepth, cur->depth);
            mMinResultDepths[cur->depth] = std::min(mMinResultDepths[cur->depth], cur->depth + cur->dist);
          }
        }
      }
    }

    State* optState = nullptr;

    REP(beamIndex, option.beamWidth) {
      REP(depth, std::min(distLimit + 1, std::min(mMinMinResultDepth + 1, mBeamLargestDepth + 1))) {

        if (optState != nullptr && depth >= optState->depth) {
          break;
        }

        State* cur = nullptr;
        while(!mBeams[depth].empty()) {
          State* s1 = mBeams[depth].top();
          mBeams[depth].pop();
          bool saved = alreadySaved(s1);
          if (!saved) {
            cur = s1;
            mSavedBeams[depth].push_back(s1);
            break;
          } else {
            if (samePlace(s1->pos, g, option.checkExactly)) {
              if (optState == nullptr || depth < optState->depth) {
                optState = s1;
              }
            }
          }
        }
        if (cur == nullptr) continue;

        if (samePlace(cur->pos, g, option.checkExactly)) {
          if (optState == nullptr || depth < optState->depth) {
            optState = cur;
          }
          break;
        }

        if (canMove(cur->pos, g, aStage, power)) {
          State* next = gen(
            g,
            0,
            dirToG,
            cur->depth + 1,
            aStage.terrain(g.toVector2()),
            cur
          );
          ASSERT(samePlace(next->pos, g, option.checkExactly));
          mBeams[next->depth].push(next);
          mBeamLargestDepth = std::max(mBeamLargestDepth, next->depth);
          mMinResultDepths[next->depth] = std::min(mMinResultDepths[next->depth], next->depth + next->dist);
          mMinMinResultDepth = std::min(mMinMinResultDepth, mMinResultDepths[next->depth]);
        } else if (depth % option.spreadStep == 0) {
          // if (std::abs(cur->dir.y()) > EPS) {
          //   setNextStateChain(cur, Vec2(cur->dir.x() > 0 ? 1 : -1, 0), g, aStage, option, gottenScrollCount, optState == nullptr ? distLimit : optState->depth + optState->dist);
          // }
          // if (std::abs(cur->dir.x()) > EPS) {
          //   setNextStateChain(cur, Vec2(0, cur->dir.y() > 0 ? 1 : -1), g, aStage, option, gottenScrollCount, optState == nullptr ? distLimit : optState->depth + optState->dist);
          // }
          FOR(j, 1, option.numTheta + 1) {
            double co = gCosValues[option.index][j];
            double si = gSinValues[option.index][j];
            const Vec2& dir = cur->dir;
            {
              // Vec2 nextDir = cur->dir.rotate(theta).normalize();
              Vec2 nextDir = Vec2(
                co*dir.x() - si*dir.y(), si*dir.x() + co*dir.y()
              ).normalize();
              setNextStateChain(cur, nextDir, g, aStage, option, gottenScrollCount, optState == nullptr ? distLimit : optState->depth + optState->dist, beamIndex == option.beamWidth - 1);
            }
            {
              // Vec2 nextDir = cur->dir.rotate(-theta).normalize();
              Vec2 nextDir = Vec2(
                co*dir.x() + si*dir.y(), -si*dir.x() + co*dir.y()
              ).normalize();
              setNextStateChain(cur, nextDir, g, aStage, option, gottenScrollCount, optState == nullptr ? distLimit : optState->depth + optState->dist, beamIndex == option.beamWidth - 1);
            }
          }
        }
      }
    }

    ASSERT(option.checkExactly || distLimit < INT_INF || optState != nullptr);
    return optState;
  }

  // firstState->posからgへ向けてのパスを探索する
  //// このとき、探索は途中で一度曲がる（dir1 → ir2）パスのみ（ただし、所々ヒューリスティックスあり）
  //// そのなかで最もパス長（dist）が短いものを探す
  // @return: firstStateの次の &state
  //          存在しない場合は nullptr
  State* setNextStateChain(
    State* firstState,
    const Vec2& nextDir,
    const Vec2& g,
    const Stage& aStage,
    const Option& option,
    const int gottenScrollCount,
    const int distLimit, // この値以下のパスを発見する
    const bool isLastBeam // 最後のビームか？
  ) {
    State* optState = nullptr;
    int minDist = INT_INF;

    float power = gPowers[gottenScrollCount];

    int dist1 = 0;
    Vec2 dir1 = nextDir;
    State* cur1 = firstState;
    State* prevCur1 = nullptr;

    int resultDepthThreshold = mMinResultDepths[firstState->depth + 1] + (isLastBeam ? 0 : option.resultDepthThresholdDiff);

    bool updated1 = false;
    while(dist1 < 200) {
      if (cur1->depth + dist1 >= resultDepthThreshold) break;
      if (cur1->depth + dist1 > distLimit) break;
      if (dist1 >= minDist) break;

      int dist2 = 0;
      Vec2 dir2 = (g - cur1->pos).normalize(); // 現在位置からgへの方向ベクトル
      State* cur2 = cur1;

      int lowerDist2 = calcLowerDist(cur1->pos, g, gottenScrollCount);
      do {
        if (dist1 == 0) break;
        if (firstState->depth + dist1 + lowerDist2 >= resultDepthThreshold) break;
        if (firstState->depth + dist1 + lowerDist2 > distLimit) break;

        // 少ししか進んでいない場合は計算をサボる
        if (
          prevCur1 != nullptr &&
          (cur1->pos - prevCur1->pos).lengthSq() < option.ignoredDistThrehold*option.ignoredDistThrehold
        ) break;
        prevCur1 = cur1;

        bool updated2 = false;
        while(dist2 < 200) {

          // ここで曲がってgへ向かう

          if (firstState->depth + dist1 + dist2 >= resultDepthThreshold) break;
          if (firstState->depth + dist1 + dist2 > distLimit) break;
          if (dist1 + dist2 >= minDist) break;

          if (samePlace(cur2->pos, g, option.checkExactly)) {
            int dist = dist1 + dist2;
            ASSERT(dist > 0);
            if (dist < minDist) {
              minDist = dist;
              optState = cur2;
              updated2 = true;
            }
            break;
          }

          cur2 = getNextState(cur2, dir2, g, power, aStage, option);
          if (cur2 == nullptr) break;

          dist2++;

          dir2 = (g - cur2->pos).normalize();
          cur2->dir = dir2;
        }

        if (updated2) {
          updated1 = true;
        } else {
          removeBackPoolN(dist2);
        }
      } while(false);

      if (
        firstState->depth + dist1 + lowerDist2 >= resultDepthThreshold &&
        dir1.dot(g - cur1->pos) < 0
      ) {
        break;
      }

      cur1 = getNextState(cur1, dir1, g, power, aStage, option);
      if (cur1 == nullptr) break;

      dist1++;
    }
    if (!updated1) removeBackPoolN(dist1);

    if (optState != nullptr) {
      State* cur = optState;
      mMinMinResultDepth = std::min(mMinMinResultDepth, cur->depth);
      mBeamLargestDepth = std::max(mBeamLargestDepth, cur->depth);

      int dist = 0;
      State* nextToFirstState = nullptr;
      while(cur != nullptr) {

        if (nextToFirstState == nullptr) {
          cur->dist = dist;
          mBeams[cur->depth].push(cur);
        }

        mMinResultDepths[cur->depth] = std::min(mMinResultDepths[cur->depth], cur->depth + dist);

        if (cur->prevState == firstState) {
          ASSERT(minDist == cur->dist + 1);
          nextToFirstState = cur;
        }

        cur = cur->prevState;
        dist++;
      }
      return nextToFirstState;
    }

    return nullptr;
  }

  // 次の遷移先の状態を取得する
  //// 存在しない場合はnullptrを返す
  State* getNextState(State* cur, const Vec2& dir, const Vec2& g, const float power, const Stage& aStage, const Option& option, bool first = true) {

    if (canMove(cur->pos, g, aStage, power)) {
      // gへ1ターンで到達できる場合は現在位置をgへ遷移する
      return gen(
        g,
        -1,
        (g - cur->pos).normalize(),
        cur->depth + 1,
        aStage.terrain(g.toVector2()),
        cur
      );
    }

    State* nextState;

    {
      float limitLen = (g - cur->pos).length();
      Vec2 nextPos = aStage.getNextPos(
        cur->pos.toVector2(),
        power,
        (cur->pos + (dir * std::min(power + 10.0f, limitLen))).toVector2()
      );
      if (aStage.isOutOfBounds(nextPos.toVector2())) {
        // 盤面から出てしまうときは、壁と並行に移動させる
        bool flip;
        if (nextPos.x() < 0.0f) {
          flip = nextPos.y() > 0;
        } else if (nextPos.x() >= Parameter::StageWidth) {
          flip = nextPos.y() < 0;
        } else if (nextPos.y() < 0.0f) {
          flip = nextPos.x() > 0;
        } else {
          flip = nextPos.x() < 0;
        }
        nextPos = findBetterPositionByRotation(cur->pos, nextPos, aStage, power, flip);
        if (aStage.isOutOfBounds(nextPos.toVector2())) {
          // それでも外に出てしまう場合は遷移しない
          return nullptr;
        }
      }

      nextState = gen(
        nextPos,
        -1,
        dir,
        cur->depth + 1,
        aStage.terrain(nextPos.toVector2()),
        cur
      );
    }

    auto afterT = nextState->terrain;
    if (first && !samePlace(nextState->pos, g, option.checkExactly) && afterT > Terrain::Plain) {
      // 遷移先は平地出ない場合は、少し調整する

      Vec2 nextNextPos = aStage.getNextPos(
        nextState->pos.toVector2(),
        power,
        (nextState->pos + (dir * (power + 10.0f))).toVector2()
      );

      auto minT = afterT;
      Vec2 minP;
      float minD = FLOAT_INF;

      int K = 3;

      // 上下左右それぞれの方向で、いい感じの地形に遷移できる場合は遷移する

      // left
      if (nextState->pos.x() - cur->pos.x() > EPS) {
        REP(diff, K) {
          Vec2 p = Vec2(static_cast<int>(nextState->pos.x()) - diff - 0.01f, nextState->pos.y());
          if (aStage.isOutOfBounds(p.toVector2())) break;
          ASSERT(!samePlace(p, nextState->pos, false));
          auto t = aStage.terrain(p.toVector2());
          if (t > minT || t >= afterT) continue;
          float d = (g - p).lengthSq();
          if (t == minT && d >= minD) continue;
          if (!canMove(cur->pos, p, aStage, power)) break;
          if (!canMove(p, nextNextPos, aStage, power)) break;

          minT = t;
          minP = p;
          minD = d;
        }
      }
      // right
      if (nextState->pos.x() - cur->pos.x() < -EPS) {
        REP(diff, K) {
          Vec2 p = Vec2(static_cast<int>(nextState->pos.x()) + 1 + diff + 0.01f, nextState->pos.y());
          if (aStage.isOutOfBounds(p.toVector2())) break;
          ASSERT(!samePlace(p, nextState->pos, false));
          auto t = aStage.terrain(p.toVector2());
          if (t > minT || t >= afterT) continue;
          float d = (g - p).lengthSq();
          if (t == minT && d >= minD) continue;
          if (!canMove(cur->pos, p, aStage, power)) break;
          if (!canMove(p, nextNextPos, aStage, power)) break;

          minT = t;
          minP = p;
          minD = d;
        }
      }
      // up
      if (nextState->pos.y() - cur->pos.y() > EPS) {
        REP(diff, K) {
          Vec2 p = Vec2(nextState->pos.x(), static_cast<int>(nextState->pos.y()) - diff - 0.01f);
          if (aStage.isOutOfBounds(p.toVector2())) break;
          ASSERT(!samePlace(p, nextState->pos, false));
          auto t = aStage.terrain(p.toVector2());
          if (t > minT || t >= afterT) continue;
          float d = (g - p).lengthSq();
          if (t == minT && d >= minD) continue;
          if (!canMove(cur->pos, p, aStage, power)) break;
          if (!canMove(p, nextNextPos, aStage, power)) break;

          minT = t;
          minP = p;
          minD = d;
        }
      }
      // down
      if (nextState->pos.y() - cur->pos.y() < -EPS) {
        REP(diff, K) {
          Vec2 p = Vec2(nextState->pos.x(), static_cast<int>(nextState->pos.y()) + 1 + diff + 0.01f);
          if (aStage.isOutOfBounds(p.toVector2())) break;
          ASSERT(!samePlace(p, nextState->pos, false));
          auto t = aStage.terrain(p.toVector2());
          if (t > minT || t >= afterT) continue;
          float d = (g - p).lengthSq();
          if (t == minT && d >= minD) continue;
          if (!canMove(cur->pos, p, aStage, power)) break;
          if (!canMove(p, nextNextPos, aStage, power)) break;

          minT = t;
          minP = p;
          minD = d;
        }
      }

      if (minT < afterT) {

        // 進む距離が、可能ジャンプ距離より小さいと（多くの場面で）損であるため、ジャンプ可能距離ぎりぎりでいい感じの遷移先がないか探し、あればそこに変更する

        Vec2 p = nextState->pos;
        nextState->pos = minP;
        nextState->terrain = aStage.terrain(minP.toVector2());
        if (option.useRotation) {
          State* nextNextState = getNextState(nextState, nextState->dir, g, power, aStage, option, false);
          if (nextNextState != nullptr) {

            Vec2 dir1 = nextNextState->pos - nextState->pos;

            bool baseFlip = (p - cur->pos).cross(nextState->pos - cur->pos) < 0;
            REP(flip, 2) {
              Vec2 q = findBetterPositionByRotation(cur->pos, p, aStage, power, baseFlip^flip);
              if (q.x() < 0) continue;
              // if (!canMove(q, nextNextState->pos, aStage, power)) continue;

              Vec2 dir2 = q - nextState->pos;
              if (
                dir1.dot(dir2) > 0
              ) {
                nextState->pos = q;
                nextState->terrain = aStage.terrain(q.toVector2());
                break;
              }
            }

            removeBackPoolN(1);
          }
        } else {
          // 回転の代わりの軽量な手抜き処理
          Vec2 newDir = nextState->pos - cur->pos;
          if (std::abs(newDir.x()) < EPS || std::abs(newDir.y()) < EPS) {
            Vec2 q = aStage.getNextPos(
              cur->pos.toVector2(), power, (cur->pos + (newDir * 100.f)).toVector2()
            );
            if (!aStage.isOutOfBounds(q.toVector2())) {
              nextState->pos = q;
              nextState->terrain = aStage.terrain(q.toVector2());
            }
          }
        }
      }
    }

    return nextState;
  }

  // sからg1への遷移に対して、"回転"を用いてg1より良い感じの場所を探して返す
  //// 存在しない場合はVec2(-1, -1)を返す
  Vec2 findBetterPositionByRotation(const Vec2& s, const Vec2& g1, const Stage& aStage, const float power, const bool flip) {
    Vec2 dir = g1 - s;

    auto t1 = aStage.isOutOfBounds(g1.toVector2()) ? Terrain::Pond : aStage.terrain(g1.toVector2());

    float len = Parameter::JumpTerrianCoefficient[(int)aStage.terrain(s.toVector2())] * power;
    double theta = PI / (2.2 * sqrt(1.0 + len));
    if (flip) theta *= -1;

    Vec2 g2 = aStage.getNextPos(
      s.toVector2(), power, (s + dir.rotate(theta)).toVector2()
    );
    if (aStage.isOutOfBounds(g2.toVector2())) return Vec2(-1, -1);
    auto t2 = aStage.terrain(g2.toVector2());
    if (t2 >= t1) return Vec2(-1, -1);

    // 二分探索で境界を見つける

    double ng = 0;
    Vec2 ngV = g1;
    double ok = theta;
    Vec2 okV = g2;

    constexpr float THRESHOLD = 0.1f;
    while((okV - ngV).lengthSq() > THRESHOLD*THRESHOLD) {
      double mid = (ng + ok)/2;
      Vec2 g3 = aStage.getNextPos(
        s.toVector2(), power, (s + dir.rotate(mid)).toVector2()
      );
      if (aStage.isOutOfBounds(g3.toVector2())) {
        ng = mid;
        ngV = g3;
      } else {
        auto t3 = aStage.terrain(g3.toVector2());
        if (t3 < t1) {
          ok = mid;
          okV = g3;
        } else {
          ng = mid;
          ngV = g3;
        }
      }
    }
    ASSERT(aStage.terrain(okV.toVector2()) < t1);
    return okV;
  }

} gBeamSearch;

// TSPで用いるビームサーチの設定値（かなり計算負荷が小さめ）
constexpr BeamSearch::Option BEAM_SEARCH_OPTION_FOR_TSP = {
  0, // index

  2,       // beamWidth
  5,       // numTheta
  PI / 10,  // stepTheta
  20,     // spreadStep
  2.3f,    // ignoredDistThrehold
  0,       // resultDepthThresholdDiff
  false,   // useRotation
  false,   // checkExactly
};


// パスを決定するメイン処理におけるビームサーチの設定（比較的計算負荷が大きめ）
constexpr BeamSearch::Option BEAM_SEARCH_OPTION_FOR_MAIN_SOLVER = {
  1, // index

  5,      // beamWidth
  16,      // numTheta
  PI / 20, // stepTheta
  1,       // spreadStep
  0.2f,    // ignoredDistThrehold
  10,       // thresholdDiff
  true,    // useRotation
  false,   // checkExactly
};

// 巻物の取得位置を決定するときのビームサーチの設定
constexpr BeamSearch::Option BEAM_SEARCH_OPTION_FOR_CALCULATING_TARGETS = {
  2, // index

  2,       // beamWidth
  6,      // numTheta
  PI / 10, // stepTheta
  4,       // spreadStep // TODO: 1にしたい
  0.2f,    // ignoredDistThrehold
  0,       // resultDepthThresholdDiff
  true,    // useRotation
  false,   // checkExactly
};

// パス最適化時のビームサーチの設定
constexpr BeamSearch::Option BEAM_SEARCH_OPTION_FOR_OPTIMIZING_PATHS = {
  3, // index

  2,       // beamWidth
  2,       // numTheta
  PI / 10, // stepTheta
  20,    // spreadStep
  2.1f,    // ignoredDistThrehold
  0,       // resultDepthThresholdDiff
  true,    // useRotation
  true,   // checkExactly
};

constexpr std::array<BeamSearch::Option, 4> BEAM_SEARCH_OPTIONS = {
  BEAM_SEARCH_OPTION_FOR_TSP,
  BEAM_SEARCH_OPTION_FOR_MAIN_SOLVER,
  BEAM_SEARCH_OPTION_FOR_CALCULATING_TARGETS,
  BEAM_SEARCH_OPTION_FOR_OPTIMIZING_PATHS
};

void setCosAndSinValues() {
  // L^p
  constexpr float p = 1.3f;

  for(const auto& option : BEAM_SEARCH_OPTIONS) {
    FOR(j, 1, option.numTheta + 1) {
      // double theta = option.stepTheta * j;
      float t = std::pow(j/(float)(option.numTheta), p);
      float theta = option.stepTheta * option.numTheta * t;

      gCosValues[option.index][j] = cos(theta);
      gSinValues[option.index][j] = sin(theta);
    }
  }
}

//==================================================================
// Tsp: TSPを解くクラス
//==================================================================

constexpr int TSP_SIZE_LIMIT = Parameter::MaxScrollCount;

class Tsp {

private:
  // mDp[bits][i]: bitsの立っているビットがすでに到達済みで、現在i番目の巻物にいるときのかかったターン数
  std::array<
    std::array<float, TSP_SIZE_LIMIT>,
    (1<<TSP_SIZE_LIMIT)
  > mDp;

  // 復元用に逆辺を保存する
  std::array<
    std::array<int, TSP_SIZE_LIMIT>,
    (1<<TSP_SIZE_LIMIT)
  > mRev;

  // mDsss[i][j][k]: 巻物取得数k個のときの、i番目の巻物からj番目の巻物への必要ターン数
  std::array<
    std::array<
      std::array<float, TSP_SIZE_LIMIT>,
      TSP_SIZE_LIMIT
    >,
    TSP_SIZE_LIMIT
  > mDsss;
  // mLowerDsss[i][j][k]: mDsss[i][j][k]の下界（枝刈り用）
  std::array<
    std::array<
      std::array<int, TSP_SIZE_LIMIT>,
      TSP_SIZE_LIMIT
    >,
    TSP_SIZE_LIMIT
  > mLowerDsss;

  // mPopcounts[bits]; bitsの立っているビットの個数
  std::array<int, 1<<Parameter::MaxScrollCount> mPopcounts;
  // mBitsToOnes[bits]: bitsの立っているビットの位置の配列
  std::array<std::vector<int>, 1<<Parameter::MaxScrollCount> mBitsToOnes;
  // mBitsToOnes[bits]: bitsの立っていないビットの位置の配列
  std::array<std::vector<int>, 1<<Parameter::MaxScrollCount> mBitsToZeros;

  // 一時的なパス
  std::deque<Vec2> mTmpPath;

public:
  Tsp() {
    // 前計算
    REP(bits, 1<<Parameter::MaxScrollCount) {
      mPopcounts[bits] = popcount(bits);
    }
    REP(bits, 1<<Parameter::MaxScrollCount) {
      REP(i, Parameter::MaxScrollCount) {
        if (bits>>i&1) {
          mBitsToOnes[bits].push_back(i);
        } else {
          mBitsToZeros[bits].push_back(i);
        }
      }
    }
  }

  void solve(
    const Stage& aStage,

    // 最適な順番のインデックス
    std::array<int, TSP_SIZE_LIMIT>& resultIndices
  ) {
    int size = aStage.scrolls().count();

    ASSERT(size <= TSP_SIZE_LIMIT);
    ASSERT(size > 0);

    clear(size);

    // 初期位置から最初の巻物へのDPの計算
    REP(bits, 1<<size) REP(i, size) {
      mDp[bits][i] = FLOAT_INF;
      mRev[bits][i] = -1;
    }

    // 下界を前計算しておく
    REP(i, size) REP(j, size) REP(k, size) {
      mLowerDsss[i][j][k] = calcLowerDist(
        aStage.scrolls()[i].pos(),
        aStage.scrolls()[j].pos(),
        k
      );
    }

    int resultD = INT_INF;
    int resultI = -1;

    {
      // 先にNearest Neighborで貪欲する
      //// あとで枝刈りに利用する

      int i = -1;
      int bits = 0;

      { // k = 0
        int minD = INT_INF;
        int minJ = -1;
        REP(j, size) {
          int d = calcDist(
            aStage.rabbit().pos(),
            aStage.scrolls()[j].pos(),
            aStage,
            0,
            resultD
          );
          mDp[1<<j][j] = d;
          if (d < minD) {
            minD = d;
            minJ = j;
          }
        }
        ASSERT(minJ >= 0);

        i = minJ;
        bits = 1<<i;
      }

      FOR(k, 1, size) {
        ASSERT(bits>>i&1);
        int minD = INT_INF;
        int minJ = -1;

        for (const int j : mBitsToZeros[bits]) {
          if (j >= size) break;
          int next = bits|(1<<j);
          int d = mDp[bits][i] + getDist(i, j, k, aStage, resultD);
          if (d < mDp[next][j]) {
            mDp[next][j] = d;
            mRev[next][j] = i;
            if (d < minD) {
              minD = d;
              minJ = j;
            }
          }
        }

        ASSERT(minJ >= 0);

        i = minJ;
        bits |= 1<<i;
      }

      ASSERT(bits == (1<<size)-1);
      resultD = mDp[bits][i];
      resultI = i;
    }

    // DP本体の計算
    FOR(bits, 1, (1<<size)-1) {
      for (const int i : mBitsToOnes[bits]) {
        if (mDp[bits][i] + (size - mPopcounts[bits]) >= resultD) continue;
        int k = mPopcounts[bits];
        for (const int j : mBitsToZeros[bits]) {
          if (j >= size) break;
          int next = bits|(1<<j);
          ASSERT(mPopcounts[next] == k + 1);

          // 枝刈り
          int lowerD = mDp[bits][i] + mLowerDsss[i][j][k];
          if (lowerD >= mDp[next][j]) continue;
          if (lowerD + (size - mPopcounts[next]) >= resultD) continue;

          int d = mDp[bits][i] + getDist(i, j, k, aStage, resultD);
          if (d < mDp[next][j]) {
            mDp[next][j] = d;
            mRev[next][j] = i;

            if (k == size-1 && d < resultD) {
              ASSERT(next == (1<<size)-1);
              resultD = d;
              resultI = j;
            }
          }
        }
      }
    }

    ASSERT(resultI >= 0);

    // 経路を復元する

    int index = resultI;
    resultIndices[size - 1] = index;

    int bits = (1<<size) - 1;
    REP_R(i, size-1) {
      ASSERT(bits>>index&1);
      int prev = bits^(1<<index);
      int prevIndex = mRev[bits][index];
      ASSERT(prev>>prevIndex&1);
      resultIndices[i] = prevIndex;

      bits = prev;
      index = prevIndex;
    }

    ASSERT(mRev[bits][index] == -1);
    ASSERT(mPopcounts[bits] == 1);
  }

private:
  // 初期化
  void clear(const int size) {
    REP(i, size) REP(j, size) {
      FOR(k, 1, size) {
        mDsss[i][j][k] = -1;
      }
    }
  }

  // k個の巻物を取得しているときの、iからjまでの必要ターン数を返す
  //// mDsssはmemoizeしておく
  float getDist(int i, int j, int k, const Stage& aStage, const int distLimit) {
    ASSERT(i != j);
    ASSERT(k > 0);

    if (mDsss[i][j][k] >= 0) {
      return mDsss[i][j][k]; // memoizeされているものはそのまま返す
    }

    // 計算をサボる
    int size = aStage.scrolls().count();
    int T = 9;
    if (size > 10 && (k - 1)%T != 0) {
      int k2 = k - (k - 1)%T;
      return mDsss[i][j][k] =
        getDist(i, j, k2, aStage, distLimit)
        * gPowers[k2] / gPowers[k]; // powerの比を考慮する
    }

    return mDsss[i][j][k] = calcDist(
      aStage.scrolls()[i].pos(),
      aStage.scrolls()[j].pos(),
      aStage,
      k,
      distLimit
    );
  }

  // k個の巻物を取得しているときの、iからjまでの必要ターン数を実際に計算する
  int calcDist(const Vec2& s, const Vec2& g, const Stage& aStage, const int gottenScrollCount, const int distLimit) {
    bool exists = gBeamSearch.solvePath(
      s,
      g,
      aStage,
      gottenScrollCount,
      BEAM_SEARCH_OPTION_FOR_TSP,
      distLimit,
      mTmpPath
    );
    return exists ? mTmpPath.size() : INT_INF;
  }

  // gottenScrollCount個の巻物を取得しているときの、i番目の巻物からj番目の巻物への必要ターン数の下界を返す
  int calcLowerDist(const Vec2& s, const Vec2& g, int gottenScrollCount) {
    return gBeamSearch.calcLowerDist(s, g, gottenScrollCount);
  }
} gTsp;

//==================================================================
// Solver: 本プログラムの本体
//==================================================================

class Solver {

private:
  // 訪れる巻物のインデックスを順番通りに保持する配列
  std::array<int, Parameter::MaxScrollCount> mTargetScrollIndices;

  // 前ターンで巻物の取得状態に変化が生じたか？
  bool mPrevScrollChanged;
  // 移動場所を並べたパス
  // mPathの先頭が次の移動場所に該当する
  std::deque<Vec2> mPath;

  // mScrollTargetPositions[index]: index番目の巻物の取得位置
  //// マスの真ん中とは限らない
  std::array<Vec2, Parameter::MaxScrollCount> mScrollTargetPositions;

  // 一時的なパス
  std::deque<Vec2> mTmpPath;

  // 今目指している巻物のインデックス
  int mNextScrollIndex;
  // 現在の取得済み巻物の個数
  int mGottenScrollCount;

public:
  Solver()
  : mTargetScrollIndices()
  , mPrevScrollChanged(false) {
  }

  // ステージに対する前計算と初期化
  void initialize(const Stage& aStage) {
    // TSPによって訪れる巻物の順番を決定
    PROFILE_BEGIN("TSP");
    solveTsp(aStage);
    PROFILE_END("TSP");

    // 書く巻物の取得位置を計算
    PROFILE_BEGIN("calcScrollTargetPositions");
    calcScrollTargetPositions(aStage);
    PROFILE_END("calcScrollTargetPositions");

    mPrevScrollChanged = true;
    mGottenScrollCount = 0;
  }

  void beforeExec(const Stage& aStage) {
    if (mPrevScrollChanged) {
      // 巻物の取得状況に変化があった場合は、次のパスを計算する

      PROFILE_BEGIN("solvePath");

      mPrevScrollChanged = false;
      mNextScrollIndex = -1;

      const auto& scrolls = aStage.scrolls();
      REP(i, scrolls.count()) {
        int index = mTargetScrollIndices[i];
        if (scrolls[index].isGotten()) continue;
        mNextScrollIndex = index;
        break;
      }
      ASSERT(mNextScrollIndex >= 0);

      Vec2 targetPos = mScrollTargetPositions[mNextScrollIndex];

      bool exists __attribute__((unused)) = gBeamSearch.solvePath(
        aStage.rabbit().pos(),
        targetPos,
        aStage,
        mGottenScrollCount,
        BEAM_SEARCH_OPTION_FOR_MAIN_SOLVER,
        Parameter::GameTurnLimit,
        mPath // ビームサーチの結果はmPathに反映される
      );
      ASSERT(exists);

      PROFILE_END("solvePath");

      PROFILE_BEGIN("optimizePath");

      // パスをより良いものに変更できるか試みる
      optimizePath(aStage);
      ASSERT(!mPath.empty());

      PROFILE_END("optimizePath");
    }
  }

  Vector2 exec(const Stage& aStage) {
    UNUSE(aStage);

    // mPathの先頭から逐次取ってきて、次の移動場所にする
    ASSERT(!mPath.empty());
    Vector2 nextPos = mPath.front().toVector2();
    mPath.pop_front();

    return nextPos;
  }

  void afterExec(const Stage& aStage, const Vector2& aNextPos) {
    for(const auto& scroll : aStage.scrolls()) {
      if (scroll.isGotten()) continue;
      if (samePlace(scroll.pos(), aNextPos, false)) {
        // 巻物の取得を検知した場合は、次のパスを計算できるようにフラグを付ける
        mPrevScrollChanged = true;
        mGottenScrollCount++;
        break;
      }
    }
  }

  // ステージ終了処理
  //// とくにやることなかった
  void finalize(const Stage& aStage) {
    UNUSE(aStage);
  }

private:
  // TSPの計算
  void solveTsp(const Stage& aStage) {
    gTsp.solve(aStage, mTargetScrollIndices);
  }

  // 巻物の取得位置を計算
  void calcScrollTargetPositions(const Stage& aStage) {
    const auto& scrolls = aStage.scrolls();
    const int size = scrolls.count();

    REP(i, size) {
      const int index1 = mTargetScrollIndices[i];
      mScrollTargetPositions[index1] = scrolls[index1].pos();
    }

    REP_R(i, size - 1) {
      const int index1 = mTargetScrollIndices[i];
      const int index2 = mTargetScrollIndices[i + 1];

      bool exists __attribute__((unused)) = gBeamSearch.solvePath(
        scrolls[index1].pos(),
        mScrollTargetPositions[index2],
        aStage,
        i + 1,
        BEAM_SEARCH_OPTION_FOR_CALCULATING_TARGETS,
        Parameter::GameTurnLimit,
        mTmpPath
      );
      ASSERT(exists);
      Vec2 nextPos = mTmpPath[0];

      ASSERT(!aStage.isOutOfBounds(nextPos.toVector2()));

      mScrollTargetPositions[index1] = getModifiedScrollPos(scrolls[index1].pos(), nextPos);
    }
  }

  // 巻物の位置scrollPosを、nextPosに近い位置にずらしたものを返す
  Vec2 getModifiedScrollPos(const Vec2& scrollPos, const Vec2& nextPos) {
    Vec2 dir = nextPos - scrollPos;
    ASSERT(dir.length() > EPS);
    float D = 0.5f - (
      std::abs(dir.x()) < EPS || std::abs(dir.y()) < EPS
        ? 0.005f // 辺
        : 0.02f  // 角 （誤差がこわいので緩めに）
    );
    float dx = dir.x() > EPS ? D : dir.x() < -EPS ? -D : 0;
    float dy = dir.y() > EPS ? D : dir.y() < -EPS ? -D : 0;
    ASSERT(samePlace(scrollPos + Vec2(dx, dy), scrollPos, false));
    return scrollPos + Vec2(dx, dy);
  }

  // パスmPathを雑な計算で最適化する
  //// もう少しまともにできそう
  void optimizePath(const Stage& aStage) {

    FOR_R(l, 3, (int)mPath.size()) {
      REP(i, (int)mPath.size() - l) {
        int n = mPath.size();
        int j = i + l;
        if (j >= (int)mPath.size()) break;

        Vec2 s = mPath[i];
        Vec2 g = mPath[j];

        // パスのi番目からj番目の経路を短くできないか試みる

        bool exists = gBeamSearch.solvePath(
          s,
          g,
          aStage,
          mGottenScrollCount,
          BEAM_SEARCH_OPTION_FOR_OPTIMIZING_PATHS,
          j-i-1,
          mTmpPath
        );
        if (!exists) continue;
        ASSERT((int)mTmpPath.size() < j-i);

        ASSERT(samePlace(mTmpPath.back(), g, true));

        if (j < n-1) {
          // どうあがいてもfloatの誤差で無理なときはある
          if (!canMove(mTmpPath.back(), mPath[j+1], aStage, gPowers[mGottenScrollCount])) {
            continue;
          }
        }

        // 短くできた場合はmPathを更新する
        PRINT("optimized: %d", (j-i) - (int)mTmpPath.size());
        if (n - j - 1 < i + 1) {
          FOR(k, j+1, n) {
            mTmpPath.push_back(mPath[k]);
          }
          FOR(k, i+1, n) {
            mPath.pop_back();
          }
          while(!mTmpPath.empty()) {
            mPath.push_back(mTmpPath.front());
            mTmpPath.pop_front();
          }
        } else {
          FOR_R(k, 0, i + 1) {
            mTmpPath.push_front(mPath[k]);
          }
          FOR_R(k, 0, j + 1) {
            mPath.pop_front();
          }
          while(!mTmpPath.empty()) {
            mPath.push_front(mTmpPath.back());
            mTmpPath.pop_back();
          }
        }
      }
    }
  }

} gSolver;

//==================================================================
// Answer
//==================================================================

Answer::Answer() {
  float power = 1.0f;
  REP(i, Parameter::MaxScrollCount) {
    gPowers[i] = power;
    power *= Parameter::JumpPowerUpRate;
  }

  setCosAndSinValues();
}

Answer::~Answer() {
  TIMESTAMP("Finished");
  PRINT_PROFILING();
}

void Answer::initialize(const Stage& aStage) {
  PRINT("Stage index: %d", gStageIndex);
  TIMESTAMP("Begin");
  gSolver.initialize(aStage);
}

Vector2 Answer::getTargetPos(const Stage& aStage) {
  gSolver.beforeExec(aStage);
  Vector2 pos = gSolver.exec(aStage);
  gSolver.afterExec(aStage, pos);
  return pos;
}

void Answer::finalize(const Stage& aStage) {
  gSolver.finalize(aStage);
  #ifdef LOCAL
    gStageIndex++;
  #endif
  TIMESTAMP("End");
}

} // namespace
