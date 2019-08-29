import macros, options, sequtils, sugar

# An implementation of Inductive Graphs as defined by
# Erwig, Martin -- Inductive Graphs and Functional Graph Algorithms.

#[
Page 5, Section 3 "Inductive Graphs"

A graph is viewed as a pair G = (V, E) where V is a set of nodes
and E ⊆ V ⨯ V is a set of edges.

The description of algorithms that work incrementally on graphs, that is,
algorithms that visit nodes one after the other, then need an additional data
structure for remembering the parts of the graph that have already been dealt
with. Alternatively, the graph representation is defined to have additional
fields that allows for marking nodes and edges directly in the graph structure
itself.

...

Now what we are proposing is essentially to regard a graph as an inductive
data type. This makes graph algorithms amenable to inductive to inductive
function definitions with all their advantages.

Page 6, Section 3.1 "Graph Constructors"

A graph consists of a set of nodes that are connected by edges. For simplicity
we assume that nodes are represented as integers, and for generality we define
a single graph type for directed node- and edge-labeled multi-graphs.
]#

type
  Adj[B, N] = seq[tuple[l: B, v: N]]
  Context[A, B, N] = object
    p*: Adj[B, N]
    v*: N
    l*: A
    s*: Adj[B, N]

  GraphKind {.pure.} = enum Empty, Graph
  Graph[A, B, N] = object
    case kind: GraphKind
    of GraphKind.Empty:
      discard
    of GraphKind.Graph:
      context: Context[A, B, N]
      graph: ref Graph[A, B, N]

proc newEmptyGraph(A, B, N: typedesc): ref Graph[A, B, N] =
  result.new
  result[] = Graph[A, B, N](kind: GraphKind.Empty)

proc `&`*[A, B, N](a: ref Graph[A, B, N], b: Context[A, B, N]): ref Graph[A, B, N] =
  result.new
  result[] = Graph[A, B, N](
    kind: GraphKind.Graph,
    context: b,
    graph: a,
  )

proc `&`*[A, B, N](a: Context[A, B, N], b: ref Graph[A, B, N]): ref Graph[A, B, N] =
  b & a

template `^`*[A, B, N](a: Context[A, B, N], b: ref Graph[A, B, N]): ref Graph[A, B, N] =
  b & a

macro simpleGraph*(A, B, N: typedesc, E, G: untyped): untyped =
  # Convenience macro for defining Graph Types and the constructors.
  quote do:
    let `E` {.inject.} = newEmptyGraph(`A`, `B`, `N`)
    type `G` {.inject.} = Context[`A`, `B`, `N`]

template simpleGraph*(A, B: typedesc): untyped =
  # Default Graph macros are created.
  # The empty graph constructor is E and the inductive graph constructor is G.
  simpleGraph(A, B, int, E, G)

template simpleGraph*(A, B, N: typedesc): untyped =
  # Default Graph macros are created with the additional parameterization of
  # the node type.
  # The empty graph constructor is E and the inductive graph constructor is G.
  simpleGraph(A, B, N, E, G)

#[
Page 8, Section 3.2 "Pattern Matching on Graphs"
]#

proc isEmpty*(g: ref Graph): bool =
  g.kind == GraphKind.Empty

proc ufold*[A, B, C, N](f: (Context[A, B, N]) -> ((C) -> C),
                        u: C,
                        g: ref Graph[A, B, N],
                       ): C =
  case g.kind:
    of GraphKind.Empty: u
    of GraphKind.Graph: f(g.context)(ufold(f, u, g.graph))

proc gmap*[A, B, N](f: (Context[A, B, N]) -> Context[A, B, N],
                    g: ref Graph[A, B, N],
                   ): ref Graph[A, B, N] =
  ufold(
    ((c: Context[A, B, N]) => ((u: ref Graph[A, B, N]) => (f c) ^ u)),
    newEmptyGraph(A, B, N),
    g,
  )

proc grev*[A, B, N](g: ref Graph[A, B, N]): ref Graph[A, B, N] =
  gmap(
    ((c: Context[A, B, N]) => Context[A, B, N](p: c.s, v: c.v, l: c.l, s: c.p)),
    g,
  )

proc nodes*[A, B, N](g: ref Graph[A, B, N]): seq[N] =
  ufold(
    ((c: Context[A, B, N]) => ((u: seq[N]) => c.v & u)),
    @[],
    g,
  )

proc match*[A, B, N](n: N, g: ref Graph[A, B, N]): Option[ref Graph[A, B, N]] =
  case g.kind:
    of GraphKind.Empty: none(ref Graph[A, B, N])
    of GraphKind.Graph:
      if n == g.context.v: some(g)
      else:                match(n, g.graph)

proc suc*[A, B, N](c: Context[A, B, N]): seq[N] =
  c.s.mapIt(it.v)

proc gsuc*[A, B, N](n: N, g: ref Graph[A, B, N]): seq[N] =
  let g_1 = match(n, g)
  if g_1.isNone: @[]
  else:          g_1.get.context.suc
