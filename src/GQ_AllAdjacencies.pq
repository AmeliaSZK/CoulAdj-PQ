let
    Source = GQ_AllUniqueRelations,

    /* Generate the symmetric rows */
    // A "symmetric" relation means that if A is adjacent to B, then B must also be adjacent to A.
    AddedSymmetricals = Table.AddColumn(Source, "Symmetricals", each Table.FromRows({ {[MinColour],[MaxColour]}, {[MaxColour],[MinColour]} }, type table[colour = binary, adj_colour = binary]), type table[colour = binary, adj_colour = binary]),
    KeptSymmetricals = Table.SelectColumns(AddedSymmetricals,{"Symmetricals"}),
    ExpandedSymmetricals = Table.ExpandTableColumn(KeptSymmetricals, "Symmetricals", {"colour", "adj_colour"})
in
    ExpandedSymmetricals