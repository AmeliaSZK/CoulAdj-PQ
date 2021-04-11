let
    Source = Folder.Files(RepoRoot),
    #"Filtered Rows" = Table.SelectRows(Source, each not Text.Contains([Folder Path], ".git\")),
    #"Filtered Rows1" = Table.SelectRows(#"Filtered Rows", each ([Extension] = ".tsv")),
    #"Removed Other Columns" = Table.SelectColumns(#"Filtered Rows1",{"Content", "Name", "Extension"}),
    #"Added Custom" = Table.AddColumn(#"Removed Other Columns", "Filename", each Text.BeforeDelimiter([Name], [Extension], {0, RelativePosition.FromEnd}), type text),
    #"Reordered Columns" = Table.ReorderColumns(#"Added Custom",{"Filename", "Content", "Name", "Extension"}),
    #"Removed Columns" = Table.RemoveColumns(#"Reordered Columns",{"Name", "Extension"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"Filename", "Name"}, {"Content", "Value"}}),
    AsRecord = Record.FromTable(#"Renamed Columns")
in
    AsRecord