import std.stdio;

void main() {
    // phi[10^^8] == 4*10^^7 であることを求める．
    /*int N = 10^^8;
    int[] phi = new int[N+1];

    // Sieve of Eratosthenes
    bool[] is_prime = new bool[N+1];
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
	foreach(int i; 1..N+1) {
		if (i==1) {
			phi[i] = 1;
		} else if (is_prime[i]) {
			phi[i] = i-1;
		} else {
			foreach(int j; 0..primes.length) {
				if (i%primes[j]==0) {
					if (i/primes[j]%primes[j]==0) {
						phi[i] = phi[i/primes[j]]*primes[j];
					} else {
						phi[i] = phi[i/primes[j]]*(primes[j]-1);
					}
					break;
				}
			}
		}
	}
    writeln(phi[N]);*/

    // オイラーの定理 (トーティエント関数があるやつ)を用いる
    // 1777^^(phi[10^^8]) % (10^^8) == 1
    // phi[10^^8] == 4*10^^7 であることを求める
    // 1777^^(10^^7) % (10^^8) == 1
    // よって1777^^(10^^8) % (10^^8) == 1 だとわかる
    ulong a = 1777;
    int b = 1855;
    ulong result = 1;
    foreach(int i; 0..b) {
        result = modPow(a, result, 10^^8);
    }
    result.writeln();
}
ulong modPow(ulong b, ulong e, ulong m)  {
    ulong r = 1;
    for (; e > 0; e >>= 1) {
        if (e & 1) {
            r = (r * b) % m;
        }
        b = (b * b) % m;
    }
    return r;
}
