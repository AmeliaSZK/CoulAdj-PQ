let
    RecordFromColour = GQ_Result_ParseBitmap[RecordFromColour],
    RecordFromColour.RecordType = GQ_Result_ParseBitmap[RecordFromColour.RecordType],
    Source = GQ_Result_EncodeRunLength,
    #"Added Custom" = Table.AddColumn(Source, "RGBA", each RecordFromColour([colour]), RecordFromColour.RecordType),
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Added Custom", "RGBA", {"Blue", "Green", "Red", "Alpha"}, {"Blue", "Green", "Red", "Alpha"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Expanded {0}",{"row", "colour", "Start", "End", "Red", "Green", "Blue", "Alpha"})
in
    #"Reordered Columns"