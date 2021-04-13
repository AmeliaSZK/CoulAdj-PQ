let
    Source = GQ_AllUniqueRelations,

    Columns = Table.ToColumns(Source),
    Combined = Table.FromColumns({
            Columns{0} & Columns{1},
            Columns{1} & Columns{0} 
        }, type table[colour = binary, adj_colour = binary])

    /* Generate the symmetric rows */
    // A "symmetric" relation means that if A is adjacent to B, then B must also be adjacent to A.
/*
    AddedSymmetricals = Table.AddColumn(Source, "Symmetricals", each Table.FromRows({ {[MinColour],[MaxColour]}, {[MaxColour],[MinColour]} }, type table[colour = binary, adj_colour = binary]), type table[colour = binary, adj_colour = binary]),
    KeptSymmetricals = Table.SelectColumns(AddedSymmetricals,{"Symmetricals"}),
    ExpandedSymmetricals = Table.ExpandTableColumn(KeptSymmetricals, "Symmetricals", {"colour", "adj_colour"})
*/
in
    Combined