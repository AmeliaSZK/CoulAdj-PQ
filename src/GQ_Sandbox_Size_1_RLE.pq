let
    DontRelateDiagonals = false,
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    RLEncoded = Table.Buffer(GQ_EncodeRunLength(Source[AllPixels])),
    #"Added Custom" = Table.AddColumn(RLEncoded, "Top", each RLEncoded, type table[row = Int64.Type, value = binary, Start = Int64.Type, End = Int64.Type]),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Added Custom", "Top", {"row", "value", "Start", "End"}, {"Top.row", "Top.value", "Top.Start", "Top.End"}),
    KeptTopRows = Table.SelectRows(#"Expanded {0}", each [Top.row] = [row] - 1),
    RemovedSameValues = Table.SelectRows(KeptTopRows, each [value] <> [Top.value]),

    // Top Center neighbours 1 of 2
    RemovedTopEndsBeforeStart = Table.SelectRows(RemovedSameValues, each not ([Top.End] < [Start])),
    // Top Center neighbours 2 of 2
    RemovedEndsBeforeTopStart = Table.SelectRows(RemovedTopEndsBeforeStart, each not ([End] < [Top.Start])),

    // Next 2 steps only done if DontRelateDiagonals is true
    // Top Left neighbours
    RemovedStartsAtTopEnd = Table.SelectRows(RemovedEndsBeforeTopStart, each not ([Start] = [Top.End])),
    // Top Right neighbours
    RemovedEndsAtTopStart = Table.SelectRows(RemovedStartsAtTopEnd, each not ([End] = [Top.Start])),

    AdjacentTopNeighbours =
        if DontRelateDiagonals then
            RemovedEndsAtTopStart
        else
            RemovedEndsBeforeTopStart,
    #"Removed Other Columns" = Table.SelectColumns(AdjacentTopNeighbours,{"value", "Top.value"})
in
    #"Removed Other Columns"