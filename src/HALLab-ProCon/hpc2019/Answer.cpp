/*
    ハル研究所プログラミングコンテスト2019
    https://www.hallab.co.jp/progcon/2019/
*/

#include "Answer.hpp"

#include <algorithm>
#include <numeric>
#include <cmath>
#include <functional>
#include <array>
#include <vector>
#include <queue>
#include <stack>
#include <bitset>

#define REP(i, n) for(int (i)=0; (i) < static_cast<int>(n); (i)++)
#define REP_R(i, n) for(int (i)=static_cast<int>(n)-1; (i) >= 0; (i)--)
#define FOR(i, l, r) for(int (i)=static_cast<int>(l); (i) < static_cast<int>(r); (i)++)
#define FOR_R(i, l, r) for(int (i)=static_cast<int>(r)-1; (i) >= static_cast<int>(l); (i)--)
#define ALL(xs) (xs).begin(), (xs).end()

// E.g. PRINT("%d, %d", x, y)
//   $ ./hpc2019.exe -j > output.json
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

#define UNUSE(aExp) (void)(aExp)


namespace hpc {

//==============================================================================

namespace MyParameter {
  constexpr int TSP_THRESHOLD = 11; // maximum: 20
  constexpr int MAX_GROUP_COUNT = 50;
}

//==============================================================================

constexpr int INT_INF = std::numeric_limits<int>::max()/3;
constexpr double DOUBLE_INF = 1.0e20;

class Config;
class DoublePoint;
class MyFood;
class Turtle;
class Group;
class MyStage;
class Solver;
class Emulator;

//==============================================================================

class Config {

public:
  Config()
  : RANDOM_SEED(RandomSeed::DefaultSeed()) {
  }

  void init() {
    mRnd = Random(RANDOM_SEED);
  }

  int groupCount(int foodCount) {
    int cnt = foodCount/GROUP_COUNT_DIV;
    ASSERT(cnt <= MyParameter::MAX_GROUP_COUNT);
    return cnt;
  }

  double distortCenterByHeight(const int h) {
    if (DISTORTION_POWER > 0.95) {
      return h;
    }
    return std::pow(h, DISTORTION_POWER);
  }

  Random& random() {
    return mRnd;
  }

  enum GroupSortPattern {
    GroupSortPattern_Default,
    GroupSortPattern_FirstFixed,
    GroupSortPattern_FirstCenter,

    GroupSortPattern_TERM,
  };

  int GROUP_COUNT_DIV;
  double DISTORTION_POWER;
  GroupSortPattern GROUP_SORT_PATTERN;
  RandomSeed RANDOM_SEED;

private:
  Random mRnd = Random(RandomSeed::DefaultSeed());

} gConfig;

//==============================================================================

class DoublePoint {

public:
  DoublePoint()
  : DoublePoint(-1, -1) {
  }

  DoublePoint(double aX, double aY)
  : x(aX), y(aY) {
  }

  DoublePoint(const Point& aPoint)
  : DoublePoint(aPoint.x, aPoint.y) {
  }

  double x;
  double y;
};

inline int dist(const Point& aPos1, const Point& aPos2) {
  return std::abs(aPos1.y - aPos2.y) + std::abs(aPos1.x - aPos2.x);
}

inline double dist(const DoublePoint& aPos1, const DoublePoint& aPos2) {
  return std::abs(aPos1.y - aPos2.y) + std::abs(aPos1.x - aPos2.x);
}

//==============================================================================

namespace Tsp {

