object fFormSetApp: TfFormSetApp
  Left = 192
  Top = 153
  Width = 434
  Height = 274
  Caption = #24494#20449#21442#25968#35774#32622
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -19
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    418
    236)
  PixelsPerInch = 96
  TextHeight = 24
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 57
    Height = 24
    Caption = 'AppID:'
  end
  object Label2: TLabel
    Left = 16
    Top = 104
    Width = 94
    Height = 24
    Caption = 'AppSecret:'
  end
  object Label3: TLabel
    Left = 16
    Top = 64
    Width = 94
    Height = 24
    Caption = 'AppToken:'
  end
  object edtAppID: TEdit
    Left = 120
    Top = 20
    Width = 298
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object edtAppSecret: TEdit
    Left = 120
    Top = 100
    Width = 298
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object BtnOK: TButton
    Left = 35
    Top = 164
    Width = 107
    Height = 30
    Anchors = []
    Caption = #20445#23384
    TabOrder = 2
    OnClick = BtnOKClick
  end
  object BtnCancel: TButton
    Left = 290
    Top = 164
    Width = 97
    Height = 30
    Anchors = []
    Caption = #21462#28040
    TabOrder = 3
    OnClick = BtnCancelClick
  end
  object edtAppToken: TEdit
    Left = 120
    Top = 60
    Width = 298
    Height = 32
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
end
