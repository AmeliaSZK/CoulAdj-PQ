let
    EncodeRunLength = (allPixels as table) as table =>
        Table.Group(
            allPixels, 
            {"row", "colour"}, 
            {{"Start", each List.First([col]), type number}, {"End", each List.Last([col])+1, type number}}, 
            GroupKind.Local
        )
in
    EncodeRunLength