  namespace DynamicProgramming {
    template <int TCapacity>
    void solve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  namespace NearestNeighbor {
    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  namespace Greedy {
    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  // Double Minimum Spanning Tree
  namespace Dmst {
    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  // Unimplemented: 実装したくない
  namespace Christofides {
  }

  namespace TwoOpt {
    template <int TCapacity>
    void improve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  namespace OrOpt {
    template <int TCapacity>
    void improve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    );
  }

  constexpr int TSP_UPPER_BOUND = 1000;

  std::array<
    std::array<double, TSP_UPPER_BOUND>,
    TSP_UPPER_BOUND
  > dss;

  // 始点と終点が異なるTSP（一周しない）
  template <int TCapacity>
  const Array<int, TCapacity>& solve(
    const Array<DoublePoint, TCapacity>& aPoints,
    const DoublePoint* aFirstPos = nullptr,
    const DoublePoint* aLastPos = nullptr
  ) {
    static_assert(TCapacity <= TSP_UPPER_BOUND, "");

    static Array<int, TCapacity> result;
    static Array<int, TCapacity> tmpResult;

    int N = aPoints.count();
    ASSERT(N > 0);

    REP(i, N) REP(j, N) {
      dss[i][j] = dist(aPoints[i], aPoints[j]);
    }

    result.clear();
    tmpResult.clear();
    REP(i, N) {
      // iota
      result.add(i);
      tmpResult.add(i);
    }

    if (N <= MyParameter::TSP_THRESHOLD) {
      // 厳密解
      DynamicProgramming::solve(aPoints, aFirstPos, aLastPos, result);
    } else {
      // 近似解

      double minD = DOUBLE_INF;
      double d;

      d = NearestNeighbor::build(aPoints, aFirstPos, aLastPos, tmpResult);
      if (d < minD) {
        minD = d;
        result.clear();
        for(const int i : tmpResult) {
          result.add(i);
        }
      }

      d = Greedy::build(aPoints, aFirstPos, aLastPos, tmpResult);
      if (d < minD) {
        minD = d;
        result.clear();
        for(const int i : tmpResult) {
          result.add(i);
        }
      }

      // d = Dmst::build(aPoints, aFirstPos, aLastPos, tmpResult);
      // if (d < minD) {
      //   minD = d;
      //   result.clear();
      //   for(const int i : tmpResult) {
      //     result.add(i);
      //   }
      // }

      // TODO: 2-opt, or-opt, etc.
      TwoOpt::improve(aPoints, aFirstPos, aLastPos, result);
      OrOpt::improve(aPoints, aFirstPos, aLastPos, result);
      TwoOpt::improve(aPoints, aFirstPos, aLastPos, result);
      OrOpt::improve(aPoints, aFirstPos, aLastPos, result);
    }

    return result;
  }

  namespace DynamicProgramming {

    std::array<
      std::array<double, MyParameter::TSP_THRESHOLD>,
      (1<<MyParameter::TSP_THRESHOLD)
    > dp;
    std::array<
      std::array<int, MyParameter::TSP_THRESHOLD>,
      (1<<MyParameter::TSP_THRESHOLD)
    > rev;

    template <int TCapacity>
    void solve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();
      ASSERT(N <= MyParameter::TSP_THRESHOLD);

      REP(bits, 1<<N) REP(i, N) {
        dp[bits][i] = DOUBLE_INF;
        rev[bits][i] = -1;
      }
      REP(i, N) {
        if (aFirstPos == nullptr) {
          dp[1<<i][i] = 0;
        } else {
          dp[1<<i][i] = dist(*aFirstPos, aPoints[i]);
        }
      }

      REP(bits, 1<<N) REP(i, N) {
        if (!(bits&(1<<i))) continue;
        REP(j, N) {
          if (bits&(1<<j)) continue;
          int next = bits|(1<<j);
          double d = dp[bits][i] + dss[i][j];
          if (d < dp[next][j]) {
            dp[next][j] = d;
            rev[next][j] = i;
          }
        }
      }

      double minD = DOUBLE_INF;
      int minI = -1;
      REP(i, N) {
        double d = dp[(1<<N)-1][i];
        ASSERT(d < DOUBLE_INF);
        if (aLastPos != nullptr) {
          d += dist(aPoints[i], *aLastPos);
        }
        if (d < minD) {
          minD = d;
          minI = i;
        }
      }
      ASSERT(minI >= 0);

      int i = minI;
      aResult[N-1] = i;

      int bits = (1<<N)-1;
      REP_R(k, N-1) {
        ASSERT(bits&(1<<i));
        int prev = bits^(1<<i);
        int j = rev[bits][i];
        ASSERT(prev&(1<<j));
        aResult[k] = j;

        bits = prev;
        i = j;
      }
      ASSERT(rev[bits][i] == -1);
      ASSERT(std::bitset<32>(bits).count() == 1);
    }
  } // namespace Tsp::DynamicProgramming

  namespace NearestNeighbor {

    std::array<bool, TSP_UPPER_BOUND> used;

    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();

      double minSumD = DOUBLE_INF;
      int minFirstIndex = -1;

      REP(firstIndex, N) {
        used.fill(false);

        double sumD = 0.0;

        int i = firstIndex;
        REP(k, N-1) {
          used[i] = true;
          double minD = DOUBLE_INF;
          int minJ = -1;
          REP(j, N) {
            if (used[j]) continue;
            double d = dss[i][j];
            if (d < minD) {
              minD = d;
              minJ = j;
            }
          }
          ASSERT(minJ != -1);

          sumD += minD;
          i = minJ;
        }

        int lastIndex = i;

        if (aFirstPos != nullptr) {
          sumD += dist(*aFirstPos, aPoints[firstIndex]);
        }
        if (aLastPos != nullptr) {
          sumD += dist(aPoints[lastIndex], *aLastPos);
        }

        if (sumD < minSumD) {
          minSumD = sumD;
          minFirstIndex = firstIndex;
        }
      }

      ASSERT(minFirstIndex != -1);
      used.fill(false);

      int i = minFirstIndex;
      aResult[0] = i;
      REP(k, N-1) {
        used[i] = true;
        double minD = DOUBLE_INF;
        int minJ = -1;
        REP(j, N) {
          if (used[j]) continue;
          double d = dss[i][j];
          if (d < minD) {
            minD = d;
            minJ = j;
          }
        }
        ASSERT(minJ != -1);

        i = minJ;
        aResult[k+1] = i;
      }

      return minSumD;
    }

  } // namespace Tsp::NearestNeighbor

  namespace Greedy {

    std::array<
      std::array<int, 2>,
      TSP_UPPER_BOUND
    > adjs;

    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();

      REP(i, N) REP(k, 2) {
        adjs[i][k] = -1;
      }

      double sumD = 0;
      REP(cnt, N) {
        double minD = DOUBLE_INF;
        int minI = -1;
        int minJ = -1;
        REP(i, N) REP(j, N) {
          if (i == j) continue;
          if (adjs[i][1] != -1) continue;
          if (adjs[j][1] != -1) continue;
          bool toLoop = false;
          {
            int s = j;
            int t = adjs[j][0];
            if (t == -1) {
            } else if (t == i) {
              toLoop = true;
            } else {
              while(true) {
                int u = adjs[t][0];
                if (u == s) u = adjs[t][1];
                if (u == -1) break;
                if (u == i) {
                  toLoop = true;
                  break;
                }
                s = t;
                t = u;
              }
            }
          }
          if (toLoop != (cnt == N-1)) continue;
          ASSERT(
            cnt < N-1 || toLoop
          );
          double d = dss[i][j];
          if (d < minD) {
            minD = d;
            minI = i;
            minJ = j;
          }
        }
        ASSERT(minI >= 0 && minJ >= 0 && minD < DOUBLE_INF);
        adjs[minI][adjs[minI][0] != -1] = minJ;
        adjs[minJ][adjs[minJ][0] != -1] = minI;
        sumD += minD;
      }

      #ifdef LOCAL
        REP(i, N) {
          ASSERT(adjs[i][0] != -1 && adjs[i][1] != -1);
        }
      #endif

      double minD = DOUBLE_INF;
      int minI = -1;
      int minJ = -1;
      REP(i, N) REP(k, 2) {
        int j = adjs[i][k];
        double d = sumD - dss[i][j];
        if (aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[j]);
        }
        if (aLastPos != nullptr) {
          d += dist(aPoints[i], *aLastPos);
        }
        if (d < minD) {
          minD = d;
          minI = i;
          minJ = j;
        }
      }
      ASSERT(minI >= 0 && minJ >= 0 && minD < DOUBLE_INF);

      int pointIndex = 0;
      aResult[pointIndex++] = minJ;
      int s = minI;
      int t = minJ;
      while(true) {
        int u = adjs[t][0];
        if (u == s) u = adjs[t][1];
        ASSERT(u != -1);
        aResult[pointIndex++] = u;
        if (u == minI) break;
        s = t;
        t = u;
      }

      return minD;
    }
  } // namespace Tsp::Greedy

  namespace Dmst {

    class Vertex {

    public:
      int index;
      Array<int, TSP_UPPER_BOUND> adjs;
      double cost;
      int revIndex;

      bool used;

      Vertex() {
      }

      void init(int aIndex) {
        index = aIndex;
        adjs.clear();
        cost = INT_INF;
        revIndex = -1;
        used = false;
      }
    };

    std::array<Vertex, TSP_UPPER_BOUND> vertices;

    std::priority_queue<
      std::pair<double, int>,
      std::vector<std::pair<double, int>>,
      std::greater<std::pair<double, int>>
    > vQueue;

    void calcMst(int N) {

      REP(i, N) {
        vertices[i].init(i);
      }

      vertices[0].cost = 0;
      while(!vQueue.empty()) vQueue.pop();
      vQueue.emplace(0, vertices[0].index);

      int cnt = 0;

      while(!vQueue.empty()) {
        double c = vQueue.top().first;
        Vertex& v = vertices[vQueue.top().second];
        vQueue.pop();
        if (v.used) continue;
        v.used = true;
        ASSERT(c == v.cost);
        UNUSE(c);

        if (v.revIndex != -1) {
          Vertex& u = vertices[v.revIndex];
          u.adjs.add(v.index);
          v.adjs.add(u.index);
          cnt++;
        }

        REP(i, N) {
          if (i == v.index) continue;
          Vertex& u = vertices[i];
          if (u.used) continue;
          if (dss[v.index][u.index] < u.cost) {
            u.cost = dss[v.index][u.index];
            u.revIndex = v.index;
            vQueue.emplace(u.cost, u.index);
          }
        }
      }

      ASSERT(cnt == N-1);
    }

    Array<int, 2*TSP_UPPER_BOUND> eulerTourIndices;
    std::array<int, TSP_UPPER_BOUND> eulerTourCounts;
    std::array<bool, TSP_UPPER_BOUND> eulerTourUsed;

    void eulerTour(int N, int firstIndex) {
      eulerTourIndices.clear();
      REP(i, N) {
        eulerTourCounts[i] = 0;
        eulerTourUsed[i] = false;
      }

      std::stack<int> st;
      eulerTourUsed[firstIndex] = true;
      st.push(firstIndex);
      while(!st.empty()) {
        Vertex& v = vertices[st.top()];

        if (eulerTourCounts[v.index] == v.adjs.count()) {
          eulerTourIndices.add(v.index);
          st.pop();
        } else {
          int i = v.adjs[eulerTourCounts[v.index]++];
          if (eulerTourUsed[i]) continue;
          eulerTourIndices.add(v.index);
          eulerTourUsed[i] = true;
          st.push(i);
        }
      }

      ASSERT(eulerTourIndices.count() == 2*N - 1);
      ASSERT(eulerTourIndices[0] == firstIndex);
      ASSERT(eulerTourIndices[eulerTourIndices.count() - 1] == firstIndex);
    }

    std::array<bool, TSP_UPPER_BOUND> dmstUsed;

