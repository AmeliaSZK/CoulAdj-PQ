let
    ParseBitmap = (bitmap as binary) as record =>

let 
    FileBytes = Binary.ToList(bitmap),

    /* Integrity checks */
    /*
    HeaderField          = List.Transform(List.Range(FileBytes, 0, 2), Character.FromNumber), // Must be "BM"
    HeaderSize           = BytesToNumber(List.Range(FileBytes, 14, 4)), // Must be 40
    */

    BytesToNumber = (bytes as list) as number => 
        let
            /* This implementation is slow, but it'll only matter if you call it millions of time. 
               (which is why it's hidden inside another function) 
               (Also, <(r, g, b) => r + g*256 + b*65536> is the fastest I've found to convert 3 bytes to a number.) */
            Accumulated = 
                List.Accumulate(
                    bytes,
                    [i = 0, Sum = 0],
                    (state, current) =>
                        [
                            i = state[i] + 1,
                            Sum = state[Sum] + ByteToDigit(current, state[i])
                        ]
                ),

            ByteToDigit = (byte as number, position as number) as number => 
                Number.BitwiseShiftLeft(byte, position*8)
        in
            Accumulated[Sum],

    /* Important infos */
    Width                = BytesToNumber(List.Range(FileBytes, 18, 4)), 
    Height               = BytesToNumber(List.Range(FileBytes, 22, 4)), 
    BitsPerPixel         = BytesToNumber(List.Range(FileBytes, 28, 2)),
    BytesPerPixel        = BitsPerPixel / 8,
    NbOfPixels           = BytesToNumber(List.Range(FileBytes, 34, 4)),
    PixelArrayOffset     = BytesToNumber(List.Range(FileBytes, 10, 4)),
    PixelArraySize       = NbOfPixels * BytesPerPixel,

    /* Main Data */
    PixelArray = List.Range(FileBytes, PixelArrayOffset, PixelArraySize),
    
    AsRecord = 
    [
        Width = Width,
        Height = Height,
        NbRows = Height,
        NbCols = Width,
        MaxRowIndex = NbRows - 1,
        MaxColIndex = NbCols - 1,
        BytesPerPixel = BytesPerPixel,
        NbPixels = NbOfPixels,
        HasAlpha = (BytesPerPixel = 4),
        PixelArraySize = PixelArraySize,
        PixelArray = PixelArray
    ]    
    
in
    AsRecord

in
    ParseBitmap