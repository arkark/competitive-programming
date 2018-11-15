/*
 *    _|    _|  _|_|_|_|    _|_|
 *    _|    _|  _|        _|    _|
 *    _|    _|  _|_|_|    _|    _|
 *    _|    _|  _|        _|    _|
 *      _|_|    _|          _|_|
 *
 * ハル研究所プログラミングコンテスト2017
 *  http://www.hallab.co.jp/progcon/2017/
 */

#define _USE_MATH_DEFINES
#include "Answer.hpp"
#include<iostream>
#include<vector>
#include<deque>
#include<list>
#include<utility>
#include<algorithm>
#include<cmath>
#include<numeric>
#include<random>
#include<assert.h>

const float INF = 1e10f;

// 乱択の繰り返し回数
const int ITER_MAX = 300;
const int ITER_MIN = 200;


namespace hpc {

struct RandSeed {
    uint x, y, z, w;
};

struct Rand {
    RandSeed seed;

public:
    Rand(RandSeed s) {
        setSeed(s);
    }

    void setSeed(RandSeed s) {
        seed = s;
    }

    // [left, right)
    int nextInt(int left, int right) {
        assert(0 <= left && left < right);
        return left + int(next() & 0x7fffffff) % (right - left);
    }
    int nextInt(int right) {
        return nextInt(0, right);
    }

    // [0, 1]
    float nextFloat() {
        return (next() & 0x10000) / float(0x10000);
    }

    uint next() {
        uint t;
        t = seed.x ^ (seed.x << 11);
        seed.x = seed.y; seed.y = seed.z; seed.z = seed.w;
        return seed.w = seed.w ^ (seed.w >> 19) ^ (t ^ (t >> 8));
    }
};

Rand rand({ 0x2538b3f8, 0xeb4648c9, 0xfe46a032, 0xa28f3405 }); //

// ターン数の測定用に _UFO/_House/_Office/StageData を定義
struct _UFO {
    UFOType _type;
    Vector2 _pos;
    float _radius;
    float _maxSpeed;
    int _itemCount;
    int _capacity;

    void move(const Vector2& aTargetPos) {
        Vector2 dir = aTargetPos - _pos;
        float length = dir.length();
        if (length > _maxSpeed) {
            dir = dir / length * _maxSpeed;
        }
        _pos += dir;
    }
    void incItem(int count) {
        _itemCount += count;
    }
    void decItem(int count) {
        _itemCount -= count;
    }
    UFOType type() const { return _type; }
    Vector2 pos() const { return _pos; }
    float radius() const { return _radius; }
    float maxSpeed() const { return _maxSpeed; }
    int itemCount() const { return _itemCount; }
    int capacity() const { return _capacity; }
};
struct _House {
    Vector2 _pos;
    bool _delivered;

    void deliver() { _delivered = true; }
    Vector2 pos() const { return _pos; }
    float radius() const { return float(Parameter::HouseRadius); }
    bool delivered() const { return _delivered; }
};
struct _Office {
    Vector2 _pos;

    Vector2 pos() const { return _pos; }
    float radius() const { return float(Parameter::OfficeRadius); }
};
using _UFOs = Array<_UFO, Parameter::UFOCount>;
using _Houses = Array<_House, Parameter::MaxHouseCount>;

struct StageData {

    _UFOs _ufos;
    _Houses _houses;
    _Office _office;

    _Office& office() {
        return _office;
    }
    _UFOs& ufos() {
        return _ufos;
    }
    _Houses& houses() {
        return _houses;
    }
};

// Stage -> StageData の変換
StageData getStageData(const Stage& aStage) {
    static StageData stageData;
    stageData.ufos().clear();
    for (auto& ufo : aStage.ufos()) {
        stageData.ufos().add({ ufo.type(), ufo.pos(), ufo.radius(), ufo.maxSpeed(), ufo.itemCount(), ufo.capacity() });
    }
    stageData.houses().clear();
    for (auto& house : aStage.houses()) {
        stageData.houses().add({ house.pos(), house.delivered() });
    }
    stageData.office() = { aStage.office().pos() };

    return stageData;
}

class Solver
{
private:
    // 各SmallUFOが次に向かう家のインデックス
    //   smallUfoIndex -> [houseIndex]
    std::vector<std::deque<int>> mTargetHouseIndices;

    // 各LargeUFOの定位置
    //   largeUfoIndex -> position
    std::vector<Vector2> mLargeUfoPositions;

    // 各SmallUfoが目指す家のインデックス
    //   smallUfoIndex -> houseIndex
    std::vector<int> mLastHouseIndices;

    // 各houseに対し、そのhouseを目指すufoとの最小距離distanceに関して(ufoIndex, d)のペア
    //   houseIndex -> (ufoIndex, distance)
    std::vector<std::pair<int, float>> mMinDists;

    // 各largeUFOの現在目指しているhouseのインデックス
    //   largeUfoIndex -> houseIndex
    std::vector<int> mLastLargeUfoTargetIndex;

    // アイテムが届けられてない家のインデックス
    //   [houseIndex]
    std::list<int> mNotDeliveredHouseIndices;

    // house間の距離
    //   houseIndex -> houseIndex -> distance
    float mHouseDists[Parameter::MaxHouseCount][Parameter::MaxHouseCount];

    // random values (乱択用)
    float mRandom_nextHouse1;
    float mRandom_nextHouse2;
    float mRandom_nextHouse3;
    float mRandom_clusterize1;
    float mRandom_clusterize2;
    float mRandom_updateLargeUfos1;
    float mRandom_updateLargeUfos2;
    float mRandom_calcLargeUfoPositions1;
    float mRandom_calcLargeUfoPositions2;
    float mRandom_calcLargeUfoPositions3;
    float mRandom_moveItems;

public:
    void init(const Stage& aStage) {
        // 0,1番目はLargeUFO
        assert(aStage.ufos()[0].type() == UFOType_Large);
        assert(aStage.ufos()[1].type() == UFOType_Large);

        init(getStageData(aStage));
    }

