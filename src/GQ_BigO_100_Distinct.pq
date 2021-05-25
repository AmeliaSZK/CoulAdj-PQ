let
    Source = GQ_BigO_100,
    #"Removed Duplicates" = Table.Distinct(Source)
in
    #"Removed Duplicates"