    template <int TCapacity>
    double build(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();

      calcMst(N);

      double minD = DOUBLE_INF;
      int minFirstIndex = -1;

      REP(firstIndex, N) {
        eulerTour(N, firstIndex);

        dmstUsed.fill(false);

        double d = 0;
        int prevJ = -1;
        for(const int j : eulerTourIndices) {
          if (dmstUsed[j]) continue;
          dmstUsed[j] = true;
          if (prevJ != -1) {
            d += dss[prevJ][j];
          }
          prevJ = j;
        }

        int lastIndex = prevJ;

        if (aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[firstIndex]);
        }
        if (aLastPos != nullptr) {
          d += dist(aPoints[lastIndex], *aLastPos);
        }

        if (d < minD) {
          minD = d;
          minFirstIndex = firstIndex;
        }
      }

      ASSERT(minFirstIndex != -1);

      eulerTour(N, minFirstIndex);

      dmstUsed.fill(false);

      int cnt = 0;
      for(const int j : eulerTourIndices) {
        if (dmstUsed[j]) continue;
        dmstUsed[j] = true;
        aResult[cnt++] = j;
      }

      ASSERT(cnt == N);

      return minD;
    }

  } // namespace Tsp::Dmst

  namespace TwoOpt {

    template <int TCapacity>
    void improve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();

      bool improved = true;
      while(improved) {
        improved = false;
        FOR(i1, 0, N-2) {
          int i2 = i1+1;
          FOR(j1, i1+2, N-1) {
            int j2 = j1+1;
            double oldD = dss[aResult[i1]][aResult[i2]] + dss[aResult[j1]][aResult[j2]];
            double newD = dss[aResult[i1]][aResult[j1]] + dss[aResult[i2]][aResult[j2]];
            if (newD < oldD) {
              improved = true;
              REP(k, (j1-i1)/2) {
                std::swap(aResult[i2+k], aResult[j1-k]);
              }
            }
          }
        }
        FOR(i1, 0, N-2) {
          int i2 = i1+1;
          int j1 = N-1;
          // int j2 = 0;
          double oldD = dss[aResult[i1]][aResult[i2]] + 0.0;
          double newD = dss[aResult[i1]][aResult[j1]] + 0.0;
          if (aLastPos != nullptr) {
            oldD += dist(aPoints[aResult[j1]], *aLastPos);
            newD += dist(aPoints[aResult[i2]], *aLastPos);
          }
          if (newD < oldD) {
            improved = true;
            REP(k, (j1-i1)/2) {
              std::swap(aResult[i2+k], aResult[j1-k]);
            }
          }
        }
        FOR(j1, 1, N-2) {
          // int i1 = N-1;
          int i2 = 0;
          int j2 = j1+1;
          double oldD = 0.0 + dss[aResult[j1%N]][aResult[j2%N]];
          double newD = 0.0 + dss[aResult[i2%N]][aResult[j2%N]];
          if (aFirstPos != nullptr) {
            oldD += dist(*aFirstPos, aPoints[aResult[i2%N]]);
            newD += dist(*aFirstPos, aPoints[aResult[j1%N]]);
          }
          if (newD < oldD) {
            improved = true;
            REP(k, (j2-i2)/2) {
              std::swap(aResult[i2+k], aResult[j1-k]);
            }
          }
        }
      }
    }
  } // namespace Tsp::TwoOpt

  namespace OrOpt {

    template <int TCapacity>
    void improve(
      const Array<DoublePoint, TCapacity>& aPoints,
      const DoublePoint* aFirstPos,
      const DoublePoint* aLastPos,
      Array<int, TCapacity>& aResult
    ) {
      int N = aPoints.count();

      int MAX_CONS_LEN = 5;

      const auto getOldD = [
        N, &aPoints, aFirstPos, aLastPos, &aResult
      ](const int i, const int j, const int consLen) -> double {
        ASSERT(j < i-1 || i-1+consLen < j);
        double d = 0.0;
        if (i != 0) {
          d += dss[aResult[i-1]][aResult[i  ]];
        } else if (i == 0 && aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[aResult[i  ]]);
        }
        if (i+consLen != N) {
          d += dss[aResult[i-1+consLen]][aResult[i+consLen]];
        } else if (i+consLen == N && aLastPos != nullptr) {
          d += dist(aPoints[aResult[i-1+consLen]], *aLastPos);
        }
        if (j != -1 && j != N-1) {
          d += dss[aResult[j  ]][aResult[j+1]];
        } else if (j == -1 && aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[aResult[j+1]]);
        } else if (j == N-1 && aLastPos != nullptr) {
          d += dist(aPoints[aResult[j  ]], *aLastPos);
        }
        return d;
      };

      const auto getNewD = [
        N, &aPoints, aFirstPos, aLastPos, &aResult
      ](const int i, const int j, const int consLen) -> double {
        ASSERT(j < i-1 || i-1+consLen < j);
        double d = 0.0;
        if (i != 0 && i+consLen != N) {
          d += dss[aResult[i-1]][aResult[i+consLen]];
        } else if (i == 0 && aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[aResult[i+consLen]]);
        } else if (i+consLen == N && aLastPos != nullptr) {
          d += dist(aPoints[aResult[i-1]], *aLastPos);
        }
        if (j != -1) {
          d += dss[aResult[j  ]][aResult[i  ]];
        } else if (j == -1 && aFirstPos != nullptr) {
          d += dist(*aFirstPos, aPoints[aResult[i  ]]);
        }
        if (j != N-1) {
          d += dss[aResult[i-1+consLen]][aResult[j+1]];
        } else if (j == N-1 && aLastPos != nullptr) {
          d += dist(aPoints[aResult[i-1+consLen]], *aLastPos);
        }
        return d;
      };

      static Array<int, TSP_UPPER_BOUND> tmpInds;

      bool improved = true;
      while(improved) {
        improved = false;

        FOR(consLen, 1, MAX_CONS_LEN + 1) {

          FOR(i, 0, N+1-consLen) {
            double maxDiff = -DOUBLE_INF;
            int maxJ = -1;

            FOR(j, -1, N) {
              if (i-1 <= j && j <= i-1+consLen) continue;
              double oldD = getOldD(i, j, consLen);
              double newD = getNewD(i, j, consLen);
              double diff = oldD - newD;
              if (diff > maxDiff) {
                maxDiff = diff;
                maxJ = j;
              }
            }

            if (maxDiff > 0.01) {
              improved = true;
              tmpInds.clear();
              FOR(k, i, i+consLen) {
                tmpInds.add(aResult[k]);
              }
              if (maxJ < i-1) {
                FOR_R(j, maxJ+1, i) {
                  aResult[j+consLen] = aResult[j];
                }
                REP_R(k, consLen) {
                  aResult[maxJ+k+1] = tmpInds[k];
                }
              } else if (maxJ > i-1+consLen) {
                FOR(j, i, maxJ-consLen+1) {
                  aResult[j] = aResult[j+consLen];
                }
                REP(k, consLen) {
                  aResult[maxJ-consLen+1+k] = tmpInds[k];
                }
              }
            }
          }

        }
      }
    }
  } // namespace Tsp::OrOpt
} // namespace Tsp

//==============================================================================

class MyFood {

private:
  int mIndex;

  Point mPosition;
  int mHeight;
  bool mIsEaten;

  Group* mGroup;

  MyFood* mPrevFood;
  MyFood* mNextFood;

  int mTtl;

public:
  MyFood() {
  }

  void init(int aIndex, const Food& aFood) {
    mIndex = aIndex;
    mPosition = aFood.pos();
    mHeight = aFood.height();
    mIsEaten = aFood.isEaten();
    mGroup = nullptr;
    mPrevFood = nullptr;
    mNextFood = nullptr;
    mTtl = INT_INF;
  }

  void beforeExec(bool aIsEaten) {
    mIsEaten = aIsEaten;
    mTtl = INT_INF;
  }

  inline int index() const {
    return mIndex;
  }

  const Point& pos() const {
    ASSERT(!isEaten());
    return mPosition;
  }

  inline int height() const {
    ASSERT(!isEaten());
    return mHeight;
  }