    void moveItems(const Stage& aStage, Actions& aActions) {
        moveItems(getStageData(aStage), aActions);
    }

    void moveUFOs(const Stage& aStage, TargetPositions& aTargetPositions) {
        moveUFOs(getStageData(aStage), aTargetPositions);
    }

private:

    void init(StageData stageData) {

        // house間の距離を前計算
        calcHouseDists(stageData);

        // シミュレーションを回して、一番良いシード値を用いる

        RandSeed maxSeed;
        const int M = int(17 + 78*stageData.houses().count()/float(Parameter::MaxHouseCount));
        int maxValue = -105;

        for (int iter = 0; iter < ITER_MIN || (maxValue<=-M && iter < ITER_MAX) || maxValue<=-105; iter++) {

        //int maxValue = -200;
        //for(int iter=0; iter<100; iter++) {
            RandSeed seed = { rand.next(), (rand.next(), rand.next()), (rand.next(), rand.next(), rand.next()), (rand.next(), rand.next()) };

            rand.setSeed(seed);
            execute(stageData);
            float value = evaluate(stageData, maxValue);
            rand.setSeed(seed);

            if (value > maxValue) {
                maxValue = value;
                maxSeed = seed;
            }
        }

        rand.setSeed(maxSeed);
        execute(stageData);

    }

    // 初期化を行う
    void execute(StageData stageData) {

        // 各乱数値の決定
        mRandom_nextHouse1 = rand.nextFloat();
        mRandom_nextHouse2 = rand.nextFloat();
        mRandom_nextHouse3 = rand.nextFloat();
        mRandom_clusterize1 = rand.nextFloat();
        mRandom_clusterize2 = rand.nextFloat();
        mRandom_updateLargeUfos1 = rand.nextFloat();
        mRandom_updateLargeUfos2 = rand.nextFloat();
        mRandom_calcLargeUfoPositions1 = rand.nextFloat();
        mRandom_calcLargeUfoPositions2 = rand.nextFloat();
        mRandom_calcLargeUfoPositions3 = rand.nextFloat();
        mRandom_moveItems = rand.nextFloat();

        int smallUfoCount = Parameter::SmallUFOCount;
        int largeUfoCount = Parameter::LargeUFOCount;
        int houseCount = stageData.houses().count();

        // 各メンバ変数の初期化
        mTargetHouseIndices.resize(smallUfoCount);
        for (uint i = 0; i < mTargetHouseIndices.size(); i++) mTargetHouseIndices[i].clear();
        mLargeUfoPositions.resize(largeUfoCount);
        for (uint i = 0; i < mLargeUfoPositions.size(); i++) mLargeUfoPositions[i] = Vector2::Zero();
        mLastHouseIndices.resize(smallUfoCount);
        for (uint i = 0; i < mLastHouseIndices.size(); i++) mLastHouseIndices[i] = -1;
        mMinDists.resize(houseCount);
        for (uint i = 0; i < mMinDists.size(); i++) mMinDists[i] = std::make_pair(-1, INF);
        mLastLargeUfoTargetIndex.resize(largeUfoCount);
        for (uint i = 0; i < mLastLargeUfoTargetIndex.size(); i++) mLastLargeUfoTargetIndex[i] = -1;
        mNotDeliveredHouseIndices.clear();
        for (uint i = 0; i < houseCount; i++) mNotDeliveredHouseIndices.push_back(i);

        // クラスタリング
        std::vector<Vector2> housePositions(houseCount);
        std::transform(stageData.houses().begin(), stageData.houses().end(), housePositions.begin(), [](_House house) {
            return house.pos();
        });
        std::vector<std::deque<int>> targetIndices(smallUfoCount);
        clusterize(smallUfoCount, housePositions, targetIndices);

        // クラスタ内のhouseの順番を並び替える
        for (int ufoIndex = 0; ufoIndex < smallUfoCount; ufoIndex++) {
            sortCluster1(targetIndices[ufoIndex], stageData);
        }
        for (int ufoIndex = 0; ufoIndex < smallUfoCount; ufoIndex++) {
            sortCluster2(targetIndices[ufoIndex], stageData);
        }

        // クラスタリングの結果を mTargetHouseIndices に代入
        std::vector<int> randomVec(smallUfoCount);
        std::iota(randomVec.begin(), randomVec.end(), 0);
        for (int i = smallUfoCount - 1; i > 0; --i) {
            std::swap(randomVec[i], randomVec[rand.nextInt(i + 1)]); // shuffle
        }
        for (int i = 0; i < smallUfoCount; i++) {
            for (auto& j : targetIndices[i]) {
                mTargetHouseIndices[randomVec[i]].push_back(j);
            }
        }

        // 各largeUfoの初期目的地を計算
        calcLargeUfoPositions(stageData);

    }

    // 評価関数
    //   実際にシミュレートしてターン数を測定する
    float evaluate(StageData stageData, int nowValue) {

        int turn = 0;

        while (!mNotDeliveredHouseIndices.empty() && -turn > nowValue) {
            Actions actions;

            moveItems(stageData, actions);

            for (auto& action : actions) {
                switch (action.type()) {
                case ActionType_PickUp: {
                    _UFO& ufo = stageData.ufos()[action.ufoIndex()];
                    if (!Util::IsIntersect(stageData.office(), ufo)) continue;
                    int pickCount = ufo.capacity() - ufo.itemCount();
                    ufo.incItem(pickCount);
                } break;
                case ActionType_Pass: {
                    auto& srcUFO = stageData.ufos()[action.srcUFOIndex()];
                    auto& dstUFO = stageData.ufos()[action.dstUFOIndex()];
                    if (!Util::IsIntersect(srcUFO, dstUFO)) continue;
                    int passCount = std::min(srcUFO.itemCount(), dstUFO.capacity() - dstUFO.itemCount());
                    srcUFO.decItem(passCount);
                    dstUFO.incItem(passCount);
                } break;
                case ActionType_Deliver: {
                    auto& ufo = stageData.ufos()[action.ufoIndex()];
                    auto& house = stageData.houses()[action.houseIndex()];
                    if (!Util::IsIntersect(ufo, house)) continue;
                    if (ufo.itemCount() == 0) continue;
                    if (house.delivered()) continue;
                    ufo.decItem(1);
                    house.deliver();
                } break;
                default: assert(false);
                }
            }

            TargetPositions targetPositions;
            moveUFOs(stageData, targetPositions);

            for (int i = 0; i < stageData.ufos().count(); ++i) {
                stageData.ufos()[i].move(targetPositions[i]);
            }

            turn++;
        }

        return -turn; // turnが小さいほどよい
    }

