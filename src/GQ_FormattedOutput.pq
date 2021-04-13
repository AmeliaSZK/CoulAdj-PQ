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
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Removed Other Columns", "decoded", {"r", "g", "b", "a"}, ColumnNames),
    #"Expanded {0}1" = Table.ExpandRecordColumn(#"Expanded {0}", "adj_decoded", {"r", "g", "b", "a"}, AdjColumnNames),
    #"Sorted Rows" = Table.Sort(#"Expanded {0}1",{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}})
in
    #"Sorted Rows"