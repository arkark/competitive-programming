// Deque - implemented in dynamic arrays

struct Deque(T) {
    import std.range, std.algorithm, std.conv, std.format;

private:
    T[] frontData = [];
    T[] backData = [];

    // [frontIndex, backIndex)
    int frontIndex = 0;
    int backIndex = 0;

public:

    this(T[] data) {
        this([], data, 0, cast(int)data.length, false);
    }

    bool empty() @property {
        return frontIndex == backIndex;
    }

    size_t length() @property {
        return cast(size_t) (backIndex - frontIndex);
    }

    void clear() {
        frontIndex = backIndex = 0;
        frontData = [];
        backData = [];
    }

    ref T front() @property in {
        assert(!empty, "Attempting to get the front of an empty Deque");
    } body {
        return this[0];
    }

    ref T front(T value) @property in {
        assert(!empty, "Attempting to assign to the front of an empty Deque");
    } body {
        return this[0] = value;
    }

    ref T back() @property in {
        assert(!empty, "Attempting to get the back of an empty Deque");
    } body {
        return this[$-1];
    }

    ref T back(T value) @property in {
        assert(!empty, "Attempting to assign to the back of an empty Deque");
    } body {
        return this[$-1] = value;
    }

    void insertFront(T value) {
        if (frontIndex>0) {
            backData[frontIndex - 1] = value;
        } else {
            frontData ~= value;
        }
        frontIndex--;
    }

    void insertBack(T value) {
        if (backIndex < 0) {
            frontData[-backIndex - 1] = value;
        } else {
            backData ~= value;
        }
        backIndex++;
    }

    void removeFront() in {
        assert(!empty, "Attempting to remove the front of an empty Deque");
    } body {
        if (frontIndex >= 0) {
            // do nothing
        } else {
            frontData = frontData[0..$-1];
        }
        frontIndex++;
    }
    alias popFront = removeFront;

    void removeBack() in {
        assert(!empty, "Attempting to remove the back of an empty Deque");
    } body {
        if (backIndex <= 0) {
            // do nothing
        } else {
            backData = backData[0..$-1];
        }
        backIndex--;
    }
    alias popBack = removeBack;

    typeof(this) save() @property {
        return typeof(this)(frontData, backData, frontIndex, backIndex, true);
    }

    void reserveFront(int num) {
        frontData.reserve(num);
    }

    void reserveBack(int num) {
        backData.reserve(num);
    }

    // xs ~= value
    typeof(this) opOpAssign(string op)(T value) if (op == "~") {
        this.insertBack(value);
        return this;
    }

    // xs[index]
    ref T opIndex(size_t index) in {
        assert(0<=index && index<length, "Access violation");
    } body {
        int _index = frontIndex + (cast(int)index);
        return _index>=0 ? backData[_index] : frontData[-_index - 1];
    }

    // xs[indices[0] .. indices[1]]
    typeof(this) opIndex(size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        return typeof(this)(frontData, backData, frontIndex + cast(int)indices[0], frontIndex + cast(int)indices[1], false);
    }

    // xs[]
    typeof(this) opIndex() {
        return this;
    }

    // xs[index] = value
    ref T opIndexAssign(T value, size_t index) in {
        assert(0<=index && index<length, "Access violation");
    } body {
        int _index = (cast(int)index) - frontIndex;
        return (_index>=0 ? backData[_index] : frontData[-_index - 1]) = value;
    }

    // xs[indices[0] .. indices[1]] = value
    typeof(this) opIndexAssign(T value, size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        int _frontIndex = frontIndex + (cast(int) indices[0]);
        int _backIndex = frontIndex + (cast(int) indices[1]);
        frontData[clamp(-_backIndex, 0, $)..clamp(-_frontIndex, 0, $)] = value;
        backData[clamp(_frontIndex, 0, $)..clamp(_backIndex, 0, $)] = value;
        return this;
    }

    // xs[] = value
    typeof(this) opIndexAssign(T value) {
        backData[] = value;
        frontData[] = value;
        return this;
    }

    // xs[indices[0] .. indices[1]] op= value
    typeof(this) opIndexOpAssign(string op)(T value, size_t[2] indices) in {
        assert(0<=indices[0] && indices[1]<=length, "Access violation");
    } body {
        int _frontIndex = frontIndex + (cast(int) indices[0]);
        int _backIndex = frontIndex + (cast(int) indices[1]);
        mixin(
            "frontData[clamp(-_backIndex, 0, $)..clamp(-_frontIndex, 0, $)] %s= value;".format(op)
        );
        mixin(
            "backData[clamp(_frontIndex, 0, $)..clamp(_backIndex, 0, $)] %s= value;".format(op)
        );
        return this;
    }

