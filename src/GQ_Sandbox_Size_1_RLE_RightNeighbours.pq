let
    DontRelateDiagonals = false,
    RLEncoded = GQ_Sandbox_Size_1_RLE_Base,
    #"Removed Other Columns" = Table.SelectColumns(RLEncoded,{"row", "value"}),
    #"Grouped Rows" = Table.Group(#"Removed Other Columns", {"row"}, {{"Segments", each _, type table [row=number, value=nullable binary]}}),

    ProcessSubtable = (table as table) as table =>
let
    Segments = List.Buffer(Table.Column(table, "value")),
    Consecutives = Table.FromColumns(
        {Segments, List.Skip(Segments, 1)},
        type table[value = binary, adj_value = binary]
    ),
    RemovedLastRow = Table.RemoveLastN(Consecutives,1)
in
    RemovedLastRow,

    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "ProcessedSegments", each ProcessSubtable([Segments]), type table[value = binary, adj_value = binary]),
    #"Removed Other Columns1" = Table.SelectColumns(#"Added Custom",{"ProcessedSegments"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns1", "ProcessedSegments", {"value", "adj_value"}, {"value", "adj_value"}),
    #"Added Custom1" = Table.AddColumn(#"Expanded {0}", "value1", each List.Min({[value], [adj_value]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "value2", each List.Max({[value], [adj_value]}), type binary),
    #"Removed Other Columns2" = Table.SelectColumns(#"Added Custom2",{"value1", "value2"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns2")

in
    #"Removed Duplicates"