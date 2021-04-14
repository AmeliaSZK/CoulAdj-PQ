let
    ParseBitmap = (bitmap as binary) as record =>

let 
    /* Integrity checks */
    /*
    HeaderField          = List.Transform(List.Range(Binary.ToList(bitmap), 0, 2), Character.FromNumber), // Must be "BM"
    HeaderSize           = ReadUint32LE(Binary.Range(bitmap, 14, 4)), // Must be 40
    */

    /* Binary format functions */
    ReadSint32LE = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian),
    ReadSint16LE = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger16, ByteOrder.LittleEndian),
    ReadUint32LE = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
    ReadUint16LE = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian),

    /* Important infos */
    Width                = ReadSint32LE(Binary.Range(bitmap, 18, 4)), 
    Height               = ReadSint32LE(Binary.Range(bitmap, 22, 4)), 
    BitsPerPixel         = ReadUint16LE(Binary.Range(bitmap, 28, 2)),
    BytesPerPixel        = BitsPerPixel / 8,
    NbOfPixels           = ReadUint32LE(Binary.Range(bitmap, 34, 4)),
    PixelArrayOffset     = ReadUint32LE(Binary.Range(bitmap, 10, 4)),
    PixelArraySize       = NbOfPixels * BytesPerPixel,
    HasAlpha             = (BytesPerPixel = 4),

    NbRows = Height,
    NbCols = Width,
    MaxRow = NbRows - 1,
    MaxCol = NbCols - 1,

    /* Main Data */
    FileBytes = Binary.ToList(bitmap),
    PixelArray = Binary.Range(bitmap, PixelArrayOffset, PixelArraySize),
    ReadPixelArray = BinaryFormat.List(BinaryFormat.Binary(BytesPerPixel)),
    PixelValues = ReadPixelArray(PixelArray),

    /* Conversion Functions */
    BluFromColour = (colour as binary) => BinaryFormat.Byte(Binary.Range(colour, 0, 1)),
    GreFromColour = (colour as binary) => BinaryFormat.Byte(Binary.Range(colour, 1, 1)),
    RedFromColour = (colour as binary) => BinaryFormat.Byte(Binary.Range(colour, 2, 1)),
    AlpFromColour = 
        if HasAlpha then
            (colour as binary) => BinaryFormat.Byte(Binary.Range(colour, 3, 1))
        else
            (colour as binary) => 255,

    Colour.Type   = type binary,
    RGB.Type      = type [r = number, g = number, b = number],
    RgbAlpha.Type = type [r = number, g = number, b = number, a = number],

    RGB.FromColour = (colour as binary) as record => [
        r = RedFromColour(colour),
        g = GreFromColour(colour),
        b = BluFromColour(colour)
    ],
    RgbAlpha.FromColour = (colour as binary) as record => [
        r = RedFromColour(colour),
        g = GreFromColour(colour),
        b = BluFromColour(colour),
        a = AlpFromColour(colour)
    ],


    /* Coordinates */
    // BMP specs say bottom row comes first
    RowIndices = List.Numbers(MaxRow, NbRows, -1),
    ColIndices = List.Numbers(     0, NbCols,  1),
    AllRowIndices = List.Combine(List.Transform(RowIndices, each List.Repeat({_}, NbCols))),
    AllColIndices = List.Repeat(ColIndices, NbRows),

    /* As Table */
    AllPixels = Table.FromColumns({AllRowIndices, AllColIndices, PixelValues}, 
        type table[row = number, col = number, colour = Colour.Type]),
    
    AsRecord = 
    [
        //MaxRow = MaxRow,
        //MaxCol = MaxCol,
        //BytesPerPixel = BytesPerPixel,
        NbPixels = NbOfPixels,
        NbRows = NbRows,
        NbCols = NbCols,
        HasAlpha = HasAlpha,
        PixelArray.AsColours = AllPixels,
        Colour.Type = Colour.Type,
        RGB.FromColour = RGB.FromColour,
        RGB.Type = RGB.Type,
        RgbAlpha.FromColour = RgbAlpha.FromColour,
        RgbAlpha.Type = RgbAlpha.Type
    ]
in
    AsRecord

in
    ParseBitmap