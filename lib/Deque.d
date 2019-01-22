// Deque - implemented in dynamic arrays

struct Deque(T) {
  import std.range, std.algorithm, std.conv, std.format;

private:
  T[] frontData = [];
  T[] backData = [];
  size_t frontSize = 0;
  size_t backSize = 0;

  // [beginIndex, endIndex)
  ptrdiff_t beginIndex = 0;
  ptrdiff_t endIndex = 0;

public:

  this(T[] data) {
    this([], data, 0, data.length, 0, cast(ptrdiff_t)data.length, false);
  }

  bool empty() @property {
    return beginIndex == endIndex;
  }

  size_t length() @property {
    return cast(size_t) (endIndex - beginIndex);
  }

  void clear() {
    beginIndex = endIndex = 0;
    frontData = [];
    backData = [];
    frontSize = 0;
    backSize = 0;
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
    if (beginIndex>0) {
      backData[beginIndex - 1] = value;
    } else {
      if (frontSize >= frontData.length) {
        resizeFront();
      }
      frontData[frontSize++] = value;
    }
    beginIndex--;
  }

  void insertBack(T value) {
    if (endIndex < 0) {
      frontData[-endIndex - 1] = value;
    } else {
      if (backSize >= backData.length) {
        resizeBack();
      }
      backData[backSize++] = value;
    }
    endIndex++;
  }

  void removeFront() in {
    assert(!empty, "Attempting to remove the front of an empty Deque");
  } body {
    if (beginIndex >= 0) {
      // do nothing
    } else {
      assert(frontSize > 0);
      frontSize--;
    }
    beginIndex++;
  }
  alias popFront = removeFront;

  void removeBack() in {
    assert(!empty, "Attempting to remove the back of an empty Deque");
  } body {
    if (endIndex <= 0) {
      // do nothing
    } else {
      assert(backSize > 0);
      backSize--;
    }
    endIndex--;
  }
  alias popBack = removeBack;

  typeof(this) save() @property {
    return typeof(this)(frontData, backData, frontSize, backSize, beginIndex, endIndex, true);
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
    ptrdiff_t _index = beginIndex + (cast(ptrdiff_t)index);
    return _index>=0 ? backData[_index] : frontData[-_index - 1];
  }

  // xs[indices[0] .. indices[1]]
  typeof(this) opIndex(size_t[2] indices) in {
    assert(0<=indices[0] && indices[1]<=length, "Access violation");
  } body {
    ptrdiff_t newBeginIndex = beginIndex + cast(ptrdiff_t)indices[0];
    ptrdiff_t newEndIndex = beginIndex + cast(ptrdiff_t)indices[1];
    size_t newFrontSize = clamp(-newBeginIndex, 0, frontSize);
    size_t newBackSize = clamp(newEndIndex, 0, backSize);
    return typeof(this)(frontData, backData, newFrontSize, newBackSize, newBeginIndex, newEndIndex, false);
  }

  // xs[]
  typeof(this) opIndex() {
    return this;
  }

  // xs[index] = value
  ref T opIndexAssign(T value, size_t index) in {
    assert(0<=index && index<length, "Access violation");
  } body {
    ptrdiff_t _index = (cast(ptrdiff_t)index) - beginIndex;
    return (_index>=0 ? backData[_index] : frontData[-_index - 1]) = value;
  }

  // xs[indices[0] .. indices[1]] = value
  typeof(this) opIndexAssign(T value, size_t[2] indices) in {
    assert(0<=indices[0] && indices[1]<=length, "Access violation");
  } body {
    ptrdiff_t _beginIndex = beginIndex + (cast(ptrdiff_t) indices[0]);
    ptrdiff_t _endIndex = beginIndex + (cast(ptrdiff_t) indices[1]);
    frontData[clamp(-_endIndex, 0, frontSize)..clamp(-_beginIndex, 0, frontSize)] = value;
    backData[clamp(_beginIndex, 0, backSize)..clamp(_endIndex, 0, backSize)] = value;
    return this;
  }

  // xs[] = value
  typeof(this) opIndexAssign(T value) {
    backData[0..backSize] = value;
    frontData[0..frontSize] = value;
    return this;
  }

  // xs[indices[0] .. indices[1]] op= value
  typeof(this) opIndexOpAssign(string op)(T value, size_t[2] indices) in {
    assert(0<=indices[0] && indices[1]<=length, "Access violation");
  } body {
    ptrdiff_t _beginIndex = beginIndex + (cast(ptrdiff_t) indices[0]);
    ptrdiff_t _endIndex = beginIndex + (cast(ptrdiff_t) indices[1]);
    mixin(q{
      frontData[clamp(-_endIndex, 0, frontSize)..clamp(-_beginIndex, 0, frontSize)] %s= value;
    }.format(op));
    mixin(q{
      backData[clamp(_beginIndex, 0, backSize)..clamp(_endIndex, 0, backSize)] %s= value;
    }.format(op));
    return this;
  }

  // xs[] op= value
  typeof(this) opIndexOpAssign(string op)(T value) {
    mixin(q{
      frontData[0..frontSize] %s= value;
    }.format(op));
    mixin(q{
      backData[0..backSize] %s= value;
    }.format(op));
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
    auto xs = frontData[clamp(-endIndex, 0, frontSize)..clamp(-beginIndex, 0, frontSize)];
    auto ys = backData[clamp(beginIndex, 0, backSize)..clamp(endIndex, 0, backSize)];
    return "Deque(%s)".format(xs.retro.array ~ ys);
  }

private:
  this(T[] frontData, T[] backData, size_t frontSize, size_t backSize, ptrdiff_t beginIndex, ptrdiff_t endIndex, bool shouldDuplicate) {
    this.frontSize = frontSize;
    this.backSize = backSize;
    this.frontData = shouldDuplicate ? frontData.dup : frontData[0..clamp(-beginIndex, 0, $)];
    this.backData = shouldDuplicate ? backData.dup : backData[0..clamp(endIndex, 0, $)];
    this.beginIndex = beginIndex;
    this.endIndex = endIndex;
  }

  void resizeFront() {
    frontData.length = max(frontSize * 2, 1);
  }

  void resizeBack() {
    backData.length = max(backSize * 2, 1);
  }

  invariant {
    assert(frontSize <= frontData.length);
    assert(backSize <= backData.length);
    assert(max(0, -beginIndex) == cast(ptrdiff_t)frontSize);
    assert(beginIndex <= endIndex);
    assert(max(0, endIndex) == cast(ptrdiff_t)backSize);
  }
}

@safe pure unittest {
  // Deque should be Range
  import std.range;
  assert(isInputRange!(Deque!long));
  // assert(isOutputRange!(Deque!long, int));
  // assert(isOutputRange!(Deque!long, long));
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
  assert(sort!"a<b"(xs).equal([3, 5, 8, 10]));
  assert(xs == [3, 5, 8, 10]);
  Deque!long ys = sort!"a>b"(xs).array;
  assert(ys == [10, 8, 5, 3]);
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
