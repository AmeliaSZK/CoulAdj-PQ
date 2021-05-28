let
    Name = GQ_ImageUnderTest_Name,
    Source = 
        if Name = "warhammer_map_1_1_shadow" then
            GQ_TB_GoldenBinaries[golden warhammer_map_1_1_shadow]
        else if Name = "wh2_main_great_vortex_map_6" then
            GQ_TB_GoldenBinaries[golden wh2_main_great_vortex_map_6]
        else if Name = "warhammer_map_1_1_twilight" then
            GQ_TB_GoldenBinaries[golden warhammer_map_1_1_twilight]
        else if Name = "wh2_main_great_vortex_map_7" then
            GQ_TB_GoldenBinaries[golden wh2_main_great_vortex_map_7]
        else if Text.StartsWith(Name, "sample_size_") then
            GQ_TB_GoldenBinaries[golden]
        else
            ...,
    Parsed = GQ_TB_ParseRgbAlphaTSV(Source)
in
    Parsed