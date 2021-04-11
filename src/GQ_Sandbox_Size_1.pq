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
    AlpChannel = List.Alternate(List.Skip(PixelArray, AlpOffset), NbBytesToSkip, NbBytesToKeep, FirstSkippedByteIndex)
in
    AlpChannel