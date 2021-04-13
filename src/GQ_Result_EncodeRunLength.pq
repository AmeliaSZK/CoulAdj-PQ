let
    Source = GQ_EncodeRunLength(GQ_Result_ParseBitmap[PixelArray.AsColours]),
    Buffered = Table.Buffer(Source)
in
    Buffered