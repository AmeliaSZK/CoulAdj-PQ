let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    PixelArray = Source[PixelArray],
    RedChannel = List.Alternate(PixelArray, 3, 1, 1)
in
    RedChannel