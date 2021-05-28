let
    // To make the showcase work, function arguments had to be converted to variables with a value
    #"~PARAMETERS~" = "This step is to have a separator in the list of steps in the GUI",
    // You can (and *should*) change this value with GQ_ImageUnderTest_Name
    bitmap = GQ_TB_ImageUnderTest_Binary as binary,
    dontRelateDiagonals = GQ_DontRelateDiagonals as nullable logical,
    // Everything beyond this point is a copy-pasta from the actual function
    #"~START OF FUNCTION~" = "This step is to have a separator in the list of steps in the GUI",
    DontRelateDiagonals = if dontRelateDiagonals is null then false else dontRelateDiagonals,


    /* IMPORTANT VOCABULARY

    # Run Length Encoding (RLE) #
    | Symbol         | Meaning                                                                |
    |----------------|------------------------------------------------------------------------|
    | Scanline       | A row of pixels                                                        |
    | Segment        | A run of consecutive pixels of the same colour on the same scanline(1) |
    | Index          | An index where the first item in the list is at index 0                |
    | Start (In RLE) | Index                 of the first pixel in this segment               |
    | End   (In RLE) | Index AFTER the index of the last  pixel in this segment(2)            |

    (1): I know that the technical term for this is a "run", as it is the "run" in "run length encoding",
         but I feel that "run" is too close to "row", and the goal of establishing this vocabulary is
         to have words for different things that: 1) *are* different, and that 2) **look** different.

    **************************************************************************************
    ******** MOST IMPORTANT INFORMATION IN THIS WHOLE COMMENT ****************************

    (2): It is crucial to remember that the "End" of a segment is *not* `last index`,
         but `last index + 1`. It is how we can identify segments on different scanlines 
         that don't overlap, but are diagonally adjacent.

    ******** MOST IMPORTANT INFORMATION IN THIS WHOLE COMMENT ****************************
    **************************************************************************************



    # Positionality #
    |     |    Left |    Cent |    Righ |
    |-----|---------|---------|---------|
    | Top | TopLeft | TopCent | TopRigh |
    | Mid | MidLeft | MidCent | MidRigh |
    | Bot | BotLeft | BotCent | BotRigh |

        ## A note about "This" and "Next" ##
        It is rarely (never?) important to know if the next row of data in a Power Query table
        is actually to the top or to the bottom of the previous row. Also, depending on how a
        bitmap has been stored in its file, the next row could be either top or bottom.

        This is why we used "This" and "Next" in several names, because what's important is that
        we're comparing "this" row with the "next" row, wether that's top or bottom, or right or left.

        However, while coding and choosing the variable and column names, we realized that positional
        terminology was necessary to tell us quickly what the variable was intended to be.

        For example, when finding the diagonal neighbours. We want TopLeft and TopRigh. But how do we name
        those with "This" and "Next"? DiagThisStartNextEnd?? (TopLeft) And then DiagThisEndNextStart??? (TopRigh)
        DiagThisStartNextEnd and DiagThisEndNextStart look to me like undistinguishable gibberish at first glance,
        and just gibberish at second glance.

        Also, if you're getting confused as to why some places use This/Next and others use positionality,
        it's not you, it's me who never managed to establish a consistent convention for which situation deserves which term.
        Towards the end of this implementation, I spent a good amount of time renaming variables and columns 
        to use terminology in ways that at least *feel* consistent, but... yeah :|



    # Relations & Adjacencies #
    | Symbol              | Meaning                            |
    |---------------------|------------------------------------|
    | A                   | The colour "A"                     |
    | {B,A}               | "Colour B is adjacent to colour A" |
    | An adjacency        | {B,A}                              |
    | Two adjacencies     | {B,A}, {C,D}                       |
    | Two adjacencies     | {A,B}, {B,A}                       |
    | A relation          | { {A,B}, {B,A} }                   |
    | An ordered relation | {A,B}                              |

    Since {A,B} always imply that {B,A} is also true, we can (and do!) 
        remove {B,A} from intermediary datasets to improve performances.
    */
    ParsedBitmap = GQ_ParseBitmap(bitmap),
    RLEncoded.Unbuffered = Table.Group(
            ParsedBitmap[PixelArray.AsColours], 
            {"Row Index", "Colour"}, 
            {{"Start", each List.First([Column Index]), type number}, {"End", each List.Last([Column Index])+1, type number}}, 
            GroupKind.Local
        ),
    RLEncoded.Unbuffered.Renamed = Table.RenameColumns(RLEncoded.Unbuffered,{{"Row Index", "Scanline Index"}}),
    // Every time I tried to remove this buffer, the duration exploded. Leave it there.
    RLEncoded = Table.Buffer(RLEncoded.Unbuffered.Renamed),
    RLEncoded.TableType = type table[Scanline Index = number, Colour = binary, Start = number, End = number],

    /* How the top neighbours are computed:
    TopLeft, TopCent, and TopRigh are in the same section of the code because of how similar they are to compute.
    TopLeft and TopRigh may be ignored if the DontRelateDiagonals option is set to True.

    For performance, computations are done with merge-sort joins, and most notably a 
        full outer merge-sort join for TopCent.
    The joins are performed between pairs of consecutive scanlines.
    For example, say we have these two (unencoded) scanlines of pixels:
        (Col Index)  : 0       4       8 9
        Next Scanline: E E E E F F F F G
        This Scanline: A A B B B B C C D
        (Col Index)  : 0   2       6   8 9
    After the Run Length Encoding, we can get these 2 subtables(*):
        [This Scanline]                         ~   [Next Scanline]
        [This.Colour] [This.Start] [This.End]   ~   [Next.Colour] [Next.Start] [Next.End]
        A             0            2            ~   E             0            4
        B             2            6            ~   F             4            8
        C             6            8            ~   G             8            9
        D             8            9            ~
        
        (*): A "subtable" is a Power Query table contained within a cell of another Power Query table.
             So for the two subtables above, the "table" has the two columns [This Scanline] and [Next Scanline].
             Then, the two shown subtables are contained in the cells of the first row of the "table".
             The representation in this comment is a bit funky because I tried to only show what's relevant.

    For the diagonal neighbours, (TopLeft and TopRigh), look at the last 2 columns in the example:
        (Col Index)  :      8 9
        Next Scanline:    F G
        This Scanline:    C D
        (Col Index)  :      8 9
    We can see that...
        For D, TopLeft is F
        For C, TopRigh is G
    We can find all the TopLeft neighbours by joining with This.Start and Next.End
        For D, This.Start is 8. For F, Next.End   is also 8.
    We can find all the TopRigh neighbours by joining with This.End   and Next.Start
        For C, This.End   is 8. For G, Next.Start is also 8.

    For the TopCent neighbours, a full outer merge-sort join on This.Start and Next.Start,
        followed by a fill-down, will find all segments that overlap.
    The join:
        [This.Colour] [This.Start] [This.End] [Next.Colour] [Next.Start] [Next.End]
        A             0            2          E             0            4
        B             2            6          null          null         null
        null          null         null       F             4            8
        C             6            8          null          null         null
        D             8            9          G             8            9   
    The fill-down:
        [This.Colour] [This.Start] [This.End] [Next.Colour] [Next.Start] [Next.End]
        A             0            2          E             0            4
        B             2            6          E             0            4
        B             2            6          F             4            8
        C             6            8          F             4            8
        D             8            9          G             8            9    
    Just the colour columns (others were removed):     
        [This.Colour] [Next.Colour]
        A             E
        B             E
        B             F
        C             F
        D             G
    Copy-pasta of the example for comparison:
        Next: E E E E F F F F G
        This: A A B B B B C C D
    */
    #"~ALL TOP NEIGHBOURS~" = "This step is to have a separator in the list of steps in the GUI",

    GroupedScanlines = Table.Group(RLEncoded, {"Scanline Index"}, {{"Scanlines", each _, RLEncoded.TableType}}, GroupKind.Local),
    AllScanlines = Table.Column(GroupedScanlines, "Scanlines"),
    AlignedMidAndTopScanlines = Table.FromColumns({List.RemoveLastN(AllScanlines,1), List.RemoveFirstN(AllScanlines,1)}, type table[Mid Scanline = RLEncoded.TableType, Top Scanline = RLEncoded.TableType]),

    AddedThisScanline = Table.AddColumn(AlignedMidAndTopScanlines, "This Scanline", each Table.PrefixColumns([Mid Scanline], "This")),
    AddedNextScanline = Table.AddColumn(AddedThisScanline,         "Next Scanline", each Table.PrefixColumns([Top Scanline], "Next")),
    AddedJoinedTopCent = Table.AddColumn(AddedNextScanline,  "Joined TopCent", each Table.Join([This Scanline], "This.Start", [Next Scanline], "Next.Start", JoinKind.FullOuter, JoinAlgorithm.SortMerge)),
    AddedTopLeft =       Table.AddColumn(AddedJoinedTopCent, "TopLeft",        each Table.Join([This Scanline], "This.Start", [Next Scanline], "Next.End",   JoinKind.Inner,     JoinAlgorithm.SortMerge)),
    AddedTopRigh =       Table.AddColumn(AddedTopLeft,       "TopRigh",        each Table.Join([This Scanline], "This.End",   [Next Scanline], "Next.Start", JoinKind.Inner,     JoinAlgorithm.SortMerge)),
    AddedTopCent =       Table.AddColumn(AddedTopRigh,       "TopCent",        each Table.FillDown([Joined TopCent], {"This.Colour", "Next.Colour"})),
    AddedAllTops = 
        if DontRelateDiagonals then 
            Table.AddColumn(AddedTopCent, "All Tops", each [TopCent])
        else
            Table.AddColumn(AddedTopCent, "All Tops", each Table.Combine({[TopCent], [TopLeft], [TopRigh]})),
    KeptAllTops = Table.SelectColumns(AddedAllTops,{"All Tops"}),
    ExpandedAllTops = Table.ExpandTableColumn(KeptAllTops, "All Tops", {"This.Colour", "Next.Colour"}),
    FilteredSameColours = Table.SelectRows(ExpandedAllTops, each [This.Colour] <> [Next.Colour]),

    ExtractOrderedRelations = (table as table, columnA as text, columnB as text) as table =>
        let
            KeptColourColumns = Table.SelectColumns(table, {columnA, columnB}),
            RenamedToKnownNames = Table.RenameColumns(KeptColourColumns,{{columnA, "colour"}, {columnB, "adj_colour"}}),
            AddedMinColour = Table.AddColumn(RenamedToKnownNames, "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
            AddedMaxColour = Table.AddColumn(AddedMinColour,      "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
            KeptMinMaxColumns = Table.SelectColumns(AddedMaxColour, {"MinColour", "MaxColour"}),
            PurgedDuplicates = Table.Distinct(KeptMinMaxColumns)
        in
            PurgedDuplicates,

    ExtractedOrderedTopNeighbours = ExtractOrderedRelations(FilteredSameColours, "This.Colour", "Next.Colour"),
    AllTopNeighbours = ExtractedOrderedTopNeighbours,

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
    KeptRowAndColourFromRLE = Table.SelectColumns(RLEncoded,{"Scanline Index", "Colour"}),
    GroupedSegments = Table.Group(KeptRowAndColourFromRLE, {"Scanline Index"}, {{"Segments", each _, type table [Scanline Index = number, Colour = binary]}}, GroupKind.Local),
    AddedSegmentsAsList = Table.AddColumn(GroupedSegments, "Segments.AsList", each Table.Column([Segments], "Colour"), type {binary}),
    AddedConsecutives = Table.AddColumn(AddedSegmentsAsList, "Consecutives", each Table.FromColumns({List.RemoveLastN([Segments.AsList],1), List.RemoveFirstN([Segments.AsList],1)}, type table[colour = binary, adj_colour = binary]), type table[colour = binary, adj_colour = binary]),
    AddedOrderedConsecutives = Table.AddColumn(AddedConsecutives, "OrderedConsecutives", each ExtractOrderedRelations([Consecutives], "colour", "adj_colour"), type table[MinColour = binary, MaxColour = binary]),
    // This is necessary because if all the pixels in a scanline are the same colour, the subtable will be empty,
    // and this will create errors later on. This happens in the Total War Warhammer 2 Vortex map.
    FilteredEmptyOrderedConsecutives = Table.SelectRows(AddedOrderedConsecutives, each not (Table.IsEmpty([OrderedConsecutives]))),

    KeptOrderedConsecutives = Table.SelectColumns(FilteredEmptyOrderedConsecutives,{"OrderedConsecutives"}),
    ExpandedOrderedConsecutives = Table.ExpandTableColumn(KeptOrderedConsecutives, "OrderedConsecutives", {"MinColour", "MaxColour"}),
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
    AddedAdjacencies = Table.AddColumn(
        AllUniqueRelations, 
        "Adjacencies", 
        each Table.FromRecords({
            [colour=[MinColour], adj_colour=[MaxColour]], 
            [colour=[MaxColour], adj_colour=[MinColour]]
        }), 
        type table[colour=binary, adj_colour=binary]
    ),
    KeptAdjacencies = Table.SelectColumns(AddedAdjacencies,{"Adjacencies"}),
    ExpandedAdjacencies = Table.ExpandTableColumn(KeptAdjacencies, "Adjacencies", {"colour", "adj_colour"}),
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
        {"r", "g", "b",      "adj_r", "adj_g", "adj_b"},

    RecordFromColour = ParsedBitmap[RecordFromColour],
    RecordFromColour.RecordType = ParsedBitmap[RecordFromColour.RecordType],

    FieldNames = Record.FieldNames(Type.RecordFields(RecordFromColour.RecordType)),
    ColumnNames = FieldNames,
    AdjColumnNames = List.Transform(ColumnNames, each "adj_" & _),

    AddedDecoded =    Table.AddColumn(AllAdjacencies,     "decoded", each RecordFromColour(    [colour]), RecordFromColour.RecordType),
    AddedAdjDecoded = Table.AddColumn(AddedDecoded,   "adj_decoded", each RecordFromColour([adj_colour]), RecordFromColour.RecordType),
    KeptDecodedColumns = Table.SelectColumns(AddedAdjDecoded,{"decoded", "adj_decoded"}),
    ExpandedDecoded =    Table.ExpandRecordColumn(KeptDecodedColumns,     "decoded", FieldNames,    ColumnNames),
    ExpandedAdjDecoded = Table.ExpandRecordColumn(ExpandedDecoded,    "adj_decoded", FieldNames, AdjColumnNames),
    RenamedColumnsPerCoulAdjAPI = Table.RenameColumns(ExpandedAdjDecoded, ColumnRenames),
    ReorderedColumnsPerCoulAdjAPI = Table.ReorderColumns(RenamedColumnsPerCoulAdjAPI, ColumnOrder),
    FormattedOutput = ReorderedColumnsPerCoulAdjAPI 
in
    FormattedOutput