    // xs[] op= value
    typeof(this) opIndexOpAssign(string op)(T value) {
        mixin(
            "frontData[] %s= value;".format(op)
        );
        mixin(
            "backData[] %s= value;".format(op)
        );
        return this;
    }

    // $
    size_t opDollar(size_t dim: 0)() {
        return length;
    }

    // i..j
    size_t[2] opSlice(size_t dim: 0)(size_t i, size_t j) in {
        assert(0<=i && j<=length, "Access violation");
    } body {
        return [i, j];
    }

    bool opEquals(S: T)(Deque!S that) {
        if (this.length != that.length) return false;
        foreach(i; 0..this.length) {
            if (this[i] != that[i]) return false;
        }
        return true;
    }

    bool opEquals(S: T)(S[] that) {
        if (this.length != that.length) return false;
        foreach(i; 0..this.length) {
            if (this[i] != that[i]) return false;
        }
        return true;
    }

    string toString() const {
        auto xs = frontData[clamp(-backIndex, 0, $)..clamp(-frontIndex, 0, $)];
        auto ys = backData[clamp(frontIndex, 0, $)..clamp(backIndex, 0, $)];
        return "Deque(%s)".format(xs.retro.array ~ ys);
    }

private:
    this(T[] frontData, T[] backData, int frontIndex, int backIndex, bool duplicated) {
        this.frontData = duplicated ? frontData.dup : frontData[0..clamp(-frontIndex, 0, $)];
        this.backData = duplicated ? backData.dup : backData[0..clamp(backIndex, 0, $)];
        this.frontIndex = frontIndex;
        this.backIndex = backIndex;
    }

    invariant {
        assert(-frontIndex <= cast(int)frontData.length);
        assert(frontIndex <= backIndex);
        assert(backIndex <= cast(int)backData.length);
    }
}

@safe pure unittest {
    // Deque should be Range
    import std.range;
    assert(isInputRange!(Deque!long));
    assert(isOutputRange!(Deque!long, int));
    assert(isOutputRange!(Deque!long, long));
    assert(isForwardRange!(Deque!long));
    assert(isBidirectionalRange!(Deque!long));
    assert(isRandomAccessRange!(Deque!long));
}

@safe pure unittest {
    // test basic operations

    Deque!long xs = [1, 2, 3]; // == Deque!long([1, 2, 3])
    assert(xs.length == 3);
    assert(xs.front == 1 && xs.back == 3);
    assert(xs[0] == 1 && xs[1] == 2 && xs[2] == 3);
    assert(xs == [1, 2, 3]);

    size_t i = 0;
    foreach(x; xs) {
        assert(x == ++i);
    }

    xs.front = 4;
    xs[1] = 5;
    xs.back = 6;
    assert(xs == [4, 5, 6]);

    xs.removeBack;
    xs.removeBack;
    assert(xs == [4]);
    xs.insertFront(3);
    xs.insertFront(2);
    xs.insertFront(1);
    assert(xs == [1, 2, 3, 4]);
    xs.insertBack(5);
    xs ~= 6;
    assert(xs == [1, 2, 3, 4, 5, 6]);
    xs.removeFront;
    assert(xs == [2, 3, 4, 5, 6]);

    xs.clear;
    assert(xs.empty);
    xs.insertBack(1);
    assert(!xs.empty);
    assert(xs == [1]);
    xs[0]++;
    assert(xs == [2]);
}

@safe pure unittest {
    // test slicing operations

    Deque!long xs = [1, 2, 3];
    assert(xs[] == [1, 2, 3]);
    assert((xs[0..2] = 0) == [0, 0, 3]);
    assert((xs[0..2] += 1) == [1, 1, 3]);
    assert((xs[] -= 2) == [-1, -1, 1]);

    Deque!long ys = xs[0..2];
    assert(ys == [-1, -1]);
    ys[0] = 5;
    assert(ys == [5, -1]);
    assert(xs == [5, -1, 1]);
}

@safe pure unittest {
    // test using phobos
    import std.algorithm, std.array;
    Deque!long xs = [10, 5, 8, 3];
    assert(xs.sort!"a<b".equal([3, 5, 8, 10]));
    Deque!long ys = xs.sort!"a<b".array;
    assert(ys == [3, 5, 8, 10]);
}

@safe pure unittest {
    // test different types of equality

    int[] xs = [1, 2, 3];
    Deque!int ys = [1, 2, 3];
    Deque!long zs = [1, 2, 3];
    assert(xs == ys);
    assert(xs == zs);
    assert(ys == zs);

    ys.removeFront;
    assert(ys != zs);
    ys.insertFront(1);
    assert(ys == zs);
}
