let
    Source = "",
    table1 = GQ_TB_Golden_MortalEmpire,
    table2 = GQ_FormattedOutput,
    #"Sorted Rows" = Table.Sort(table2,{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}}),
    Table1_AsRecords = Table.ToRecords(table1),
    Table2_AsRecords = Table.ToRecords(#"Sorted Rows"),
    AsTable = Table.FromColumns({Table1_AsRecords, Table2_AsRecords}, type table[Table1 = record, Table2 = record]),
    #"Added [Same?]" = Table.AddColumn(AsTable, "Same?", each [Table1] = [Table2], type logical)
in
    #"Added [Same?]"