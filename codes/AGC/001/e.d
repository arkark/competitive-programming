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
void times(alias fun)(int n) {
    foreach(i; 0..n) fun();
}
auto rep(alias fun, T = typeof(fun()))(int n) {
    T[] res = new T[n];
    foreach(ref e; res) e = fun();
    return res;
}
// fold was added in D 2.071.0.
template fold(fun...) if (fun.length >= 1) {
    auto fold(R, S...)(R r, S seed) {
        static if (S.length < 2) {
            return reduce!fun(seed, r);
        } else {
            return reduce!fun(tuple(seed), r);
        }
    }
}

int MAX = 2000+1;
immutable long MOD = 10^^9+7;
alias ModLong = ModNum!(long, MOD);
void main() {
    int N = readln.chomp.to!int;
    int[] A = new int[N];
    int[] B = new int[N];
    N.iota.each!(i => readf("%d %d\n", &A[i], &B[i]));

    ModLong ans = ModLong(0);

    ModLong[][] dp = new ModLong[][](2*MAX+1, 2*MAX+1);
    int[][] flg = new int[][](2*MAX+1, 2*MAX+1);
    foreach(i; 0..N) {
        dp[MAX-A[i]][MAX-B[i]]++;
        flg[MAX+A[i]][MAX+B[i]]++;
    }
    foreach(i; 0..2*MAX) foreach(j; 0..2*MAX) {
        ans += dp[i][j]*flg[i][j];
        dp[i+1][j] += dp[i][j];
        dp[i][j+1] += dp[i][j];
    }

    ModLong[] fact = new ModLong[4*MAX+1];
    ModLong[] _fact = new ModLong[4*MAX+1];
    foreach(i, ref e; fact) {
        e = i==0 ? ModLong(1) : ModLong(i) * fact[i-1];
    }
    foreach(i; _fact.length.iota.retro) {
        _fact[i] = _fact.length-1 ? ModLong(1)/fact[i] : ModLong(i+1) * _fact[i+1];
    }
    ModLong comb(int n, int r) {
        return fact[n]*_fact[r]*_fact[n-r];
    }

    foreach(i; 0..N) {
        ans -= comb(2*(A[i]+B[i]), 2*A[i]);
    }

    (ans/2).writeln;
}

struct ModNum(T, T mod) if (__traits(isIntegral, T)) {
    T value;

    typeof(this) opBinary(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*") {
        mixin("return typeof(this)((this.value"~op~"that.value+mod)%mod);");
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "/") {
        return this*getReciprocal(that);
    }
    typeof(this) opBinary(string op)(T that) if (op=="+" || op=="-" || op=="*") {
        mixin("return typeof(this)((this.value"~op~"that+mod)%mod);");
    }
    typeof(this) opBinary(string op)(T that) if (op == "/") {
        return this*getReciprocal(typeof(this)(that));
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "^^") {
        return typeof(this)(modPow(this.value, that.value));
    }
    typeof(this) opBinary(string op, S)(S that) if (op == "^^" && __traits(isIntegral, S)) {
        return typeof(this)(modPow(this.value, that));
    }
    void opOpAssign(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*") {
        mixin("this.value = (this.value"~op~"that.value+mod)%mod;");
    }
    void opOpAssign(string op)(T that) if (op=="+" || op=="*") {
        mixin("this.value = (this.value"~op~"that)%mod;");
    }
    typeof(this) opUnary(string op)() if (op == "++") {
        mixin("value"~op~";");
        return this;
    }
    typeof(this) getReciprocal(typeof(this) x) in {
        assert(isPrime(mod));
    } body {
        return typeof(this)(modPow(x.value, mod-2));
    }
    T modPow(T base, T power)  {
        T result = 1;
        for (; power > 0; power >>= 1) {
            if (power & 1) {
                result = (result * base) % mod;
            }
            base = base^^2 % mod;
        }
        return result;
    }
    string toString() {
        import std.conv;
        return this.value.to!string;
    }
    invariant() {
        assert(this.value>=0);
        assert(this.value<mod);
    }
    bool isPrime(T n) {
        if (n<2) {
            return false;
        } else if (n==2) {
            return true;
        } else if (n%2==0) {
            return false;
        } else {
            for(T i=3; i*i<=n; i+=2) {
                if (n%i==0) return false;
            }
            return true;
        }
    }

    static typeof(this) zero() {
        return typeof(this)(0);
    }
    static typeof(this) one() {
        return typeof(this)(1);
    }
}
