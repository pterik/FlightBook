object Form1: TForm1
  Left = 280
  Top = 222
  Width = 754
  Height = 348
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pn_controls: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 129
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lbDepartDate: TLabel
      Left = 436
      Top = 68
      Width = 58
      Height = 13
      Caption = 'Depart Date'
    end
    object lbReturnDate: TLabel
      Left = 436
      Top = 95
      Width = 58
      Height = 13
      Caption = 'Return Date'
    end
    object lbDepartingFrom: TLabel
      Left = 12
      Top = 8
      Width = 69
      Height = 13
      Caption = 'Departing from'
    end
    object lbGoingTo: TLabel
      Left = 12
      Top = 46
      Width = 40
      Height = 13
      Caption = 'Going to'
    end
    object pn_ReturnOneWay: TPanel
      Left = 429
      Top = 5
      Width = 186
      Height = 31
      BevelOuter = bvNone
      TabOrder = 0
      object rbReturn: TRadioButton
        Left = 4
        Top = 8
        Width = 82
        Height = 17
        Anchors = []
        Caption = 'Return'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbOneWay: TRadioButton
        Left = 95
        Top = 8
        Width = 90
        Height = 17
        Anchors = []
        Caption = 'One Way'
        TabOrder = 1
      end
    end
    object chbFlexible: TCheckBox
      Left = 436
      Top = 42
      Width = 160
      Height = 17
      Caption = 'My travel dates are flexible'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object btnStart: TBitBtn
      Left = 12
      Top = 87
      Width = 197
      Height = 29
      Caption = 'Book Cheap Flights'
      TabOrder = 2
      OnClick = btnStartClick
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        1800000000000003000000000000000000000000000000000000FAE6E6FAE6E6
        FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6
        E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6F1D0C4CB854FCE
        6F1ECD6D17C77437DAA285FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6
        FAE6E6FAE6E6EFC3AAD27925FFAE4FFFAD48FFA73DFF972AEC7F19D89064FAE6
        E6FAE6E6FAE6E6FAE6E6FAE6E6DE8B3DE89C52F1D1C1CE7724FFB763FFB259D7
        7A23D99768E5B39BD89A76BC5915E3AF94FAE6E6FAE6E6FAE6E6FAE6E6D5893B
        FDC285C57212FFC98EFFBE74D98029F0C7B0FAE6E6FAE6E6FAE6E6F4D5CCDD9C
        77FAE6E6FAE6E6FAE6E6FAE6E6D58E45FFE0BDFFCF9EFFCC96ECA660E4AC80FA
        E6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6D5934C
        FFE9D1FFD2A4FFCF9FD1832BE0A77CF7DED5FAE6E6FAE6E6FAE6E6FAE6E6FAE5
        E5F7E0DFFAE6E6FAE6E6FAE6E6D99C63FFF3E5FFE2C5FFDCB7FFD4A1FFC37EDD
        9E63EEC8B9DB915BD58349D48347C78649C67B41E0B09CFAE6E6FAE6E6E8BB99
        E09F4AE0A251E99E44E79946E1974AF2D0B9D29160FFD9A0FFE5BCFFE4C0FFE2
        BCFFE4BAC48165FAE6E6FAE6E6FAE6E6FAE2DDFAE5E4FAE6E6FAE6E6FAE6E6FA
        E6E6F6DAD3D39877CD7E39FFD3A0FFD1A2FFE0B1C0764AFAE6E6FAE6E6FAE6E6
        FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6DEA47FF8B776FFCC94FFCF
        98FFDFB0C1743EFAE6E6FAE6E6FAE6E6FAE6E6E29F64FADCCFFAE6E6FAE6E6FA
        E6E6F1C9B0E18A33FFBE75FFCA88B0560EFECC9BC87535FAE6E6FAE6E6FAE6E6
        FAE6E6EBB991DB8517ECB47AEFC29EE4A56AE48A2AFFB057FFC179D07729EFCC
        C1DB8A4FD98044FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6ECA860F8901BFC952AFF
        A13AFFA743FFBF75D47925E2AF8DFAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6
        FAE6E6FAE6E6FAE6E6E4B081DE943ED67F21D27F29CD8442E6BAA2FAE6E6FAE6
        E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FA
        E6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6FAE6E6}
    end
    object dtDepartDate: TDateTimePicker
      Left = 511
      Top = 65
      Width = 85
      Height = 21
      CalAlignment = dtaLeft
      Date = 40340.5091510185
      Time = 40340.5091510185
      DateFormat = dfShort
      DateMode = dmComboBox
      Kind = dtkDate
      ParseInput = False
      TabOrder = 3
      OnChange = dtDepartDateChange
    end
    object dtReturnDate: TDateTimePicker
      Left = 511
      Top = 92
      Width = 85
      Height = 21
      CalAlignment = dtaLeft
      Date = 40340.5091510185
      Time = 40340.5091510185
      DateFormat = dfShort
      DateMode = dmComboBox
      Kind = dtkDate
      ParseInput = False
      TabOrder = 4
      OnChange = dtReturnDateChange
    end
    object gbNumberOfPassengers: TGroupBox
      Left = 618
      Top = 8
      Width = 134
      Height = 105
      Caption = 'Number of Passengers '
      TabOrder = 5
      object lbAdults: TLabel
        Left = 50
        Top = 22
        Width = 29
        Height = 13
        Caption = 'Adults'
      end
      object lbChildren: TLabel
        Left = 50
        Top = 50
        Width = 38
        Height = 13
        Caption = 'Children'
      end
      object lbInfants: TLabel
        Left = 50
        Top = 78
        Width = 32
        Height = 13
        Caption = 'Infants'
      end
      object seChildren: TSpinEdit
        Left = 6
        Top = 47
        Width = 38
        Height = 22
        MaxValue = 25
        MinValue = 0
        TabOrder = 0
        Value = 0
      end
      object seInfants: TSpinEdit
        Left = 6
        Top = 75
        Width = 38
        Height = 22
        MaxValue = 9
        MinValue = 0
        TabOrder = 1
        Value = 0
      end
      object seAdults: TSpinEdit
        Left = 6
        Top = 19
        Width = 38
        Height = 22
        MaxValue = 25
        MinValue = 0
        TabOrder = 2
        Value = 1
      end
    end
    object cbGoingTo: TComboBox
      Left = 12
      Top = 60
      Width = 197
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 6
    end
    object cbDepartingFrom: TComboBox
      Left = 12
      Top = 22
      Width = 197
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 7
      OnChange = cbDepartingFromChange
    end
    object RadioGroup1: TRadioGroup
      Left = 223
      Top = 8
      Width = 201
      Height = 105
      Caption = 'Carriers'
      Columns = 2
      Items.Strings = (
        'Ryanair'
        'Airberlin'
        'Corendon'
        'Transavia'
        'Jetairfly'
        'Pegasus'
        'Vueling'
        'Easyjet CHEAP '
        'Easyjet SLOW '
        'Airbaltic')
      TabOrder = 8
      OnClick = RadioGroup1Click
    end
  end
  object sgResults: TStringGrid
    Left = 0
    Top = 129
    Width = 746
    Height = 192
    Align = alClient
    ColCount = 11
    DefaultColWidth = 100
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 1
  end
end
