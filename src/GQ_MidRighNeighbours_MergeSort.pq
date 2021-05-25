let
    thisKeys = {"This.Row", "This.End"},
    nextKeys = {"Next.Row", "Next.Start"},
    joinKind = JoinKind.Inner,
    MidRighNeighbours = GQ_SelfMergeSortRLE(thisKeys, nextKeys, joinKind)
in
    MidRighNeighbours