let
    Source = 
        let
            Encoded = "c/KdxcgABlVAnAPEnEDMAcSMDAoMzEBaASifyw3BCPAfhsAcRiQZYtggIHeH6xcYi1z6hoyfiXD9geBLX+BqoBghRws1lz4h42d3uH6gYHLVAMXQMSE1oHAAAA==",
            Decoded = Binary.FromText(Encoded, BinaryEncoding.Base64),
            Decompressed = Binary.Decompress(Decoded, Compression.Deflate)
        in
            Decompressed,

    Adjacencies = GQ_CoulAdj(Source, true)
in
    Adjacencies