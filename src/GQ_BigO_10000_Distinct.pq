let
    Source = GQ_BigO_10000,
    #"Removed Duplicates" = Table.Distinct(Source)
in
    #"Removed Duplicates"