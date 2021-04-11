let
    Source = GQ_TB_GoldenBinaries,
    golden = Source[golden],
    #"Imported CSV" = Csv.Document(golden,[Delimiter="#(tab)", Encoding=65001]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"r", Int64.Type}, {"g", Int64.Type}, {"b", Int64.Type}, {"a", Int64.Type}, {"adj_r", Int64.Type}, {"adj_g", Int64.Type}, {"adj_b", Int64.Type}, {"adj_a", Int64.Type}})
in
    #"Changed Type"