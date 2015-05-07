object fFormTemplate: TfFormTemplate
  Left = 192
  Top = 153
  Width = 384
  Height = 428
  Caption = 'fFormTemplate'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    368
    390)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 96
    Width = 105
    Height = 24
    AutoSize = False
    Caption = #27169#29256'TYPE'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 77
    Height = 24
    Caption = #27169#26495'ID'#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 8
    Top = 136
    Width = 105
    Height = 24
    AutoSize = False
    Caption = #27169#26495#22791#27880#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object mmoTemplate: TMemo
    Left = 8
    Top = 168
    Width = 351
    Height = 215
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object BtnCreate: TButton
    Left = 16
    Top = 8
    Width = 105
    Height = 33
    Caption = #26032#22686
    TabOrder = 1
    OnClick = BtnCreateClick
  end
  object BtnDel: TButton
    Left = 136
    Top = 8
    Width = 105
    Height = 33
    Caption = #21024#38500
    TabOrder = 2
    OnClick = BtnDelClick
  end
  object edtID: TEdit
    Left = 120
    Top = 57
    Width = 241
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object BtnExit: TButton
    Left = 256
    Top = 8
    Width = 105
    Height = 33
    Caption = #36864#20986
    TabOrder = 4
    OnClick = BtnExitClick
  end
  object edtType: TEdit
    Left = 119
    Top = 96
    Width = 241
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
  end
  object edtComment: TEdit
    Left = 119
    Top = 136
    Width = 241
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
  end
end
