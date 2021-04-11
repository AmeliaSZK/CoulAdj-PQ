let
    Source = GQ_TB_GoldenBinaries[#"pixels-size-1"],
    #"Imported CSV" = Csv.Document(Source,[Delimiter="#(tab)", Columns=6, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"row", Int64.Type}, {"col", Int64.Type}, {"r", Int64.Type}, {"g", Int64.Type}, {"b", Int64.Type}, {"a", Int64.Type}})
in
    #"Changed Type"