    // num 個にクラスタリングする
    //   k-means++ を適当に改造
    void clusterize(int num, std::vector<Vector2> positions, std::vector<std::deque<int>>& aTargetIndices) {

        int iteration = 20; //

        int count = positions.size();

        std::vector<Vector2> centers(num);
        std::vector<int> tempCounts(num);

        std::vector<int> randomVec(count);
        std::iota(randomVec.begin(), randomVec.end(), 0);
        for (int i = count - 1; i > 0; --i) {
            std::swap(randomVec[i], randomVec[rand.nextInt(i + 1)]); // shuffle
        }

        std::vector<int> doko(count, -1);

        std::vector<int> po(num, -1);
        int startI = rand.nextInt(count);
        doko[startI] = 0;
        po[0] = startI;

        std::vector<float> minDVec(count);

        for (int koko = 1; koko < std::min(num, count); koko++) {

            float sumD = 0;
            for (int i = 0; i < count; i++) {
                if (doko[i] >= 0) {
                    minDVec[i] = 0;
                } else {
                    float minD = INF;
                    for (int j = 0; j < num; j++) {
                        if (po[j] < 0) break;
                        float d = positions[i].dist(positions[po[j]]);
                        if (d < minD) {
                            minD = d;
                        }
                    }
                    minDVec[i] = minD * minD;
                    sumD += minDVec[i];
                }
            }

            float t = rand.nextFloat() * sumD;
            float accD = 0;
            for (int i = 0; i < count; i++) {
                if (doko[i] >= 0) continue;
                accD += minDVec[i];
                if (t < accD || i == count - 1) {
                    doko[i] = koko;
                    po[koko] = i;
                    break;
                }
            }
        }

        for (int i = 0; i < count; i++) {
            int koko = rand.nextInt(num);
            aTargetIndices[koko].push_back(i);
            doko[i] = koko;
        }

        bool changed = true;
        while (iteration-->0 && changed) {
            changed = false;

            for (int i = 0; i < num; i++) {
                tempCounts[i] = aTargetIndices[i].size();
            }
            for (int i = 0; i < num; i++) {
                if (aTargetIndices[i].size() == 0) {
                    changed = true;

                    int maxN = 0;
                    int maxJ = -1;
                    for (int j = 0; j < num; j++) {

                        int n = tempCounts[j];
                        if (n > maxN) {
                            maxN = n;
                            maxJ = j;
                        }

                    }
                    assert(maxJ >= 0);
                    doko[aTargetIndices[maxJ].front()] = i;
                    aTargetIndices[i].push_back(aTargetIndices[maxJ].front());
                    aTargetIndices[maxJ].pop_front();
                    float N = mRandom_clusterize2 * 3 + 3;
                    tempCounts[maxJ] = std::min((int)aTargetIndices[maxJ].size(), int(tempCounts[maxJ] / N) + 1);
                }
            }

            for (int i = 0; i < num; i++) {
                centers[i] = Vector2::Zero();
            }
            for (int i = 0; i < num; i++) {
                for (auto& j : aTargetIndices[i]) {
                    centers[i] += positions[j];
                }
                if (aTargetIndices[i].size() > 0) centers[i] /= aTargetIndices[i].size();
            }


            for (int i = 0; i < num; i++) {
                aTargetIndices[i].clear();
            }
            for (int _i = 0; _i < count; _i++) {
                int i = randomVec[_i];

                int minJ = -1;
                float minSquareD = INF;
                for (int j = 0; j < num; j++) {

                    float R = mRandom_clusterize1 * 3 + 1; // 2.0;
                    float squareD = Vector2(positions[i].dist(centers[j]), R*aTargetIndices[j].size()).squareLength();

                    if (squareD < minSquareD) {
                        minSquareD = squareD;
                        minJ = j;
                    }
                }
                aTargetIndices[minJ].push_back(i);
                if (doko[i] != minJ) {
                    // クラスタに変化が
                    doko[i] = minJ;
                    changed = true;
                }
            }

            adjustClusters(positions, aTargetIndices);
        }

    }

    // クラスタを若干調整する
    void adjustClusters(std::vector<Vector2> positions, std::vector<std::deque<int>>& aTargetIndices) {
        int num = aTargetIndices.size();
        bool changed = true;
        int iterMax = 2;
        while (changed && iterMax-->0) {
            changed = false;
            for (int i = 0; i < num; i++) {
                auto& list = aTargetIndices[i];

                for (int diffN = 1; diffN <= 2; diffN++) {
                    if ((int)list.size() == Parameter::SmallUFOCapacity + diffN) {
                        changed = true;

                        std::deque<int> q;
                        Vector2 center1 = Vector2::Zero();
                        for (int _ = 0; _ < diffN; _++) {
                            q.push_back(list.back());
                            list.pop_back();
                            center1 += positions[q.back()];
                        }
                        center1 /= q.size();

                        for (auto& index : q) {
                            int minJ = -1;
                            float minSquareD = INF;
                            for (int j = 0; j < num; j++) {
                                if (i == j) continue;
                                if ((int)aTargetIndices[j].size() == Parameter::SmallUFOCapacity) continue;
                                if ((int)aTargetIndices[j].size() == Parameter::SmallUFOCapacity + 1) continue;

                                Vector2 center2 = Vector2::Zero();
                                for (auto& k : aTargetIndices[j]) {
                                    center2 += positions[k];
                                }
                                if (aTargetIndices[j].size() > 0) center2 /= aTargetIndices[j].size();

                                float squareD = center1.squareDist(center2);
                                if (squareD < minSquareD) {
                                    minSquareD = squareD;
                                    minJ = j;
                                }
                            }
                            aTargetIndices[minJ<0 ? i : minJ].push_back(index);
                        }
                    }
                }
            }
        }
    }

