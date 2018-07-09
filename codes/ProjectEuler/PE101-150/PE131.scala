println(solve(1000000))

// n^3 + n^2p = m^3
// nが立方数でなくてはならないので、k=n^(1/3)とおく
// 式変形&条件をうまく使うと、 p=3k^2+3k+1 が導かれる

def solve(limit: Int): Int = {
    val isPrimes = getIsPrimes(limit-1)

    (1L until limit).map(k => 3*k*k + 3*k + 1).map(p => {
        if (p<limit && isPrimes(p.toInt)) 1 else 0
    }).fold(0)(_+_)
}

// Sieve of Eratosthenes
def getIsPrimes(limit: Int): List[Boolean] = {
    val isPrimes = Array.fill(limit+1)(true)
    isPrimes(0) = false
    isPrimes(1) = false
    for (i <- 0 to limit) {
        if (isPrimes(i) && i.toLong*i<limit) {
            for (j <- Range(i*i, limit+1, i)) {
                isPrimes(j) = false
            }
        }
    }
    isPrimes.toList
}


// def getPrimes(limit: Int): List[Int] = {
//     def sieve(xs: List[Int]): List[Int] = xs match {
//         case x if (x.isEmpty) => Nil
//         case _ => xs.head :: sieve(xs.tail.filter(_%xs.head != 0))
//     }
//     sieve(List.range(2, limit+1))
// }
