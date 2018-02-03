import intsets, random, sequtils, tables

type
  Node = int
  Edge[T] = tuple[src, dst: T]

include simple_graph/private/graph_map
include simple_graph/private/graph_set

# Implementation for the base Graph type.
type Graph[T] = ref object of RootObj
  map: GraphMap[T]
  graph: GraphSet

method initGraph*[T](G: Graph[T]) {.base.} =
  G.map = newGraphMap[T]()
  G.graph = newGraphSet()

proc `[]`[T](G: Graph[T], A: T): Node {.raises: [KeyError].} =
  ## Handy alias for node-id lookup.
  result = G.map.keyToNode[A]

# Procedures dealing with Node manipulation.
method addNode*[T](G: Graph[T], A: T) {.base, raises: [KeyError].} =
  ## Add a new node to the graph.
  G.graph.addNode(G.map.register(A))

method delNode*[T](G: Graph[T], A: T) {.base, raises: [KeyError].} =
  ## Delete a node from the graph.
  G.graph.delNode(G.map.unregister(A))

method hasNode*[T](G: Graph[T], A: T): bool {.base.} =
  result = A in G.map.keyToNode

# XXX: Iterator here caused some issues with inheritance.
method nodes*[T](G: Graph[T]): seq[T] {.base.} =
  result = toSeq(G.map.keyToNode.keys)

# Procedures dealing with Edge manipulation.
method addEdge*[T](G: Graph[T], A: T, B: T) {.base, raises: [KeyError].} =
  ## Add a new edge to the graph.
  G.graph.addEdge(G[A], G[B])

method delEdge*[T](G: Graph[T], A: T, B: T) {.base, raises: [KeyError].} =
  ## Delete an edge from the graph.
  G.graph.delEdge(G[A], G[B])

method edges*[T](G: Graph[T], A: T, out_edges: bool = true): seq[Edge[T]]
    {.base.} =
  let collection =
    if out_edges:
      G.graph.outEdges[G[A]]
    else:
      G.graph.inEdges[G[A]]
  result = @[]
  for node in collection.items:
    result.add((A, G.map.nodeToKey[node]))

method edges*[T](G: Graph[T], out_edges: bool = true): seq[Edge[T]]
    {.base.} =
  result = @[]
  for node in G.nodes:
    for edge in G.edges(node, out_edges):
      result.add(edge)

method hasEdge*[T](G: Graph[T], A: T, B: T): bool {.base.} =
  ## This method checks for the presence of an edge in either direction to
  ## satisfy the properties of a directionless simple graph.
  if not G.hasNode(A) or not G.hasNode(B):
    return false
  result = G[B] in G.graph.outEdges[G[A]]

# Implementation for the SimpleGraph Type.
type SimpleGraph*[T] = ref object of Graph[T]

method hasEdge*[T](G: SimpleGraph[T], A: T, B: T): bool =
  ## SimpleGraph pays no heed to direction.
  result = (procCall(Graph[T](G).hasEdge(A, B)) or
            procCall(Graph[T](G).hasEdge(B, A)))

# Implementation for the DiGraph Type
type DirectedGraph*[T] = ref object of Graph[T]
