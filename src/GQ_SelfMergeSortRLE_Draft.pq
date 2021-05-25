let
    // Debug
    RecordFromColour = GQ_Result_ParseBitmap[RecordFromColour],
    RecordFromColour.RecordType = GQ_Result_ParseBitmap[RecordFromColour.RecordType],

    // Parameters
    thisKeys = {"This.NextRow", "This.Start"} as any,
    nextKeys = {"Next.Row", "Next.Start"} as any,
    joinKind = JoinKind.FullOuter as number,

    // Prologue
    RLEnconded = GQ_Result_EncodeRunLength,
    This.BufferedSource = Table.PrefixColumns(RLEnconded, "This"),
    Next.BufferedSource = Table.PrefixColumns(RLEnconded, "Next"),

    // Join
    Joined = Table.Join(This.BufferedSource, thisKeys, Next.BufferedSource, nextKeys, joinKind, JoinAlgorithm.SortMerge),
    Filled = 
        if joinKind = JoinKind.Inner then
            Joined
        else if joinKind = JoinKind.FullOuter then
            if List.ContainsAll(thisKeys & nextKeys, {"This.Start", "Next.Start"}) then
                Table.RemoveFirstN(Table.FillDown(Joined,{"This.Colour", "Next.Colour"}), each [This.Colour] is null)
            else if List.ContainsAll(thisKeys & nextKeys, {"This.End", "Next.End"}) then
                Table.RemoveLastN( Table.FillUp(  Joined,{"This.Colour", "Next.Colour"}), each [Next.Colour] is null)
            else
                error "Are you SURE you want a full outer join on This.Start & Next.End or This.End & Next.Start ? "
                      & "If so, you'll need to modify the source code, because I didn't account for this possibility."
        else
            error "Support for join kinds other than Inner or FullOuter has not been implemented.",

    // Debug
    FilledDown = Table.FillDown(Joined,{"This.Colour", "Next.Colour"}),
    RemovedNulls = Table.RemoveFirstN(FilledDown,  each [This.Colour] is null),

    // Remove reflexive relations (when both colours are the same)
    FilteredSameColours = Table.SelectRows(RemovedNulls, each [This.Colour] <> [Next.Colour]),
    #"Added Custom3" = Table.AddColumn(FilteredSameColours, "This", each RecordFromColour([This.Colour]), RecordFromColour.RecordType),
    #"Expanded {0}3" = Table.ExpandRecordColumn(#"Added Custom3", "This", {"Alpha"}, {"This.Alpha"}),
    #"Added Custom2" = Table.AddColumn(#"Expanded {0}3", "Next", each RecordFromColour([Next.Colour]), RecordFromColour.RecordType),
    #"Expanded {0}2" = Table.ExpandRecordColumn(#"Added Custom2", "Next", {"Alpha"}, {"Next.Alpha"}),
    KeptColourColumns = Table.SelectColumns(#"Expanded {0}2",{"This.Colour", "Next.Colour"}),
    RemovedDuplicates = Table.Distinct(KeptColourColumns),

    // Remove symmetrical relations (A->B implies B->A, so if we already have A->B, this will remove B->A)
    AddedMinColour = Table.AddColumn(RemovedDuplicates , "MinColour", each List.Min({[This.Colour], [Next.Colour]}), type binary),
    AddedMaxColour = Table.AddColumn(AddedMinColour, "MaxColour", each List.Max({[This.Colour], [Next.Colour]}), type binary),
    KeptMinMaxColours = Table.SelectColumns(AddedMaxColour,{"MinColour", "MaxColour"}),
    RemovedMinMaxDuplicates = Table.Distinct(KeptMinMaxColours),
    #"Added Custom" = Table.AddColumn(RemovedMinMaxDuplicates, "Min", each RecordFromColour([MinColour]), RecordFromColour.RecordType),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Max", each RecordFromColour([MaxColour]), RecordFromColour.RecordType),
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Added Custom1", "Min", {"Blue", "Green", "Red", "Alpha"}, {"Min.Blue", "Min.Green", "Min.Red", "Min.Alpha"}),
    #"Expanded {0}1" = Table.ExpandRecordColumn(#"Expanded {0}", "Max", {"Blue", "Green", "Red", "Alpha"}, {"Max.Blue", "Max.Green", "Max.Red", "Max.Alpha"})
in
    #"Expanded {0}1"