let
    Source = GQ_AllUniqueRelations,

    #"Added Custom" = Table.AddColumn(Source, "Adjacencies", each Table.FromRecords({[colour=[MinColour], adj_colour=[MaxColour]], [colour=[MaxColour], adj_colour=[MinColour]]}), type table[colour=binary, adj_colour=binary]),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom",{"Adjacencies"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns", "Adjacencies", {"colour", "adj_colour"}, {"colour", "adj_colour"})

in
    #"Expanded {0}"