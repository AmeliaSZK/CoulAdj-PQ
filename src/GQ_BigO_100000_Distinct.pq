let
    Source = GQ_BigO_100000,
    #"Removed Duplicates" = Table.Distinct(Source)
in
    #"Removed Duplicates"