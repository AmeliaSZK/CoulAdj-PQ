let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),

    /* Combine all unique ordered relations */
    // unique = no duplicates
    // ordered = value1 < value2, for all rows
    // relation = "A is adjacent to B" is one (1) relation, but in the final output it needs two rows: {A, B} & {B, A}
    //            By "relation", we mean only the row {A, B}, because that's enough to know we also need {B, A} later.
    CombinedAllOrderedRelations = Table.Combine({GQ_Sandbox_Size_1_RLE_AllTopNeighbours, GQ_Sandbox_Size_1_RLE_RightNeighbours}),
    PurgedDuplicates = Table.Distinct(CombinedAllOrderedRelations),
    /* Generate the symmetric rows */
    // A "symmetric" relation means that if A is adjacent to B, then B must also be adjacent to A.
    AddedSymmetricals = Table.AddColumn(PurgedDuplicates, "Symmetricals", each Table.FromRows({ {[value1],[value2]}, {[value2],[value1]} }, type table[value = binary, adj_value = binary]), type table[value = binary, adj_value = binary]),
    KeptSymmetricals = Table.SelectColumns(AddedSymmetricals,{"Symmetricals"}),
    ExpandedSymmetricals = Table.ExpandTableColumn(KeptSymmetricals, "Symmetricals", {"value", "adj_value"}),

    /* Format Output */
    AddedRed = Table.AddColumn(ExpandedSymmetricals, "r", each Source[RedFromValue]([value]), Int64.Type),
    AddedGre = Table.AddColumn(AddedRed, "g", each Source[GreenFromValue]([value]), Int64.Type),
    AddedBlu = Table.AddColumn(AddedGre, "b", each Source[BlueFromValue]([value]), Int64.Type),
    AddedAlp = Table.AddColumn(AddedBlu, "a", each Source[AlphaFromValue]([value]), Int64.Type),
    AddedAdjRed = Table.AddColumn(AddedAlp, "adj_r", each Source[RedFromValue]([adj_value]), Int64.Type),
    AddedAdjGre = Table.AddColumn(AddedAdjRed, "adj_g", each Source[GreenFromValue]([adj_value]), Int64.Type),
    AddedAdjBlu = Table.AddColumn(AddedAdjGre, "adj_b", each Source[BlueFromValue]([adj_value]), Int64.Type),
    AddedAdjAlp = Table.AddColumn(AddedAdjBlu, "adj_a", each Source[AlphaFromValue]([adj_value]), Int64.Type),
    RemovedBinaryColumns = Table.RemoveColumns(AddedAdjAlp,{"value", "adj_value"}),
    SortedRows = Table.Sort(RemovedBinaryColumns,{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}})
in
    SortedRows