let
    DontRelateDiagonals = GQ_DontRelateDiagonals,
    RLEncoded = GQ_Result_EncodeRunLength,

    /* Align consecutive rows */
    GroupedByRowIndex = Table.Group(RLEncoded, {"row"}, {{"Rows", each _, type table [row = number, colour = binary, Start = number, End = number]}}, GroupKind.Local),
    AllRows = Table.Column(GroupedByRowIndex, "Rows"),
    AlignedTopRow = Table.FromColumns({AllRows, List.Skip(AllRows)}, {"bottom", "Top"}),
    RemovedLastRow = Table.RemoveLastN(AlignedTopRow,1),

    /* Merge-sort */
    AddedThisScanline = Table.AddColumn(RemovedLastRow, "thisScanline", each Table.PrefixColumns([bottom], "this")),
    AddedNextScanline = Table.AddColumn(AddedThisScanline, "nextScanline", each Table.PrefixColumns([Top], "next")),
    AddedJoined = Table.AddColumn(AddedNextScanline, "Joined", each Table.Join([thisScanline], "this.Start", [nextScanline], "next.Start", JoinKind.FullOuter, JoinAlgorithm.SortMerge)),
    AddedJoinedDiagStartEnd = Table.AddColumn(AddedJoined, "JoinedDiagStartEnd", each Table.Join([thisScanline], "this.Start", [nextScanline], "next.End",   JoinKind.Inner, JoinAlgorithm.SortMerge)),
    AddedJoinedDiagEndStart = Table.AddColumn(AddedJoinedDiagStartEnd, "JoinedDiagEndStart", each Table.Join([thisScanline], "this.End",   [nextScanline], "next.Start", JoinKind.Inner, JoinAlgorithm.SortMerge)),
    AddedFilled = Table.AddColumn(AddedJoinedDiagEndStart, "Filled", each Table.FillDown([Joined], {"this.colour", "next.colour"})),
    AddedCombined = 
        if DontRelateDiagonals then 
            Table.AddColumn(AddedFilled, "Combined", each [Filled])
        else
            Table.AddColumn(AddedFilled, "Combined", each Table.Combine({[Filled], [JoinedDiagStartEnd], [JoinedDiagEndStart]})),
    KeptCombined = Table.SelectColumns(AddedCombined,{"Combined"}),
    ExpandedCombined = Table.ExpandTableColumn(KeptCombined, "Combined", {"this.colour", "next.colour"}, {"this.colour", "next.colour"}),
    RenamedForCompatibility = Table.RenameColumns(ExpandedCombined,{{"this.colour", "colour"}, {"next.colour", "Top.colour"}}),
    RemovedSameValues = Table.SelectRows(RenamedForCompatibility, each [colour] <> [Top.colour]),

    /* Keep Ordered Relations */
    #"Removed Other Columns" = Table.SelectColumns(RemovedSameValues,{"colour", "Top.colour"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Other Columns",{{"Top.colour", "adj_colour"}}),
    #"Added Custom1" = Table.AddColumn(#"Renamed Columns", "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom2",{"MinColour", "MaxColour"}),
    /* Purge Dupicate ordered relations */
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns1")
in
    #"Removed Duplicates"