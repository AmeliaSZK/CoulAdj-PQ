let
    bitmap = GQ_ImageUnderTest_Binary,
    dontRelateDiagonals = GQ_DontRelateDiagonals,
    Result = GQ_CoulAdj(bitmap, dontRelateDiagonals)
in
    Result