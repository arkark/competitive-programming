// /*
//   MP法
//   @return:
//     out[0] == -1
//     out[i] == max { ys.length | ys is a prefix of xs[0..i] and a suffix of xs[0..i] }
//   計算量
//     - 全体: O(n)
//     - 各ステップ: 最悪 O(n)
//  */
// long[] solveMp(T)(T[] xs) {
//   long n = xs.length;
//   long[] mp = new long[n+1];
//   long j = -1;
//   mp[0] = j;
//   foreach(i; 0..n) {
//     while(j >= 0 && xs[i] != xs[j]) {
//       j = mp[j];
//     }
//     mp[i+1] = ++j;
//   }
//   return mp;
// }

/*
  KMP法
  @return:
    out[0] == -1
    out[i] == max { ys.length | ys is a prefix of xs[0..i] and a suffix of xs[0..i] }
  計算量
    - 全体: O(n)
    - 各ステップ: 最悪 O(log n)
 */
long[] solveKmp(T)(T[] xs) {
  long n = xs.length;
  long[] kmp = new long[n+1];
  long[] mp = new long[n+1];
  long j = -1;
  kmp[0] = mp[0] = j;
  foreach(i; 0..n) {
    while(j >= 0 && xs[i] != xs[j]) {
      j = kmp[j];
    }
    kmp[i+1] = mp[i+1] = ++j;
    if (i+1 < n && xs[i+1] == xs[j]) {
      kmp[i+1] = kmp[j];
    }
  }
  return mp;
}

/*
  textからpatternに一致する開始インデックスを列挙する
  - O(n + m)
 */
long[] searchPattern(T)(T[] text, T[] pattern) {
  long n = text.length;
  long m = pattern.length;
  assert(m <= n);
  long[] indices = [];
  long[] kmp = solveKmp!T(pattern);
  long i = 0; // index for `text`
  long j = 0; // index for `pattern`
  while(i < n) {
    while(j >= 0 && text[i] != pattern[j]) {
      j = kmp[j];
    }
    j++;
    i++;
    if (j == m) {
      assert(i >= m);
      indices ~= i-m;
      j = kmp[j-1];
      i--;
    }
  }
  return indices;
}
