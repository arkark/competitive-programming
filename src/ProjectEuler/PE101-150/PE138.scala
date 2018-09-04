// keywords:
//     原始ピタゴラス数
//     ペル方程式
// 原始ピタゴラス数の生成から m^2-n^2-4mn = +-1 が得られる
// (m-2n)^2-5n^2 = +-1
// よって x^2-5y^2 = +-1 のペル方程式が得られる
// 最小解 (x, y) = (2, 1)
// [[x], [y]] = [[2, 5], [1, 2]] ^^ n * [[1], [0]]

println(solve(12))
def solve(N: Int): Long = {
    def func(_x: Long, _y: Long, depth: Int = 1): Long = {
        val x = 2*_x + 5*_y
        val y = 1*_x + 2*_y
        val L = (x+2*y)*(x+2*y) + y*y
        L + (if (depth<N) func(x, y, depth+1) else 0)
    }
    func(1, 0)
}
