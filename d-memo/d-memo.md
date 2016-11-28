いつかちゃんと書く

# D言語メモ
## std
### std.algorithm

#### searching

- **find**
- **canFind**

```d
// ","があるかを探してあればそれ以降の文字列を返す
assert(find("hello, world", ',') == ", world");
// 含まれていない場合は空の配列を返す
assert(find([1, 2, 3, 5], 4) == []);
// 関数を用いて探すこともできる(2より大きい数を探す)
assert(find!("a > b")([1, 2, 3, 5], 2) == [3, 5]);
// 含むかどうかはcanFindを用いる
assert(canFind([1, 2, 4, 10], 4) == true);
// 100よりも大きい数字はあるか
assert(canFind!("a > b")([23, 124, 2], 100) == true);
```

#### comparison

- **isPermutation**

二つのrangeがアナグラムであるかどうかを返す
```d
assert(isPermutation([1, 2, 3], [3, 2, 1]));
assert(isPermutation([1.1, 2.3, 3.5], [2.3, 3.5, 1.1]));
assert(isPermutation("abc", "bca"));

assert(!isPermutation([1, 2], [3, 4]));
assert(!isPermutation([1, 1, 2, 3], [1, 2, 2, 3]));
assert(!isPermutation([1, 1], [1, 1, 1]));

// Faster, but allocates GC handled memory
assert(isPermutation!(AllocateGC.yes)([1.1, 2.3, 3.5], [2.3, 3.5, 1.1]));
assert(!isPermutation!(AllocateGC.yes)([1, 2], [3, 4]));
```

- **equal**

```d
int[] a = [ 1, 2, 4, 3 ];
assert(!equal(a, a[1..$]));
assert(equal(a, a));

異なる型との同値比較ができる
double[] b = [ 1.0, 2, 4, 3];
assert(!equal(a, b[1..$]));
assert(equal(a, b));
```

#### iteration

- **map**

```d
string[] strs = readln.split;
// 各要素をint型に変換
// mapの返り値は配列ではないのでstd.array.arrayを用いて配列に変換
int[] data = array(map!(to!int)(str)); // str.to!(int[]) と同じ効果
// ラムダ式を用いることもできる (各要素をint型に変換した後，1を引く)
int[] data = array(map!(a => a.to!int-1)(str));
// 文字列を用いても可
int[] data = array(map!("a.to!int-1")(str));
```

- **reduce**

```d

```

- **filter**

rangeの要素のうち，ある条件を満たすものだけからなるrangeを返す

```d

```

- **uniq**

rangeの隣り合う重複した要素を一つにまとめたrangeを返す

sortしてから使うと重複した要素が完全になくなる

```d

```

- **permutations**

全ての順列をrangeにして返す
```d
assert(equal!equal(iota(3).permutations,
    [[0, 1, 2],
     [1, 0, 2],
     [2, 0, 1],
     [0, 2, 1],
     [1, 2, 0],
     [2, 1, 0]]));
```

#### sorting

- **multiSort**

複数条件ソート(例では二つの条件でソートしているが条件の数は可変)
```d
static struct Point { int x, y; }
auto pts1 = [Point(0, 0), Point(5, 5), Point(0, 1), Point(3, 0)];
auto pts2 = [Point(0, 0), Point(0, 1), Point(3, 0), Point(5, 5)];
multiSort!("a.x < b.x", "a.y < b.y", SwapStrategy.unstable)(pts1);
assert(pts1 == pts2);
```

- **nextPermutation**

全ての順列についてループを回したい時などに使う
```d
// Enumerate all permutations
int[] a = [1,2,3,4,5];
do {
    // use the current permutation and
    // proceed to the next permutation of the array.
} while (nextPermutation(a));
```

### std.array

- **split**

```d
// split は引数を指定しなかったら空白で区切って配列を作る(このとき末尾に改行文字があればそれを落とす)
assert(split("hello world") == ["hello","world"]);
// 区切る文字を指定した場合は，末尾の改行文字が落とされないことに注意
assert(split("192.168.0.1", ".") == ["192", "168", "0", "1"]);
// 配列をさらに区切ることもできる
auto a = split([1, 2, 3, 4, 5, 1, 2, 3, 4, 5], [2, 3]);
assert(a == [[1], [4, 5, 1], [4, 5]]);
```

### std.container

- **dlist** 双方向連結リスト(Doubly linked list)

- **slist** 片方向連結リスト(Singly linked list)

- **binaryheap** 二分ヒープ(Binary heap)

- **rbtree** 赤黒木(Red–black tree)

### std.functional

- **memoize**

任意の関数をメモ化できる
```d
int factorial(int n) {
    return n==0 ? 1:n*func(n-1);
}
alias memoize!factorial fact; // メモ化
void main() {
    fact(5).writeln(); // 5の階乗
}
```

### std.range

- **iota**

```d
// 0..3のrangeを返す
iota(3).writeln; // => [0, 1, 2]
// 2..5のrangeを返す
iota(2, 5).writeln; // => [2, 3, 4]
// 0..10のうち0から2stepおきのrangeを返す
iota(0, 10, 2).writeln; // => [0, 2, 4, 6, 8]
// n!を求める
int n = 5;
n.iota.map!(a => a+1).reduce!((a, b) => a*b).writeln; // => 120
```

- **zip**

複数の配列を一つにまとめる．
pairとしてソートしたい時などに便利．

```d
int[] ary = [1, 2, 3];
string[] strs = ["a", "b", "c"];
// 二つの配列をタプルにまとめる
auto tuples = zip(ary, strs);
assert(tuples[0] == Tuple!(int, string)(ary[0], strs[0]));
// 元の二つの配列をpairとしてソートできる
sort!((a, b) => a[0]>b[0])(tuples);
assert(ary == [3, 2, 1]);
assert(strs == ["c", "b", "a"]);
```

- **assumeSorted**

SortedRangeを返す．すでにソートされているrangeに対し二分探索するときに使う．
注: ソートしてくれる関数ではない．ソートにはstd.algorithm.sortを使う．

- **lowerBound**

```d
auto a = assumeSorted([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]);
auto p = a.lowerBound(4);
assert(equal(p, [0, 1, 2, 3]));
```

- **upperBound**

```d
auto a = assumeSorted([ 1, 2, 3, 3, 3, 4, 4, 5, 6 ]);
auto p = a.upperBound(3);
assert(equal(p, [4, 4, 5, 6]));
```

- **equalRange**

```d
auto a = [1, 2, 3, 3, 3, 4, 4, 5, 6];
// assumeSorted を使わなくても良いが使うことが推奨されている
auto r = a.assumeSorted.equalRange(3);
assert(equal(r, [3, 3, 3]));
```

### std.string

- **chomp**

文字列の末尾に改行文字があればそれを落とす．

- **tr** - translate characters

(注: 正規表現は使えない)
```d
string str = readln.chomp;
// 母音を取り除く
str.tr("aiueo", "", "d").writeln();
// a→A,b→B,c→C,d→D,e→E に置換
str.tr("aiueo", "AIUEO", "d").writeln();
// a,i,u,e,o 以外を全て T に置換
str.tr("aiueo", "T", "c").writeln();
// a*→A,b*→B,c*→C,d*→D,e*→E に置換
str.tr("aiueo", "AIUEO", "s").writeln();
```
