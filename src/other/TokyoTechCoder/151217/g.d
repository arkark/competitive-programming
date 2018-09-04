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

void main() {
    string INF = "|";
    string[] input;
    while(true) {
        input = readln.split;
        if (input == ["0", "0", "0", "0"]) break;

        int n = input[0].to!int;
        int a = input[1].to!int;
        int s = input[2].to!int;
        int g = input[3].to!int;

        string[] vertices = new string[n];
        vertices[] = INF;
        Edge[] edges = new Edge[a];
        foreach(int i; 0..a) {
            input = readln.split;
            int from = input[1].to!int;
            int to = input[0].to!int;
            string cost = input[2];
            if (from == to) {
                edges[i] = Edge(from, vertices.length.to!int, cost);
                edges ~= Edge(vertices.length.to!int, to, "");
                vertices ~= INF;
            } else {
                edges[i] = Edge(from, to, cost);
            }
        }

        vertices[g] = "";
        bool flg = false;
        for (int count=0; count<6*vertices.length; count++) {
            for (int i=0; i<edges.length; i++) {
                string value = edges[i].cost~vertices[edges[i].from];
                if (value < vertices[edges[i].to] && vertices[edges[i].from]!=INF) {
                    vertices[edges[i].to] = value;
                    if (count>=vertices.length-1 && edges[i].to==s) {
                        flg = true;
                    }
                }
            }
        }

        writeln(vertices[s] == INF || flg ? "NO":vertices[s]);
    }
}
struct Edge {
    int from, to;
    string cost;
    this(int from, int to, string cost) {
        this.from = from;
        this.to = to;
        this.cost = cost;
    }
}
