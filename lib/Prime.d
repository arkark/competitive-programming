// sieve of Eratosthenes

bool[] getIsPrimes(long limit) @safe pure {
  bool[] isPrimes = new bool[limit+1];
  isPrimes[2..$] = true;
  for (long i=2; i*i<=isPrimes.length; i++) {
    if (isPrimes[i]) {
      for (long j=i*i; j<isPrimes.length; j+=i) {
        isPrimes[j] = false;
      }
    }
  }
  return isPrimes;
}

long[] getPrimes(long limit) @safe pure {
  bool[] isPrimes = new bool[limit+1];
  isPrimes[2..$] = true;
  for (long i=2; i*i<=isPrimes.length; i++) {
    if (isPrimes[i]) {
      for (long j=i*i; j<isPrimes.length; j+=i) {
        isPrimes[j] = false;
      }
    }
  }
  long[] primes = [];
  foreach (long i, flg; isPrimes) {
    if (flg) primes ~= i;
  }
  return primes;
}

@safe pure unittest {
  long n = 12;
  assert(n.getIsPrimes == [
    false, // 0
    false, // 1
    true, // 2
    true, // 3
    false, // 4
    true, // 5
    false, // 6
    true, // 7
    false, // 8
    false, // 9
    false, // 10
    true, // 11
    false, // 12
  ]);
  assert(n.getPrimes == [
    2, 3, 5, 7, 11
  ]);
}
