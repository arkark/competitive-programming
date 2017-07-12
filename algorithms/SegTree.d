// RMQ (Range Minimum Query)
alias RMQ(T) = SegTree!(T, (a, b) => a<b ? a:b, T.max);

// SegTree (Segment Tree)
struct SegTree(T, alias fun, T initValue)
    if (is(typeof(fun(T.init, T.init)) : T)) {

private:
    T[] _data;
    size_t _size;
    size_t _l, _r;

public:
    // size ... データ数
    // initValue ... 初期値(例えばRMQだとINF)
    this(size_t size) {
        init(size);
    }

    // 配列で指定
    this(T[] ary) {
        init(ary.length);
        update(ary);
    }

    // O(N)
    void init(size_t size){
        _size = 1;
        while(_size < size) {
            _size *= 2;
        }
        _data.length = _size*2-1;
        _data[] = initValue;
        _l = 0;
        _r = size;
    }

    // i番目の要素をxに変更
    // O(logN)
    void update(size_t i, T x) {
        i += _size-1;
        _data[i] = x;
        while(i>0) {
            i = (i-1)/2;
            _data[i] = fun(_data[i*2+1], _data[i*2+2]);
        }
    }

    // 配列で指定
    // O(N)
    void update(T[] ary) {
        foreach(size_t i, e; ary) {
            size_t _i = i+_size-1;
            _data[_i] = e;
        }
        foreach(i; 0.._size-1) {
            size_t _i = _size-i-2;
            _data[_i] = fun(_data[_i*2+1], _data[_i*2+2]);
        }
    }

    // 区間[a, b)でのクエリ
    // O(logN)
    T query(size_t a, size_t b) {
        T rec(size_t a, size_t b, size_t k, size_t l, size_t r) {
            if (b<=l || r<=a) return initValue;
            if (a<=l && r<=b) return _data[k];
            T vl = rec(a, b, k*2+1, l, (l+r)/2);
            T vr = rec(a, b, k*2+2, (l+r)/2, r);
            return fun(vl, vr);
        }
        return rec(a, b, 0, 0, _size);
    }

    // O(N)
    T[] array() {
        return _data[_l+_size-1.._r+_size-1];
    }
}