  inline bool isEaten() const {
    return mIsEaten;
  }

  inline Group* group() const {
    ASSERT(!isEaten());
    return mGroup;
  }

  void setGroup(Group* aGroup) {
    ASSERT(!isEaten());
    mGroup = aGroup;
  }

  inline MyFood* prevFood() const {
    ASSERT(!isEaten());
    return mPrevFood;
  }

  void setPrevFood(MyFood* aPrevFood) {
    ASSERT(!isEaten());
    mPrevFood = aPrevFood;
  }

  inline MyFood* nextFood() const {
    ASSERT(!isEaten());
    return mNextFood;
  }

  void setNextFood(MyFood* aNextFood) {
    ASSERT(!isEaten());
    mNextFood = aNextFood;
  }

  inline int ttl() const {
    ASSERT(!isEaten());
    return mTtl;
  }

  void setTtl(int aTtl) {
    ASSERT(!isEaten());
    mTtl = aTtl;
  }
};

//==============================================================================

class Turtle {

private:
  int mIndex;
  Point mPos;
  Point mTargetPos;

  bool mHasTarget;

  int mRedundancy;

  int mLastRedundancy;
  Point mLastTargetPos;

  Point mPrevTurnTargetPos;

public:
  Turtle() {
  }

  void init(int aIndex, const Point& aPos) {
    mIndex = aIndex;
    mPos = aPos;
    mTargetPos = aPos;
    mHasTarget = false;
    mRedundancy = 0;
    mLastRedundancy = 0;
    mLastTargetPos = aPos;
    mPrevTurnTargetPos = Point(-1, -1);
  }

  void beforeExec(const Point& aPos) {
    mPos = aPos;
    mTargetPos = aPos;
    mHasTarget = false;
    mRedundancy = 0;
    mLastRedundancy = 0;
    mLastTargetPos = aPos;
  }

  void afterExec() {
    mPrevTurnTargetPos = mTargetPos;
  }

  inline int index() const {
    return mIndex;
  }

  inline const Point& pos() const {
    return mPos;
  }

  inline const Point& targetPos() const {
    ASSERT(hasTarget());
    return mTargetPos;
  }

  inline bool hasTarget() const {
    return mHasTarget;
  }

  inline int redundancy() const {
    return mRedundancy;
  }

  void setRedundancy(int aRedundancy) {
    ASSERT(aRedundancy >= mRedundancy);
    mRedundancy = aRedundancy;
    setLastRedundancy(aRedundancy);
  }

  void setTargetFood(const MyFood* aFood) {
    setTargetPos(aFood->pos());
  }

  void setTargetPos(const Point& aTargetPos) {
    mTargetPos = aTargetPos;
    mHasTarget = true;
    mRedundancy = dist(pos(), aTargetPos);
    setLastTargetPos(aTargetPos);
  }

  void setLastTargetFood(const MyFood* aFood) {
    setLastTargetPos(aFood->pos());
  }

  inline int lastRedundancy() const {
    return mLastRedundancy;
  }

  void setLastRedundancy(int aLastRedundancy) {
    ASSERT(redundancy() > 0);
    mLastRedundancy = aLastRedundancy;
  }

  inline const Point& lastTargetPos() const {
    return mLastTargetPos;
  }

  void stay() {
    setTargetPos(pos());
  }

  inline const Point& prevTurnTargetPos() const {
    ASSERT(mPrevTurnTargetPos.x != -1 && mPrevTurnTargetPos.y != -1);
    return mPrevTurnTargetPos;
  }

private:
  void setLastTargetPos(const Point& aLastTargetPos) {
    ASSERT(mHasTarget);
    mLastTargetPos = aLastTargetPos;
  }

};

//==============================================================================

class Group {

private:
  int mIndex;

  Array<MyFood*, Parameter::MaxFoodCount> mFoods;
  int mMaxFoodHeight;

  Array<Turtle*, Parameter::MaxTurtleCount> mTurtles;

  DoublePoint mCenterPos;
  DoublePoint mPseudoCenterPos;

  Group* mPrevGroup;
  Group* mNextGroup;

public:
  Group()
  : mIndex(-1) {
  }

  void init(const Array<MyFood*, Parameter::MaxFoodCount>& aFoods) {
    mIndex = -1;
    mFoods.clear();
    mMaxFoodHeight = -1;
    mTurtles.clear();
    mCenterPos = DoublePoint();
    mPseudoCenterPos = DoublePoint();
    mPrevGroup = nullptr;
    mNextGroup = nullptr;
    for(MyFood* food : aFoods) {
      mFoods.add(food);
      food->setGroup(this);
    }
    updateFoods();
  }

  inline int index() const {
    return mIndex;
  }

  void setIndex(int aIndex) {
    mIndex = aIndex;
  }

  inline const Array<MyFood*, Parameter::MaxFoodCount>& foods() const {
    return mFoods;
  }

  inline const DoublePoint& centerPos() const {
    return mCenterPos;
  }

  inline const DoublePoint& pseudoCenterPos() const {
    return mPseudoCenterPos;
  }

  inline const Point& firstPos() const {
    ASSERT(!foods().isEmpty());
    return foods()[0]->pos();
  }

  inline const Point& lastPos() const {
    ASSERT(!foods().isEmpty());
    return foods()[foods().count() - 1]->pos();
  }

  inline Group* prevGroup() const {
    return mPrevGroup;
  }

  void setPrevGroup(Group* aPrevGroup) {
    mPrevGroup = aPrevGroup;
  }

  inline Group* nextGroup() const {
    return mNextGroup;
  }

  void setNextGroup(Group* aNextGroup) {
    mNextGroup = aNextGroup;
  }

  void updateFoods() {
    static Array<MyFood*, Parameter::MaxFoodCount> tmpFoods;
    tmpFoods.clear();
    for(MyFood* food : mFoods) {
      if (food->isEaten()) continue;
      tmpFoods.add(food);
    }
    mMaxFoodHeight = 0;
    mFoods.clear();
    for(MyFood* food : tmpFoods) {
      mMaxFoodHeight = std::max(mMaxFoodHeight, food->height());
      mFoods.add(food);
    }

    calcCenterPos();
    calcPseudoCenterPos();
  }

  inline int maxFoodHeight() const {
    return mMaxFoodHeight;
  }

  void setTurtles(const Array<Turtle*, Parameter::MaxTurtleCount>& aTurtles) {
    mTurtles.clear();
    if (foods().isEmpty()) {
      return;
    }

    for(Turtle* turtle : aTurtles) {
      mTurtles.add(turtle);
    }
  }

  void sortFoods() {
    ASSERT(!foods().isEmpty());

    static Array<DoublePoint, Parameter::MaxFoodCount> points;
    points.clear();
    for(const MyFood* food : mFoods) {
      points.add(food->pos());
    }

    DoublePoint* prevPos = nullptr;
    DoublePoint* nextPos = nullptr;

    DoublePoint tmpFirst;
    DoublePoint tmpLast;
    if (mPrevGroup != nullptr) {
      DoublePoint p1 = mPrevGroup->lastPos();
      DoublePoint p2 = mPrevGroup->pseudoCenterPos();
      tmpFirst.x = p1.x*0.5 + p2.x*0.5;
      tmpFirst.y = p1.y*0.5 + p2.y*0.5;
      prevPos = &tmpFirst;
    }
    if (mNextGroup != nullptr) {
      tmpLast = mNextGroup->pseudoCenterPos();
      nextPos = &tmpLast;
    }

    const auto& indices = Tsp::solve(points, prevPos, nextPos);

    static Array<MyFood*, Parameter::MaxFoodCount> tmpFoods;
    tmpFoods.clear();
    for(MyFood* food : mFoods) {
      tmpFoods.add(food);
    }

    mFoods.clear();
    REP(i, tmpFoods.count()) {
      mFoods.add(tmpFoods[indices[i]]);
    }
  }

private:

