let
    bitmap = GQ_ImageUnderTest_Binary,
    dontRelateDiagonals = true,
    Result = GQ_CoulAdj(bitmap, dontRelateDiagonals)
in
    Result