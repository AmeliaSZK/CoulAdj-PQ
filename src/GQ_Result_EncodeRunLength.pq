let
    Source = GQ_EncodeRunLength(GQ_Result_ParseBitmap[PixelArray.AsColours]),
    // Every time I tried to remove this buffer, the duration exploded. Leave it there.
    Buffered = Table.Buffer(Source)
in
    Buffered