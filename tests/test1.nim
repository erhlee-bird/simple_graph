# Create a simple graph of character nodes.
import sequtils
import simple_graph

var G: SimpleGraph[char] = SimpleGraph[char]()
G.initGraph()

G.addNode('a')
G.addNode('b')
G.addNode('c')

doAssert(G.hasNode('a'))
doAssert(G.hasEdge('a', 'b') == false)
doAssert(G.nodes().len() == 3)
doAssert(G.edges().len() == 0)

G.addEdge('a', 'b')

doAssert(G.hasEdge('a', 'b') == true)
doAssert(G.nodes().len() == 3)
doAssert(G.edges().len() == 1)

# Ensure that the graph is properly simple.
doAssert(G.hasEdge('a', 'b') == true and G.hasEdge('b', 'a') == true)
