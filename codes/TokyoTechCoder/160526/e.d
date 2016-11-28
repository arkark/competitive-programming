import std.stdio;
import std.string;
import std.conv;
import std.typecons;
import std.algorithm;
import std.functional;
import std.bigint;
import std.numeric;
import std.array;
import std.math;
import std.range;
import std.container;
import std.ascii;

int INF = 1<<25;
struct Pos{int y, x;}
int[] dx = [1, 0, -1,  0, 0];
int[] dy = [0, 1,  0, -1, 0];
void main() {
    while(true) {
        int H, W;
        readf("%d %d\n", &H, &W);
        if (H==0 && W==0) break;

        Pos player;
        Pos ghost;
        bool[][] grid = H.iota.map!(i => readln.chomp.enumerate.tee!((a) {
            if (a.value=='A') player = Pos(i.to!int, a.index.to!int);
            if (a.value=='B') ghost = Pos(i.to!int, a.index.to!int);
        }).map!(a => (a.value!='#')).array).array;

        int[][] dist = new int[][](H, W);
        foreach(ref e; dist) e[] = INF;
        auto list = DList!Pos(player);
        dist[player.y][player.x] = 0;
        while (!list.empty) {
            Pos p = list.front;
            list.removeFront;
            foreach(int i; 0..4) {
                int _y = p.y+dy[i];
                int _x = p.x+dx[i];
                if (0<=_y && _y<H && 0<=_x && _x<W) {
                    if (grid[_y][_x] && dist[_y][_x]==INF) {
                        list.insert(Pos(_y, _x));
                        dist[_y][_x] = dist[p.y][p.x]+1;
                    }
                }
            }
        }

        int[] pattern = readln.chomp.map!(c => c=='6'?0:c=='2'?1:c=='4'?2:c=='8'?3:4).array;
        bool flag = false;
        int[] ans;
        int time = 0;
        for(int _=0; _<1000; _++) {
            foreach(i; pattern) {
                if (dist[ghost.y][ghost.x] <= time) {
                    ans = [time, ghost.y, ghost.x];
                    flag = true;
                    break;
                }
                ghost = Pos(min(H-1, max(0, ghost.y+dy[i])), min(W-1, max(0, ghost.x+dx[i])));
                time++;
            }
        }
        writeln(flag ? ans.to!(string[]).join(" "):"impossible");
    }
}
