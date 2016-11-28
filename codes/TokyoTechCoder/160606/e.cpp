#include<cstdio>
#include<iostream>
#include<algorithm>
#include<cstring>
#include<string>
#include<complex>
#include<vector>
#include<queue>
#include<stack>
#include<functional>

using namespace std;

#define FOR(i,a,b) for (int i=(a);i<(b);i++)
#define RFOR(i,a,b) for (int i=(b)-1;i>=(a);i--)
#define REP(i,n) for (int i=0;i<(n);i++)
#define RREP(i,n) for (int i=(n)-1;i>=0;i--)
#define ALL(a) (a).begin(),(a).end()
typedef long long ll;

const ll INF = 1ll<<60;

struct Edge {
    int end;
    ll cost;
};

struct Vertex {
    ll dist[3];
    bool used[3];
    vector<Edge> edges;
    Vertex() {
        REP(i, 3) {
            dist[i] = INF;
            used[i] = false;
        }
    }
};

struct Node {
    int index;
    int state; // 0, 1, 2
};

ll solve() {
    int N, M;
    scanf("%d%d", &N, &M);
    if (N==0 && M==0) return -1;

    Vertex vertices[N];
    REP(i, M) {
        int a, b; ll c;
        scanf("%d%d%lld", &a, &b, &c);
        a--; b--;
        vertices[a].edges.push_back((Edge){b, c});
        vertices[b].edges.push_back((Edge){a, c});
    }

    priority_queue<Node, vector<Node>, function<bool(Node&, Node&)>> queue([&](Node& a, Node& b){
        if (a.state==b.state) return vertices[a.index].dist[a.state] > vertices[b.index].dist[b.state];
        return a.state > b.state;
    });
    vertices[0].dist[0] = 0;
    queue.push((Node){0, 0});
    while(!queue.empty()) {
        Node n = queue.top(); queue.pop();
        if (vertices[n.index].used[n.state]) continue;
        vertices[n.index].used[n.state] = true;
        for(auto& edge: vertices[n.index].edges) {
            if (n.state==0 || n.state==2) {
                if (vertices[n.index].dist[n.state]+edge.cost < vertices[edge.end].dist[n.state]) {
                    vertices[edge.end].dist[n.state] = vertices[n.index].dist[n.state]+edge.cost;
                    queue.push((Node){edge.end, n.state});
                }
            }
            if (n.state==0 || n.state==1) {
                if (vertices[n.index].dist[n.state] < vertices[edge.end].dist[n.state+1]) {
                    vertices[edge.end].dist[n.state+1] = vertices[n.index].dist[n.state];
                    queue.push((Node){edge.end, n.state+1});
                }
            }
        }
    }
    return min(vertices[N-1].dist[0], vertices[N-1].dist[2]);
}

int main() {
    ll ans;
    while((ans=solve())>=0) {
        printf("%lld\n", ans);
    }
    return 0;
}
