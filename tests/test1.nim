# Create a simple graph of character nodes.
import sequtils
import simple_graph

var G: Graph[char] = newGraph[char]()

G.addNode('a')
G.addNode('b')
G.addNode('c')

doAssert(G.hasNode('a'))
doAssert(G.hasEdge('a', 'b') == false)
doAssert(toSeq(G.nodes).len() == 3)
doAssert(toSeq(G.edges).len() == 0)

G.addEdge('a', 'b')

doAssert(G.hasEdge('a', 'b') == true)
doAssert(toSeq(G.nodes).len() == 3)
doAssert(toSeq(G.edges).len() == 1)

# Ensure that the graph is properly simple.
