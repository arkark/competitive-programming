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
    while(true) {
        string[] input = readln.chomp.split(".");
        if (input == ["#"]) break;
        if (input.length == 3) {
            seirekiToMaya(input).reduce!((a,b)=>a~"."~b).writeln;
        } else {
            mayaToSeireki(input).reduce!((a,b)=>a~"."~b).writeln;
        }
    }
}
string[] seirekiToMaya(string[] seireki) {
    int Y = seireki[0].to!int;
    int M = seireki[1].to!int;
    int D = seireki[2].to!int;
    long temp = 0;
    if (Y>2012) {
        temp = func(12, 2012)-21;
        foreach(y; 2013..Y) {
            temp += isUruu(y) ? 366:365;
        }
        foreach(m; 1..M) {
            temp += func(m, Y);
        }
        temp += D;
    } else {
        temp = D-21;
    }
    temp %= 13*20*20*18*20;
    long ki, w, t, ka, b;
    ki = temp;
    w = ki/20;
    ki %= 20;
    t = w/18;
    w %= 18;
    ka = t/20;
    t %= 20;
    b = ka/20;
    ka %= 20;
    return [b, ka, t, w, ki].to!(string[]);
}
string[] mayaToSeireki(string[] maya) {
    int b = maya[0].to!int;
    int ka = maya[1].to!int;
    int t = maya[2].to!int;
    int w = maya[3].to!int;
    int ki = maya[4].to!int;
    long temp = b;
    temp = temp*20+ka;
    temp = temp*20+t;
    temp = temp*18+w;
    temp = temp*20+ki;

    int y, m, d;
    if (temp>10) {
        temp-=11;
        y = 2013;
        m = 1;
        d = 1;
        while (temp>= (isUruu(y) ? 366:365)) {
            temp -= isUruu(y) ? 366:365;
            y += 1;
        }
        while (temp>= func(m, y)) {
            temp -= func(m, y);
            m += 1;
        }
        d += temp.to!int;
    } else {
        y = 2012;
        m = 12;
        d = 21+temp.to!int;
    }
    return [y, m, d].to!(string[]);
}
int func(int m, int y) {
    switch(m) {
        case 2: {
            if (isUruu(y)) {
                return 29;
            } else {
                return 28;
            }
        } break;
        case 4: case 6: case 9: case 11: {
            return 30;
        } break;
        default: {
            return 31;
        }
    }
}
bool isUruu(int y) {
    return y%4==0 && (y%100!=0 || y%400==0);
}
