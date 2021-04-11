let
    tsvBinary = GQ_TB_GoldenBinaries[golden],
    // Encoding=65001 is UTF-8, but Encoding=TextEncoding.Utf8 will make Power Query crash (wtf?)
    #"Imported CSV" = Csv.Document(tsvBinary, [Delimiter="#(tab)", Encoding=65001]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    // These column names (and their order) is guaranteed by the CoulAdj API
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"r", Int64.Type}, {"g", Int64.Type}, {"b", Int64.Type}, {"a", Int64.Type}, {"adj_r", Int64.Type}, {"adj_g", Int64.Type}, {"adj_b", Int64.Type}, {"adj_a", Int64.Type}})
in
    #"Changed Type"