  void calcCenterPos() {
    if (foods().isEmpty()) return;

    DoublePoint center(0, 0);
    for(const MyFood* food : foods()) {
      DoublePoint p = food->pos();
      center.x += p.x;
      center.y += p.y;
    }
    center.x /= foods().count();
    center.y /= foods().count();
    mCenterPos = center;
  }

  void calcPseudoCenterPos() {
    if (foods().isEmpty()) return;

    double cnt = 0;

    DoublePoint center(0, 0);
    for(const MyFood* food : foods()) {
      DoublePoint p = food->pos();
      double v = gConfig.distortCenterByHeight(food->height());
      center.x += p.x*v;
      center.y += p.y*v;
      cnt += v;
    }
    center.x /= cnt;
    center.y /= cnt;
    mPseudoCenterPos = center;
  }
};

//==============================================================================

class MyStage {

private:
  int mTurn;
  TurtlePositions mTurtlePositions;
  Foods mFoods;

  bool mFoodsChanged;

public:
  MyStage() {
  }

  void init(const Stage& aStage) {
    mTurtlePositions.clear();
    for(const Point& pos : aStage.turtlePositions()) {
      mTurtlePositions.add(pos);
    }
    mFoods.clear();
    for(const Food& food : aStage.foods()) {
      mFoods.add(food);
    }
    mTurn = 0;

    mFoodsChanged = true;
  }

  inline int turn() const {
    return mTurn;
  }

  const TurtlePositions& turtlePositions() const {
    return mTurtlePositions;
  }

  inline const Foods& foods() const {
    return mFoods;
  }

  void update(const Actions& aActions) {
    ASSERT(aActions.count() == mTurtlePositions.count());

    int turtleCount[Parameter::StageHeight][Parameter::StageWidth] = {};
    REP(i, mTurtlePositions.count()) {
      Point nextPoint = mTurtlePositions[i];
      switch (aActions[i]) {
        case Action_Wait: {
        } break;
        case Action_MoveUp: {
          nextPoint.y = std::max(nextPoint.y - 1, 0);
        } break;
        case Action_MoveDown: {
          nextPoint.y = std::min(nextPoint.y + 1, Parameter::StageHeight - 1);
        } break;
        case Action_MoveLeft: {
          nextPoint.x = std::max(nextPoint.x - 1, 0);
        } break;
        case Action_MoveRight: {
          nextPoint.x = std::min(nextPoint.x + 1, Parameter::StageWidth - 1);
        } break;
        default: {
          ASSERT(false);
        }
      }
      mTurtlePositions[i] = nextPoint;
      turtleCount[nextPoint.y][nextPoint.x]++;
    }

    mFoodsChanged = false;
    for(Food& food : mFoods) {
      const Point& foodPos = food.pos();
      if (!food.isEaten() && food.height() <= turtleCount[foodPos.y][foodPos.x]) {
        food.setIsEaten(true);
        mFoodsChanged = true;
      }
    }
  }

  void advanceTurn() {
    mTurn++;
  }

  bool isEnd() const {
    for(const Food& food : mFoods) {
      if (!food.isEaten()) {
        return false;
      }
    }
    return true;
  }

  inline bool foodsChanged() const {
    return mFoodsChanged;
  }
};

//==============================================================================

class Solver {

private:
  std::array<Group, MyParameter::MAX_GROUP_COUNT> mGroupsPool;
  Array<Group*, MyParameter::MAX_GROUP_COUNT> mGroups;

  std::array<MyFood, Parameter::MaxFoodCount> mFoodsPool;
  Array<MyFood*, Parameter::MaxFoodCount> mFoods;

  std::array<Turtle, Parameter::MaxTurtleCount> mTurtlesPool;
  Array<Turtle*, Parameter::MaxTurtleCount> mTurtles;

  DoublePoint mGlobalPseudoCenterPos;

  std::array<Turtle, Parameter::MaxTurtleCount> calcTargetFoods_turtlesPool;
  std::array<Turtle*, Parameter::MaxTurtleCount> calcTargetFoods_turtles;
  std::array<MyFood*, Parameter::MaxFoodCount> calcTargetFoods_foods;

public:
  Solver()
  : mGroupsPool()
  , mGroups()
  , mFoodsPool()
  , mFoods()
  , mTurtlesPool()
  , mTurtles()
  , mGlobalPseudoCenterPos() {
  }

  void init(const MyStage& aStage) {
    mFoods.clear();
    REP(i, aStage.foods().count()) {
      mFoodsPool[i].init(i, aStage.foods()[i]);
      mFoods.add(&mFoodsPool[i]);
    }
    calcGlobalPseudoCenter();

    mTurtles.clear();
    REP(i, aStage.turtlePositions().count()) {
      const auto& pos = aStage.turtlePositions()[i];
      mTurtlesPool[i].init(i, pos);
      mTurtles.add(&mTurtlesPool[i]);
      calcTargetFoods_turtles[i] = &calcTargetFoods_turtlesPool[i];
    }

    clusterize();

    if (gConfig.GROUP_SORT_PATTERN == Config::GroupSortPattern_Default) {
      sortGroups();
      if (mGroups[mGroups.count()-1]->maxFoodHeight() < mGroups[0]->maxFoodHeight()) {
        REP(i, mGroups.count()/2) {
          std::swap(mGroups[i], mGroups[mGroups.count()-1-i]);
        }
      }
    } else if (gConfig.GROUP_SORT_PATTERN == Config::GroupSortPattern_FirstFixed) {
      Array<Turtle*, Parameter::MaxTurtleCount> tmpTurtles = mTurtles;
      double minMaxD = DOUBLE_INF;
      int minI = -1;
      REP(i, mGroups.count()) {
        Group* group = mGroups[i];
        const DoublePoint& p = group->pseudoCenterPos();
        std::sort(ALL(tmpTurtles), [&p](const Turtle* t1, const Turtle* t2) {
          double d1 = dist(t1->pos(), p);
          double d2 = dist(t2->pos(), p);
          return d1 < d2;
        });
        double maxD = 0;
        REP(j, group->maxFoodHeight()) {
          const Turtle* turtle = tmpTurtles[j];
          maxD = std::max(maxD, dist(turtle->pos(), p));
        }
        if (maxD < minMaxD) {
          minMaxD = maxD;
          minI = i;
        }
      }
      ASSERT(minI != -1);
      sortGroupsWithFirstFixed(minI);
    } else if (gConfig.GROUP_SORT_PATTERN == Config::GroupSortPattern_FirstCenter) {
      DoublePoint center = mGlobalPseudoCenterPos;
      double minD = DOUBLE_INF;
      int minI = -1;
      REP(i, mGroups.count()) {
        double d = dist(mGroups[i]->pseudoCenterPos(), center);
        if (d < minD) {
          minD = d;
          minI = i;
        }
      }
      ASSERT(minI != -1);
      sortGroupsWithFirstFixed(minI);
    } else {
      ASSERT(false);
    }

    REP(i, mGroups.count()) {
      mGroups[i]->setIndex(i);
    }

    FOR(i, 1, mGroups.count()) {
      mGroups[i-1]->setNextGroup(mGroups[i]);
      mGroups[i]->setPrevGroup(mGroups[i-1]);
    }

    REP(i, mGroups.count()) {
      mGroups[i]->sortFoods();
    }

    setFoodRelations();
  }

  void beforeExec(const MyStage& aStage) {
    REP(i, aStage.turtlePositions().count()) {
      ASSERT(mTurtlesPool[i].index() == i);
      ASSERT(mTurtles[i] == &mTurtlesPool[i]);
      const auto& pos = aStage.turtlePositions()[i];
      mTurtlesPool[i].beforeExec(pos);
    }

    if (!aStage.foodsChanged()) {
      return;
    }

    REP(i, aStage.foods().count()) {
      ASSERT(mFoodsPool[i].index() == i);
      ASSERT(mFoods[i] == &mFoodsPool[i]);
      mFoodsPool[i].beforeExec(aStage.foods()[i].isEaten());
    }
    calcGlobalPseudoCenter();

    for(Group* group : mGroups) {
      group->updateFoods();
    }

    setFoodRelations();

    for(Group* group : mGroups) {
      group->setTurtles(mTurtles);
    }
  }

