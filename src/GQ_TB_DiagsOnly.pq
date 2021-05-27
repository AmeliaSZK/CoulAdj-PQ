let
    Source = Table.NestedJoin(GQ_TB_CoulAdj_default, {"a", "adj_a"}, GQ_TB_CoulAdj_noDiags, {"a", "adj_a"}, "GQ_TB_CoulAdj_noDiags", JoinKind.LeftAnti),
    #"Removed Columns" = Table.RemoveColumns(Source,{"GQ_TB_CoulAdj_noDiags"})
in
    #"Removed Columns"