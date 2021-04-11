let
    Source = GQ_ParseBitmap(GQ_TB_Binary_Size_1),
    Combined = Table.Combine({GQ_Sandbox_Size_1_RLE_AllTopNeighbours, GQ_Sandbox_Size_1_RLE_RightNeighbours}),
    #"Removed Duplicates" = Table.Distinct(Combined),
    #"Added Custom" = Table.AddColumn(#"Removed Duplicates", "Symmetricals", each Table.FromRows({ {[value1],[value2]}, {[value2],[value1]} }, type table[value = binary, adj_value = binary]), type table[value = binary, adj_value = binary]),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom",{"Symmetricals"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns", "Symmetricals", {"value", "adj_value"}),
    AddedRed = Table.AddColumn(#"Expanded {0}", "r", each Source[RedFromValue]([value]), Int64.Type),
    AddedGre = Table.AddColumn(AddedRed, "g", each Source[GreenFromValue]([value]), Int64.Type),
    AddedBlu = Table.AddColumn(AddedGre, "b", each Source[BlueFromValue]([value]), Int64.Type),
    AddedAlp = Table.AddColumn(AddedBlu, "a", each Source[AlphaFromValue]([value]), Int64.Type),
    AddedAdjRed = Table.AddColumn(AddedAlp, "adj_r", each Source[RedFromValue]([adj_value]), Int64.Type),
    AddedAdjGre = Table.AddColumn(AddedAdjRed, "adj_g", each Source[GreenFromValue]([adj_value]), Int64.Type),
    AddedAdjBlu = Table.AddColumn(AddedAdjGre, "adj_b", each Source[BlueFromValue]([adj_value]), Int64.Type),
    AddedAdjAlp = Table.AddColumn(AddedAdjBlu, "adj_a", each Source[AlphaFromValue]([adj_value]), Int64.Type),
    #"Removed Columns" = Table.RemoveColumns(AddedAdjAlp,{"value", "adj_value"}),
    #"Sorted Rows" = Table.Sort(#"Removed Columns",{{"r", Order.Ascending}, {"g", Order.Ascending}, {"b", Order.Ascending}, {"a", Order.Ascending}, {"adj_r", Order.Ascending}, {"adj_g", Order.Ascending}, {"adj_b", Order.Ascending}, {"adj_a", Order.Ascending}})
in
    #"Sorted Rows"