  void exec(const MyStage& aStage) {
    if (aStage.foodsChanged()) {
      execWithTraverse();
      execWithProximity();
    } else {
      for(Turtle* turtle : mTurtles) {
        turtle->setTargetPos(turtle->prevTurnTargetPos());
      }
    }
  }

  void afterExec(const MyStage& aStage, Actions& aActions) {
    REP(i, aStage.turtlePositions().count()) {
      ASSERT(mTurtlesPool[i].index() == i);
      ASSERT(mTurtles[i] == &mTurtlesPool[i]);
      mTurtlesPool[i].afterExec();
    }
    setActions(aStage, aActions);
  }

  void finalize(const MyStage& aStage) {
    UNUSE(aStage);
  }

private:

  // k-means++
  void clusterize() {
    ASSERT(!mFoods.isEmpty());

    mGroups.clear();

    static Array<
      Array<MyFood*, Parameter::MaxFoodCount>,
      MyParameter::MAX_GROUP_COUNT
    > clusters;
    clusters.clear();

    int groupCount = gConfig.groupCount(mFoods.count());
    REP(i, groupCount) {
      clusters.add(Array<MyFood*, Parameter::MaxFoodCount>());
    }

    static Array<DoublePoint, Parameter::MaxFoodCount> centers;
    centers.clear();

    {
      static std::array<int, Parameter::MaxFoodCount> ids;

      ids[0] = gConfig.random().randTerm(mFoods.count());
      centers.add(mFoods[ids[0]]->pos());

      static std::array<double, Parameter::MaxFoodCount> ds;
      FOR(i, 1, groupCount) {
        double sumD = 0;
        REP(j, mFoods.count()) {
          double minD = DOUBLE_INF;
          REP(k, i) {
            double d = dist(mFoods[j]->pos(), mFoods[ids[k]]->pos());
            if (d < minD) {
              minD = d;
            }
          }
          ds[j] = minD*minD;
          sumD += minD*minD;
        }
        FOR(j, 1, mFoods.count()) {
          ds[j] += ds[j-1];
        }
        REP(j, mFoods.count()) {
          ds[j] /= sumD;
        }
        ASSERT(1.0-ds[mFoods.count() - 1] < 1.0e-8);
        double r = gConfig.random().randFloat();
        int id = mFoods.count() - 1;
        REP(j, mFoods.count()) {
          if (r < ds[j]) {
            id = j;
            break;
          }
        }
        ids[i] = id;
        centers.add(mFoods[id]->pos());
      }
    }

    bool more = true;
    for(int iter = 0; iter < 36 || more; iter++) {
      more = false;
      REP(i, centers.count()) {
        clusters[i].clear();
      }
      for(MyFood* food : mFoods) {
        double minD = DOUBLE_INF;
        int minI = -1;
        REP(i, centers.count()) {
          double d = dist(centers[i], food->pos());
          if (d < minD) {
            minD = d;
            minI = i;
          }
        }
        clusters[minI].add(food);
      }
      REP(i, centers.count()) {
        if (clusters[i].isEmpty()) {
          centers.erase(i);
          clusters.erase(i);
          i--;
          more = true;
        } else if (clusters[i].count() <= 2 && !more) {
          // heuristic
          centers.erase(i);
          clusters.erase(i);
          i--;
          more = true;
        } else {
          centers[i] = getPseudoCenter(clusters[i]);
        }
      }
    }

    // PRINT("%d", centers.count());

    ASSERT(centers.count() == clusters.count());
    REP(groupIndex, centers.count()) {
      mGroupsPool[groupIndex].init(clusters[groupIndex]);
      mGroups.add(&mGroupsPool[groupIndex]);
    }
  }

  void sortGroups() {
    static Array<DoublePoint, MyParameter::MAX_GROUP_COUNT> points;
    points.clear();

    for(const Group* group : mGroups) {
      points.add(group->pseudoCenterPos());
    }
    const auto& indices = Tsp::solve(points);

    static Array<Group*, MyParameter::MAX_GROUP_COUNT> tmpGroups;
    tmpGroups = mGroups;
    tmpGroups.clear();
    REP(i, mGroups.count()) {
      tmpGroups.add(mGroups[i]);
    }

    mGroups.clear();
    REP(i, tmpGroups.count()) {
      mGroups.add(tmpGroups[indices[i]]);
    }
  }

  void sortGroupsWithFirstFixed(int firstIndex) {
    static Array<DoublePoint, MyParameter::MAX_GROUP_COUNT> points;
    points.clear();

    Group* firstGroup = mGroups[firstIndex];
    DoublePoint firstPos = firstGroup->pseudoCenterPos();

    REP(i, mGroups.count()) {
      if (i == firstIndex) continue;
      points.add(mGroups[i]->pseudoCenterPos());
    }
    const auto& indices = Tsp::solve(points, &firstPos, nullptr);

    static Array<Group*, MyParameter::MAX_GROUP_COUNT> tmpGroups;
    tmpGroups = mGroups;
    tmpGroups.clear();
    REP(i, mGroups.count()) {
      if (i == firstIndex) continue;
      tmpGroups.add(mGroups[i]);
    }

    mGroups.clear();
    mGroups.add(firstGroup);
    REP(i, tmpGroups.count()) {
      mGroups.add(tmpGroups[indices[i]]);
    }
  }

  DoublePoint getPseudoCenter(const Array<MyFood*, Parameter::MaxFoodCount>& aFoods) const {
    ASSERT(!aFoods.isEmpty());

    double cnt = 0;

    DoublePoint center(0, 0);
    for(const MyFood* food : aFoods) {
      if (food->isEaten()) continue;
      DoublePoint p = food->pos();
      double v = gConfig.distortCenterByHeight(food->height());
      center.x += p.x*v;
      center.y += p.y*v;
      cnt += v;
    }
    center.x /= cnt;
    center.y /= cnt;
    return center;
  }

  void calcGlobalPseudoCenter() {
    static Array<MyFood*, Parameter::MaxFoodCount> notEatenFoods;
    notEatenFoods.clear();
    for(MyFood* food : mFoods) {
      if (food->isEaten()) continue;
      notEatenFoods.add(food);
    }
    if (notEatenFoods.isEmpty()) return;
    mGlobalPseudoCenterPos = getPseudoCenter(notEatenFoods);
  }

  void setFoodRelations() {
    REP(i, mGroups.count()) {
      const auto& foods = mGroups[i]->foods();
      REP(j, foods.count()) {
        if (j > 0) {
          foods[j]->setPrevFood(foods[j-1]);
        } else if (i > 0) {
          const auto& prevFoods = mGroups[i]->foods();
          if (prevFoods.isEmpty()) {
            foods[j]->setPrevFood(nullptr);
          } else {
            foods[j]->setPrevFood(prevFoods[prevFoods.count()-1]);
          }
        } else {
          foods[j]->setPrevFood(nullptr);
        }

        if (j < foods.count()-1) {
          foods[j]->setNextFood(foods[j+1]);
        } else if (i < mGroups.count()-1) {
          const auto& nextFoods = mGroups[i+1]->foods();
          if (nextFoods.isEmpty()) {
            foods[j]->setNextFood(nullptr);
          } else {
            foods[j]->setNextFood(nextFoods[nextFoods.count()-1]);
          }
        } else {
          foods[j]->setNextFood(nullptr);
        }
      }
    }
  }

