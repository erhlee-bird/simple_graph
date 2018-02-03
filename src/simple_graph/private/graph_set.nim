## Basic Graph Implementation.
## Component included by all Graph types.

type GraphSet = ref object
  nodes: IntSet
  outEdges: Table[Node, IntSet]
  inEdges: Table[Node, IntSet]

proc newGraphSet(): GraphSet =
  result.new()
  result.nodes = initIntSet()
  result.outEdges = initTable[Node, IntSet]()
  result.inEdges = initTable[Node, IntSet]()

# Procedures dealing with Edge manipulation.
proc addEdge(GS: GraphSet, src: Node, dst: Node) =
  GS.outEdges[src].incl(dst)
  GS.inEdges[dst].incl(src)

proc delEdge(GS: GraphSet, src: Node, dst: Node) =
  GS.outEdges[src].excl(dst)
  GS.inEdges[dst].excl(src)

# Procedures dealing with Node manipulation.
proc addNode(GS: GraphSet, n: Node) =
  ## Add the node-id to our graph.
  ## We are assured that the node-id is unique because of the GraphMap.
  GS.nodes.incl(n)
  GS.outEdges[n] = initIntSet()
  GS.inEdges[n] = initIntSet()

proc delNode(GS: GraphSet, n: Node) =
  ## Delete a node-id from the GraphSet.
  ## Delete all edges going to and from the provided node-id.
  for outEdge in GS.outEdges[n]:
    GS.delEdge(n, outEdge)
  for inEdge in GS.inEdges[n]:
    GS.delEdge(inEdge, n)
  GS.outEdges.del(n)
  GS.inEdges.del(n)
  GS.nodes.excl(n)
