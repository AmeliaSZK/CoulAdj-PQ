let
    DecodeColour = GQ_Result_ParseBitmap[RecordFromColour],
    DecodedType = GQ_Result_ParseBitmap[RecordFromColour.RecordType],

    ColumnNames = Record.FieldNames(Type.RecordFields(DecodedType)),
    AdjColumnNames = List.Transform(ColumnNames, each "adj_" & _),

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

    Source = GQ_AllAdjacencies,
    #"Added Custom" = Table.AddColumn(Source, "decoded", each DecodeColour([colour]), DecodedType),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "adj_decoded", each DecodeColour([adj_colour]), DecodedType),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom1",{"decoded", "adj_decoded"}),
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Removed Other Columns", "decoded", ColumnNames, ColumnNames),
    #"Expanded {0}1" = Table.ExpandRecordColumn(#"Expanded {0}", "adj_decoded", ColumnNames, AdjColumnNames),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded {0}1", ColumnRenames),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns",ColumnOrder)
in
    #"Reordered Columns"