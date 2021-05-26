let
    /* IMPORTANT VOCABULARY
    | Symbol              | Meaning                            |
    |---------------------|------------------------------------|
    | A                   | The colour "A"                     |
    | {B,A}               | "Colour B is adjacent to colour A" |
    | An adjacency        | {B,A}                              |
    | Two adjacencies     | {B, A}, {C, D}                     |
    | Two adjacencies     | {A, B}, {B, A}                     |
    | A relation          | { {A,B}, {B,A} }                   |
    | An ordered relation | {A, B}                             |
    Since {A,B} always imply that {B,A} is also true, we can remove {B,A} from
        the dataset to improve performances.
    However, we will still need to re-introduce {B,A} later so that the output has both.

    | Symbol   | Meaning                                                                |
    |----------|------------------------------------------------------------------------|
    | Scanline | A row of pixels                                                        |
    | Segment  | A run of consecutive pixels of the same colour on the same scanline(1) |
    | Index    | An index where the first item in the list is at index 0                |

    (1): I know that the technical term for this is a "run", as it is the "run" in "run length encoding",
         but I feel that "run" is too close to "row", and the goal of establishing this vocabulary is
         to have words for different things that: 1) *are* different, and that 2) **look** different.
    
    */
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
    RLEncoded.Unbuffered.Renamed = Table.RenameColumns(RLEncoded.Unbuffered,{{"row", "Scanline Index"}, {"colour", "Colour"}}),
    // Every time I tried to remove this buffer, the duration exploded. Leave it there.
    RLEncoded = Table.Buffer(RLEncoded.Unbuffered.Renamed),
    RLEncoded.TableType = type table[Scanline Index = number, Colour = binary, Start = number, End = number],

    #"~ALL TOP NEIGHBOURS~" = "This step is to have a separator in the list of steps in the GUI",
    /* Align consecutive rows */
    GroupedScanlines = Table.Group(RLEncoded, {"Scanline Index"}, {{"Scanlines", each _, RLEncoded.TableType}}, GroupKind.Local),
    AllScanlines = Table.Column(GroupedScanlines, "Scanlines"),
    AlignedMidAndTopScanlines = Table.FromColumns({List.RemoveLastN(AllScanlines,1), List.RemoveFirstN(AllScanlines,1)}, type table[Mid Scanline = RLEncoded.TableType, Top Scanline = RLEncoded.TableType]),
    /* Merge-sort */
    AddedThisScanline = Table.AddColumn(AlignedMidAndTopScanlines, "This Scanline", each Table.PrefixColumns([Mid Scanline], "This")),
    AddedNextScanline = Table.AddColumn(AddedThisScanline, "Next Scanline", each Table.PrefixColumns([Top Scanline], "Next")),
    AddedJoinedMidTop = Table.AddColumn(AddedNextScanline, "Joined MidTop", each Table.Join([This Scanline], "This.Start", [Next Scanline], "Next.Start", JoinKind.FullOuter, JoinAlgorithm.SortMerge)),
    AddedMidTop = Table.AddColumn(AddedJoinedMidTop, "MidTop", each Table.FillDown([Joined MidTop], {"This.Colour", "Next.Colour"})),
    AddedTopLeft = Table.AddColumn(AddedMidTop, "TopLeft", each Table.Join([This Scanline], "This.Start", [Next Scanline], "Next.End",   JoinKind.Inner, JoinAlgorithm.SortMerge)),
    AddedTopRigh = Table.AddColumn(AddedTopLeft, "TopRigh", each Table.Join([This Scanline], "This.End",   [Next Scanline], "Next.Start", JoinKind.Inner, JoinAlgorithm.SortMerge)),
    AddedAllTops = 
        if DontRelateDiagonals then 
            Table.AddColumn(AddedTopRigh, "All Tops", each [MidTop])
        else
            Table.AddColumn(AddedTopRigh, "All Tops", each Table.Combine({[MidTop], [TopLeft], [TopRigh]})),
    KeptAllTops = Table.SelectColumns(AddedAllTops,{"All Tops"}),
    ExpandedAllTops = Table.ExpandTableColumn(KeptAllTops, "All Tops", {"This.Colour", "Next.Colour"}),
    FilteredSameColours = Table.SelectRows(ExpandedAllTops, each [This.Colour] <> [Next.Colour]),

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

    AllTopNeighbours = ExtractOrderedRelations(FilteredSameColours, "This.Colour", "Next.Colour"),

    /* To extract the right neighbours, we look at consecutive segments on the same scanline.
    So, for example, say we have this unencoded scanline, where each letter is a pixel of that colour:
        AAAAAABBCCCCAADDDAAAA
    The Run Length Encoding will return this list of segments:
        ABCADA
    Thus, the adjacencies we will first extract, called the "Consecutives" are:
        A-B
        B-C
        C-A
        A-D
        D-A
    Then, they will be ordered:
        A-B
        B-C
        A-C
        A-D
        A-D
    And then the duplicates will be purged:
        A-B
        B-C
        A-C
        A-D
    */
    #"~RIGHT NEIGHBOURS~" = "This step is to have a separator in the list of steps in the GUI",
    /* Group Segments by Row Index */
    KeptRowAndColourFromRLE = Table.SelectColumns(RLEncoded,{"Scanline Index", "Colour"}),
    GroupedSegments = Table.Group(KeptRowAndColourFromRLE, {"Scanline Index"}, {{"Segments", each _, type table [Scanline Index = number, Colour = binary]}}, GroupKind.Local),
    AddedSegmentsAsList = Table.AddColumn(GroupedSegments, "Segments.AsList", each Table.Column([Segments], "Colour"), type {binary}),
    AddedConsecutives = Table.AddColumn(AddedSegmentsAsList, "Consecutives", each Table.FromColumns({List.RemoveLastN([Segments.AsList],1), List.RemoveFirstN([Segments.AsList],1)}, type table[colour = binary, adj_colour = binary]), type table[colour = binary, adj_colour = binary]),
    AddedOrderedConsecutives = Table.AddColumn(AddedConsecutives, "OrderedConsecutives", each ExtractOrderedRelations([Consecutives], "colour", "adj_colour"), type table[MinColour = binary, MaxColour = binary]),
    // This is necessary because if all the pixels in a scanline are the same colour, its subtable will be empty,
    // and this will create errors later on. This case is present in the Total War Warhammer 2 Vortex map.
    FilteredEmptyOrderedConsecutives = Table.SelectRows(AddedOrderedConsecutives, each not (Table.IsEmpty([OrderedConsecutives]))),
    
    /* (Boilerplate) Expand & keep consecutives */
    KeptOrderedConsecutives = Table.SelectColumns(FilteredEmptyOrderedConsecutives,{"OrderedConsecutives"}),
    ExpandedOrderedConsecutives = Table.ExpandTableColumn(KeptOrderedConsecutives, "OrderedConsecutives", {"MinColour", "MaxColour"}, {"MinColour", "MaxColour"}),
    PurgedDuplicateRightNeighbours = Table.Distinct(ExpandedOrderedConsecutives),
    RightNeighbours = PurgedDuplicateRightNeighbours,

    #"~ALL UNIQUE RELATIONS~" = "This step is to have a separator in the list of steps in the GUI",
    /* Combine all unique ordered relations */
    // unique = no duplicates
    // ordered = value1 < value2, for all rows
    // relation = "A is adjacent to B" is one (1) relation, but in the final output it needs two rows: {A, B} & {B, A}
    //            By "relation", we mean only the row {A, B}, because that's enough to know we also need {B, A} later.
    CombinedAllOrderedRelations = Table.Combine({AllTopNeighbours, RightNeighbours}),
    PurgedDuplicateOrderedRelations = Table.Distinct(CombinedAllOrderedRelations),
    AllUniqueRelations = PurgedDuplicateOrderedRelations,

    #"~ALL ADJACENCIES~" = "This step is to have a separator in the list of steps in the GUI",
    AddedAdjacencies = Table.AddColumn(AllUniqueRelations, "Adjacencies", each Table.FromRecords({[colour=[MinColour], adj_colour=[MaxColour]], [colour=[MaxColour], adj_colour=[MinColour]]}), type table[colour=binary, adj_colour=binary]),
    KeptAdjacencies = Table.SelectColumns(AddedAdjacencies,{"Adjacencies"}),
    ExpandedAdjacencies = Table.ExpandTableColumn(KeptAdjacencies, "Adjacencies", {"colour", "adj_colour"}, {"colour", "adj_colour"}),
    AllAdjacencies = ExpandedAdjacencies,

    #"~FORMATTED OUTPUT~" = "This step is to have a separator in the list of steps in the GUI",
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