let
    EncodeRunLengthSubtable = (table as table) as table =>

let
    GroupedRows = Table.Group(table, {"value"}, {{"Count", each Table.RowCount(_), Int64.Type}, {"Start", each List.Min([col]), Int64.Type}}, GroupKind.Local),
    AddedEnd = Table.AddColumn(GroupedRows, "End", each [Count] + [Start], Int64.Type),
    RemovedCount = Table.RemoveColumns(AddedEnd, "Count")
in
    RemovedCount 

in
    EncodeRunLengthSubtable