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

void main() {
    double[] t = array(map!(to!double)(readln.split));
    double[][] p = new double[][3];
    for(int i=0; i<p.length; i++) {
        p[i] = new double[2];
        for (int j=0; j<p[0].length; j++) {
            p[i][j] = t[2*i+j];
        }
    }
    double ans = (((p[1][0]-p[0][0])*(p[2][1]-p[0][1])-(p[1][1]-p[0][1])*(p[2][0]-p[0][0]))/2).abs;
    writefln("%.3f", ans);
}
