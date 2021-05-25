let
    Source = GQ_BigO_1000,
    #"Removed Duplicates" = Table.Distinct(Source)
in
    #"Removed Duplicates"