import std.stdio;

void main() {
    int N = 10^^8;

    // Sieve of Eratosthenes
    bool[] is_prime = new bool[N/2+1];
	int[] primes;
	for (int i=2; i<is_prime.length; i++) {
		is_prime[i] = true;
	}
	for (int i=2; i*i<=is_prime.length; i++) {
		if (is_prime[i]) {
			for (int j=i*i; j<is_prime.length; j+=i) {
				is_prime[j] = false;
			}
		}
	}
	for (int i=0; i<is_prime.length; i++) {
		if (is_prime[i]) {
			primes ~= i;
		}
	}

    int[] primeCount = new int[N/2+1];
    for(int i=0, c=0; i<primeCount.length; i++) {
        if (is_prime[i]) c++;
        primeCount[i] = c;
    }

    ulong result = 0;
    foreach(prime; primes) {
        result += primeCount[N/prime < prime ? N/prime : prime];
    }
    result.writeln();
}
