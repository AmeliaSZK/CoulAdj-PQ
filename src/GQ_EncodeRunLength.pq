let

    EncodeRunLength = (allPixels as table) as table =>
let
    #"Grouped Rows" = Table.Group(allPixels, {"row"}, {{"All Rows", each _, type table [row=number, col=number, colour=binary]}}),
    #"Invoked Custom Function" = Table.AddColumn(#"Grouped Rows", "RLE", each EncodeRunLengthSubtable([All Rows]), type table[colour = binary, Start = number, End = number]),
    #"Removed Columns" = Table.RemoveColumns(#"Invoked Custom Function",{"All Rows"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Columns", "RLE", {"colour", "Start", "End"})
in
    #"Expanded {0}",


    EncodeRunLengthSubtable = (table as table) as table =>
let
    GroupedRows = Table.Group(table, {"colour"}, {{"End", each List.Last([col])+1, type number}, {"Start", each List.First([col]), type number}}, GroupKind.Local)
    //AddedEnd = Table.AddColumn(GroupedRows, "End", each [Count] + [Start], type number),
    //RemovedCount = Table.RemoveColumns(AddedEnd, "Count")
in
    GroupedRows

in
    EncodeRunLength