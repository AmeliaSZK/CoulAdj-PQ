let
    Source = GQ_EncodeRunLength(GQ_Result_ParseBitmap[PixelArray.AsColours]),
    BufferedColours = Table.TransformColumns(Source, {"colour", Binary.Buffer}),
    Buffered = Table.Buffer(BufferedColours)
in
    Buffered