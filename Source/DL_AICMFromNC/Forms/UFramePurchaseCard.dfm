inherited fFramePurchaseCard: TfFramePurchaseCard
  Width = 891
  Height = 590
  Color = 14474460
  object Pnl_OrderInfo: TPanel
    Left = 0
    Top = 328
    Width = 891
    Height = 262
    Align = alBottom
    BevelOuter = bvNone
    Color = 15592941
    TabOrder = 0
    object lbl_2: TLabel
      Left = 26
      Top = 2
      Width = 265
      Height = 68
      Caption = #23458#25143#21517#31216#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = 7895160
      Font.Height = -53
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lbl_3: TLabel
      Left = 26
      Top = 64
      Width = 265
      Height = 68
      Caption = #29289#26009#21517#31216#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = 7895160
      Font.Height = -53
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lbl_TruckId: TLabel
      Left = 26
      Top = 186
      Width = 265
      Height = 68
      Caption = #36710#29260#21495#30721#65306
      Font.Charset = GB2312_CHARSET
      Font.Color = 7895160
      Font.Height = -53
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object btnSave: TSpeedButton
      Left = 645
      Top = 197
      Width = 236
      Height = 57
      Caption = #30830#35748#26080#35823#24182#21150#21345
      Font.Charset = GB2312_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
      OnClick = btnSaveClick
    end
    object lbl_CusName: TLabel
      Left = 282
      Top = 4
      Width = 15
      Height = 66
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -51
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lbl_StockName: TLabel
      Left = 282
      Top = 68
      Width = 15
      Height = 66
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -51
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 26
      Top = 127
      Width = 247
      Height = 68
      Caption = #30719'       '#28857' :'
      Font.Charset = GB2312_CHARSET
      Font.Color = 7895160
      Font.Height = -53
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object lbl_Area: TLabel
      Left = 282
      Top = 131
      Width = 15
      Height = 66
      Font.Charset = GB2312_CHARSET
      Font.Color = clBlack
      Font.Height = -51
      Font.Name = #24494#36719#38597#40657
      Font.Style = []
      ParentFont = False
    end
    object edt_TruckNo: TcxComboBox
      Left = 283
      Top = 200
      AutoSize = False
      ParentFont = False
      Properties.ImmediatePost = True
      Properties.OnChange = edt_TruckNoPropertiesChange
      Style.BorderStyle = ebsSingle
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -36
      Style.Font.Name = #24494#36719#38597#40657
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Height = 45
      Width = 290
    end
  end
  object lvOrders: TListView
    Left = 0
    Top = 0
    Width = 891
    Height = 328
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Columns = <>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    RowSelect = True
    ParentFont = False
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = lvOrdersClick
  end
  object tmr1: TTimer
    Interval = 200
    OnTimer = tmr1Timer
    Left = 24
    Top = 184
  end
end
