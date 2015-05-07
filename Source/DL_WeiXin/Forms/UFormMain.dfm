object fFormMain: TfFormMain
  Left = 408
  Top = 182
  Width = 727
  Height = 480
  Caption = #24494#20449#20844#20247#24179#21488
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mainMemu
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 711
    Height = 70
    Align = alTop
    TabOrder = 0
    object CheckSrv: TCheckBox
      Left = 45
      Top = 45
      Width = 100
      Height = 17
      Caption = #21551#21160#23432#25252#26381#21153
      TabOrder = 0
      OnClick = CheckSrvClick
    end
    object EditPort: TLabeledEdit
      Left = 45
      Top = 20
      Width = 80
      Height = 21
      EditLabel.Width = 27
      EditLabel.Height = 13
      EditLabel.Caption = #31471#21475':'
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 1
    end
    object CheckAuto: TCheckBox
      Left = 180
      Top = 23
      Width = 100
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160
      TabOrder = 2
    end
    object CheckLoged: TCheckBox
      Left = 180
      Top = 45
      Width = 100
      Height = 17
      Caption = #26174#31034#35843#35797#26085#24535
      TabOrder = 3
      OnClick = CheckLogedClick
    end
    object BtnConn: TButton
      Left = 312
      Top = 37
      Width = 75
      Height = 25
      Caption = #25968#25454#36830#25509
      TabOrder = 4
      OnClick = BtnConnClick
    end
    object BtnClear: TButton
      Left = 400
      Top = 37
      Width = 75
      Height = 25
      Caption = #28165#38500
      TabOrder = 5
      OnClick = BtnClearClick
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 70
    Width = 711
    Height = 333
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 403
    Width = 711
    Height = 19
    Panels = <
      item
        Text = #24403#21069#26102#38388
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 14
    Top = 114
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 42
    Top = 114
  end
  object mainMemu: TMainMenu
    Left = 16
    Top = 144
    object N1: TMenuItem
      Caption = #31995#32479#35774#32622
      object N4: TMenuItem
        Caption = #21551#21160#26381#21153
        Enabled = False
        OnClick = N4Click
      end
      object N5: TMenuItem
        Caption = #20572#27490#26381#21153
        OnClick = N5Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object N10: TMenuItem
        Caption = #21442#25968#35774#32622
        OnClick = N10Click
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object N7: TMenuItem
        Caption = #36864#20986
        OnClick = N7Click
      end
    end
    object N2: TMenuItem
      Caption = #33756#21333#31649#29702
      object N8: TMenuItem
        Caption = #21019#24314#33756#21333
        OnClick = N8Click
      end
      object N9: TMenuItem
        Caption = #21024#38500#33756#21333
        OnClick = N9Click
      end
    end
    object N12: TMenuItem
      Caption = #27169#26495#31649#29702
      object N13: TMenuItem
        Caption = #22686#21152#27169#26495
        OnClick = N13Click
      end
      object N14: TMenuItem
        Caption = #21024#38500#27169#29256
        OnClick = N14Click
      end
    end
    object N3: TMenuItem
      Caption = #25968#25454#24211
      OnClick = N3Click
    end
  end
  object NowTimer: TTimer
    OnTimer = NowTimerTimer
    Left = 66
    Top = 114
  end
end
