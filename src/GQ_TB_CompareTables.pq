let
    Source = "",
    table1 = GQ_TB_Golden_SizedSamples,
    table2 = GQ_FormattedOutput,
    Table1_AsRecords = Table.ToRecords(table1),
    Table2_AsRecords = Table.ToRecords(table2),
    AsTable = Table.FromColumns({Table1_AsRecords, Table2_AsRecords}, type table[Table1 = record, Table2 = record]),
    #"Added [Same?]" = Table.AddColumn(AsTable, "Same?", each [Table1] = [Table2], type logical)
in
    #"Added [Same?]"