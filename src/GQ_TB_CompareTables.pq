let
    GoldenResults = GQ_TB_ImageUnderTest_Golden,
    ActualResults.Unsorted = GQ_TB_CoulAdj,
    ActualResults = Table.Sort(ActualResults.Unsorted,{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}}),
    Golden_AsRecords = Table.ToRecords(GoldenResults),
    Actual_AsRecords = Table.ToRecords(ActualResults),
    AsTable = Table.FromColumns({Actual_AsRecords, Golden_AsRecords}, type table[Actual = record, Golden = record]),
    #"Added [Same?]" = Table.AddColumn(AsTable, "Same?", each [Actual] = [Golden], type logical)
in
    #"Added [Same?]"