    // クラスタ内の順番をofficeから遠い順にソート
    void sortCluster1(std::deque<int>& aList, StageData stageData) {

        std::vector<std::pair<int, float>>  vec(aList.size());
        std::transform(aList.begin(), aList.end(), vec.begin(), [&](int i) {
            Vector2 v = stageData.houses()[i].pos() - stageData.office().pos();
            return std::make_pair(i, v.length());
        });

        std::sort(vec.begin(), vec.end(), [](std::pair<int, float> a, std::pair<int, float> b) {
            return a.second != b.second ? a.second > b.second : a.first < b.first;
        });

        std::transform(vec.begin(), vec.end(), aList.begin(), [&](std::pair<int, float> a) {
            return a.first;
        });

    }

    // クラスタ内の順番をいい感じに並び替える
    void sortCluster2(std::deque<int>& aList, StageData stageData) {
        int num = aList.size();

        if (num < 2) return;

        // 実質TSP

        int MAX_N = 8; //
        if (num <= MAX_N) {

            // 全探索

            // 末尾は動かさない
            std::vector<int> ary(num);
            std::transform(aList.begin(), aList.end(), ary.begin(), [](int i) {
                return i;
            });

            std::vector<int> perm(num - 1);
            std::iota(perm.begin(), perm.end(), 0);

            float minD = INF;
            std::vector<int> temp(num - 1);
            do {
                for (int i = 0; i < num - 1; i++) {
                    temp[i] = ary[perm[i]];
                }
                float d = 0;
                int index1 = ary[num - 1];
                for (int i = num - 2; i >= 0; i--) {
                    int index2 = temp[i];
                    d += mHouseDists[index1][index2];
                    index1 = index2;
                }
                if (d < minD) {
                    minD = d;
                    for (int i = 0; i < num - 1; i++) {
                        ary[i] = temp[i];
                    }
                }
            } while (std::next_permutation(perm.begin(), perm.end()));

            aList.clear();
            for (int i = 0; i < num; i++) {
                aList.push_back(ary[i]);
            }

        } else {

            // 改善法

            std::vector<int> ary(num);
            std::transform(aList.begin(), aList.end(), ary.begin(), [](int i) {
                return i;
            });

            bool improved = true; // 改善されたか
            int maxIter = 6; // 最大繰り返し回数

            // ランダムな順番の生成
            std::vector<int> randomVecI(num);
            std::vector<int> randomVecJ(num);
            std::vector<int> randomVecK(num);
            std::iota(randomVecI.begin(), randomVecI.end(), 0);
            std::iota(randomVecJ.begin(), randomVecJ.end(), 0);
            std::iota(randomVecK.begin(), randomVecK.end(), 0);
            for (int i = num - 1; i > 0; --i) {
                std::swap(randomVecI[i], randomVecI[rand.nextInt(i + 1)]); // shuffle
                std::swap(randomVecJ[i], randomVecJ[rand.nextInt(i + 1)]); // shuffle
                std::swap(randomVecK[i], randomVecK[rand.nextInt(i + 1)]); // shuffle
            }

            std::vector<int> _ary(num);

            while (improved && maxIter-->0) {
                improved = false;

                // 2-opt & 3-opt
                for (int _i = 0; _i < num; _i++) {
                    int i = randomVecI[_i];
                    if (i == num - 1) continue;
                    for (int _j = 0; _j < num; _j++) {
                        int j = randomVecJ[_j];
                        if (j == num - 1) continue;
                        if (j < i + 2) continue;
                        for (int _k = 0; _k < num; _k++) {
                            int k = randomVecK[_k];
                            if (k == num - 1) continue;
                            if (k < j + 2) continue;

                            int i0 = i, i1 = i + 1;
                            int j0 = j, j1 = j + 1;
                            int k0 = k, k1 = k + 1;

                            float d0 = mHouseDists[ary[i0]][ary[i1]] + mHouseDists[ary[j0]][ary[j1]] + mHouseDists[ary[k0]][ary[k1]];

                            float d1 = mHouseDists[ary[i0]][ary[k0]] + mHouseDists[ary[j1]][ary[i1]] + mHouseDists[ary[j0]][ary[k1]];
                            float d2 = mHouseDists[ary[i0]][ary[j1]] + mHouseDists[ary[k0]][ary[j0]] + mHouseDists[ary[k1]][ary[i1]];
                            float d3 = mHouseDists[ary[i0]][ary[j1]] + mHouseDists[ary[k0]][ary[i1]] + mHouseDists[ary[j0]][ary[k1]];
                            float d4 = mHouseDists[ary[i0]][ary[j0]] + mHouseDists[ary[j1]][ary[k1]] + mHouseDists[ary[k0]][ary[i1]];

                            float value[7 + 1];

                            value[0] = d0 - d0;

                            value[1] = d0 - d1;
                            value[2] = d0 - d2;
                            value[3] = d0 - d3;
                            value[4] = d0 - d4;

                            value[5] = (mHouseDists[ary[i0]][ary[i1]] + mHouseDists[ary[j0]][ary[j1]]) - (mHouseDists[ary[i0]][ary[j0]] + mHouseDists[ary[i1]][ary[j1]]);
                            value[6] = (mHouseDists[ary[j0]][ary[j1]] + mHouseDists[ary[k0]][ary[k1]]) - (mHouseDists[ary[j0]][ary[k0]] + mHouseDists[ary[j1]][ary[k1]]);
                            value[7] = (mHouseDists[ary[k0]][ary[k1]] + mHouseDists[ary[i0]][ary[i1]]) - (mHouseDists[ary[k0]][ary[i0]] + mHouseDists[ary[k1]][ary[i1]]);

                            float maxValue = 0;
                            int maxIndex = 0;
                            for (int l = 0; l < 7+1; l++) {
                                if (value[l] > maxValue) {
                                    maxValue = value[l];
                                    maxIndex = l;
                                }
                            }

                            if (maxIndex > 0) {
                                improved = true;

                                std::copy(ary.begin(), ary.end(), _ary.begin());

                                if (false) {
                                } else if (maxIndex == 1) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::reverse_copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1);
                                    std::copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1 + (k0 - j1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (k0 - j1) + 1 + (j0 - i1) + 1);
                                } else if (maxIndex == 2) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1);
                                    std::reverse_copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1 + (k0 - j1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (k0 - j1) + 1 + (j0 - i1) + 1);
                                } else if (maxIndex == 3) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1);
                                    std::copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1 + (k0 - j1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (k0 - j1) + 1 + (j0 - i1) + 1);
                                } else if (maxIndex == 4) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::reverse_copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1);
                                    std::reverse_copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1 + (j0 - i1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (j0 - i1) + 1 + (k0 - j1) + 1);
                                } else if (maxIndex == 5) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::reverse_copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1);
                                    std::copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1 + (j0 - i1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (j0 - i1) + 1 + (k0 - j1) + 1);
                                } else if (maxIndex == 6) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1);
                                    std::reverse_copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1 + (j0 - i1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (j0 - i1) + 1 + (k0 - j1) + 1);
                                } else if (maxIndex == 7) {
                                    std::copy(_ary.begin(), _ary.begin() + i0 + 1, ary.begin());
                                    std::reverse_copy(_ary.begin() + i1, _ary.begin() + j0 + 1, ary.begin() + i0 + 1);
                                    std::reverse_copy(_ary.begin() + j1, _ary.begin() + k0 + 1, ary.begin() + i0 + 1 + (j0 - i1) + 1);
                                    std::copy(_ary.begin() + k1, _ary.end(), ary.begin() + i0 + 1 + (j0 - i1) + 1 + (k0 - j1) + 1);
                                }
                            }
                        }
                    }
                }

                //// or-opt (あまり効果なかったので使わない)
                //for (int _i = 0; _i < num - 1; _i++) {
                //    int i = randomVecI[_i];
                //    if (i >= num - 2) continue;
                //    for (int _j = 0; _j < num - 1; _j++) {
                //        int j = randomVecJ[_j];
                //        if (j >= num - 1) continue;
                //        if (i <= j + 1 && i + 2 >= j) continue;

                //        int i0 = i, i1 = i + 1, i2 = i + 2;
                //        int j0 = j, j1 = j + 1;

                //        float d1 = mHouseDists[ary[i0]][ary[i1]];
                //        float d2 = mHouseDists[ary[i1]][ary[i2]];
                //        float d3 = mHouseDists[ary[j0]][ary[j1]];
                //        float d4 = mHouseDists[ary[i0]][ary[i2]];
                //        float d5 = mHouseDists[ary[j0]][ary[i1]];
                //        float d6 = mHouseDists[ary[i1]][ary[j1]];

                //        if (d4 + d5 + d6 < d1 + d2 + d3) {
                //            improved = true;
                //            int temp = ary[i + 1];
                //            for (int index = i + 1; index < j; index++) {
                //                ary[index] = ary[index + 1];
                //            }
                //            ary[j] = temp;
                //        }
                //    }
                //}
            }


            for (int i = 0; i < num; i++) {
                aList[i] = ary[i];
            }

        }
    }


    // largeUfoの初期目標位置を計算する -> mLargeUfoPositions
    //   - 要素数の多いクラスタの重心を目標位置とする
    //   - ただし、各目標位置が近づきすぎる場合は遠ざける
    void calcLargeUfoPositions(StageData stageData) {
        int largeUfoCount = Parameter::LargeUFOCount;
        int smallUfoCount = Parameter::SmallUFOCount;

        std::vector<int> vec(smallUfoCount);
        std::iota(vec.begin(), vec.end(), 0);
        std::sort(vec.begin(), vec.end(), [&](int a, int b) {
            return mTargetHouseIndices[a].size() > mTargetHouseIndices[b].size();
        });

        for (int i = 0; i < largeUfoCount; i++) {
            int j = vec[i];
            Vector2 p = Vector2::Zero();
            for (auto& a : mTargetHouseIndices[j]) {
                p += stageData.houses()[a].pos();
            }
            p /= mTargetHouseIndices[j].size();
            mLargeUfoPositions[i] = p;
        }

        //
        Vector2 diff1 = mLargeUfoPositions[0] - stageData.office().pos();
        float ang1 = std::atan2(diff1.y, diff1.x);

        for(int diff=1; ; diff++) {

            Vector2 diff2 = mLargeUfoPositions[1] - stageData.office().pos();
            float ang2 = std::atan2(diff2.y, diff2.x);
            float t = std::fmod(ang1 - ang2 + 2 * M_PI, 2 * M_PI);
            t = t < M_PI ? t : t - 2 * M_PI;
            t = std::abs(t);

            float P = mRandom_calcLargeUfoPositions3 * 3 + 3; // 5
            if (t > 2*M_PI / (P+diff)) {
                break;
            }

            int i = 1;
            if (i + diff >= smallUfoCount) break;
            int j = vec[i + diff];

            Vector2 p = Vector2::Zero();
            for (auto& a : mTargetHouseIndices[j]) {
                p += stageData.houses()[a].pos();
            }
            p /= mTargetHouseIndices[j].size();

            float R = mRandom_calcLargeUfoPositions1 * 0.4; // 0.3;
            mLargeUfoPositions[i] = mLargeUfoPositions[i]*R + p*(1-R);

        }

        // 目標位置を若干officeに近づける
        for (int i = 0; i < largeUfoCount; i++) {
            float R = mRandom_calcLargeUfoPositions2 * 0.2 + 0.8;
            Vector2 dir = mLargeUfoPositions[i] - stageData.office().pos();
            mLargeUfoPositions[i] = stageData.office().pos() + dir * R;
        }
    }

    // ↑ここまで init に関する処理
    //-----------------------------------------------
    // ↓ここから moveItems/moveUfos に関する処理

    void moveItems(StageData stageData, Actions& aActions) {

        // deliveredなhouseを除外する
        filterNotDeliveredHouses(stageData);

        int ufoCount = stageData.ufos().count();
        int largeUfoCount = Parameter::LargeUFOCount;

        for (int ufoIndex = 0; ufoIndex < ufoCount; ++ufoIndex) {
            const auto& ufo = stageData.ufos()[ufoIndex];

            if (stageData.ufos()[ufoIndex].type() == UFOType_Large) {
                // largeUfoに関するアクション

                // officeの上にいたら箱を積み込む
                if (Util::IsIntersect(ufo, stageData.office())) {
                    aActions.add(Action::PickUp(ufoIndex));
                }

                // アイテムを持っていなかったら何もしない
                if (ufo.itemCount() == 0) continue;

                // houseと重なっていたらitemを届ける
                for (auto& houseIndex : mNotDeliveredHouseIndices) {
                    if (stageData.houses()[houseIndex].delivered()) continue;
                    if (Util::IsIntersect(ufo, stageData.houses()[houseIndex])) {
                        aActions.add(Action::Deliver(ufoIndex, houseIndex));
                    }
                }

            } else {
                // smallUfoに関するアクション

                // officeの上にいたら箱を積み込む
                if (Util::IsIntersect(ufo, stageData.office())) {
                    aActions.add(Action::PickUp(ufoIndex));
                }

                // largeUfoに重なっていたらitemを受け取る
                for (int i = 0; i < largeUfoCount; i++) {
                    if (Util::IsIntersect(ufo, stageData.ufos()[i])) {
                        aActions.add(Action::Pass(i, ufoIndex));
                    }
                }

                // itemを持っていなかったらなにもしない
                if (ufo.itemCount() == 0) continue;

                // 目標のhouseの計算
                int houseIndex = -1;
                while (true) {
                    houseIndex = nextHouse(ufoIndex, stageData);
                    if (houseIndex < 0) break;
                    if (stageData.houses()[houseIndex].delivered()) {
                        popNextHouse(ufoIndex);
                    } else {
                        break;
                    }
                }

                if (houseIndex >= 0) {
                    // 目標のhouseの上にいたら届ける
                    if (Util::IsIntersect(ufo, stageData.houses()[houseIndex])) {
                        aActions.add(Action::Deliver(ufoIndex, houseIndex));

                        // 目標のhouseを更新
                        popNextHouse(ufoIndex);
                    }
                }

                // 途中にhouseがあったらついでに届ける
                for (auto& i : mNotDeliveredHouseIndices) {
                    if (ufo.itemCount() == 0) break;
                    if (ufo.itemCount() == 1  && mRandom_moveItems<0.6) break; // 残り1個のときは届けない
                    if (stageData.houses()[i].delivered()) continue;
                    if (Util::IsIntersect(ufo, stageData.houses()[i])) {
                        aActions.add(Action::Deliver(ufoIndex, i));
                    }
                }

            }

        }
    }

    void moveUFOs(StageData stageData, TargetPositions& aTargetPositions) {

        // deliveredなhouseを除外する
        filterNotDeliveredHouses(stageData);

        int ufoCount = stageData.ufos().count();

        // largeUfoの目的位置を再計算する
        updateLargeUfos(stageData);

        // 各ufoに関するアクション
        for (int ufoIndex = 0; ufoIndex < ufoCount; ++ufoIndex) {
            moveUfo(ufoIndex, stageData, aTargetPositions);
        }
    }

    // stageData.ufos()[ufoIndex] のtargetPositionの計算&アクションの追加
    void moveUfo(int ufoIndex, StageData stageData, TargetPositions& aTargetPositions) {
        const auto& ufo = stageData.ufos()[ufoIndex];

        if (stageData.ufos()[ufoIndex].type() == UFOType_Large) {
            // largeUfoに関するアクション

            if (ufo.itemCount() == 0) {
                // itemがなければofficeに向かう
                aTargetPositions.add(stageData.office().pos());
            } else {
                // itemがあれば目標位置に向かう
                aTargetPositions.add(mLargeUfoPositions[ufoIndex]);
            }

        } else {
            // smallUfoに関するアクション

            // 近くの補給位置(office or largeUfo)を探す
            Vector2 supplyPos;
            getSupplyPosition(supplyPos, ufo.pos(), stageData);

            if (ufo.itemCount() == 0) {
                // itemがないとき

                aTargetPositions.add(supplyPos);

            } else {
                // itemがあるときは目標houseに向かう

                // 目標houseの計算
                int houseIndex = -1;
                while (true) {
                    houseIndex = nextHouse(ufoIndex, stageData);
                    if (houseIndex < 0) break;
                    if (stageData.houses()[houseIndex].delivered()) {
                        popNextHouse(ufoIndex);
                    } else {
                        break;
                    }
                }

                if (houseIndex < 0) {
                    // 目標houseがないので役割終了
                    aTargetPositions.add(stageData.office().pos());
                } else {
                    // 目標houseがあるとき

                    // itemが残り少なく近くに補給所(office or largeUfo)があればそちらを優先する

                    bool near = true;
                    near &= ufo.itemCount() <= 2;
                    near &= mNotDeliveredHouseIndices.size() >= 10;
                    if (near) {
                        float supplyPosDist = supplyPos.dist(ufo.pos());
                        near &= supplyPosDist < Parameter::StageHeight / (8 + ufo.itemCount());
                        if (near) {
                            near &= supplyPosDist < stageData.houses()[houseIndex].pos().dist(ufo.pos()) / 2;
                        }
                    }

                    if (near) {
                        aTargetPositions.add(supplyPos);
                    } else {
                        Vector2 diff = stageData.houses()[houseIndex].pos() - ufo.pos();
                        float leng = diff.length();
                        if (leng > 0) {
                            diff = diff / leng * std::min(leng + Parameter::SmallUFORadius*0.9f + Parameter::HouseRadius*0.9f, (float)Parameter::SmallUFOMaxSpeed);
                        }
                        aTargetPositions.add(ufo.pos() + diff);
                    }

                }
            }
        }
    }

    // 次のhouseのindexを取得

    int nextHouse(int ufoIndex, StageData stageData) {
        assert(ufoIndex >= Parameter::LargeUFOCount);

        int result = -1;

        if (!mTargetHouseIndices[ufoIndex - Parameter::LargeUFOCount].empty()) {
            // 担当クラスタにまだhouseが残ってたらそれらを優先的に
            result = mTargetHouseIndices[ufoIndex - Parameter::LargeUFOCount].back();
            float R = mRandom_nextHouse3*0.8 + 1.1; // 1.5
            if (result >= 0) {
                float d = stageData.houses()[result].pos().dist(stageData.ufos()[ufoIndex].pos());
                if (d/R > mMinDists[result].second && ufoIndex != mMinDists[result].first) {
                    mTargetHouseIndices[ufoIndex - Parameter::LargeUFOCount].pop_back();
                    result = nextHouse(ufoIndex, stageData);
                }
            }
        }

        //if (result < 0 && mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount] >= 0) {
        //    // 目標houseから離れていたら別のhouseへ変更しない
        //    auto& house = stageData.houses()[mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount]];
        //    float dist = stageData.ufos()[ufoIndex].pos().dist(house.pos());
        //    if (!house.delivered() && dist > Parameter::StageHeight / 6) {
        //        result = mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount];
        //    }
        //}

        if (result < 0) {
            // 近くのまだ届けられてないhouseを探す

            // dir: officeからufoへの方向ベクトル
            Vector2 dir = stageData.ufos()[ufoIndex].pos() - stageData.office().pos();
            float dirLeng = dir.length();
            if (dirLeng > 0) dir /= dirLeng; // normalize

            float minWeightD1 = INF;
            int minIndex1 = -1;
            float minWeightD2 = INF;
            int minIndex2 = -1;

            float T = mRandom_nextHouse1 * 15 + 40; // 50;
            float W = mRandom_nextHouse2 * 2 + 2; // 3
            for (auto& j : mNotDeliveredHouseIndices) {
                if (stageData.houses()[j].delivered()) continue;

                Vector2 diff = stageData.houses()[j].pos() - stageData.ufos()[ufoIndex].pos();
                float d = diff.length();
                Vector2 diffDir = d > 0 ? diff / d : diff; // ufoからhouseへの方向ベクトル

                bool flag = (stageData.houses()[j].pos() - stageData.office().pos()).dot(dir) > 0;
                float a = flag ? W - diffDir.dot(dir) : W+1; // dir方向に重み付け
                float weightD = d * a;

                float d1 = stageData.ufos()[0].pos().dist(stageData.houses()[j].pos());
                float d2 = stageData.ufos()[1].pos().dist(stageData.houses()[j].pos());
                float largeD = std::min(d1, d2);

                // LargeUfoに近い家には運びにくくする
                weightD *= 1 + std::pow(
                    std::max(
                        0.0f,
                        Parameter::StageHeight / 2 - largeD
                    ) / (Parameter::StageHeight / 2),
                    4
                ) * T;

                if (weightD < minWeightD2) {
                    minWeightD2 = weightD;
                    minIndex2 = j;
                }
                if (
                    d > mMinDists[j].second &&
                    (ufoIndex != mMinDists[j].first || d > Parameter::StageHeight / 8)
                ) {
                    continue;
                }
                if (weightD < minWeightD1) {
                    minWeightD1 = weightD;
                    minIndex1 = j;
                }
            }

            result = minIndex1 >= 0 ? minIndex1 : minIndex2;
        }

        // mMinDistsの更新
        if (result >= 0 && stageData.ufos()[ufoIndex].itemCount() > 0) {
            float d = stageData.houses()[result].pos().dist(stageData.ufos()[ufoIndex].pos());
            if (d < mMinDists[result].second) {
                mMinDists[result].first = ufoIndex;
                mMinDists[result].second = d * 1.0001;
            }
        }

        // mLastHouseIndicesの更新
        if (result != mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount]) {
            int preIndex = mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount];
            if (preIndex >= 0 && mMinDists[preIndex].first==ufoIndex) {
                // 対象が変わった場合は mMinDists[preIndex] を初期化
                mMinDists[preIndex].first = -1;
                mMinDists[preIndex].second = INF;
            }
            mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount] = result; // memorize
        }

        return result;
    }

    // 次のhouseの削除
    void popNextHouse(int ufoIndex) {
        assert(ufoIndex >= Parameter::LargeUFOCount);

        int target = mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount];
        for (int i = 0; i < (int)mTargetHouseIndices.size(); i++) {
            auto& list = mTargetHouseIndices[i];
            if (list.empty()) continue;
            if (list.front() == target) {
                list.pop_front();
                break;
            } else if (list.back() == target) {
                list.pop_back();
                break;
            }
        }
        mLastHouseIndices[ufoIndex - Parameter::LargeUFOCount] = -1;
    }

    // ufoPosから一番近い補給位置(office or largeUfo)を計算する -> supplyPos
    void getSupplyPosition(Vector2& supplyPos, Vector2 ufoPos, StageData stageData) {

        supplyPos = stageData.office().pos();

        float minSquareD = ufoPos.squareDist(supplyPos);
        for (int i = 0; i < Parameter::LargeUFOCount; i++) {
            if (stageData.ufos()[i].itemCount() == 0) continue;

            // largeUfo は動くので †いい感じ† に距離を求める

            Vector2 dir = mLargeUfoPositions[i] - stageData.ufos()[i].pos();
            float tempD = dir.length();
            if (tempD > 0) {
                dir = dir / tempD * (float)Parameter::LargeUFOMaxSpeed * ufoPos.dist(stageData.ufos()[i].pos()) / (float)Parameter::SmallUFOMaxSpeed;
            }
            Vector2 tempPos = stageData.ufos()[i].pos() + dir;

            float squareD = ufoPos.squareDist(tempPos);
            if (squareD < minSquareD) {
                minSquareD = squareD;
                supplyPos = tempPos;
            }
        }
    }

    // largeUfoの目標位置の再計算 -> mLargeUfoPositions, mMinDists
    void updateLargeUfos(StageData stageData) {

        for (int i = 0; i < Parameter::LargeUFOCount; i++) {
            updateLargeUfo(i, stageData);
        }

    }

    void updateLargeUfo(int ufoIndex, StageData stageData) {

        float dist = (stageData.ufos()[ufoIndex].pos() - mLargeUfoPositions[ufoIndex]).length(); // 目的地までの距離

        float T = mRandom_updateLargeUfos2 * 2 + 3;
        if (
            (dist > Parameter::StageHeight / T) &&
            (mLastLargeUfoTargetIndex[ufoIndex]<0 || !stageData.houses()[mLastLargeUfoTargetIndex[ufoIndex]].delivered())
        ) return; // 目的地まで離れすぎてたら目的地を変更しない

        auto getMinIndex = [&](Vector2 ufoPos, int deliverdIndex = -1)->int {
            Vector2 dir = Vector2::Zero();
            for (int j = 0; j < Parameter::SmallUFOCount; j++) {
                auto& smallUfo = stageData.ufos()[Parameter::LargeUFOCount + j];
                if (smallUfo.itemCount() == 0) continue;
                Vector2 diff = smallUfo.pos() - ufoPos;
                float d = diff.length();
                if (d > 0) diff /= d;
                if (d < Parameter::StageHeight / 8) {
                    if (smallUfo.itemCount() <= 2) {
                        dir += diff; // アイテムの少ないsmallUfoには近づく
                    } else {
                        //dir -= diff; // アイテムの多いsmallUfoには離れる
                    }
                }
            }
            float dirLeng = dir.length();
            if (dirLeng > 0) dir /= dirLeng; // normalize

            float minWeightD1 = INF;
            int minJ1 = -1;
            float minWeightD2 = INF;
            int minJ2 = -1;
            for (auto& j : mNotDeliveredHouseIndices) {
                if (stageData.houses()[j].delivered()) continue;
                if (j == deliverdIndex) continue;

                Vector2 v = stageData.houses()[j].pos() - ufoPos;
                float d = v.length();
                Vector2 vDir = d > 0 ? v / d : v;

                float W = mRandom_updateLargeUfos1 * 3 + 4; // 6
                bool flag = (stageData.houses()[j].pos() - stageData.office().pos()).dot(dir) > 0;
                float a = flag ? W - vDir.dot(dir) : W + 1; // dirの方向に重み付け
                float weightD = d*a;

                if (weightD < minWeightD2) {
                    minWeightD2 = weightD;
                    minJ2 = j;
                }
                if (
                    d * Parameter::SmallUFOMaxSpeed / Parameter::LargeUFOMaxSpeed / 2 > mMinDists[j].second &&
                    (ufoIndex != mMinDists[j].first || d > Parameter::StageHeight/8)
                ) {
                    continue;
                }
                if (weightD < minWeightD1) {
                    minWeightD1 = weightD;
                    minJ1 = j;
                }
            }

            return minJ1>=0 ? minJ1 : minJ2;
        };

        int index1 = getMinIndex(stageData.ufos()[ufoIndex].pos());
        if (index1 >= 0) {
            Vector2 targetPos = stageData.houses()[index1].pos();

            int index2 = getMinIndex(targetPos, index1);
            if (index2 >= 0) {
                Vector2 diff = stageData.houses()[index2].pos() - targetPos;

                if (diff.length() > 0) diff = diff / diff.length() * Parameter::LargeUFORadius * 0.95;
                targetPos += diff;
            }

            mLastLargeUfoTargetIndex[ufoIndex] = index1;
            mLargeUfoPositions[ufoIndex] = targetPos;

            float d = stageData.ufos()[ufoIndex].pos().dist(targetPos);
            if (d * Parameter::SmallUFOMaxSpeed / Parameter::LargeUFOMaxSpeed < mMinDists[index1].second) {
                mMinDists[index1].first = ufoIndex;
                mMinDists[index1].second = d * Parameter::SmallUFOMaxSpeed / Parameter::LargeUFOMaxSpeed;
            }
        }

    }

    // deliveredなhouseの除外 -> mNotDeliveredHouseIndices
    void filterNotDeliveredHouses(StageData stageData) {
        mNotDeliveredHouseIndices.remove_if([&](int i) {
            return stageData.houses()[i].delivered();
        });
    }

    // house間の距離の計算 -> mHouseDists
    void calcHouseDists(StageData stageData) {
        auto& houses = stageData.houses();
        for (int i = 0; i < houses.count(); i++) {
            for (int j = 0; j < houses.count(); j++) {
                mHouseDists[i][j] = houses[i].pos().dist(houses[j].pos());
            }
        }
    }

};

Solver g_Solver;
Answer::Answer() {}
Answer::~Answer() {}
void Answer::init(const Stage& aStage) {
    g_Solver.init(aStage);
}
void Answer::moveItems(const Stage& aStage, Actions& aActions) {
    g_Solver.moveItems(aStage, aActions);
}
void Answer::moveUFOs(const Stage& aStage, TargetPositions& aTargetPositions) {
    g_Solver.moveUFOs(aStage, aTargetPositions);
}
void Answer::finalize(const Stage& aStage) {}
}
