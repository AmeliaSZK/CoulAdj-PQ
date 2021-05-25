let
    GQ_SelfMergeSortRLE = (
        thisKeys as list,
        nextKeys as list,
        joinKind as number
    ) as table =>
let
    // Prologue
    RLEnconded = GQ_Result_EncodeRunLength,
    Source = Table.AddColumn(RLEnconded, "NextRow", each [row] + 1, type number),
    RenamedColumnsForInput = Table.RenameColumns(Source,{{"row", "Row"}, {"colour", "Colour"}}),
    BufferedSource = Table.Buffer(RenamedColumnsForInput),
    This.BufferedSource = Table.PrefixColumns(BufferedSource, "This"),
    Next.BufferedSource = Table.PrefixColumns(BufferedSource, "Next"),

    // Join
    Joined = Table.Join(This.BufferedSource, thisKeys, Next.BufferedSource, nextKeys, joinKind, JoinAlgorithm.SortMerge),

    // Epilogue
    FilteredSameColours = Table.SelectRows(Joined, each [This.Colour] <> [Next.Colour]),
    KeptColourColumns = Table.SelectColumns(FilteredSameColours,{"This.Colour", "Next.Colour"}),
    RemovedDuplicates = Table.Distinct(KeptColourColumns),
    RenamedColumnsForOutput = Table.RenameColumns(RemovedDuplicates,{{"This.Colour", "colour"}, {"Next.Colour", "adj_colour"}})
in
    RenamedColumnsForOutput
in
    GQ_SelfMergeSortRLE