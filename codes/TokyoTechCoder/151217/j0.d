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

long prime = 101;
int n;
char[] set = '.' ~ iota('A', 'Z'+1).map!(a=>a.to!char).array;
void main() {
    while(true) {
        int[] input = readln.split.to!(int[]);
        if (input == [0, 0]) break;
        int d = input[0];
        n = input[1];
        char[] kaizan = readln.chomp.to!(char[]);
        char[][] pieces = new char[][n];
        foreach(int i; 0..n) {
            pieces[i] = readln.chomp.to!(char[]);
        }

        char[][] ary;

        bool[] flg = new bool[kaizan.length];
        foreach(int i; 0..n) {
            rabinKarp(kaizan, pieces[i], flg);
        }
        if (flg.filter!(a=>a).array.length == flg.length) {
            ary ~= kaizan;
        }
        ary ~= getSet_insert(kaizan, pieces);
        ary ~= getSet_replace(kaizan, pieces);
        ary ~= getSet_remove(kaizan, pieces);
        if (d==2) {
            ary ~= getSet_insert_insert(kaizan, pieces);
            ary ~= getSet_replace_replace(kaizan, pieces);
            ary ~= getSet_remove_remove(kaizan, pieces);
            ary ~= getSet_insert_replace(kaizan, pieces);
            ary ~= getSet_insert_remove(kaizan, pieces);
            ary ~= getSet_replace_remove(kaizan, pieces);
        }
        /*if (d==2) {
            int leng = ary.length.to!int;
            foreach (int i; 1..leng) {
                ary ~= getSet_insert(ary[i], pieces);
                ary ~= getSet_replace(ary[i], pieces);
                ary ~= getSet_remove(ary[i], pieces);
            }
        }*/

        char[][] ans = ary.sort.uniq.array;
        ans.length.writeln;
        if (ans.length <= 5) {
            for(int i=0; i<ans.length; i++) {
                ans[i].writeln;
            }
        }
    }
}
char[][] getSet_insert(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<=str.length; i++) {
        for(int j=0; j<set.length; j++) {
            char[] temp = str[0..i] ~ set[j] ~ str[i..$];
            bool[] flg = new bool[temp.length];
            foreach(int k; 0..n) {
                rabinKarp(temp, pieces[k], flg);
            }
            if (flg.filter!(a=>a).array.length == flg.length) {
                result ~= temp;
            }
        }
    }
    return result;
}
char[][] getSet_replace(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<str.length; i++) {
        for(int j=0; j<set.length; j++) {
            if (str[i] == set[j]) continue;
            char[] temp = str[0..i] ~ set[j] ~ str[i+1..$];
            bool[] flg = new bool[temp.length];
            foreach(int k; 0..n) {
                rabinKarp(temp, pieces[k], flg);
            }
            if (flg.filter!(a=>a).array.length == flg.length) {
                result ~= temp;
            }
        }
    }
    return result;
}
char[][] getSet_remove(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<str.length; i++) {
        char[] temp = str[0..i] ~ str[i+1..$];
        bool[] flg = new bool[temp.length];
        foreach(int k; 0..n) {
            rabinKarp(temp, pieces[k], flg);
        }
        if (flg.filter!(a=>a).array.length == flg.length) {
            result ~= temp;
        }
    }
    return result;
}
char[][] getSet_insert_insert(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<=str.length; i++) {
        for(int j=0; j<set.length; j++) {
            char[] temp = str[0..i] ~ set[j] ~ str[i..$];
            for(int k=0; k<=temp.length; k++) {
                for(int l=j; l<set.length; l++) {
                    char[] _temp = temp[0..k] ~ set[l] ~ temp[k..$];
                    bool[] flg = new bool[_temp.length];
                    foreach(int m; 0..n) {
                        rabinKarp(_temp, pieces[m], flg);
                    }
                    if (flg.filter!(a=>a).array.length == flg.length) {
                        result ~= _temp;
                    }
                }
            }

        }
    }
    return result;
}
char[][] getSet_replace_replace(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<str.length; i++) {
        for(int j=0; j<set.length; j++) {
            if (str[i] == set[j]) continue;
            char[] temp = str[0..i] ~ set[j] ~ str[i+1..$];
            for(int k=0; k<temp.length; k++) {
                if (k==i) continue;
                for(int l=j; l<set.length; l++) {
                    char[] _temp = temp[0..k] ~ set[l] ~ temp[k+1..$];
                    bool[] flg = new bool[_temp.length];
                    foreach(int m; 0..n) {
                        rabinKarp(_temp, pieces[m], flg);
                    }
                    if (flg.filter!(a=>a).array.length == flg.length) {
                        result ~= _temp;
                    }
                }
            }
        }
    }
    return result;
}
char[][] getSet_remove_remove(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<str.length; i++) {
        for(int j=i+1; j<str.length; j++) {
            char[] temp = str[0..i] ~ str[i+1..j] ~ str[j+1..$];
            bool[] flg = new bool[temp.length];
            foreach(int k; 0..n) {
                rabinKarp(temp, pieces[k], flg);
            }
            if (flg.filter!(a=>a).array.length == flg.length) {
                result ~= temp;
            }
        }

    }
    return result;
}
char[][] getSet_insert_replace(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<=str.length; i++) {
        for(int j=0; j<set.length; j++) {
            char[] temp = str[0..i] ~ set[j] ~ str[i..$];
            for(int k=0; k<temp.length; k++) {
                if (k==i) continue;
                for(int l=0; l<set.length; l++) {
                    char[] _temp = temp[0..k] ~ set[l] ~ temp[k+1..$];
                    bool[] flg = new bool[_temp.length];
                    foreach(int m; 0..n) {
                        rabinKarp(_temp, pieces[m], flg);
                    }
                    if (flg.filter!(a=>a).array.length == flg.length) {
                        result ~= _temp;
                    }
                }
            }

        }
    }
    return result;
}
char[][] getSet_insert_remove(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<=str.length; i++) {
        for(int j=0; j<set.length; j++) {
            char[] temp = str[0..i] ~ set[j] ~ str[i..$];
            for(int k=0; k<temp.length; k++) {
                if (k==i) continue;
                char[] _temp = temp[0..k] ~ temp[k+1..$];
                bool[] flg = new bool[_temp.length];
                foreach(int m; 0..n) {
                    rabinKarp(_temp, pieces[m], flg);
                }
                if (flg.filter!(a=>a).array.length == flg.length) {
                    result ~= _temp;
                }
            }
        }
    }
    return result;
}
char[][] getSet_replace_remove(char[] str, char[][] pieces) {
    char[][] result;
    for(int i=0; i<str.length; i++) {
        for(int j=0; j<set.length; j++) {
            if (str[i] == set[j]) continue;
            char[] temp = str[0..i] ~ set[j] ~ str[i+1..$];
            for(int k=0; k<temp.length; k++) {
                if (k==i) continue;
                char[] _temp = temp[0..k] ~ temp[k+1..$];
                bool[] flg = new bool[_temp.length];
                foreach(int m; 0..n) {
                    rabinKarp(_temp, pieces[m], flg);
                }
                if (flg.filter!(a=>a).array.length == flg.length) {
                    result ~= _temp;
                }
            }
        }
    }
    return result;
}
void rabinKarp(char[] target, char[] pattern, bool[] flg) {
    int leng = pattern.length.to!int;
    long ph = 0, th = 0;
    for(int i=0; i<leng; i++) {
        ph += pattern[i]*prime^^(leng-1-i);
        th += target[i]*prime^^(leng-1-i);
    }
    for(int i=0; i<target.length-leng+1; i++) {
        if (ph==th) flg[i..i+leng] = true;
        if (i<target.length-leng) th = th*prime+target[i+leng]-target[i]*prime^^leng;
    }
}
