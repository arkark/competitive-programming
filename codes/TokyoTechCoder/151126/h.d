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
    int N = readln.chomp.to!int;
    long[] x = readln.split.to!(long[]);
    int[] id = N.iota.map!(a=>a+1).array;

    sort!((a, b) => a[0]>b[0])(zip(x, id));
    bool[][] capacity = new bool[][](N, N);
    foreach(int j; 0..N) foreach(int k; j+1..N) {
        if (x[j]%x[k]==0) capacity[j][k] = true;
    }
    int maxLength = getLength(capacity);
    sort!((a, b) => a[1]<b[1])(zip(x, id));

    int[] ans;
    for (int i=0; i<x.length; i++) {
        long[] _x = x[0..i]~x[i+1..$];
        int[] _id = id[0..i]~id[i+1..$];
        int count = 0;
        for(int j=0; j<_x.length; j++) {
            if (x[i]%_x[j]==0 || _x[j]%x[i]==0) {
                if (_id[j]<id[i]) count++;
                _x = _x[0..j]~_x[j+1..$];
                _id = _id[0..j]~_id[j+1..$];
                j--;
            }
        }

        sort!((a, b) => a[0]>b[0])(zip(_x, _id));
        bool[][] _capacity = new bool[][](_x.length, _x.length);
        for (int j=0; j<_x.length; j++) for (int k=j+1; k<_x.length; k++) {
            if (_x[j]%_x[k]==0) _capacity[j][k] = true;
        }
        int _maxLength = getLength(_capacity);
        sort!((a, b) => a[1]<b[1])(zip(_x, _id));

        if (_maxLength+1 == maxLength) {
            ans ~= id[i];
            x = _x;
            id = _id;
            capacity = _capacity;
            maxLength = _maxLength;
            i = i-1-count;
        }
    }
    ans.sort.to!string.tr("[],", "", "d").writeln;
}
int getLength(bool[][] capacity) {
    int size = capacity.length.to!int;
    bool[][] flow = new bool[][](size, size);
    foreach(int i; 0..size) foreach(int j; 0..size) {
        bool _flg = true;
        foreach(int k; 0..size) if (flow[k][j]) _flg = false;
        if (_flg && capacity[i][j]) {
            flow[i][j] = true;
            break;
        }
    }
    int result = size;
    foreach(int j; 0..size) foreach(int i; 0..size) {
        if (flow[i][j]) {
            result--;
            break;
        }
    }
    result.writeln;
    return result;
}
