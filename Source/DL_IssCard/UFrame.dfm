object Frame1: TFrame1
  Left = 0
  Top = 0
  Width = 347
  Height = 402
  TabOrder = 0
  object GroupBox1: TGroupBox
    Left = 8
    Top = 0
    Width = 332
    Height = 396
    TabOrder = 0
    object ToolBar1: TToolBar
      Left = 8
      Top = 509
      Width = 44
      Height = 0
      Align = alNone
      AutoSize = True
      ButtonHeight = 7
      ButtonWidth = 8
      Caption = 'ToolBar1'
      EdgeInner = esNone
      EdgeOuter = esNone
      ShowCaptions = True
      TabOrder = 0
      object ToolButton2: TToolButton
        Left = 0
        Top = 2
        Width = 8
        Caption = 'ToolButton2'
        ImageIndex = 1
        Style = tbsSeparator
      end
      object btnPause: TToolButton
        Left = 8
        Top = 2
        Width = 4
        Caption = #26242'  '#20572
        Enabled = False
        ImageIndex = 4
        Style = tbsSeparator
        Visible = False
      end
      object ToolButton9: TToolButton
        Left = 12
        Top = 2
        Width = 8
        Caption = 'ToolButton9'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton6: TToolButton
        Left = 20
        Top = 2
        Width = 8
        Caption = 'ToolButton6'
        ImageIndex = 3
        Style = tbsSeparator
      end
      object ToolButton10: TToolButton
        Left = 28
        Top = 2
        Width = 8
        Caption = 'ToolButton10'
        ImageIndex = 4
        Style = tbsSeparator
      end
      object ToolButton1: TToolButton
        Left = 36
        Top = 2
        Width = 8
        Caption = 'ToolButton1'
        ImageIndex = 4
        Style = tbsSeparator
      end
    end
    object GroupBox2: TGroupBox
      Left = 7
      Top = 15
      Width = 316
      Height = 86
      Caption = #24403#21069#36755#20837
      TabOrder = 1
      object EditValue: TcxTextEdit
        Left = 0
        Top = 19
        AutoSize = False
        ParentFont = False
        Properties.ReadOnly = True
        Style.BorderStyle = ebsNone
        Style.Font.Charset = ANSI_CHARSET
        Style.Font.Color = clYellow
        Style.Font.Height = -43
        Style.Font.Name = 'Roboto Cn'
        Style.Font.Style = []
        Style.IsFontAssigned = True
        TabOrder = 0
        Height = 62
        Width = 316
      end
    end
    object MemoLog: TMemo
      Left = 7
      Top = 104
      Width = 314
      Height = 289
      Lines.Strings = (
        'MemoLog')
      TabOrder = 2
    end
  end
  object InitTimer: TTimer
    Enabled = False
    OnTimer = InitTimerTimer
    Left = 144
    Top = 152
  end
  object GetTruckTimer: TTimer
    Interval = 2000
    OnTimer = GetTruckTimerTimer
    Left = 176
    Top = 152
  end
end
