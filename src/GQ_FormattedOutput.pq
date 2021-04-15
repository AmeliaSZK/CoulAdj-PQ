let
    DecodeColour = 
        if GQ_IncludeAlpha then 
            GQ_Result_ParseBitmap[RgbAlpha.FromColour]
        else
            GQ_Result_ParseBitmap[RGB.FromColour],
    DecodedType = 
        if GQ_IncludeAlpha then 
            GQ_Result_ParseBitmap[RgbAlpha.Type]
        else
            GQ_Result_ParseBitmap[RGB.Type],

    ColumnNames = 
        if GQ_IncludeAlpha then 
            {"r", "g", "b", "a"}
        else
            {"r", "g", "b"},
    AdjColumnNames = 
        if GQ_IncludeAlpha then 
            {"adj_r", "adj_g", "adj_b", "adj_a"}
        else
            {"adj_r", "adj_g", "adj_b"},

    Source = GQ_AllAdjacencies,
    #"Added Custom" = Table.AddColumn(Source, "decoded", each DecodeColour([colour]), (DecodedType)),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "adj_decoded", each DecodeColour([adj_colour]), (DecodedType)),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom1",{"decoded", "adj_decoded"}),
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Removed Other Columns", "decoded", ColumnNames, ColumnNames),
    #"Expanded {0}1" = Table.ExpandRecordColumn(#"Expanded {0}", "adj_decoded", ColumnNames, AdjColumnNames)
in
    #"Expanded {0}1"