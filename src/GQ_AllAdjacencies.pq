let
    Source = GQ_AllUniqueRelations,

    AddedAdjacencies = Table.AddColumn(Source, "Adjacencies", each Table.FromRecords({[colour=[MinColour], adj_colour=[MaxColour]], [colour=[MaxColour], adj_colour=[MinColour]]}), type table[colour=binary, adj_colour=binary]),
    KeptAdjacencies = Table.SelectColumns(AddedAdjacencies,{"Adjacencies"}),
    ExpandedAdjacencies = Table.ExpandTableColumn(KeptAdjacencies, "Adjacencies", {"colour", "adj_colour"}, {"colour", "adj_colour"})

in
    ExpandedAdjacencies