let
    DontRelateDiagonals = GQ_DontRelateDiagonals,
    RLEncoded = GQ_Result_EncodeRunLength,

    /* Align consecutive rows */
    GroupedByRowIndex = Table.Group(RLEncoded, {"row"}, {{"Rows", each _, type table [row = number, colour = binary, Start = number, End = number]}}, GroupKind.Local),
    AllRows = Table.Column(GroupedByRowIndex, "Rows"),
    AlignedTopRow = Table.FromColumns({AllRows, List.Skip(AllRows)}, {"bottom", "Top"}),
    RemovedLastRow = Table.RemoveLastN(AlignedTopRow,1),
    /* Prepare for filtering */
    ExpandedBottom = Table.ExpandTableColumn(RemovedLastRow, "bottom", {"row", "colour", "Start", "End"}),
    KeptTopNeighbours = Table.ExpandTableColumn(ExpandedBottom, "Top", {"colour", "Start", "End"}, {"Top.colour", "Top.Start", "Top.End"}),

    /* Purged identical colours */
    RemovedSameValues = Table.SelectRows(KeptTopNeighbours, each [colour] <> [Top.colour]),

    /* Top Center */
    RemovedNonNeighbours = Table.SelectRows(RemovedSameValues, each not ([Top.End] < [Start]) and not ([End] < [Top.Start])),
    // Top Center neighbours 1 of 2
    RemovedTopEndsBeforeStart = Table.SelectRows(RemovedSameValues, each not ([Top.End] < [Start])),
    // Top Center neighbours 2 of 2
    RemovedEndsBeforeTopStart = Table.SelectRows(RemovedTopEndsBeforeStart, each not ([End] < [Top.Start])),

    /* Diagonals */
    // Next 2 steps only done if DontRelateDiagonals is true
    // Top Left neighbours
//    RemovedStartsAtTopEnd = Table.SelectRows(RemovedEndsBeforeTopStart, each not ([Start] = [Top.End])),
    RemovedStartsAtTopEnd = Table.SelectRows(RemovedNonNeighbours , each not ([Start] = [Top.End])),
    // Top Right neighbours
    RemovedEndsAtTopStart = Table.SelectRows(RemovedStartsAtTopEnd, each not ([End] = [Top.Start])),

    AdjacentTopNeighbours =
        if DontRelateDiagonals then
            RemovedEndsAtTopStart
        else
//            RemovedEndsBeforeTopStart,
            RemovedNonNeighbours,

    /* Keep Ordered Relations */
    #"Removed Other Columns" = Table.SelectColumns(AdjacentTopNeighbours,{"colour", "Top.colour"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Top.colour", "adj_colour"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom2",{"MinColour", "MaxColour"}),
    /* Purge Dupicate ordered relations */
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns1")
in
    #"Removed Duplicates"