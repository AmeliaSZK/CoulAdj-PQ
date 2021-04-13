let
    Binary = Record.Field(GQ_TB_ImageBinaries, "warhammer_map_1_1_shadow" /*"sample_size_1"*/),
    Buffered = Binary.Buffer(Binary)
in
    Buffered