struct ModNum(T, T mod) if (__traits(isIntegral, T)) {
    T value;
    typeof(this) opBinary(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*") {
        mixin("return typeof(this)((this.value"~op~"that.value+mod)%mod);");
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "/") {
        return this*getReciprocal(that);
    }
    typeof(this) opBinary(string op)(typeof(this) that) if (op == "^^") {
        return typeof(this)(modPow(this.value, that.value));
    }
    typeof(this) opBinary(string op, S)(S that) if (op == "^^" && __traits(isIntegral, S)) {
        return typeof(this)(modPow(this.value, that));
    }
    void opOpAssign(string op)(typeof(this) that) if (op=="+" || op=="-" || op=="*" || op=="/") {
        mixin("this = this" ~op~ "that;");
    }
    typeof(this) getReciprocal(typeof(this) x) in {
        debug {
            assert(isPrime(mod));
        }
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
