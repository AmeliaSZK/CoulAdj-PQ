//let
//    ParseBitmap = (bitmap as binary) as record =>

let 
    bitmap = GQ_TB_Binary_Size_1,

    /* Integrity checks */
    /*
    HeaderField          = List.Transform(List.Range(Binary.ToList(bitmap), 0, 2), Character.FromNumber), // Must be "BM"
    HeaderSize           = ReadUint32LE(Binary.Range(bitmap, 14, 4)), // Must be 40
    */

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
    BlueFromValue  = (value as binary) => BinaryFormat.Byte(Binary.Range(value, 0, 1)),
    GreenFromValue = (value as binary) => BinaryFormat.Byte(Binary.Range(value, 1, 1)),
    RedFromValue   = (value as binary) => BinaryFormat.Byte(Binary.Range(value, 2, 1)),
    AlphaFromValue = 
        if HasAlpha then
            (value as binary) => BinaryFormat.Byte(Binary.Range(value, 3, 1))
        else
            (value as binary) => null,

    /* Coordinates */
    // BMP specs say bottom row comes first
    RowIndices = List.Numbers(MaxRow, NbRows, -1),
    ColIndices = List.Numbers(     0, NbCols,  1),
    AllRowIndices = List.Combine(List.Transform(RowIndices, each List.Repeat({_}, NbCols))),
    AllColIndices = List.Repeat(ColIndices, NbRows),

    /* As Table */
    AllPixels = Table.FromColumns({AllRowIndices, AllColIndices, PixelValues}, 
        type table[row = Int64.Type, col = Int64.Type, value = binary]),
    
    AsRecord = 
    [
        Width = Width,
        Height = Height,
        NbRows = NbRows,
        NbCols = NbCols,
        MaxRow = MaxRow,
        MaxCol = MaxCol,
        BytesPerPixel = BytesPerPixel,
        NbPixels = NbOfPixels,
        HasAlpha = HasAlpha,
        PixelArraySize = PixelArraySize,
        PixelArray = PixelArray,
        PixelValues = PixelValues
    ],
    PixelValues1 = AsRecord[PixelValues],
    #"Converted to Table" = Table.FromList(PixelValues1, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Renamed Columns" = Table.RenameColumns(#"Converted to Table",{{"Column1", "Value"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns", "Red", each RedFromValue([Value])),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "Green", each GreenFromValue([Value])),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "Blue", each BlueFromValue([Value])),
    #"Added Custom3" = Table.AddColumn(#"Added Custom2", "Alpha", each AlphaFromValue([Value]))
in
    #"Added Custom3"

//in
//    ParseBitmap