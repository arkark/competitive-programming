// フィボナッチの性質を用いると A(x) = x/(1-x-x^2) となる
// 5n^2+2n+1 が平方数になる自然数nのうち小さいものから15番目のnが答え
// 5n^2+2n+1 = m^2 <=> (5n+1)^2-5m^2 = -4
// ペル方程式 http://mathematics-pdf.com/pdf/pells_equation.pdf
// 最小解(1, 1)

def solve(N: Int): Long = {
    def func(_x: Long, _y: Long, _count: Int = 0): Long = {
        val x = (1*_x + 5*_y)/2
        val y = (1*_x + 1*_y)/2
        val count = _count + (if(x%5==1) 1 else 0)
        if (count<N) func(x, y, count) else (x-1)/5
    }
    func(1, 1)
}
println(solve(15))
