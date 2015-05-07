object Form1: TForm1
  Left = 610
  Top = 319
  Width = 702
  Height = 476
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 694
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 12
      Top = 8
      Width = 75
      Height = 25
      Caption = #36716#25442
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 694
    Height = 216
    Align = alTop
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object Memo2: TMemo
    Left = 0
    Top = 257
    Width = 694
    Height = 192
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 2
  end
end
