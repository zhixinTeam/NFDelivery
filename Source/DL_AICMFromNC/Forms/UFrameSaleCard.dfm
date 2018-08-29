inherited fFrameSaleCard: TfFrameSaleCard
  Width = 1000
  Height = 514
  Color = 14474460
  object Pnl_OrderInfo: TPanel
    Left = 0
    Top = 416
    Width = 1000
    Height = 98
    Align = alBottom
    BevelOuter = bvNone
    Color = 15592941
    TabOrder = 0
    object btnSave: TSpeedButton
      Left = 517
      Top = 21
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
  end
  object lvOrders: TListView
    Left = 0
    Top = 0
    Width = 1000
    Height = 416
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Columns = <
      item
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 1
    ViewStyle = vsReport
    OnClick = lvOrdersClick
  end
end
