let
    RLEncoded = GQ_Result_EncodeRunLength,

    /* Group Segments by Row Index */
    #"Removed Other Columns" = Table.SelectColumns(RLEncoded,{"row", "colour"}),
    #"Grouped Rows" = Table.Group(#"Removed Other Columns", {"row"}, {{"Segments", each _, type table [row = number, colour = binary]}}, GroupKind.Local),

    /* Join consecutive segments */
    ProcessSubtable = (table as table) as table =>
let
    Segments = Table.Column(table, "colour"),
    Consecutives = Table.FromColumns(
        {Segments, List.Skip(Segments, 1)},
        type table[colour = binary, adj_colour = binary]
    ),
    RemovedLastRow = Table.RemoveLastN(Consecutives,1),
    AddedCustom1 = Table.AddColumn(RemovedLastRow, "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
    AddedCustom2 = Table.AddColumn(AddedCustom1, "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
    RemovedOtherColumns2 = Table.SelectColumns(AddedCustom2,{"MinColour", "MaxColour"}),
    RemovedDuplicates = Table.Distinct(RemovedOtherColumns2)
in
    RemovedDuplicates,
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "ProcessedSegments", each ProcessSubtable([Segments]), type table[MinColour = binary, MaxColour = binary]),
    #"Filtered Rows" = Table.SelectRows(#"Added Custom", each not (Table.IsEmpty([ProcessedSegments]))),
    
    /* (Boilerplate) Expand & keep consecutives */
    #"Removed Other Columns1" = Table.SelectColumns(#"Filtered Rows",{"ProcessedSegments"}),
    #"Expanded {0}" = Table.ExpandTableColumn(#"Removed Other Columns1", "ProcessedSegments", {"MinColour", "MaxColour"}, {"MinColour", "MaxColour"})
    
/*
    // Order the relations 
    #"Added Custom1" = Table.AddColumn(#"Expanded {0}", "MinColour", each List.Min({[colour], [adj_colour]}), type binary),
    #"Added Custom2" = Table.AddColumn(#"Added Custom1", "MaxColour", each List.Max({[colour], [adj_colour]}), type binary),
    // Purge Duplicates
    #"Removed Other Columns2" = Table.SelectColumns(#"Added Custom2",{"MinColour", "MaxColour"}),
    #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns2")
*/

in
    #"Expanded {0}"