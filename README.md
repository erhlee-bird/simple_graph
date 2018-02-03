Simple Graph
===
Quick and easy graph data structure library for Nim.

Examples
===
```nim
import simple_graph

var G: DirectedGraph[char] = DirectedGraph[char]()
G.initGraph()

G.addNode('a')
G.addNode('b')
G.addNode('c')

G.addEdge('a', 'b')

G.delNode('b')

for node in G.nodes():
  echo($node)
```
