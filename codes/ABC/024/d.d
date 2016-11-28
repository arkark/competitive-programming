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
void times(void delegate() pred)(int n) {
    foreach(i; 0..n) pred();
}
T[] rep(T)(int n, T delegate() pred) {
    T[] res = new T[n];
    foreach(ref e; res) e = pred();
    return res;
}

immutable long MOD = 10^^9+7; // is prime
void main() {
    long A, B, C;
    readf("%d\n%d\n%d", &A, &B, &C);
    alias modLong = modNum!(long, MOD);
    modLong a, b, c;
    a = modLong(A);
    b = modLong(B);
    c = modLong(C);
    writeln((b*c-a*c)/(a*b+a*c-b*c), " ", (b*c-a*b)/(a*b+a*c-b*c));
}

struct modNum(T, T mod) if (__traits(isIntegral, T)) {
    T value;
    typeof(this) opBinary(string op)(typeof(this) rhs) if (op=="+" || op=="-" || op=="*") {
        mixin("return typeof(this)((this.value"~op~"rhs.value+mod)%mod);");
    }
    typeof(this) opBinary(string op)(typeof(this) rhs) if (op == "/") {
        return this*getReciprocal(rhs);
    }
    typeof(this) opBinary(string op)(typeof(this) rhs) if (op == "^^") {
        return typeof(this)(modPow(this.value, rhs.value));
    }
    typeof(this) opBinary(string op, S)(S rhs) if (op == "^^" && __traits(isIntegral, S)) {
        return typeof(this)(modPow(this.value, rhs));
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
}
