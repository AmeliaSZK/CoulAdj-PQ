let
    thisKeys = {"This.NextRow", "This.End"},
    nextKeys = {"Next.Row", "Next.Start"},
    joinKind = JoinKind.Inner,
    TopRighNeighbours = GQ_SelfMergeSortRLE(thisKeys, nextKeys, joinKind)
in
    TopRighNeighbours