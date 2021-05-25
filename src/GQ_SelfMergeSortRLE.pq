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

    // Remove reflexive relations (when both colours are the same)
    FilteredSameColours = Table.SelectRows(Joined, each [This.Colour] <> [Next.Colour]),
    KeptColourColumns = Table.SelectColumns(FilteredSameColours,{"This.Colour", "Next.Colour"}),
    RemovedDuplicates = Table.Distinct(KeptColourColumns),

    // Remove symmetrical relations (A->B implies B->A, so if we already have A->B, this will remove B->A)
    AddedMinColour = Table.AddColumn(RemovedDuplicates , "MinColour", each List.Min({[This.Colour], [Next.Colour]}), type binary),
    AddedMaxColour = Table.AddColumn(AddedMinColour, "MaxColour", each List.Max({[This.Colour], [Next.Colour]}), type binary),
    KeptMinMaxColours = Table.SelectColumns(AddedMaxColour,{"MinColour", "MaxColour"}),
    RemovedMinMaxDuplicates = Table.Distinct(KeptMinMaxColours)
in
    RemovedMinMaxDuplicates 
in
    GQ_SelfMergeSortRLE