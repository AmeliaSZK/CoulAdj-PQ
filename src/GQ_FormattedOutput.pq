let
    // The CoulAdj API specifies the column names and the order in which they appear, and these names
    //    are different from what ParseBitmap returns.
    ColumnRenames =
    if GQ_Result_ParseBitmap[HasAlpha] then
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
    if GQ_Result_ParseBitmap[HasAlpha] then
        {"r", "g", "b", "a", "adj_r", "adj_g", "adj_b", "adj_a"}
    else
        {"r", "g", "b", "adj_r", "adj_g", "adj_b"},

    RecordFromColour = GQ_Result_ParseBitmap[RecordFromColour],
    RecordFromColour.RecordType = GQ_Result_ParseBitmap[RecordFromColour.RecordType],

    FieldNames = Record.FieldNames(Type.RecordFields(RecordFromColour.RecordType)),
    ColumnNames = FieldNames,
    AdjColumnNames = List.Transform(ColumnNames, each "adj_" & _),

    Source = GQ_AllAdjacencies,
    AddedDecoded = Table.AddColumn(Source, "decoded", each RecordFromColour([colour]), RecordFromColour.RecordType),
    AddedAdjDecoded = Table.AddColumn(AddedDecoded, "adj_decoded", each RecordFromColour([adj_colour]), RecordFromColour.RecordType),
    KeptDecodedColumns = Table.SelectColumns(AddedAdjDecoded,{"decoded", "adj_decoded"}),
    ExpandedDecoded = Table.ExpandRecordColumn(KeptDecodedColumns, "decoded", FieldNames, ColumnNames),
    ExpandedAdjDecoded = Table.ExpandRecordColumn(ExpandedDecoded, "adj_decoded", FieldNames, AdjColumnNames),
    RenamedColumnsPerCoulAdjAPI = Table.RenameColumns(ExpandedAdjDecoded, ColumnRenames),
    ReorderedColumnsPerCoulAdjAPI = Table.ReorderColumns(RenamedColumnsPerCoulAdjAPI, ColumnOrder)
in
    ReorderedColumnsPerCoulAdjAPI