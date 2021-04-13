let
    Source = GQ_AllUniqueRelations,

    Columns = Table.ToColumns(Source),
    Combined = Table.FromColumns({
            Columns{0} & Columns{1},
            Columns{1} & Columns{0} 
        }, type table[colour = binary, adj_colour = binary])
in
    Combined