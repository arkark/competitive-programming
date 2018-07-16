import std.stdio;
import std.conv;
import std.string;

// sieve of Eratosthenes

void main() {
  long n = readln().chomp().to!long();
  bool[] ary1 = n.getIsPrimes();
  ary1[10].writeln();
  long[] ary2 = n.getPrimes();
  ary2[10].writeln();
}

bool[] getIsPrimes(long limit) {
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

long[] getPrimes(long limit) {
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
