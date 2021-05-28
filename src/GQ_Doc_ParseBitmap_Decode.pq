let
    Source = 
        let
            Encoded = "c/KdxcgABlVAnAPEnEDMAcSMDAoMzEBaASifyw3BCPAfhsAcRiQZYtggIHeH6xcYi1z6hoyfiXD9geBLX+BqoBghRws1lz4h42d3uH6gYHLVAMXQMSE1oHAAAA==",
            Decoded = Binary.FromText(Encoded, BinaryEncoding.Base64),
            Decompressed = Binary.Decompress(Decoded, Compression.Deflate)
        in
            Decompressed,
    Parsed = GQ_ParseBitmap(Source),
    PixelArray = Parsed[PixelArray.AsColours],

    Decoded = Table.AddColumn(PixelArray, "Decoded", each Parsed[RecordFromColour]([Colour]), Parsed[RecordFromColour.RecordType]),

    Expanded = Table.ExpandRecordColumn(Decoded, "Decoded", {"Blue", "Green", "Red", "Alpha"})
in
    Expanded