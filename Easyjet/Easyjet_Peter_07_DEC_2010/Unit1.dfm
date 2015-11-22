object Form1: TForm1
  Left = 126
  Top = 136
  Width = 868
  Height = 712
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 672
    Top = 136
    Width = 15
    Height = 13
    Caption = 'org'
  end
  object Label2: TLabel
    Left = 672
    Top = 160
    Width = 56
    Height = 13
    Caption = 'bestemming'
  end
  object Label3: TLabel
    Left = 672
    Top = 184
    Width = 35
    Height = 13
    Caption = 'vdatum'
  end
  object Label4: TLabel
    Left = 672
    Top = 208
    Width = 19
    Height = 13
    Caption = 'vmy'
  end
  object Label5: TLabel
    Left = 672
    Top = 232
    Width = 32
    Height = 13
    Caption = 'rdatum'
  end
  object Label6: TLabel
    Left = 672
    Top = 256
    Width = 16
    Height = 13
    Caption = 'rmy'
  end
  object Label7: TLabel
    Left = 8
    Top = 8
    Width = 36
    Height = 13
    Caption = 'website'
  end
  object Edit1: TEdit
    Left = 96
    Top = 8
    Width = 553
    Height = 21
    TabOrder = 0
    Text = 'http://www.easyjet.com'
  end
  object WebBrowser1: TWebBrowser
    Left = -8
    Top = 32
    Width = 657
    Height = 641
    TabOrder = 1
    ControlData = {
      4C000000E7430000404200000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object btn_open_website: TButton
    Left = 712
    Top = 72
    Width = 129
    Height = 25
    Caption = 'open website'
    TabOrder = 2
    OnClick = btn_open_websiteClick
  end
  object Edit3: TEdit
    Left = 744
    Top = 136
    Width = 81
    Height = 21
    TabOrder = 3
    Text = 'AMS'
  end
  object Edit4: TEdit
    Left = 744
    Top = 160
    Width = 81
    Height = 21
    TabOrder = 4
    Text = 'PRG'
  end
  object btn_add_input: TButton
    Left = 720
    Top = 280
    Width = 121
    Height = 25
    Caption = 'add input'
    TabOrder = 5
    OnClick = btn_add_inputClick
  end
  object Edit5: TEdit
    Left = 744
    Top = 184
    Width = 81
    Height = 21
    TabOrder = 6
    Text = '01'
  end
  object Edit6: TEdit
    Left = 744
    Top = 208
    Width = 81
    Height = 21
    TabOrder = 7
    Text = '122010'
  end
  object Edit7: TEdit
    Left = 744
    Top = 232
    Width = 81
    Height = 21
    TabOrder = 8
    Text = '14'
  end
  object Edit8: TEdit
    Left = 744
    Top = 256
    Width = 81
    Height = 21
    TabOrder = 9
    Text = '122010'
  end
  object btn_submit: TButton
    Left = 720
    Top = 312
    Width = 121
    Height = 25
    Caption = 'submit'
    TabOrder = 10
    OnClick = btn_submitClick
  end
  object btn_test: TButton
    Left = 728
    Top = 392
    Width = 105
    Height = 25
    Caption = 'test'
    TabOrder = 11
    OnClick = btn_testClick
  end
end
