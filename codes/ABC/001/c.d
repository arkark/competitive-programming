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
    string[] strs = readln.split;
    double deg = strs[0].to!double / 10.0;
    double dis = (strs[1].to!double / 6.0).round / 10.0;

    string dir;
    int w;

    double[] ary = new double[16];
    for (int i=0; i<ary.length; i++) {
        ary[i] = 11.25 + 22.5*i;
    }
    if (deg < ary[0]) dir = "N";
    else if (deg < ary[1]) dir = "NNE";
    else if (deg < ary[2]) dir = "NE";
    else if (deg < ary[3]) dir = "ENE";
    else if (deg < ary[4]) dir = "E";
    else if (deg < ary[5]) dir = "ESE";
    else if (deg < ary[6]) dir = "SE";
    else if (deg < ary[7]) dir = "SSE";
    else if (deg < ary[8]) dir = "S";
    else if (deg < ary[9]) dir = "SSW";
    else if (deg < ary[10]) dir = "SW";
    else if (deg < ary[11]) dir = "WSW";
    else if (deg < ary[12]) dir = "W";
    else if (deg < ary[13]) dir = "WNW";
    else if (deg < ary[14]) dir = "NW";
    else if (deg < ary[15]) dir = "NNW";
    else dir = "N";

    if (dis < 0.3) w = 0;
    else if (dis < 1.6) w = 1;
    else if (dis < 3.4) w = 2;
    else if (dis < 5.5) w = 3;
    else if (dis < 8.0) w = 4;
    else if (dis < 10.8) w = 5;
    else if (dis < 13.9) w = 6;
    else if (dis < 17.2) w = 7;
    else if (dis < 20.8) w = 8;
    else if (dis < 24.5) w = 9;
    else if (dis < 28.5) w = 10;
    else if (dis < 32.7) w = 11;
    else w = 12;

    if (w == 0) dir = "C";

    writeln(dir, " ", w);
}
