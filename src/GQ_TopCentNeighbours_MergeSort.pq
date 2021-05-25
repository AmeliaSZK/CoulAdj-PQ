let
    thisKeys = {"This.NextRow", "This.Start"},
    nextKeys = {"Next.Row", "Next.Start"},
    joinKind = JoinKind.FullOuter,
    RightNeighbours = GQ_SelfMergeSortRLE(thisKeys, nextKeys, joinKind)
in
    RightNeighbours