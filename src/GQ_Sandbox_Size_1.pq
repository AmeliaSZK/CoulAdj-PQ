let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    PixelArray = Source[AllPixels],
    #"Added [r]" = Table.AddColumn(PixelArray, "r", each Source[RedFromValue]([value]), Int64.Type),
    #"Added [g]" = Table.AddColumn(#"Added [r]", "g", each Source[GreenFromValue]([value]), Int64.Type),
    #"Added [b]" = Table.AddColumn(#"Added [g]", "b", each Source[BlueFromValue]([value]), Int64.Type),
    #"Added [a]" = Table.AddColumn(#"Added [b]", "a", each Source[AlphaFromValue]([value]), Int64.Type),
    #"Removed Columns" = Table.RemoveColumns(#"Added [a]",{"value"}),
    #"Sorted Rows" = Table.Sort(#"Removed Columns",{{"row", Order.Ascending}, {"col", Order.Ascending}})
in
    #"Sorted Rows"