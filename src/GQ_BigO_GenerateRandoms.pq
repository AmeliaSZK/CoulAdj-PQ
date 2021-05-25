let
    GQ_BigO_GenerateRandoms = (count as number) =>
let
    Count = count,
    // Did I pick the world seed for Dream's first 5-hunters manhunt in Minecraft? Yes, yes I did LOL
    // Update: The seeds must be within the range of 32-bit integers :(
    //    (so I truncated the last 12 digits)
    RandomNumbers = List.Random(Count, 8494389),
    Source = Table.FromColumns({RandomNumbers}, type table[Base Numbers = number]),
    #"Inserted Multiplication" = Table.AddColumn(Source, "Multiplication", each [Base Numbers] * 10, type number),
    #"Inserted Round Down" = Table.AddColumn(#"Inserted Multiplication", "RNG", each Number.RoundDown([Multiplication]), Int64.Type),
    #"Removed Other Columns" = Table.SelectColumns(#"Inserted Round Down",{"RNG"})
in
    #"Removed Other Columns"
in
    GQ_BigO_GenerateRandoms