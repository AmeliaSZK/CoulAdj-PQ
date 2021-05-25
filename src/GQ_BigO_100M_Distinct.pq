let
    Source = GQ_BigO_GenerateRandoms(100 * 1000 * 1000),
    #"Removed Duplicates" = Table.Distinct(Source)
in
    #"Removed Duplicates"