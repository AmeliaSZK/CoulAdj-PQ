let
    Source = GQ_TB_ImageBinaries[sample_size_1],
    Compressed = Binary.Compress(Source, Compression.Deflate),
    Encoded = Binary.ToText(Compressed, BinaryEncoding.Base64),
    AsText = "c/KdxcgABlVAnAPEnEDMAcSMDAoMzEBaASifyw3BCPAfhsAcRiQZYtggIHeH6xcYi1z6hoyfiXD9geBLX+BqoBghRws1lz4h42d3uH6gYHLVAMXQMSE1oHAAAA==",
    Decoded = Binary.FromText(AsText, BinaryEncoding.Base64),
    Decompressed = Binary.Decompress(Decoded, Compression.Deflate),
    Parsed = GQ_ParseBitmap(Decompressed)
in
    Parsed