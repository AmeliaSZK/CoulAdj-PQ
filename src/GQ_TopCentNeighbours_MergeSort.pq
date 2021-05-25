let
    // ~~~ Parameters ~~~
    thisKeys = {"This.NextRow", "This.Start"},
    nextKeys = {"Next.Row", "Next.Start"},
    joinKind = JoinKind.FullOuter,

    // ~~~ Prologue ~~~
    RLEnconded = GQ_Result_EncodeRunLength,
    Source = Table.AddColumn(RLEnconded, "NextRow", each [row] + 1, type number),
    RenamedColumnsForInput = Table.RenameColumns(Source,{{"row", "Row"}, {"colour", "Colour"}}),
    BufferedSource = Table.Buffer(RenamedColumnsForInput),
    This.BufferedSource = Table.PrefixColumns(BufferedSource, "This"),
    Next.BufferedSource = Table.PrefixColumns(BufferedSource, "Next"),

    // ~ Post-prologue for TopCent ~
    /* FullOuter will make sure to include all the rows from both sides.
        We use this property, along with FillDown, as a way to match "equal or greater than, until next equal",
            for the keys This.Start and Next.Start
    However, since we're also matching This.NextRow and Next.Row, the FullOuter will include lines that make no sense.
        (in these comments, a "line" is a row in a Power Query table, to distinguish from a row of pixel in the image)
    For example, say we have the row indexes: {0, 1, 2, 3}
        The match we want is:
            (keys are This.NextRow and Next.Row, other columns are included for comprehension)
            [This.Row] [This.NextRow] [Next.Row] [Next.NextRow]
            0          1              1          2
            1          2              2          3
            2          3              3          4
        But by default, we'll get:
            [This.Row] [This.NextRow] [Next.Row] [Next.NextRow]
            null       null           0          1              // <-- Purge here
            0          1              1          2
            1          2              2          3
            2          3              3          4
            3          4              null       null           // <-- Purge here
    Hence, before doing the join, we need to purge:
        Where Next.Row = 0 (first row index)
        Where This.Row = 3 (last  row index)
    Fortunately, since the lines to purge are by definition either at the start or the end of the
        table, we can use Table.RemoveFirstN and Table.RemoveLastN
    */
    FirsRowIndex = 0,
    LastRowIndex = GQ_Result_ParseBitmap[NbRows] - 1,

    // Where *Next*.Row = *First* row index, at the *beginning* of the table
    Next.BufferedSource.Purged = Table.RemoveFirstN(Next.BufferedSource, each [Next.Row] = FirsRowIndex),

    // Where *This*.Row = *Last*  row index, at the *ending*    of the table
    This.BufferedSource.Purged = Table.RemoveLastN( This.BufferedSource, each [This.Row] = LastRowIndex),

    // ~~~ Join ~~~
    Joined = Table.Join(This.BufferedSource.Purged, thisKeys, Next.BufferedSource.Purged, nextKeys, joinKind, JoinAlgorithm.SortMerge),
    // When keys are This.Start and Next.Start, FillDown
    // When keys are This.End   and Next.End,   FillUp
    FilledDown = Table.FillDown(Joined,{"This.Colour", "Next.Colour"}),

    // ~~~ Epilogue ~~~
    // ~ Remove reflexive relations ~ (when both colours are the same)
    FilteredSameColours = Table.SelectRows(FilledDown, each [This.Colour] <> [Next.Colour]),
    KeptColourColumns = Table.SelectColumns(FilteredSameColours,{"This.Colour", "Next.Colour"}),
    RemovedDuplicates = Table.Distinct(KeptColourColumns),

    // ~ Remove symmetrical relations ~ (A->B implies B->A, so if we already have A->B, this will remove B->A)
    AddedMinColour = Table.AddColumn(RemovedDuplicates , "MinColour", each List.Min({[This.Colour], [Next.Colour]}), type binary),
    AddedMaxColour = Table.AddColumn(AddedMinColour, "MaxColour", each List.Max({[This.Colour], [Next.Colour]}), type binary),
    KeptMinMaxColours = Table.SelectColumns(AddedMaxColour,{"MinColour", "MaxColour"}),
    RemovedMinMaxDuplicates = Table.Distinct(KeptMinMaxColours)
in
    RemovedMinMaxDuplicates