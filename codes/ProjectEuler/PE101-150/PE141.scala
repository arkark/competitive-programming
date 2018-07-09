def solve(limit: Long): Long = {
    val primes =
    
}
println(solve(100000))

def isSquare(n: Long): Boolean = {
    val m = Math.sqrt(n).toLong
    m*m == n
}

def getPrimes(limit: Int): List[Int] = {
    def sieve(xs: List[Int]): List[Int] = xs match {
        case x if (x.isEmpty) => Nil
        case _ => xs.head :: sieve(xs.tail.filter(_%xs.head != 0))
    }
    sieve(List.range(2, limit+1))
}
