inherited fFramePrintHYDan: TfFramePrintHYDan
  Width = 891
  Height = 590
  Color = 14474460
  object Pnl_OrderInfo: TPanel
    Left = 0
    Top = 0
    Width = 891
    Height = 590
    Align = alClient
    BevelOuter = bvNone
    Color = 15592941
    TabOrder = 0
    object lbl_2: TLabel
      Left = 8
      Top = 16
      Width = 265
      Height = 68
      Caption = #25552#36135#21333#21495#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = 7895160
      Font.Height = -53
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object btnPrint: TSpeedButton
      Left = 589
      Top = 477
      Width = 236
      Height = 57
      Caption = #25171#21360#21270#39564#21333
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
      OnClick = btnPrintClick
    end
    object EditID: TcxTextEdit
      Left = 288
      Top = 16
      AutoSize = False
      ParentFont = False
      Properties.OnChange = EditIDPropertiesChange
      Style.Font.Charset = GB2312_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -53
      Style.Font.Name = #24494#36719#38597#40657
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Height = 68
      Width = 577
    end
  end
end