  void execWithTraverse() {
    calcTargetFoods();

    Group* group = mGroups[mGroups.count() - 1];
    while(group->foods().isEmpty()) {
      group = group->prevGroup();
    }
    const DoublePoint& doublePos = group->pseudoCenterPos();
    Point p(static_cast<int>(doublePos.x), static_cast<int>(doublePos.y));
    for(Turtle* turtle : mTurtles) {
      if (turtle->hasTarget()) continue;
      turtle->setTargetPos(p);
      turtle->setRedundancy(INT_INF);
    }
  }

  void execWithProximity() {

    static Array<MyFood*, Parameter::MaxFoodCount> tmpFoods;
    tmpFoods.clear();
    for(MyFood* food : mFoods) {
      if (food->isEaten()) continue;
      tmpFoods.add(food);
    }

    std::sort(ALL(tmpFoods), [](const MyFood* f1, const MyFood* f2) {
      int h1 = f1->height();
      int h2 = f2->height();
      if (h1 != h2) return h1 > h2;
      int g1 = f1->group()->index();
      int g2 = f2->group()->index();
      if (g1 != g2) return g1 > g2;
      int ttl1 = f1->ttl();
      int ttl2 = f2->ttl();
      if (ttl1 != ttl2) return ttl1 > ttl2;
      return f1->index() < f2->index();
    });

    static std::array<bool, Parameter::MaxFoodCount> used;
    used.fill(false);

    static Array<Turtle*, Parameter::MaxTurtleCount> tmpTurtles;

    bool exists = true;
    while(exists) {
      exists = false;
      int minTtl = INT_INF;
      int minI = -1;

      REP(i, tmpFoods.count()) {
        const MyFood* food = tmpFoods[i];
        if (food->isEaten()) continue;
        if (used[i]) continue;
        if (food->ttl() == 1) continue;

        tmpTurtles.clear();
        for(Turtle* turtle : mTurtles) {
          int d = dist(turtle->pos(), food->pos()) + dist(food->pos(), turtle->targetPos());
          if (d <= turtle->redundancy()) {
            tmpTurtles.add(turtle);
          }
        }
        if (tmpTurtles.count() >= food->height()) {
          std::sort(ALL(tmpTurtles), [&food](const Turtle* t1, const Turtle* t2) {
            int d1 = dist(t1->pos(), food->pos());
            int d2 = dist(t2->pos(), food->pos());
            if (d1 != d2) return d1 < d2;
            return t1->index() < t2->index();
          });
          int maxD = dist(tmpTurtles[tmpTurtles.count() - 1]->pos(), food->pos()) + 1;
          REP(ttl, std::min(maxD+1, food->ttl())) {
            int cnt = 0;
            for(const Turtle* turtle : tmpTurtles) {
              int d = dist(turtle->pos(), food->pos());
              if (d > ttl) continue;
              d = ttl + dist(food->pos(), turtle->targetPos());
              if (d <= turtle->redundancy()) {
                cnt++;
              }
            }
            if (cnt < food->height()) {
              continue;
            }
            if (ttl < minTtl) {
              minTtl = ttl;
              minI = i;
              break;
            }
          }
        }
      }

      if (minI != -1) {
        exists = true;

        ASSERT(minTtl < tmpFoods[minI]->ttl());

        ASSERT(!used[minI]);
        used[minI] = true;

        MyFood* food = tmpFoods[minI];

        tmpTurtles.clear();
        for(Turtle* turtle : mTurtles) {
          int d = dist(turtle->pos(), food->pos()) + dist(food->pos(), turtle->targetPos());
          if (d <= turtle->redundancy()) {
            tmpTurtles.add(turtle);
          }
        }

        ASSERT(tmpTurtles.count() >= food->height());

        std::sort(ALL(tmpTurtles), [&food](const Turtle* t1, const Turtle* t2) {
          int d1 = dist(t1->pos(), food->pos());
          int d2 = dist(t2->pos(), food->pos());
          if (d1 != d2) return d1 < d2;

          // ここより下は逆順
          return t1->index() > t2->index();
        });

        int cnt = 0;
        int turtleIndex = 0;
        while(turtleIndex < tmpTurtles.count()) {
          Turtle* turtle = tmpTurtles[turtleIndex];
          int d = dist(turtle->pos(), food->pos());
          if (d > minTtl) break;
          d = minTtl + dist(food->pos(), turtle->targetPos());
          if (d <= turtle->redundancy()) {
            cnt++;
          }
          turtleIndex++;
        }
        ASSERT(cnt >= food->height());

        cnt = 0;
        REP_R(i, turtleIndex) {
          if (cnt == food->height()) break;
          Turtle* turtle = tmpTurtles[i];
          int d = dist(turtle->pos(), food->pos());
          ASSERT(d <= minTtl);
          d = minTtl + dist(food->pos(), turtle->targetPos());
          if (d <= turtle->redundancy()) {
            turtle->setTargetFood(food);
            turtle->setRedundancy(minTtl);
            cnt++;
          }
        }
        food->setTtl(minTtl);
        ASSERT(cnt == food->height());
      }
    }
  }

