template Rerooting(
    // M は可換モノイドを仮定
    M, // DPの要素の型
    X, // 各頂点がもつ値の型
    alias fun, // DPの要素間の2項演算
    alias afterFun, // 頂点の値からDPの要素への作用
    M identity, // DPの要素の単位元
    bool ctfeCheckActive = true,
) {
  import std.algorithm : map;
  import std.array : array;
  import std.functional : binaryFun;

  static if (ctfeCheckActive) {
    static assert(is(typeof(binaryFun!fun(identity, identity)) : M));
    static assert(is(typeof(binaryFun!afterFun(identity, X.init)) : M));
    static assert(binaryFun!fun(identity, identity) == identity);
  }

  struct Rerooting {

  private:
    alias _fun = binaryFun!fun;
    alias _afterFun = binaryFun!afterFun;

    Vertex[] _vertices;

  public:
    // O(n)
    this(size_t n) {
      _vertices.length = n;
      foreach (i; 0 .. n) {
        _vertices[i] = new Vertex(X.init);
      }
    }

    // O(n)
    this(X[] values) {
      _vertices = values.map!(
          value => new Vertex(value)
      ).array;
    }

    size_t size() {
      return _vertices.length;
    }

    void addEdge(size_t x, size_t y) {
      _vertices[x].adj ~= _vertices[y];
      _vertices[y].adj ~= _vertices[x];
    }

    M[] solve(size_t rootIndex = 0)
    in {
      assert(rootIndex < size);
    }
    body {
      Vertex[] vs = getOrderedVertices(rootIndex);

      foreach_reverse (v; vs) {
        M acc = identity;
        foreach (u; v.adj) {
          if (u is v.parent)
            continue;
          acc = _fun(acc, u.dpValue);
        }
        acc = _afterFun(acc, v.value);
        v.dpValue = acc;
      }

      M[] accL = new M[size];
      M[] accR = new M[size];
      foreach (v; vs) {
        size_t len = v.adj.length;
        assert(len + 1 <= size);
        accL[0] = identity;
        accR[len] = identity;
        foreach (j, u; v.adj) {
          accL[j + 1] = _fun(
              accL[j],
              u is v.parent ? v.parentDpValue : u.dpValue
          );
        }
        foreach_reverse (j, u; v.adj) {
          accR[j] = _fun(
              u is v.parent ? v.parentDpValue : u.dpValue,
              accR[j + 1]
          );
        }
        assert(accL[len] == accR[0]);
        v.dpValue = _afterFun(accL[len], v.value);

        foreach (j, u; v.adj) {
          if (u is v.parent)
            continue;
          u.parentDpValue = _afterFun(
              _fun(accL[j], accR[j + 1]),
              v.value
          );
        }
      }

      return _vertices.map!"a.dpValue".array;
    }

  private:
    class Vertex {
      X value;
      M dpValue;
      Vertex[] adj;
      Vertex parent;
      M parentDpValue;
      this(X value) {
        this.value = value;
      }
    }

    Vertex[] getOrderedVertices(size_t rootIndex) {
      Vertex[] vs = new Vertex[size];
      size_t index = 0;

      auto stack = DList!Vertex(_vertices[rootIndex]);
      while (!stack.empty) {
        Vertex v = stack.back;
        stack.removeBack;
        vs[index++] = v;
        foreach (u; v.adj) {
          if (u is v.parent)
            continue;
          u.parent = v;
          stack.insertBack(u);
        }
      }
      assert(index == size);

      return vs;
    }
  }
}
