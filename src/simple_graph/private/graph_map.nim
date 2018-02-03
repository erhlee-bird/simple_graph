type GraphMap[T] = ref object
  ## Create a mapping between arbitrary objects to an internal node-id.
  keyToNode: Table[T, Node]
    ## Provide a lookup from a key to a node-id.
  nodeToKey: Table[Node, T]
    ## Provide a reverse lookup from a node-id to a key.

proc newGraphMap[T](): GraphMap[T] =
  result.new()
  result.keyToNode = initTable[T, Node]()
  result.nodeToKey = initTable[Node, T]()

proc register[T](GM: GraphMap, A: T, n: Node): Node =
  ## Register a node-id and the associated object.
  result = n
  GM.keyToNode[A] = n
  GM.nodeToKey[n] = A

proc register[T](GM: GraphMap, A: T): Node {.raises: [KeyError].} =
  ## Map the provided node to a newly generated node-id.
  ## Raise an error if the node is already registered in the graph.
  if A in GM.keyToNode:
    raise KeyError.newException("Attempting to reregister a node that is " &
                                "already present in the graph mapping.")
  while true:
    # Repeat until a unique id is generated.
    let id: Node = rand(int.high)
    if id in GM.nodeToKey:
      continue
    return GM.register(A, id)

proc unregister[T](GM: GraphMap, A: T): Node {.raises: [KeyError].} =
  ## Unmap the provided node.
  ## Raise an error if the node is not already registered in the graph.
  if not (A in GM.keyToNode):
    raise KeyError.newException("Attempting to unregister a node that " &
                                "is not present in the graph mapping.")

  result = GM.keyToNode[A]
  GM.nodeToKey.del(result)
  GM.keyToNode.del(A)
