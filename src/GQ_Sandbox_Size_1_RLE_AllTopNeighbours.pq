let
    DontRelateDiagonals = false,
    RLEncoded = GQ_Sandbox_Size_1_RLE_Base,
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
    #"Removed Other Columns" = Table.SelectColumns(AdjacentTopNeighbours,{"value", "Top.value"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Top.value", "adj_value"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "value1", each List.Min({[value], [adj_value]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "value2", each List.Max({[value], [adj_value]}), type binary),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom2",{"value1", "value2"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns1")
in
    #"Removed Duplicates"