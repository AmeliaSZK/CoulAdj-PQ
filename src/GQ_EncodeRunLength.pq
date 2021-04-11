let

    EncodeRunLength = (allPixels as table) as table =>
let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    AllPixels = Source[AllPixels],
    #"Grouped Rows" = Table.Group(AllPixels, {"row"}, {{"All Rows", each _, type table [row=number, col=number, value=binary]}}),
    #"Invoked Custom Function" = Table.AddColumn(#"Grouped Rows", "RLE", each EncodeRunLengthSubtable([All Rows]), type table[value = binary, Start = Int64.Type, End = Int64.Type]),
    #"Removed Columns" = Table.RemoveColumns(#"Invoked Custom Function",{"All Rows"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Columns", "RLE", {"value", "Start", "End"})
in
    #"Expanded {0}",


    EncodeRunLengthSubtable = (table as table) as table =>
let
    GroupedRows = Table.Group(table, {"value"}, {{"Count", each Table.RowCount(_), Int64.Type}, {"Start", each List.Min([col]), Int64.Type}}, GroupKind.Local),
    AddedEnd = Table.AddColumn(GroupedRows, "End", each [Count] + [Start], Int64.Type),
    RemovedCount = Table.RemoveColumns(AddedEnd, "Count")
in
    RemovedCount

in
    EncodeRunLength