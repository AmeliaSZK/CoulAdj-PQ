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
    // But answers in this StackOverflow question say that...
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
    
    ReadUntilPixelArray = BinaryFormat.Binary(UnbufferedFileHeader[OffBits]),
    BufferedHeaders = Binary.Buffer(ReadUntilPixelArray(bitmap)),
    ReadBothHeaders = BinaryFormat.Record([
        FileHeader = BITMAPFILEHEADER,
        ImageHeader = ReadImageHeader
    ]),
    Headers = ReadBothHeaders(BufferedHeaders),
    FileHeader  = Headers[FileHeader],
    ImageHeader = Headers[ImageHeader],


    /* Integrity checks */
    /*
    HeaderField          = List.Transform(List.Range(Binary.ToList(bitmap), 0, 2), Character.FromNumber), // Must be "BM"
    */

    /* Binary format functions */
    ReadSint32LE = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger32, ByteOrder.LittleEndian),
    ReadSint16LE = BinaryFormat.ByteOrder(BinaryFormat.SignedInteger16, ByteOrder.LittleEndian),
    ReadUint32LE = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger32, ByteOrder.LittleEndian),
    ReadUint16LE = BinaryFormat.ByteOrder(BinaryFormat.UnsignedInteger16, ByteOrder.LittleEndian),

    /* Important infos */
    Width                = ImageHeader[Width], 
    Height               = ImageHeader[Height], 
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
    // Positive Height is bottom-up, and negative is top-down
    // https://docs.microsoft.com/en-us/previous-versions/dd183376(v=vs.85)#members
    IsBottomUp           = 0 < Height,
    IsTopDown            = not IsBottomUp,

    NbRows = Height,
    NbCols = Width,
    MaxRow = NbRows - 1,
    MaxCol = NbCols - 1,

    /* Main Data */
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
    // Yes, the order is BGR(A). Refer to RGBQUAD and RGBTRIPLE
    RGB.Type      = type [Blue = number, Green = number, Red = number],
    RgbAlpha.Type = type [Blue = number, Green = number, Red = number, Alpha = number],

    // Regular cases
    RGB.FromRgbColour = RGBTRIPLE,
    RgbAlpha.FromRgbAlphaColour = RGBQUAD,

    // Sepcial cases
    RGB.FromRgbAlphaColour = (colour as binary) as record => Record.RemoveFields(RGBQUAD(colour), "a"),

    // The established CoulAdj API says that if it is asked to invent an alpha value, the max alpha
    //    value will be used. 
    // No link to this API, because those that are public are in languages whose libraries can't
    //    tell easily if there is an alpha channel in the source image,
    // And also, a link doesn't matter, because I'm the one who wrote the CoulAdj API(s).
    // (Hopefully, by the time this code is pulished, I will have documented the CoulAdj API for Power Query,
    //    and will have remembered to update this comment with a link or with proper function documentation.)
    RgbAlpha.FromRgbColour = (colour as binary) as record => RGBTRIPLE(colour) & [a = MaxAlphaValue],

    // MaxAlphaValue is never more than 255 because the bitmap specs only allows up to 8 bits for a component value.
    // We don't care about the values with less than 8 bits, because this Power Query parser doesn't support
    //    reading binary values that small.
    // And we don't support these values because no convenient functions in the library exists to read
    //    binary values of less than 8 bits.
    // Also, I have the sneaking suspicion that nowadays, the only use-case for BMP images that aren't
    //    24 or 32 bits per pixel is to be used internally by Windows desktop applications, and not to
    //    be stored as files.
    MaxAlphaValue = 255, 
    
    FromColourFunctions = 
        /*if Compression = BI_BITFIELDS then
            error "Image uses bit fields for encoding, and this feature is not supported."
        else if Compression <> BI_RGB then
            error "Image uses an unsupported compression method. Only uncompressed images are supported."

        else*/ if BitsPerPixel = 24 then
            [RGB      =      RGB.FromRgbColour, 
             RgbAlpha = RgbAlpha.FromRgbColour]
        else if BitsPerPixel = 32 then
            [RGB      =      RGB.FromRgbAlphaColour, 
             RgbAlpha = RgbAlpha.FromRgbAlphaColour]

        else
            error "Image has " & Number.ToText(BitsPerPixel) & " bits per pixel, and only 24 and 32 bits per pixel are supported.",

    RGB.FromColour      = FromColourFunctions[RGB],
    RgbAlpha.FromColour = FromColourFunctions[RgbAlpha],


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
        RgbAlpha.Type = RgbAlpha.Type,
        ImageHeader = ImageHeader
    ]
in
    AsRecord

in
    ParseBitmap