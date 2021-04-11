let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    #"Converted to Table" = Record.ToTable(Source)
in
    #"Converted to Table"