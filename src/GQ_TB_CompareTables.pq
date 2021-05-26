let
    GoldenResults = GQ_ImageUnderTest_Golden,
    ActualResults = GQ_TB_CoulAdj,
    #"Sorted Rows" = Table.Sort(ActualResults,{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}}),
    Table1_AsRecords = Table.ToRecords(GoldenResults),
    Table2_AsRecords = Table.ToRecords(#"Sorted Rows"),
    AsTable = Table.FromColumns({Table1_AsRecords, Table2_AsRecords}, type table[Table1 = record, Table2 = record]),
    #"Added [Same?]" = Table.AddColumn(AsTable, "Same?", each [Table1] = [Table2], type logical)
in
    #"Added [Same?]"