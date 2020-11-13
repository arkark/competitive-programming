
# A Repository for Competitive Programming

[![Build Status](https://travis-ci.com/arkark/competitive-programming.svg?branch=master)](https://travis-ci.com/arkark/competitive-programming)
![Lines of code](https://tokei.rs/b1/github/arkark/competitive-programming?category=code)

競プロ用リポジトリ

- lib: ライブラリ
- src: ソースコード置き場
  - [AtCoder](src/AtCoder): https://atcoder.jp/
  - [ProjectEuler](src/ProjectEuler): https://projecteuler.net/
  - [AOJ](src/AOJ): http://judge.u-aizu.ac.jp/onlinejudge/
  - [HALLab-ProCon](src/HALLab-ProCon): https://www.hallab.co.jp/progcon/
  - others
- template.d: テンプレート

## Prepare for a contest

```terminal
$ ./compro.sh a b c d e f
Input a contest URL: https://atcoder.jp/contests/agc001
Created:
workspace/b.d
workspace/c.d
workspace/.config.toml
workspace/d.d
workspace/a.d
workspace/e.d
workspace/f.d
$ cd workspace
$ atcoder-auto-tester
```
