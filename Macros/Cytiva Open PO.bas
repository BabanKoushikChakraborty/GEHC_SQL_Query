Sub CytivaOpenPO()
'
' CytivaOpenPO Macro
'

'
    Selection.AutoFilter
    With ActiveWindow
        .SplitColumn = 0
        .SplitRow = 1
    End With
    ActiveWindow.FreezePanes = True
    Selection.Columns.AutoFit
    With Selection.Interior
        .Pattern = xlSolid
        .PatternColorIndex = xlAutomatic
        .ThemeColor = xlThemeColorAccent1
        .TintAndShade = 0.399975585192419
        .PatternTintAndShade = 0
    End With
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=2, Criteria1:="<>"
    Range("A4203").Select
    Range(Selection, ActiveCell.SpecialCells(xlLastCell)).Select
    With Selection.Font
        .Color = -16776961
        .TintAndShade = 0
    End With
    Cells.Select
    Range("AP1").Activate
    Selection.AutoFilter
    Selection.AutoFilter
    Columns("B:B").Select
    Selection.Delete Shift:=xlToLeft
    Columns("C:C").Select
    Selection.TextToColumns Destination:=Range("C1"), DataType:=xlDelimited, _
        TextQualifier:=xlDoubleQuote, ConsecutiveDelimiter:=False, Tab:=True, _
        Semicolon:=False, Comma:=False, Space:=False, Other:=False, FieldInfo _
        :=Array(1, 1), TrailingMinusNumbers:=True
    Selection.NumberFormat = "0.00"
    Selection.NumberFormat = "0.0"
    Selection.NumberFormat = "0"
    Selection.Copy
    Columns("F:F").Select
    Selection.PasteSpecial Paste:=xlPasteFormats, Operation:=xlNone, _
        SkipBlanks:=False, Transpose:=False
    ActiveWindow.LargeScroll ToRight:=3
    ActiveWindow.ScrollColumn = 30
    ActiveWindow.ScrollColumn = 31
    ActiveWindow.ScrollColumn = 32
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 34
    ActiveWindow.ScrollColumn = 35
    ActiveWindow.ScrollColumn = 36
    ActiveWindow.ScrollColumn = 35
    ActiveWindow.ScrollColumn = 34
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 32
    ActiveWindow.ScrollColumn = 31
    ActiveWindow.ScrollColumn = 30
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 28
    ActiveWindow.ScrollColumn = 27
    ActiveWindow.ScrollColumn = 26
    ActiveWindow.ScrollColumn = 25
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 23
    ActiveWindow.ScrollColumn = 22
    ActiveWindow.ScrollColumn = 21
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 19
    ActiveWindow.ScrollColumn = 18
    ActiveWindow.ScrollColumn = 17
    ActiveWindow.ScrollColumn = 16
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 14
    ActiveWindow.ScrollColumn = 13
    ActiveWindow.ScrollColumn = 12
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 10
    ActiveWindow.ScrollColumn = 9
    ActiveWindow.ScrollColumn = 8
    ActiveWindow.ScrollColumn = 7
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 5
    ActiveWindow.ScrollColumn = 4
    ActiveWindow.ScrollColumn = 3
    ActiveWindow.ScrollColumn = 2
    ActiveWindow.ScrollColumn = 1
    Application.CutCopyMode = False
    Range("C7").Select
    ActiveWindow.LargeScroll ToRight:=1
    Columns("O:O").Select
    Selection.TextToColumns Destination:=Range("O1"), DataType:=xlDelimited, _
        TextQualifier:=xlDoubleQuote, ConsecutiveDelimiter:=False, Tab:=True, _
        Semicolon:=False, Comma:=False, Space:=False, Other:=False, FieldInfo _
        :=Array(1, 1), TrailingMinusNumbers:=True
    Columns("P:P").Select
    Selection.Insert Shift:=xlToRight
    Range("P1").Select
    ActiveCell.FormulaR1C1 = "Requestor Cytiva or not"
    Range("P1").Select
    Selection.Columns.AutoFit
    Selection.End(xlToRight).Select
    Columns("AY:AY").Select
    Selection.Insert Shift:=xlToRight
    Selection.Insert Shift:=xlToRight
    Selection.Insert Shift:=xlToRight
    Sheets("Sheet 4").Select
    Sheets("DNC").Visible = True
    Selection.Copy
    Sheets("Sheet 4").Select
    Range("AZ1").Select
    ActiveSheet.Paste
    Range("AY1").Select
    Application.CutCopyMode = False
    ActiveCell.FormulaR1C1 = "PO TO BE CLOSED BY DATE"
    Range("AY1:BA1").Select
    Selection.Columns.AutoFit
    Range("AY2").Select
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=49, Criteria1:="<>"
    Selection.End(xlUp).Select
    Range("AY561").Select
    ActiveCell.FormulaR1C1 = "=EDATE(RC[-1],6)"
    Range("AY561").Select
    Selection.FillDown
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=49
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=49, Criteria1:="="
    Range("AY2").Select
    ActiveCell.FormulaR1C1 = "=EDATE(RC[-44],18)"
    Range("AY2").Select
    Selection.NumberFormat = "[$-en-US]dd-mmm-yy;@"
    Selection.Copy
    Range("AU2").Select
    Selection.End(xlDown).Select
    Range("AY29577").Select
    Range(Selection, Selection.End(xlUp)).Select
    ActiveSheet.Paste
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=49
    Columns("AY:AY").Select
    Application.CutCopyMode = False
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Range("AY9").Select
    Application.CutCopyMode = False
    Range("AZ2").Select
    ActiveCell.FormulaR1C1 = _
        "=IFNA(VLOOKUP(RC[-46],DNC!C[-51]:C[-49],2,FALSE),""NA"")"
    Range("BA2").Select
    ActiveCell.FormulaR1C1 = _
        "=IFNA(VLOOKUP(RC[-47],DNC!C[-52]:C[-50],3,FALSE),""NA"")"
    Range("AZ2:BA2").Select
    Selection.AutoFill Destination:=Range("AZ2:BA29577")
    Range("AZ2:BA29577").Select
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=52, Criteria1:=Array( _
        "44196", "44316", "44561", "44918"), Operator:=xlFilterValues
    Range("AZ844").Select
    Selection.End(xlUp).Select
    Range("AZ836").Select
    Range(Selection, Selection.End(xlDown)).Select
    Application.CutCopyMode = False
    Selection.NumberFormat = "[$-en-US]dd-mmm-yy;@"
    ActiveSheet.Range("$A$1:$BC$1048576").AutoFilter Field:=52
    Range("P848").Select
    Selection.End(xlUp).Select
    Range("P2").Select
    ActiveCell.FormulaR1C1 = _
        "=IFERROR(IF(VLOOKUP(RC[-1],'[MonacoCensus February 200229 for Sourcing IT.xlsx]Full Census'!C1,1,0)=RC[-1],""CYTIVA""),""NON CYTIVA"")"
    Range("P2").Select
    Selection.AutoFill Destination:=Range("P2:P1048576")
    Range("P2:P1048576").Select
    Selection.Copy
    Selection.PasteSpecial Paste:=xlPasteValues, Operation:=xlNone, SkipBlanks _
        :=False, Transpose:=False
    Application.CutCopyMode = False
    ActiveWindow.ScrollColumn = 14
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 18
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 21
    ActiveWindow.ScrollColumn = 22
    ActiveWindow.ScrollColumn = 23
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 25
    ActiveWindow.ScrollColumn = 26
    ActiveWindow.ScrollColumn = 27
    ActiveWindow.ScrollColumn = 28
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 30
    ActiveWindow.ScrollColumn = 31
    ActiveWindow.ScrollColumn = 32
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 34
    ActiveWindow.ScrollColumn = 35
    ActiveWindow.ScrollColumn = 36
    ActiveWindow.ScrollColumn = 37
    ActiveWindow.ScrollColumn = 38
    ActiveWindow.ScrollColumn = 39
    ActiveWindow.ScrollColumn = 40
    ActiveWindow.ScrollColumn = 41
    ActiveWindow.ScrollColumn = 42
    ActiveWindow.ScrollColumn = 43
    ActiveWindow.ScrollColumn = 44
    ActiveWindow.ScrollColumn = 45
    ActiveWindow.ScrollColumn = 46
    ActiveWindow.ScrollColumn = 47
    Range("A1").Select
    Range(Selection, ActiveCell.SpecialCells(xlLastCell)).Select
    Selection.Copy
    ActiveSheet.Previous.Select
    ActiveSheet.Previous.Select
    Range("A2").Select
    Application.CutCopyMode = False
    Selection.Copy
    ActiveSheet.Next.Select
    ActiveSheet.Next.Select
    Application.CutCopyMode = False
    Selection.Copy
    ActiveSheet.Previous.Select
    ActiveSheet.Previous.Select
    ActiveSheet.Previous.Select
    ActiveSheet.Next.Select
    Range("A1").Select
    ActiveSheet.Paste
    Sheets("Sheet 4").Select
    Application.CutCopyMode = False
    ActiveWindow.SelectedSheets.Delete
    Sheets("DNC").Select
    ActiveWindow.SelectedSheets.Visible = False
    Rows("1:1").Select
    Selection.AutoFilter
    Selection.AutoFilter
    With ActiveWindow
        .SplitColumn = 0
        .SplitRow = 1
    End With
    ActiveWindow.FreezePanes = True
    Selection.Columns.AutoFit
    Range("D8").Select
    ActiveWindow.ScrollColumn = 2
    ActiveWindow.ScrollColumn = 3
    ActiveWindow.ScrollColumn = 4
    ActiveWindow.ScrollColumn = 5
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 7
    ActiveWindow.ScrollColumn = 8
    ActiveWindow.ScrollColumn = 9
    ActiveWindow.ScrollColumn = 10
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 12
    ActiveWindow.ScrollColumn = 13
    ActiveWindow.ScrollColumn = 14
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 16
    ActiveWindow.ScrollColumn = 17
    ActiveWindow.ScrollColumn = 18
    ActiveWindow.ScrollColumn = 19
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 21
    ActiveWindow.ScrollColumn = 22
    ActiveWindow.ScrollColumn = 23
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 25
    ActiveWindow.ScrollColumn = 26
    ActiveWindow.ScrollColumn = 27
    ActiveWindow.ScrollColumn = 28
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 30
    ActiveWindow.ScrollColumn = 31
    ActiveWindow.ScrollColumn = 32
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 34
    ActiveWindow.ScrollColumn = 35
    ActiveWindow.ScrollColumn = 36
    ActiveWindow.ScrollColumn = 37
    ActiveWindow.ScrollColumn = 38
    ActiveWindow.ScrollColumn = 39
    ActiveWindow.ScrollColumn = 40
    ActiveWindow.ScrollColumn = 41
    ActiveWindow.ScrollColumn = 42
    ActiveWindow.ScrollColumn = 43
    ActiveWindow.ScrollColumn = 44
    ActiveWindow.ScrollColumn = 45
    ActiveWindow.ScrollColumn = 46
    ActiveWindow.ScrollColumn = 47
    ActiveWindow.ScrollColumn = 48
    ActiveWindow.ScrollColumn = 49
    ActiveWindow.ScrollColumn = 50
    ActiveWindow.ScrollColumn = 51
    ActiveWindow.ScrollColumn = 52
    ActiveWindow.ScrollColumn = 53
    ActiveWindow.ScrollColumn = 52
    ActiveWindow.ScrollColumn = 51
    ActiveWindow.ScrollColumn = 50
    ActiveWindow.ScrollColumn = 49
    ActiveWindow.ScrollColumn = 48
    ActiveWindow.ScrollColumn = 47
End Sub




