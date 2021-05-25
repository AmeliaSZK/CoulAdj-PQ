let
    DontRelateDiagonals = GQ_DontRelateDiagonals,

    TopLeft = GQ_TopLeftNeighbours_MergeSort,
    TopCent = GQ_TopCentNeighbours_MergeSort,
    TopRigh = GQ_TopRighNeighbours_MergeSort,

    Combined =
        if DontRelateDiagonals then
            TopCent
        else
            Table.Combine({TopLeft , TopCent, TopRigh}),
    RemovedDuplicates = Table.Distinct(Combined)
in
    RemovedDuplicates