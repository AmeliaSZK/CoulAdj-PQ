let
    thisKeys = {"This.NextRow", "This.Start"},
    nextKeys = {"Next.Row", "Next.End"},
    joinKind = JoinKind.Inner,
    TopLeftNeighbours = GQ_SelfMergeSortRLE(thisKeys, nextKeys, joinKind)
in
    TopLeftNeighbours