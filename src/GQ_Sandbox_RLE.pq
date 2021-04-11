let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    AllPixels = Source[AllPixels],
    #"Grouped Rows" = Table.Group(AllPixels, {"row"}, {{"All Rows", each _, type table [row=number, col=number, value=binary]}}),
    #"7" = #"Grouped Rows"{[row=7]}[All Rows],
    #"Grouped Rows1" = Table.Group(#"7", {"value"}, {{"Count", each Table.RowCount(_), Int64.Type}, {"Start", each List.Min([col]), Int64.Type}}, GroupKind.Local),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows1", "End", each [Count] + [Start], Int64.Type)
in
    #"Added Custom"