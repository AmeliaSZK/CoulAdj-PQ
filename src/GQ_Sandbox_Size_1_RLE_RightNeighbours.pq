let
    DontRelateDiagonals = false,
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    RLEncoded = Table.Buffer(GQ_EncodeRunLength(Source[AllPixels])),
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
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns1", "ProcessedSegments", {"value", "adj_value"}, {"value", "adj_value"})

in
    #"Expanded {0}"