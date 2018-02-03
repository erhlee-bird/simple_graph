# Create a directed graph of int nodes.
import sequtils
import simple_graph

let G: DirectedGraph[int] = DirectedGraph[int]()
G.initGraph()

for i in 1 .. 10:
  G.addNode(i)

doAssert(G.nodes().len() == 10)
doAssert(G.edges().len() == 0)

for u in 1 .. 10:
  for v in 1 .. 10:
    if v > 1 and u > v and u mod v == 0:
      G.addEdge(u, v)

doAssert(G.hasEdge(10, 5))
doAssert(not G.hasEdge(5, 10))
let edgeCount = G.edges().len()

# Test removals.
G.delNode(10)

doAssert(not G.hasNode(10))
doAssert(not G.hasEdge(10, 5))
doAssert(G.edges().len() == edgeCount - 2)
