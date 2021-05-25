let
    Source = GQ_EncodeRunLength(GQ_Result_ParseBitmap[PixelArray.AsColours]),
    AddedNextRowIndex = Table.AddColumn(Source, "NextRow", each [row] + 1, type number),
    #"Renamed Columns" = Table.RenameColumns(AddedNextRowIndex,{{"row", "Row"}, {"colour", "Colour"}}),
    // Every time I tried to remove this buffer, the duration exploded. Leave it there.
    Buffered = Table.Buffer(#"Renamed Columns")
in
    Buffered