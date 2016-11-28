// RMQ (Range Minimum Query)
alias RMQ(T) = SegTree!(T, (a, b) => a<b ? a:b, T.max);

// SegTree (Segment Tree)
struct SegTree(T, alias pred, T initValue)
    if (is(typeof(pred(T.init, T.init)) : T)) {

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
    void update(size_t i, T x) {
        i += _size-1;
        _data[i] = x;
        while(i>0) {
            i = (i-1)/2;
            _data[i] = pred(_data[i*2+1], _data[i*2+2]);
        }
    }

    // 配列で指定
    void update(T[] ary) {
        foreach(size_t i, e; ary) {
            size_t _i = i+_size-1;
            _data[_i] = e;
        }
        foreach(i; 0.._size-1) {
            size_t _i = _size-i-2;
            _data[_i] = pred(_data[_i*2+1], _data[_i*2+2]);
        }
    }

    // 区間[a, b)でのクエリ
    T query(size_t a, size_t b) {
        return _query(a, b, 0, 0, _size);
    }
    T _query(size_t a, size_t b, size_t k, size_t l, size_t r) {
        if (b<=l || r<=a) return initValue;
        if (a<=l && r<=b) return _data[k];
        T vl = _query(a, b, k*2+1, l, (l+r)/2);
        T vr = _query(a, b, k*2+2, (l+r)/2, r);
        return pred(vl, vr);
    }

    T[] array() {
        return _data[_l+_size-1.._r+_size-1];
    }
}
