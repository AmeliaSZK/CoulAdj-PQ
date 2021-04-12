let
    DontRelateDiagonals = false,
    RLEncoded = GQ_Sandbox_Size_1_RLE_Base,

    /* Align consecutive rows */
    GroupedByRowIndex = Table.Group(RLEncoded, {"row"}, {{"Rows", each _, type table [row = Int64.Type, value = binary, Start = Int64.Type, End = Int64.Type]}}),
    AllRows = Table.Column(GroupedByRowIndex, "Rows"),
    AlignedTopRow = Table.FromColumns({AllRows, List.Skip(AllRows)}, {"bottom", "Top"}),
    RemovedLastRow = Table.RemoveLastN(AlignedTopRow,1),
    /* Prepare for filtering */
    ExpandedBottom = Table.ExpandTableColumn(RemovedLastRow, "bottom", {"row", "value", "Start", "End"}),
    KeptTopNeighbours = Table.ExpandTableColumn(ExpandedBottom, "Top", {"value", "Start", "End"}, {"Top.value", "Top.Start", "Top.End"}),

    /* Purged identical colours */
    RemovedSameValues = Table.SelectRows(KeptTopNeighbours, each [value] <> [Top.value]),

    /* Top Center */
    // Top Center neighbours 1 of 2
    RemovedTopEndsBeforeStart = Table.SelectRows(RemovedSameValues, each not ([Top.End] < [Start])),
    // Top Center neighbours 2 of 2
    RemovedEndsBeforeTopStart = Table.SelectRows(RemovedTopEndsBeforeStart, each not ([End] < [Top.Start])),

    /* Diagonals */
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

    /* Keep Ordered Relations */
    #"Removed Other Columns" = Table.SelectColumns(AdjacentTopNeighbours,{"value", "Top.value"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Top.value", "adj_value"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "value1", each List.Min({[value], [adj_value]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "value2", each List.Max({[value], [adj_value]}), type binary),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom2",{"value1", "value2"}),
    /* Purge Dupicate ordered relations */
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns1")
in
    #"Removed Duplicates"