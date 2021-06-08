// スライド最小値/最大値 O(n+k)
//   fun = "a<b" => ys[i] := argmin(xs[max(0, i+1-k)..min(n, i+1)])
//   fun = "a>b" => ys[i] := argmax(xs[max(0, i+1-k)..min(n, i+1)])
size_t[] slideMinimum(T, alias fun = "a<b")(T[] xs, size_t k)
if (is(typeof(binaryFun!fun(T.init, T.init)) == bool))
in {
  assert(k > 0);
}
do {
  size_t n = xs.length;
  size_t[] deq = new size_t[n];
  size_t l = 0, r = 0;
  size_t empty() {
    return l == r;
  }

  size_t front() {
    return deq[l];
  }

  size_t back() {
    return deq[r - 1];
  }

  void removeFront() {
    l++;
  }

  void removeBack() {
    r--;
  }

  void insertBack(size_t v) {
    deq[r++] = v;
  }

  size_t[] ys = new size_t[n + k - 1];
  foreach (i; 0 .. n + k - 1) {
    if (i < n) {
      while (!empty() && !binaryFun!fun(xs[back()], xs[i])) {
        removeBack();
      }
      insertBack(i);
    }
    ys[i] = front();
    if (front() + k == i + 1) {
      removeFront();
    }
  }
  assert(empty());
  return ys;
}

// // スライド最小値/最大値 O(n)
// //   fun = "a<b" => ys[i] := argmin(xs[max(0, i+1-k)..i+1])
// //   fun = "a>b" => ys[i] := argmax(xs[max(0, i+1-k)..i+1])
// size_t[] slideMinimum(T, alias fun = "a<b")(T[] xs, size_t k)
// if (is(typeof(binaryFun!fun(T.init, T.init)) == bool))
// in {
//   assert(k > 0);
// }
// do {
//   size_t n = xs.length;
//   size_t[] deq = new size_t[n];
//   size_t l = 0, r = 0;
//   size_t empty() {
//     return l == r;
//   }

//   size_t front() {
//     return deq[l];
//   }

//   size_t back() {
//     return deq[r - 1];
//   }

//   void removeFront() {
//     l++;
//   }

//   void removeBack() {
//     r--;
//   }

//   void insertBack(size_t v) {
//     deq[r++] = v;
//   }

//   size_t[] ys = new size_t[n];
//   foreach (i; 0 .. n) {
//     while (!empty() && !binaryFun!fun(xs[back()], xs[i])) {
//       removeBack();
//     }
//     insertBack(i);
//     ys[i] = front();
//     if (front() + k == i + 1) {
//       removeFront();
//     }
//   }
//   return ys;
// }
