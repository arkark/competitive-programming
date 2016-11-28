#include <bits/stdc++.h>
using namespace std;

#define FOR(i,a,b) for (int i=(a);i<(b);i++)
#define FORR(i,a,b) for (int i=(b)-1;i>=(a);i--)
#define REP(i,n) for (int i=0;i<(n);i++)
#define REPR(i,n) for (int i=(n)-1;i>=0;i--)
#define ALL(a) (a).begin(),(a).end()
typedef long long ll;

// UnionFindTree
struct DisjointSet {

private:
    struct Vertex {
        int parent;
        int rank;
    };
    int _size;
    vector<Vertex> _vertices;

public:
    void init(int size) {
        _size = size;
        _vertices.resize(_size);
        for(int i=0; i<_size; i++) {
            _vertices[i].parent = i;
            _vertices[i].rank = 0;
        }
    }

    void unite(int x, int y) {
        link(find(x), find(y));
    }

    void link(int x, int y) {
        if (x==y) return;
        if (_vertices[x].rank > _vertices[y].rank) {
            _vertices[y].parent = x;
        } else {
            _vertices[x].parent = y;
            if (_vertices[x].rank == _vertices[y].rank) {
                _vertices[y].rank++;
            }
        }
    }

    bool same(int x, int y) {
        return find(x) == find(y);
    }

    int find(int index) {
        if (_vertices[index].parent == index) {
            return index;
        } else {
            return _vertices[index].parent = find(_vertices[index].parent);
        }
    }
};

struct Edge {
    int start;
    int end;
    ll cost;
    int time;
    bool used;
};

int N, M;
int h[1000];
vector<Edge> edges;
DisjointSet ufSet;

bool span(int time) {
    for(auto& edge: edges) {
        if (edge.time>=time && !ufSet.same(edge.start, edge.end)) {
            ufSet.unite(edge.start, edge.end);
            edge.used = true;
        }
    }

    int t = -1;
    REP(i, N) {
        if (h[i]>=time && t==-1) t = i;
        if (h[i]>=time && !ufSet.same(i, t)) return false;
    }
    return true;
}

void refresh() {
    ufSet.init(N);
    for(auto& edge: edges) edge.used = false;
}

ll solve() {
    scanf("%d%d", &N, &M);
    if (N==0 && M==0) return -1;
    REP(i, N) scanf("%d", &h[i]);

    edges = vector<Edge>();
    REP(i, M) {
        int a, b; ll c;
        scanf("%d%d%lld", &a, &b, &c);
        a--; b--;
        edges.push_back((Edge){a, b, c, min(h[a], h[b])});
    }
    sort(ALL(edges), [](Edge& e1, Edge& e2) {return e1.cost<e2.cost;});

    int temp[1000];
    memcpy(temp, h, sizeof(h));
    sort(temp, temp+N);
    int _i=0;
    REP(i, N) {
        refresh();
        if (!span(temp[i])) break;
        _i++;
    }
    refresh();
    REPR(j, _i) span(temp[j]);

    return [](){
        ll ans = 0;
        for(auto& edge: edges) {
            if (edge.used) ans += edge.cost;
        }
        return ans;
    }();
}

int main() {
    ll ans;
    while((ans=solve())>=0) {
        printf("%d\n", ans);
    }
    return 0;
}
