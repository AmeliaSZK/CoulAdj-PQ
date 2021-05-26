let
    ParseBitmap = (bitmap as binary) as record =>

let 
    /* DATA TYPES */
    // Number of bits and signedness:
    //    https://docs.microsoft.com/en-ca/windows/win32/learnwin32/windows-coding-conventions#integer-types
    // For the little-endian byte order, the only source I found was the wikipedia :/
    //    https://en.wikipedia.org/wiki/BMP_file_format#Bitmap_file_header
    //    "All of the integer values are stored in little-endian format (i.e. least-significant byte first)."
    BYTE      = BinaryFormat.ByteOrder(BinaryFormat.Byte,              ByteOrder.LittleEndian),
    DWORD     = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
    INT32     = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32,   ByteOrder.LittleEndian),
    INT64     = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64,   ByteOrder.LittleEndian),
    LONG      = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32,   ByteOrder.LittleEndian),
    LONGLONG  = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger64,   ByteOrder.LittleEndian),
    UINT32    = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
    UINT64    = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger64, ByteOrder.LittleEndian),
    ULONG     = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
    ULONGLONG = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger64, ByteOrder.LittleEndian),
    WORD      = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian),
    // While not all of these will be needed, I wrote them all to make verification easier


    /* CONSTANTS */
    /* Compression Methods */
    // https://en.wikipedia.org/wiki/BMP_file_format#DIB_header_(bitmap_information_header)
    //    You'll need to scroll a bit down to find the table.
    // Again, I couldn't find any Microsoft webpage with this information.
    //    If I understood my web searches correctly, the official source is a .h file
    //        that comes with the Windows SDK from Visual Studio. This is like tens of gigabytes
    //        of downloads.
    //    Aside from the Wikipedia, other websites that list the values of Windows constants
    //        looked like they came from the 90s. 
    BI_RGB            = 0,
    BI_RLE8           = 1,
    BI_RLE4           = 2,
    BI_BITFIELDS      = 3,
    BI_JPEG           = 4,
    BI_PNG            = 5,
    BI_ALPHABITFIELDS = 6,
    BI_CMYK           = 11,
    BI_CMYKRLE8       = 12,
    BI_CMYKRLE4       = 13,


    /* STRUCTURES */
    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapfileheader#syntax
    BITMAPFILEHEADER = BinaryFormat.Record([
        Type      = WORD,
        Size      = DWORD,
        Reserved1 = WORD,
        Reserved2 = WORD,
        OffBits   = DWORD
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapcoreheader
    BITMAPCOREHEADER = BinaryFormat.Record([
        Size     = DWORD,
        Width    = WORD,
        Height   = WORD,
        Planes   = WORD,
        BitCount = WORD
    ]),

    // https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)
    BITMAPINFOHEADER = BinaryFormat.Record([
        Size          = DWORD,
        Width         = LONG,
        Height        = LONG,
        Planes        = WORD,
        BitCount      = WORD,
        Compression   = DWORD,
        SizeImage     = DWORD,
        XPelsPerMeter = LONG,
        YPelsPerMeter = LONG,
        ClrUsed       = DWORD,
        ClrImportant  = DWORD
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv4header
    // The Endpoints field is of type CIEXYZTRIPLE, which contains values of type CIEXYZ,
    //    which contains values of type FXPT2DOT30. 
    // https://stackoverflow.com/a/39374931
    BITMAPV4HEADER = BinaryFormat.Record([
        Size          = DWORD,
        Width         = LONG,
        Height        = LONG,
        Planes        = WORD,
        BitCount      = WORD,
        Compression   = DWORD,
        SizeImage     = DWORD,
        XPelsPerMeter = LONG,
        YPelsPerMeter = LONG,
        ClrUsed       = DWORD,
        ClrImportant  = DWORD,

        RedMask    = DWORD,
        GreenMask  = DWORD,
        BlueMask   = DWORD,
        AlphaMask  = DWORD,
        CSType     = DWORD,
        Endpoints  = CIEXYZTRIPLE,
        GammaRed   = DWORD,
        GammaGreen = DWORD,
        GammaBlue  = DWORD
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-bitmapv5header
    BITMAPV5HEADER = BinaryFormat.Record([
        Size          = DWORD,
        Width         = LONG,
        Height        = LONG,
        Planes        = WORD,
        BitCount      = WORD,
        Compression   = DWORD,
        SizeImage     = DWORD,
        XPelsPerMeter = LONG,
        YPelsPerMeter = LONG,
        ClrUsed       = DWORD,
        ClrImportant  = DWORD,

        RedMask    = DWORD,
        GreenMask  = DWORD,
        BlueMask   = DWORD,
        AlphaMask  = DWORD,
        CSType     = DWORD,
        Endpoints  = CIEXYZTRIPLE,
        GammaRed   = DWORD,
        GammaGreen = DWORD,
        GammaBlue  = DWORD,

        Intent      = DWORD,
        ProfileData = DWORD,
        ProfileSize = DWORD,
        Reserved    = DWORD
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-ciexyztriple
    CIEXYZTRIPLE = BinaryFormat.Record([
        ciexyzRed   = CIEXYZ,
        ciexyzGreen = CIEXYZ,
        ciexyzBlue  = CIEXYZ
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-ciexyz
    CIEXYZ = BinaryFormat.Record([
        ciexyzX = FXPT2DOT30,
        ciexyzY = FXPT2DOT30,
        ciexyzZ = FXPT2DOT30
    ]),

    // I found no Microsoft reference for what the FXPT2DOT30 is.
    // But I found a StackOverflow question: https://stackoverflow.com/questions/20864752/how-is-defined-the-data-type-fxpt2dot30-in-the-bmp-file-structure
    // And the answers in this StackOverflow question say that...
    //    1) It's a fixed-point value with a 2-bit integer part and 30-bit fractional part
    //    2) Someone wrote an unpacked version and assigned them to LONG.
    // LONG is a signed type, and I am dubious that one of the two integer bits would be used as the sign bit.
    // However, what's clear is that this is a 32-bit value, and part of the point of these BinaryFormat.Record is
    //    to get a correct count of bytes to extract.
    // Also, I really don't give a flying chicken about these advanced CIEXYZ fields, I didn't even look-up what they
    //    do, and I don't expect them to be ever needed by a bitmap parser written in Power Query.
    // Anywayz, I didn't use LONG because LONG means signed integer, and that's not what a 2.30 fixed-point is.
    FXPT2DOT30 = BinaryFormat.ByteOrder(BinaryFormat.Binary(4), ByteOrder.LittleEndian),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbquad
    // I renamed the Reserved to Alpha, because in practice that's what it is.
    RGBQUAD = BinaryFormat.Record([
        Blue  = BYTE,
        Green = BYTE,
        Red   = BYTE,
        Alpha = BYTE
    ]),

    // https://docs.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-rgbtriple
    RGBTRIPLE = BinaryFormat.Record([
        Blue  = BYTE,
        Green = BYTE,
        Red   = BYTE
    ]),

    
    /* HEADER SIZES (in bytes) */
    // These numbers are from the Wikipedia, because I didn't find a Microsoft source.
    // I think that Microsoft didn't bother, because when you're programming in C (and C++?),
    //    you can just do `sizeof(BITMAPINFOHEADER)` to get the size of the structure.
    // Technically, you could probably write a Power Query function that would take a BinaryFormat
    //    and return the amount of bytes it's going to read, but that felt like a waste of a lot of time.
    // https://en.wikipedia.org/wiki/BMP_file_format#DIB_header_(bitmap_information_header)
    AllHeaderSizes = [
        BITMAPCOREHEADER = 12,
        BITMAPINFOHEADER = 40,
        BITMAPV4HEADER   = 108,
        BITMAPV5HEADER   = 124
    ],

    
    /* PARSING */
    // We need the Size to know which header format to parse next.
    ReadFileHeaderAndNextHeaderSize = BinaryFormat.Record([
        FileHeader = BITMAPFILEHEADER,
        Size = DWORD
    ]),
    FileHeaderAndNextHeaderSize = ReadFileHeaderAndNextHeaderSize(bitmap),
    UnbufferedFileHeader = FileHeaderAndNextHeaderSize[FileHeader],
    Size = FileHeaderAndNextHeaderSize[Size],
    
    ReadImageHeader =
        if Size = AllHeaderSizes[BITMAPCOREHEADER] then
            BITMAPCOREHEADER
        else if Size = AllHeaderSizes[BITMAPINFOHEADER] then
            BITMAPINFOHEADER
        else if Size = AllHeaderSizes[BITMAPV4HEADER] then
            BITMAPV4HEADER
        else if Size = AllHeaderSizes[BITMAPV5HEADER] then
            BITMAPV5HEADER
        else
            error "Unrecognized bitmap format; Headers of size " & Number.ToText(Size) & " are not supported.",
    
    ReadUntilPixelArrayStarts = BinaryFormat.Binary(UnbufferedFileHeader[OffBits]),
    BufferedHeaders = Binary.Buffer(ReadUntilPixelArrayStarts(bitmap)),
    ReadBothHeaders = BinaryFormat.Record([
        FileHeader = BITMAPFILEHEADER,
        ImageHeader = ReadImageHeader
    ]),
    Headers = ReadBothHeaders(BufferedHeaders),
    FileHeader  = Headers[FileHeader],
    ImageHeader = Headers[ImageHeader],


    /* Important infos */
    Width                = ImageHeader[Width], 
    Height               = Number.Abs(ImageHeader[Height]), 
    // Positive Height is bottom-up, and negative is top-down
    // https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)#members
    IsBottomUp           = 0 < ImageHeader[Height],
    IsTopDown            = not IsBottomUp,

    BitsPerPixel         = ImageHeader[BitCount], 
    BytesPerPixel        = BitsPerPixel / 8,
    NbOfPixels           = Width * Height,
    PixelArrayOffset     = FileHeader[OffBits],
    // BITMAPCOREHEADER doesn't have the Compression field
    Compression          = Record.FieldOrDefault(ImageHeader, "Compression", BI_RGB), 
    // Do NOT use the ImageHeader[SizeImage] to  get PixelArraySize, because:
    //    1) The intended input had incorrectly put the size in PIXELS, instead of BYTES, in that field
    //    2) And anyway, the specs say that you can put zero in this field with BI_RGB compression
    PixelArraySize       = NbOfPixels * BytesPerPixel, 
    HasAlpha             = (BytesPerPixel = 4),


    NbRows = Height,
    NbCols = Width,
    MaxRow = NbRows - 1,
    MaxCol = NbCols - 1,


    /* Conversion To Record */
    // I tried to make RecordFromColour reorder the fields to RGB(A),
    //    but it showed a consistent & noticeable performance cost in tests.
    //    (From 1m35s to 1m41s.)
    RecordFromColour = 
        if BitsPerPixel = 24 then
            RGBTRIPLE
        else if BitsPerPixel = 32 then
            RGBQUAD
        else
            error ErrorMessage.BitsPerPixel,
    RecordFromColour.RecordType =
        if BitsPerPixel = 24 then
            RGB.Type
        else if BitsPerPixel = 32 then
            RgbAlpha.Type
        else
            error ErrorMessage.BitsPerPixel,

    // Yes, the order is BGR(A) per bitmap specs
    RGB.Type      = type [Blue = number, Green = number, Red = number],
    RgbAlpha.Type = type [Blue = number, Green = number, Red = number, Alpha = number],

    /* Error messages */
    // These were rescued from removed code
    ErrorMessage.Compression = "Image uses an unsupported compression method. Only uncompressed images are supported.",
    ErrorMessage.BitsPerPixel = 
        "Image has " & Number.ToText(BitsPerPixel) & " bits per pixel, and only 24 and 32 bits per pixel are supported.",
    

    /* Main Data */
    PixelArray = Binary.Range(bitmap, PixelArrayOffset, PixelArraySize),
    ReadPixelArray = BinaryFormat.List(BinaryFormat.Binary(BytesPerPixel)),
    PixelValues = ReadPixelArray(PixelArray),

    /* Coordinates */
    // Wether image is bottom-up or top-down, BMP specs make sure that 
    // the first row in the file is #0.
    RowIndices = List.Numbers(0, NbRows, 1),
    ColIndices = List.Numbers(0, NbCols, 1),
    AllRowIndices = List.Combine(List.Transform(RowIndices, each List.Repeat({_}, NbCols))),
    AllColIndices = List.Repeat(ColIndices, NbRows),

    /* As Table */
    AllPixels = Table.FromColumns({AllRowIndices, AllColIndices, PixelValues}, 
        type table[Row Index = number, Column Index = number, Colour = binary]),
    
    AsRecord = 
    [
        NbPixels = NbOfPixels,
        NbRows = NbRows,
        NbCols = NbCols,
        HasAlpha = HasAlpha,
        BytesPerPixel = BytesPerPixel,
        IsBottomUp = IsBottomUp,
        IsTopDown = IsTopDown,
        PixelArray.AsColours = AllPixels,
        RecordFromColour = RecordFromColour,
        RecordFromColour.RecordType = RecordFromColour.RecordType,
        ImageHeader = ImageHeader
    ]
in
    AsRecord

in
    ParseBitmap