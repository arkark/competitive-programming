import std.stdio;
import std.conv;
import std.string;

// sieve of Eratosthenes

void main() {
    int n = readln().chomp().to!int();
    bool[] ary1 = n.getIsPrimes();
    ary1[10].writeln();
    int[] ary2 = n.getPrimes();
    ary2[10].writeln();
}

bool[] getIsPrimes(int limit) {
    bool[] isPrimes = new bool[limit+1];
    isPrimes[2..$] = true;
    for (int i=2; i*i<=isPrimes.length; i++) {
        if (isPrimes[i]) {
            for (int j=i*i; j<isPrimes.length; j+=i) {
                isPrimes[j] = false;
            }
        }
    }
    return isPrimes;
}

int[] getPrimes(int limit) {
    bool[] isPrimes = new bool[limit+1];
    isPrimes[2..$] = true;
    for (int i=2; i*i<=isPrimes.length; i++) {
        if (isPrimes[i]) {
            for (int j=i*i; j<isPrimes.length; j+=i) {
                isPrimes[j] = false;
            }
        }
    }
    int[] primes = [];
    foreach (int i, flg; isPrimes) {
        if (flg) primes ~= i;
    }
    return primes;
}
