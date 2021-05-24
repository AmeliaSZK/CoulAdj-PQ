let
    DontRelateDiagonals = GQ_DontRelateDiagonals,
    RLEncoded = GQ_Result_EncodeRunLength,

    /* Align consecutive rows */
    GroupedByRowIndex = Table.Group(RLEncoded, {"row"}, {{"Rows", each _, type table [row = number, colour = binary, Start = number, End = number]}}, GroupKind.Local),
    AllRows = Table.Column(GroupedByRowIndex, "Rows"),
    AlignedTopRow = Table.FromColumns({AllRows, List.Skip(AllRows)}, {"bottom", "Top"}),
    RemovedLastRow = Table.RemoveLastN(AlignedTopRow,1),
    AddedThisScanline = Table.AddColumn(RemovedLastRow, "thisScanline", each Table.PrefixColumns([bottom], "this")),
    AddedNextScanline = Table.AddColumn(AddedThisScanline, "nextScanline", each Table.PrefixColumns([Top], "next")),
    AddedJoined = Table.AddColumn(AddedNextScanline, "Joined", each Table.Join([thisScanline], "this.Start", [nextScanline], "next.Start", JoinKind.FullOuter, JoinAlgorithm.SortMerge)),
    AddedFilled = Table.AddColumn(AddedJoined, "Filled", each Table.FillDown([Joined], {"this.colour", "next.colour"})),
    KeptFilled = Table.SelectColumns(AddedFilled,{"Filled"}),
    ExpandedFilled = Table.ExpandTableColumn(KeptFilled, "Filled", {"this.colour", "next.colour"}, {"this.colour", "next.colour"}),
    RenamedForCompatibility = Table.RenameColumns(ExpandedFilled,{{"this.colour", "colour"}, {"next.colour", "Top.colour"}})
in
    RenamedForCompatibility