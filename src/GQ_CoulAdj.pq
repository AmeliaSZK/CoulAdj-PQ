let
    // Parameters
    bitmap = GQ_ImageUnderTest_Binary,
    dontRelateDiagonals = GQ_DontRelateDiagonals,
    DontRelateDiagonals = if dontRelateDiagonals is null then false else dontRelateDiagonals,
    
    ParsedBitmap = GQ_ParseBitmap(bitmap),
    RLEncoded.Unbuffered = Table.Group(
            ParsedBitmap[PixelArray.AsColours], 
            {"row", "colour"}, 
            {{"Start", each List.First([col]), type number}, {"End", each List.Last([col])+1, type number}}, 
            GroupKind.Local
        ),
    // Every time I tried to remove this buffer, the duration exploded. Leave it there.
    RLEncoded = Table.Buffer(RLEncoded.Unbuffered),

    // ALL TOP NEIGHBOURS
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
    RemovedSameValues = Table.SelectRows(ExpandedCombined, each [this.colour] <> [next.colour]),

    ExtractOrderedRelations = (table as table, columnA as text, columnB as text) as table =>
        let
            KeptColourColumns = Table.SelectColumns(table, {columnA, columnB}),
            RenamedToKnownNames = Table.RenameColumns(KeptColourColumns,{{columnA, "colour"}, {columnB, "adj_colour"}}),
            AddedMinColour = Table.AddColumn(RenamedToKnownNames, "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
            AddedMaxColour = Table.AddColumn(AddedMinColour, "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
            KeptMinMaxColumns = Table.SelectColumns(AddedMaxColour, {"MinColour", "MaxColour"}),
            PurgedDuplicates = Table.Distinct(KeptMinMaxColumns)
        in
            PurgedDuplicates,

    AllTopNeighbours = ExtractOrderedRelations(RemovedSameValues, "this.colour", "next.colour"),

    // RIGHT NEIGHBOURS
    /* Group Segments by Row Index */
    #"Removed Other Columns2" = Table.SelectColumns(RLEncoded,{"row", "colour"}),
    #"Grouped Rows" = Table.Group(#"Removed Other Columns2", {"row"}, {{"Segments", each _, type table [row = number, colour = binary]}}, GroupKind.Local),

    /* Join consecutive segments */
    ProcessSubtable = (table as table) as table =>
    let
        Segments = Table.Column(table, "colour"),
        Consecutives = Table.FromColumns(
            {Segments, List.Skip(Segments, 1)},
            type table[colour = binary, adj_colour = binary]
        ),
        RemovedLastRow = Table.RemoveLastN(Consecutives,1),
        OrderedRelations = ExtractOrderedRelations(RemovedLastRow, "colour", "adj_colour")
    in
        OrderedRelations,
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "ProcessedSegments", each ProcessSubtable([Segments]), type table[MinColour = binary, MaxColour = binary]),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each not (Table.IsEmpty([ProcessedSegments]))),
    
    /* (Boilerplate) Expand & keep consecutives */
    #"Removed Other Columns3" = Table.SelectColumns(#"Filtered Rows",{"ProcessedSegments"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns3", "ProcessedSegments", {"MinColour", "MaxColour"}, {"MinColour", "MaxColour"}),
    #"Removed Duplicates1" = Table.Distinct(#"Expanded {0}"),
    RightNeighbours = #"Removed Duplicates1",

    // ALL UNIQUE RELATIONS
    /* Combine all unique ordered relations */
    // unique = no duplicates
    // ordered = value1 < value2, for all rows
    // relation = "A is adjacent to B" is one (1) relation, but in the final output it needs two rows: {A, B} & {B, A}
    //            By "relation", we mean only the row {A, B}, because that's enough to know we also need {B, A} later.
    CombinedAllOrderedRelations = Table.Combine({AllTopNeighbours, RightNeighbours}),
    PurgedDuplicates = Table.Distinct(CombinedAllOrderedRelations),
    AllUniqueRelations = PurgedDuplicates,

    // ALL ADJACENCIES
    AddedAdjacencies = Table.AddColumn(AllUniqueRelations, "Adjacencies", each Table.FromRecords({[colour=[MinColour], adj_colour=[MaxColour]], [colour=[MaxColour], adj_colour=[MinColour]]}), type table[colour=binary, adj_colour=binary]),
    KeptAdjacencies = Table.SelectColumns(AddedAdjacencies,{"Adjacencies"}),
    ExpandedAdjacencies = Table.ExpandTableColumn(KeptAdjacencies, "Adjacencies", {"colour", "adj_colour"}, {"colour", "adj_colour"}),
    AllAdjacencies = ExpandedAdjacencies,

    // FORMATTED OUTPUT
    // The CoulAdj API specifies the column names and the order in which they appear, and these names
    //    are different from what ParseBitmap returns.
    ColumnRenames =
    if ParsedBitmap[HasAlpha] then
        {
            {"Red",   "r"},
            {"Green", "g"},
            {"Blue",  "b"},
            {"Alpha", "a"},
            {"adj_Red",   "adj_r"},
            {"adj_Green", "adj_g"},
            {"adj_Blue",  "adj_b"},
            {"adj_Alpha", "adj_a"}
        }
    else
        {
            {"Red",   "r"},
            {"Green", "g"},
            {"Blue",  "b"},
            {"adj_Red",   "adj_r"},
            {"adj_Green", "adj_g"},
            {"adj_Blue",  "adj_b"}
        },

    // The order of the fields returned by ParseBitmap isn't guaranteed,
    //    but the CoulAdj API does guarantee it.
    ColumnOrder = 
    if ParsedBitmap[HasAlpha] then
        {"r", "g", "b", "a", "adj_r", "adj_g", "adj_b", "adj_a"}
    else
        {"r", "g", "b", "adj_r", "adj_g", "adj_b"},

    RecordFromColour = ParsedBitmap[RecordFromColour],
    RecordFromColour.RecordType = ParsedBitmap[RecordFromColour.RecordType],

    FieldNames = Record.FieldNames(Type.RecordFields(RecordFromColour.RecordType)),
    ColumnNames = FieldNames,
    AdjColumnNames = List.Transform(ColumnNames, each "adj_" & _),

    AddedDecoded = Table.AddColumn(AllAdjacencies, "decoded", each RecordFromColour([colour]), RecordFromColour.RecordType),
    AddedAdjDecoded = Table.AddColumn(AddedDecoded, "adj_decoded", each RecordFromColour([adj_colour]), RecordFromColour.RecordType),
    KeptDecodedColumns = Table.SelectColumns(AddedAdjDecoded,{"decoded", "adj_decoded"}),
    ExpandedDecoded = Table.ExpandRecordColumn(KeptDecodedColumns, "decoded", FieldNames, ColumnNames),
    ExpandedAdjDecoded = Table.ExpandRecordColumn(ExpandedDecoded, "adj_decoded", FieldNames, AdjColumnNames),
    RenamedColumnsPerCoulAdjAPI = Table.RenameColumns(ExpandedAdjDecoded, ColumnRenames),
    ReorderedColumnsPerCoulAdjAPI = Table.ReorderColumns(RenamedColumnsPerCoulAdjAPI, ColumnOrder),
    FormattedOutput = ReorderedColumnsPerCoulAdjAPI 
in
    FormattedOutput