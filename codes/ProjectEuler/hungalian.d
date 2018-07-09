import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.functional;
import std.bigint;
import std.numeric;
import std.array;
import std.math;
import std.range;
import std.container;
import std.ascii;
import std.concurrency;
import std.random;
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}

void main() {
    long[][] m = [
        [  7, 53,183,439,863,497,383,563, 79,973,287, 63,343,169,583],
        [627,343,773,959,943,767,473,103,699,303,957,703,583,639,913],
        [447,283,463, 29, 23,487,463,993,119,883,327,493,423,159,743],
        [217,623,  3,399,853,407,103,983, 89,463,290,516,212,462,350],
        [960,376,682,962,300,780,486,502,912,800,250,346,172,812,350],
        [870,456,192,162,593,473,915, 45,989,873,823,965,425,329,803],
        [973,965,905,919,133,673,665,235,509,613,673,815,165,992,326],
        [322,148,972,962,286,255,941,541,265,323,925,281,601, 95,973],
        [445,721, 11,525,473, 65,511,164,138,672, 18,428,154,448,848],
        [414,456,310,312,798,104,566,520,302,248,694,976,430,392,198],
        [184,829,373,181,631,101,969,613,840,740,778,458,284,760,390],
        [821,461,843,513, 17,901,711,993,293,157,274, 94,192,156,574],
        [ 34,124,  4,878,450,476,712,914,838,669,875,299,823,329,699],
        [815,559,813,459,522,788,168,586,966,232,308,833,251,631,107],
        [813,883,451,509,615, 77,281,613,459,205,380,274,302, 35,805]
    ];

    hungarian(m).writeln;
}

// Hungarian algorithm
// O(n^3)
//  ref: https://www.cs.ucsb.edu/~suri/cs231/Matching.pdf

long hungarian(long[][] costMatrix) {
    int dim = costMatrix.length.to!int;

    // initialize labels
    long[] label1 = dim.iota.map!(i => costMatrix[i].reduce!max).array;
    long[] label2 = 0L.repeat(dim).array;

    // initialize a matching
    int[] match1 = (-1).repeat(dim).array;
    int[] match2 = (-1).repeat(dim).array;
    foreach(int i, costs; costMatrix) {
        foreach(int j, cost; costs) {
            if (label1[i] + label2[j] != cost) continue;
            if (match1[i]>=0 || match2[j]>=0)  continue;
            match1[i] = j;
            match2[j] = i;
        }
    }

    bool[] S = new bool[dim];
    bool[] T = new bool[dim];
    bool[] N = new bool[dim];
    while(true) {

        // If match1/match2 is perfect matching, stop.
        if (match1.all!"a>=0") break;

        // Step 3
        S[] = false;
        T[] = false;
        int u = match1.countUntil!"a<0".to!int;
        S[u] = true;

        while(true) {
            N[] = false;
            foreach(i, flg; S) {
                if (flg) {
                    foreach(j; 0..dim) {
                        if (costMatrix[i][j] == label1[i] + label2[j]) {
                            N[j] = true;
                        }
                    }
                }
            }

            // Step 4
            if (N == T) {
                long a = long.max;
                foreach(i, flg1; S) foreach(j, flg2; T) {
                    if (flg1 && !flg2) {
                        a = min(a, label1[i] + label2[j] - costMatrix[i][j]);
                    }
                }
                foreach(i, flg; S) {
                    if (flg) label1[i] -= a;
                }
                foreach(j, flg; T) {
                    if (flg) label2[j] += a;
                }
            }


            N[] = false;
            foreach(i, flg; S) {
                if (flg) {
                    foreach(j; 0..dim) {

                        if (costMatrix[i][j] == label1[i] + label2[j]) {
                            N[j] = true;
                        }
                    }
                }
            }
            assert(N != T);

            // Step 4
            if (N != T) {
                size_t y = -1;
                foreach(j; 0..dim) {
                    if (N[j] && !T[j]) {
                        y = j;
                        break;
                    }
                }

                if (match2[y] < 0) {
                    match1[u] = y;
                    match2[y] = u;
                    break;
                } else {
                    S[match2[y]] = true;
                    T[y] = true;
                    int v = match2[y];
                    match1[u] = y;
                    match2[y] = u;
                    u = v;
                }
            }
        }

    }

    long res = 0;
    match1.writeln;
    foreach(i, j; match1) {
        res += costMatrix[i][j];
    }
    return res;
}
