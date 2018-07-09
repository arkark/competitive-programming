// フィボナッチの性質を用いると A(x) = (x+3x^2)/(1-x-x^2) となる
// 5n^2+14n+1 が平方数になる自然数nのうち小さいものから20番目のnが答え
// 5n^2+14n+1 = m^2 <=> (5n+7)^2-5m^2 = 44
// ペル方程式を用いる？

// def solve(N: Int): Long = {
//     def func(_x: Long, _y: Long, _count: Int = 0): Long = {
//         val x = (1*_x + 5*_y)/2
//         val y = (1*_x + 1*_y)/2
//         val count = _count + (if(x%5==1) 1 else 0)
//         if (count<N) func(x, y, count) else (x-1)/5
//     }
//     func(1, 1)
// }
// println(solve(15))
