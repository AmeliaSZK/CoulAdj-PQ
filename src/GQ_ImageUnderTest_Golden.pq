let
    Name = GQ_ImageUnderTest_Name,
    Source = 
        if Name = "warhammer_map_1_1_shadow" then
            GQ_TB_Golden_MortalEmpire
        else if Name = "wh2_main_great_vortex_map_6" then
            GQ_TB_Golden_Vortex
        else if Text.StartsWith(Name, "sample_size_") then
            GQ_TB_Golden_SizedSamples
        else
            ...
in
    Source