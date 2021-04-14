let
    /* Combine all unique ordered relations */
    // unique = no duplicates
    // ordered = value1 < value2, for all rows
    // relation = "A is adjacent to B" is one (1) relation, but in the final output it needs two rows: {A, B} & {B, A}
    //            By "relation", we mean only the row {A, B}, because that's enough to know we also need {B, A} later.
    CombinedAllOrderedRelations = Table.Combine({GQ_AllTopNeighbours, GQ_RightNeighbours}),
    PurgedDuplicates = Table.Distinct(CombinedAllOrderedRelations)
in
    PurgedDuplicates