let
    DecodeColour = GQ_Result_ParseBitmap[RecordFromColour],
    DecodedType = GQ_Result_ParseBitmap[RecordFromColour.RecordType],

    ColumnNames = Record.FieldNames(Type.RecordFields(DecodedType)),
    AdjColumnNames = List.Transform(ColumnNames, each "adj_" & _),

    /* The CoulAdj API has long established the column names to use, and in which order they must appear.
    Previously, ParseBitmap was taking care of returning RGB(A) records with the expected names in the expected order.

    However, when we started using BinaryFormat.Record to parse binary values, two things changed:
        1) Order was now BGR(A), since that's the order in which the bytes are stored in the file
        2) The field names were now full words: Blue, Green, Red(, Alpha).
            There were two places in ParseBitmap where we could have renamed the fields:
                A) The RGBQUAD and RGBTRIPLE binary formats
                B) The RGB.FromColour and RgbAlpha.FromColour functions.
            Doing the changes in the functions felt sketchy, because these functions are called on every cell
                in FormattedOutput, and FormattedOutput can do these renamings in one go for the whole table.
            And we chose to leave the binary formats with their official names, because the main point of
                using the binary formats is to make verification against official references easy. And changing these
                names to fit the expected output felt like an overreach for a function whose role is only to parse a bitmap.
    */
    ColumnRenames =
        {
            {"Red",   "r"},
            {"Green", "g"},
            {"Blue",  "b"},
            {"Alpha", "a"},
            {"adj_Red",   "adj_r"},
            {"adj_Green", "adj_g"},
            {"adj_Blue",  "adj_b"},
            {"adj_Alpha", "adj_a"}
        },
    // The expanded records may not have an alpha field, so we'll use MissingField.Ignore
    //    in Table.RenameColumns and Table.ReorderColumns
    ColumnOrder = {"r", "g", "b", "a", "adj_r", "adj_g", "adj_b", "adj_a"},

    Source = GQ_AllAdjacencies,
    #"Added Custom" = Table.AddColumn(Source, "decoded", each DecodeColour([colour]), DecodedType),
    #"Added Custom1" = Table.AddColumn(#"Added Custom", "adj_decoded", each DecodeColour([adj_colour]), DecodedType),
    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom1",{"decoded", "adj_decoded"}),
    #"Expanded {0}" = Table.ExpandRecordColumn(#"Removed Other Columns", "decoded", ColumnNames, ColumnNames),
    #"Expanded {0}1" = Table.ExpandRecordColumn(#"Expanded {0}", "adj_decoded", ColumnNames, AdjColumnNames),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded {0}1", ColumnRenames, MissingField.Ignore),
    #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns",ColumnOrder, MissingField.Ignore)
in
    #"Reordered Columns"