object fFormMain: TfFormMain
  Left = 329
  Top = 201
  Width = 678
  Height = 394
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #21160#24577#34913#31995#32479#21516#27493#24037#20855
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 662
    Height = 70
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 401
      Top = 44
      Width = 60
      Height = 12
      Caption = #37325#26032#21516#27493#31532
    end
    object Label2: TLabel
      Left = 546
      Top = 44
      Width = 36
      Height = 12
      Caption = #26465#35760#24405
    end
    object CheckSrv: TCheckBox
      Left = 13
      Top = 45
      Width = 100
      Height = 17
      Caption = #21551#21160#23432#25252#26381#21153
      TabOrder = 0
      OnClick = CheckSrvClick
    end
    object EditTable: TLabeledEdit
      Left = 69
      Top = 20
      Width = 132
      Height = 20
      EditLabel.Width = 54
      EditLabel.Height = 12
      EditLabel.Caption = #25968#25454#34920#21517':'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object CheckAuto: TCheckBox
      Left = 212
      Top = 23
      Width = 100
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160
      TabOrder = 2
    end
    object CheckLoged: TCheckBox
      Left = 212
      Top = 45
      Width = 100
      Height = 17
      Caption = #26174#31034#35843#35797#26085#24535
      TabOrder = 3
      OnClick = CheckLogedClick
    end
    object BtnConn: TButton
      Left = 317
      Top = 37
      Width = 75
      Height = 25
      Caption = #25968#25454#36830#25509
      TabOrder = 4
      OnClick = BtnConnClick
    end
    object Button1: TButton
      Left = 317
      Top = 8
      Width = 75
      Height = 25
      Caption = #26032#24314#32034#24341
      TabOrder = 5
      OnClick = Button1Click
    end
    object ReSyncValue: TEdit
      Left = 465
      Top = 40
      Width = 78
      Height = 20
      TabOrder = 6
    end
    object ReSync: TButton
      Left = 584
      Top = 38
      Width = 75
      Height = 25
      Caption = #37325#26032#21516#27493
      TabOrder = 7
      OnClick = ReSyncClick
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 70
    Width = 662
    Height = 267
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 337
    Width = 662
    Height = 19
    Panels = <>
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 76
  end
end
