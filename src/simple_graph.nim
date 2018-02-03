import intsets, random, tables

type
  Node = int
  Edge[T] = tuple[src, dst: T]

include simple_graph/private/graph_map
include simple_graph/private/graph_set

type Graph*[T] = ref object of RootObj
  map: GraphMap[T]
  graph: GraphSet

proc newGraph*[T](): Graph[T] =
  result.new()
  result.map = newGraphMap[T]()
  result.graph = newGraphSet()

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

iterator nodes*[T](G: Graph[T]): T =
  for key in G.map.keyToNode.keys:
    yield key

# Procedures dealing with Edge manipulation.
method addEdge*[T](G: Graph[T], A: T, B: T) {.base, raises: [KeyError].} =
  ## Add a new edge to the graph.
  G.graph.addEdge(G[A], G[B])

method delEdge*[T](G: Graph[T], A: T, B: T) {.base, raises: [KeyError].} =
  ## Delete an edge from the graph.
  G.graph.delEdge(G[A], G[B])

iterator edges*[T](G: Graph[T], A: T, out_edges: bool = true): Edge[T]
    {.raises: [KeyError].} =
  let collection =
    if out_edges:
      G.graph.outEdges[G[A]]
    else:
      G.graph.inEdges[G[A]]
  for node in collection.items:
    yield (A, G.map.nodeToKey[node])

iterator edges*[T](G: Graph[T], out_edges: bool = true): Edge[T]
    {.raises: [KeyError].} =
  for node in G.nodes():
    for edge in G.edges(node, out_edges):
      yield edge

method hasEdge*[T](G: Graph[T], A: T, B: T): bool {.base.} =
  if not G.hasNode(A) or not G.hasNode(B):
    return false
  result = G[B] in G.graph.outEdges[G[A]]