  void calcTargetFoods() {

    int FOOD_NUM = 0;
    for(const Group* group : mGroups) {
      for(MyFood* food : group->foods()) {
        calcTargetFoods_foods[FOOD_NUM++] = food;
      }
    }

    int TURTLE_NUM = mTurtles.count();

    int K;
    if (TURTLE_NUM < 12) {
      K = FOOD_NUM > 18 ? 3 : FOOD_NUM > 6 ? 4 : 6;
    } else {
      K = FOOD_NUM > 17 ? 3 : FOOD_NUM > 6 ? 4 : 6;
    }

    int T = std::min(K, FOOD_NUM); //

    int minLastTurn = INT_INF;
    std::array<int, 6> minPerm;

    std::array<int, 6> perm;
    std::iota(perm.begin(), perm.begin() + T, 0);

    do {
      int lastTurn = 0;

      REP(i, TURTLE_NUM) {
        calcTargetFoods_turtlesPool[i] = mTurtlesPool[i];
      }

      REP(foodIndex, FOOD_NUM) {
        MyFood* food = calcTargetFoods_foods[
          foodIndex < T ? perm[foodIndex] : foodIndex
        ];

        std::sort(calcTargetFoods_turtles.begin(), calcTargetFoods_turtles.begin() + TURTLE_NUM, [&food](const Turtle* t1, const Turtle* t2) {
          const Point& p1 = t1->lastTargetPos();
          const Point& p2 = t2->lastTargetPos();
          int d1 = dist(p1, food->pos()) + t1->lastRedundancy();
          int d2 = dist(p2, food->pos()) + t2->lastRedundancy();
          if (d1 != d2) return d1 < d2;

          // ↓ ここより下は逆順
          if (food->nextFood() != nullptr) {
            // heuristic
            d1 = dist(p1, food->nextFood()->pos()) + t1->lastRedundancy();
            d2 = dist(p2, food->nextFood()->pos()) + t2->lastRedundancy();
            if (d1 != d2) return d1 < d2;
            // if (food->nextFood()->nextFood() != nullptr) {
            //   d1 = dist(p1, food->nextFood()->nextFood()->pos()) + t1->lastRedundancy();
            //   d2 = dist(p2, food->nextFood()->nextFood()->pos()) + t2->lastRedundancy();
            //   if (d1 != d2) return d1 < d2;
            // }
          }
          return t1->index() > t2->index();
        });
        int turtleIndex = 0;
        int cnt = 0;
        int maxD = 0;
        while(cnt < food->height()) {
          const Turtle* turtle = calcTargetFoods_turtles[turtleIndex++];
          int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
          maxD = std::max(maxD, d);
          cnt++;
        }
        while(turtleIndex < TURTLE_NUM) {
          const Turtle* turtle = calcTargetFoods_turtles[turtleIndex];
          int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
          if (d > maxD) break;
          turtleIndex++;
        }

        int redundancy = maxD;
        lastTurn = std::max(lastTurn, redundancy);

        if (lastTurn >= minLastTurn) {
          // 枝刈り
          break;
        }

        cnt = 0;
        REP_R(index, turtleIndex) {
          if (cnt == food->height()) break;
          Turtle* turtle = calcTargetFoods_turtles[index];
          int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
          ASSERT(d <= redundancy);
          if (!turtle->hasTarget()) {
            turtle->setTargetFood(food);
            turtle->setRedundancy(redundancy);
          } else {
            turtle->setLastTargetFood(food);
            turtle->setLastRedundancy(redundancy);
          }
          cnt++;
        }
        ASSERT(cnt == food->height());
      }

      if (lastTurn < minLastTurn) {
        minLastTurn = lastTurn;
        minPerm = perm;
      }
    } while (std::next_permutation(perm.begin(), perm.begin() + T));

    ASSERT(minLastTurn < INT_INF);


    REP(i, TURTLE_NUM) {
      calcTargetFoods_turtlesPool[i] = *mTurtles[i];
    }

    REP(foodIndex, FOOD_NUM) {
      MyFood* food = calcTargetFoods_foods[
        foodIndex < T ? minPerm[foodIndex] : foodIndex
      ];

      std::sort(calcTargetFoods_turtles.begin(), calcTargetFoods_turtles.begin() + TURTLE_NUM, [&food](const Turtle* t1, const Turtle* t2) {
        const Point& p1 = t1->lastTargetPos();
        const Point& p2 = t2->lastTargetPos();
        int d1 = dist(p1, food->pos()) + t1->lastRedundancy();
        int d2 = dist(p2, food->pos()) + t2->lastRedundancy();
        if (d1 != d2) return d1 < d2;

        // ↓ ここより下は逆順
        if (food->nextFood() != nullptr) {
          // heuristic
          d1 = dist(p1, food->nextFood()->pos()) + t1->lastRedundancy();
          d2 = dist(p2, food->nextFood()->pos()) + t2->lastRedundancy();
          if (d1 != d2) return d1 < d2;
          // if (food->nextFood()->nextFood() != nullptr) {
          //   d1 = dist(p1, food->nextFood()->nextFood()->pos()) + t1->lastRedundancy();
          //   d2 = dist(p2, food->nextFood()->nextFood()->pos()) + t2->lastRedundancy();
          //   if (d1 != d2) return d1 < d2;
          // }
        }
        return t1->index() > t2->index();
      });
      int turtleIndex = 0;
      int cnt = 0;
      int maxD = 0;
      while(cnt < food->height()) {
        const Turtle* turtle = calcTargetFoods_turtles[turtleIndex++];
        int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
        maxD = std::max(maxD, d);
        cnt++;
      }
      while(turtleIndex < TURTLE_NUM) {
        const Turtle* turtle = calcTargetFoods_turtles[turtleIndex];
        int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
        if (d > maxD) break;
        turtleIndex++;
      }

      int redundancy = maxD;

      cnt = 0;
      REP_R(index, turtleIndex) {
        if (cnt == food->height()) break;
        Turtle* turtle = calcTargetFoods_turtles[index];
        int d = dist(turtle->lastTargetPos(), food->pos()) + turtle->lastRedundancy();
        ASSERT(d <= redundancy);
        if (!turtle->hasTarget()) {
          turtle->setTargetFood(food);
          turtle->setRedundancy(redundancy);
        } else {
          turtle->setLastTargetFood(food);
          turtle->setLastRedundancy(redundancy);
        }
        cnt++;
      }
      ASSERT(cnt == food->height());

      ASSERT(redundancy <= minLastTurn);
      food->setTtl(redundancy);
    }

    REP(i, mTurtles.count()) {
      *mTurtles[i] = calcTargetFoods_turtlesPool[i];
    }
  }

  void setActions(const MyStage& aStage, Actions& aActions) {
    REP(i, aStage.turtlePositions().count()) {
      aActions.add(Action_Wait);
    }
    for(const Turtle* turtle : mTurtles) {
      Action& action = aActions[turtle->index()];
      if (turtle->pos().x < turtle->targetPos().x) {
        action = Action_MoveRight;
      } else if (turtle->pos().x > turtle->targetPos().x) {
        action = Action_MoveLeft;
      } else if (turtle->pos().y < turtle->targetPos().y) {
        action = Action_MoveDown;
      } else if (turtle->pos().y > turtle->targetPos().y) {
        action = Action_MoveUp;
      } else {
        action = Action_Wait;
      }
    }
  }

} gSolver;

//==============================================================================

class Emulator {

private:
  MyStage mStage;
  std::array<Actions, Parameter::GameTurnLimit> mActionsList;

public:
  Emulator() {
  }

  int evaluate(const Stage& aStage) {
    mStage.init(aStage);

    gSolver.init(mStage);

    while(!mStage.isEnd() && mStage.turn() < Parameter::GameTurnLimit) {
      Actions actions;

      gSolver.beforeExec(mStage);
      gSolver.exec(mStage);
      gSolver.afterExec(mStage, actions);

      mStage.update(actions);
      saveActions(actions, mStage.turn());
      mStage.advanceTurn();
    }

    gSolver.finalize(mStage);

    return mStage.turn();
  }

  const std::array<Actions, Parameter::GameTurnLimit>& actionsList() const {
    return mActionsList;
  }

private:
  void saveActions(const Actions& aActions, int turn) {
    mActionsList[turn] = aActions;
  }

} gEmulator;

//==============================================================================

Answer::Answer() {
}
Answer::~Answer() {
}

#ifdef LOCAL
  int gStageIndex = 0;
#endif

int gMinTurn;
std::array<Actions, Parameter::GameTurnLimit> gMinActionsList;

void Answer::initialize(const Stage& aStage) {
  PRINT("Stage index: %d", gStageIndex);

  gMinTurn = INT_INF;

  Random r(
    RandomSeed(
      0x87e5df8d, 0x04f42583, 0xbc0ce3ac, 0xdaa5b76f
    )
  );

  FOR(distortion, 1, 2+1) {
    FOR(div, 2, 3+1) {
      REP_R(sortPattern, Config::GroupSortPattern_TERM) {
        gConfig.RANDOM_SEED = r.generateRandomSeed();
        gConfig.GROUP_COUNT_DIV = div;
        gConfig.DISTORTION_POWER = distortion*0.5 + 0.001;
        gConfig.GROUP_SORT_PATTERN = static_cast<Config::GroupSortPattern>(sortPattern);

        gConfig.init();
        int turn = gEmulator.evaluate(aStage);
        if (turn < gMinTurn) {
          gMinTurn = turn;
          gMinActionsList = gEmulator.actionsList();
        }
      }
    }
  }

  FOR(distortion, 1, 2+1) {
    FOR(div, 2, 3+1) {
      REP_R(sortPattern, Config::GroupSortPattern_TERM) {
        gConfig.RANDOM_SEED = r.generateRandomSeed();
        gConfig.GROUP_COUNT_DIV = div;
        gConfig.DISTORTION_POWER = distortion*0.5 + 0.001;
        gConfig.GROUP_SORT_PATTERN = static_cast<Config::GroupSortPattern>(sortPattern);

        gConfig.init();
        int turn = gEmulator.evaluate(aStage);
        if (turn < gMinTurn) {
          gMinTurn = turn;
          gMinActionsList = gEmulator.actionsList();
        }
      }
    }
  }
}

void Answer::setActions(const Stage& aStage, Actions& aActions) {
  ASSERT(aStage.turn() < gMinTurn);
  aActions = gMinActionsList[aStage.turn()];
}

void Answer::finalize(const Stage& aStage) {
  ASSERT(aStage.turn() == gMinTurn);
  UNUSE(aStage);
  #ifdef LOCAL
    gStageIndex++;
  #endif
}

} // namespace
