// (gcd(a,b)=1 and a+b=c) => (gcd(a,c)=1 and gcd(b,d)=1 and rad(a)*rad(b)*rad(c)=rad(abc))

def solve(limit: Int): Long = {
    val radicals: Array[Long] = Array.fill(limit+1)(1)
    for (i <- 2 to limit) {
        if (radicals(i) == 1) {
            for (j <- Range(i, limit+1, i)) {
                radicals(j) *= i
            }
        }
    }

    // 枝刈りのためにソート
    val list = radicals.zipWithIndex.sortWith(_._1 < _._1).toList
    (1 to limit).map(c => {
        // takeWhileで枝刈り
        list.takeWhile(_._1*2*radicals(c) < c).map(x => {
            val a = x._2
            val b = c-a
            if (b>a && radicals(a)*radicals(b)*radicals(c)<c && gcd(a, b)==1) c else 0
        }).fold(0)(_+_)
    }).fold(0)(_+_)
}

def gcd(x: Long, y: Long): Long = if (y==0) x else gcd(y, x%y)

println(solve(120000))
