let
    ParseRgbAlphaTSV = (tsvBinary as binary) as table =>
let
    // Encoding=65001 is UTF-8, but Encoding=TextEncoding.Utf8 will make Power Query crash (wtf?)
    #"Imported CSV" = Csv.Document(tsvBinary, [Delimiter="#(tab)", Encoding=65001]),
    #"Promoted Headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars=true]),
    HasAlpha = Table.ColumnCount(#"Promoted Headers") = 8,
    // These column names (and their order) is guaranteed by the CoulAdj API
    TypeTransforms =
        if HasAlpha then
            {
                {"r", Int64.Type},
                {"g", Int64.Type},
                {"b", Int64.Type},
                {"a", Int64.Type},
                {"adj_r", Int64.Type},
                {"adj_g", Int64.Type},
                {"adj_b", Int64.Type},
                {"adj_a", Int64.Type}
            }
        else
            {
                {"r", Int64.Type},
                {"g", Int64.Type},
                {"b", Int64.Type},
                {"adj_r", Int64.Type},
                {"adj_g", Int64.Type},
                {"adj_b", Int64.Type}
            },
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers", TypeTransforms)
in
    #"Changed Type"
in
    ParseRgbAlphaTSV