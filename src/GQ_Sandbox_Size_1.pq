let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    PixelArray = Source[PixelArray],
    NbBytesToSkip = Source[BytesPerPixel] - 1,
    NbBytesToKeep = 1,
    FirstSkippedByteIndex = 1, // This way, byte at index 0 is always kept
    BluOffset = 0, 
    GreOffset = 1,
    RedOffset = 2,
    AlpOffset = 3,
    BluChannel = List.Alternate(List.Skip(PixelArray, BluOffset), NbBytesToSkip, NbBytesToKeep, FirstSkippedByteIndex),
    GreChannel = List.Alternate(List.Skip(PixelArray, GreOffset), NbBytesToSkip, NbBytesToKeep, FirstSkippedByteIndex),
    RedChannel = List.Alternate(List.Skip(PixelArray, RedOffset), NbBytesToSkip, NbBytesToKeep, FirstSkippedByteIndex),
    AlpChannel = List.Alternate(List.Skip(PixelArray, AlpOffset), NbBytesToSkip, NbBytesToKeep, FirstSkippedByteIndex),
    RowIndices = {0..Source[MaxRowIndex]},
    ColIndices = {0..Source[MaxColIndex]},
    IndicesAsTable = Table.FromColumns({{RowIndices}, {ColIndices}}, {"Row", "Col"}),
    ExpandedRowIndices = Table.ExpandListColumn(IndicesAsTable, "Row"),
    ExpandedColIndices = Table.ExpandListColumn(ExpandedRowIndices, "Col"),
    AllRowIndices = Table.Column(ExpandedColIndices, "Row"),
    AllColIndices = Table.Column(ExpandedColIndices, "Col"),
    AsTable = Table.FromColumns({AllRowIndices, AllColIndices, RedChannel, GreChannel, BluChannel, AlpChannel}, type table[row = Int64.Type, col = Int64.Type, r = Int64.Type, g = Int64.Type, b = Int64.Type, a = Int64.Type])
in
    AsTable