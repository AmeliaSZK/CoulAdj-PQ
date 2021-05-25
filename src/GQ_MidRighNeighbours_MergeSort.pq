let
    thisKeys = {"This.Row", "This.End"},
    nextKeys = {"Next.Row", "Next.Start"},
    joinKind = JoinKind.Inner,
    RightNeighbours = GQ_SelfMergeSortRLE(thisKeys, nextKeys, joinKind)
in
    RightNeighbours