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

void main() {
    int[] input = readln.split.to!(int[]);
    int N = input[0];
    int K = input[1];
    long[][] data = new long[][N];
    bool[long][] aa = new bool[long][3];
    foreach(i; 0..N) {
        data[i] = readln.split.to!(long[]);
        foreach(j; 0..3) {
            aa[j][data[i][j]] = true;
            aa[j][data[i][j+3]] = true;
        }
    }
    long[][] values = new long[][3];
    foreach(i; 0..3) values[i] = aa[i].keys.sort;
    int[long][] keys = new int[long][3];
    foreach(i; 0..3) foreach(k, v; values[i]) keys[i][v] = k.to!int;
    int[][][] imos = new int[][][](keys[0].length, keys[1].length, keys[2].length);
    foreach(e; data) {
        imos[keys[0][e[0]]][keys[1][e[1]]][keys[2][e[2]]]++;
        imos[keys[0][e[3]]][keys[1][e[1]]][keys[2][e[2]]]--;
        imos[keys[0][e[0]]][keys[1][e[4]]][keys[2][e[2]]]--;
        imos[keys[0][e[0]]][keys[1][e[1]]][keys[2][e[5]]]--;
        imos[keys[0][e[3]]][keys[1][e[4]]][keys[2][e[2]]]++;
        imos[keys[0][e[0]]][keys[1][e[4]]][keys[2][e[5]]]++;
        imos[keys[0][e[3]]][keys[1][e[1]]][keys[2][e[5]]]++;
        imos[keys[0][e[3]]][keys[1][e[4]]][keys[2][e[5]]]--;
    }
    foreach(i; 1..keys[0].length) {
        foreach(j; 0..keys[1].length) {
            foreach(k; 0..keys[2].length) {
                imos[i][j][k] += imos[i-1][j][k];
            }
        }
    }
    foreach(i; 0..keys[0].length) {
        foreach(j; 1..keys[1].length) {
            foreach(k; 0..keys[2].length) {
                imos[i][j][k] += imos[i][j-1][k];
            }
        }
    }
    foreach(i; 0..keys[0].length) {
        foreach(j; 0..keys[1].length) {
            foreach(k; 1..keys[2].length) {
                imos[i][j][k] += imos[i][j][k-1];
            }
        }
    }
    long ans = 0;
    foreach(i; 0..keys[0].length) {
        foreach(j; 0..keys[1].length) {
            foreach(k; 0..keys[2].length) {
                if (imos[i][j][k]>=K) {
                    ans += (values[0][i+1]-values[0][i])*(values[1][j+1]-values[1][j])*(values[2][k+1]-values[2][k]);
                }
            }
        }
    }
    ans.writeln;
}
