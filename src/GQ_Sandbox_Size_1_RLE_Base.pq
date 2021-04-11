let
    DontRelateDiagonals = false,
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    RLEncoded = Table.Buffer(GQ_EncodeRunLength(Source[AllPixels]))
in
    RLEncoded