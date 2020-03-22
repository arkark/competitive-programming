// Suffix Array (Manber & Myers algorithm)
//   O(n (log n)^2)
int[] getSuffixArray(T)(T[] xs) in {
  import std.algorithm : all;
  assert(xs.all!"a>=0");
} body {
  import std.conv : to;
  import std.algorithm : sort;
  import std.array : array;

  int n = xs.length.to!int;

  int[] suffixArray = new int[n+1];
  int[] ranks = new int[n+1];
  int[] temps = new int[n+1];

  foreach(i; 0..n+1) {
    suffixArray[i] = i;
    ranks[i] = i<n ? xs[i].to!int : -1;
  }

  int k;
  bool compare(int i, int j) {
    if (ranks[i] != ranks[j]) {
      return ranks[i] < ranks[j];
    } else {
      return (i+k<=n ? ranks[i+k] : -1) < (j+k<=n ? ranks[j+k] : -1);
    }
  }

  for(k=1; k<=n; k*=2) {
    suffixArray = suffixArray.sort!compare.array;
    temps[suffixArray[0]] = 0;
    foreach(i; 1..n+1) {
      temps[suffixArray[i]] = temps[suffixArray[i-1]] + (compare(suffixArray[i-1], suffixArray[i]) ? 1 : 0);
    }
    ranks[] = temps[];
  }

  return suffixArray;
}

// Longest Common Prefix Array (LCP Array)
//   O(n)
//   @required Suffix Array
int[] getLCPArray(T)(T[] xs, int[] suffixArray) {
  import std.conv : to;

  int n = xs.length.to!int;
  assert(n+1 == suffixArray.length);

  int[] ranks = new int[n+1];
  foreach(i; 0..n+1) ranks[suffixArray[i]] = i;

  int[] lcpArray = new int[n];
  int len = 0;
  lcpArray[0] = 0;
  foreach(i; 0..n) {
    int j = suffixArray[ranks[i] - 1];

    if (len > 0) len--;
    while(true) {
      if (i+len >= n) break;
      if (j+len >= n) break;
      if (xs[i+len] != xs[j+len]) break;
      len++;
    }

    lcpArray[ranks[i] - 1] = len;
  }

  return lcpArray;
}

@safe pure unittest {
  string xs = "abracadabra";
  int[] suffixArray = xs.getSuffixArray;
  int[] lcpArray = xs.getLCPArray(suffixArray);

  /*
   Suffix Array and LCP Array of "abracadabra":
    11: ""            - 0
    10: "a"           - 1
     7: "abra"        - 4
     0: "abracadabra" - 1
     3: "acadabra"    - 1
     5: "adabra"      - 0
     8: "bra"         - 3
     1: "bracadabra"  - 0
     4: "cadabra"     - 0
     6: "dabra"       - 0
     9: "ra"          - 2
     2: "racadabra"   - _
  */

  assert(suffixArray == [11, 10, 7, 0, 3, 5, 8, 1, 4, 6, 9, 2]);
  assert(lcpArray == [0, 1, 4, 1, 1, 0, 3, 0, 0, 0, 2]);
}
