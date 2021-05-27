let
    bitmap = GQ_ImageUnderTest_Binary,
    dontRelateDiagonals = false,
    Result = GQ_CoulAdj(bitmap, dontRelateDiagonals)
in
    Result