let
    Source = GQ_TB_GoldenBinaries,
    golden = Source[golden],
    #"Imported CSV" = Csv.Document(golden,[Delimiter="#(tab)", Encoding=TextEncoding.Utf8])
in
    #"Imported CSV"