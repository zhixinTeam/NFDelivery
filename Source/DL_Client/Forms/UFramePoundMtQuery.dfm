inherited fFramePoundMtQuery: TfFramePoundMtQuery
  Width = 976
  Height = 582
  inherited ToolBar1: TToolBar
    Width = 976
    inherited BtnAdd: TToolButton
      Visible = False
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
    inherited S1: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 976
    Height = 377
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 976
    Height = 138
    object cxTextEdit1: TcxTextEdit [0]
      Left = 81
      Top = 93
      Hint = 'T.Truck'
      ParentFont = False
      TabOrder = 3
      Width = 125
    end
    object EditTruck: TcxButtonEdit [1]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditCus: TcxButtonEdit [2]
      Left = 269
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 125
    end
    object EditDate: TcxButtonEdit [3]
      Left = 457
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 185
    end
    object cxTextEdit4: TcxTextEdit [4]
      Left = 305
      Top = 93
      Hint = 'T.TotalWeight'
      ParentFont = False
      TabOrder = 4
      Width = 125
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #24403#21069#24635#32047#35745#37325#37327':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 976
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 976
    inherited TitleBar: TcxLabel
      Caption = #30721#22836#25235#26007#31204#31216#37327#26597#35810
      Style.IsFontAssigned = True
      Width = 976
      AnchorX = 488
      AnchorY = 11
    end
  end
  object Check1: TcxCheckBox [5]
    Left = 651
    Top = 96
    Caption = #26597#35810#24050#21024#38500
    ParentFont = False
    TabOrder = 5
    Transparent = True
    OnClick = Check1Click
    Width = 110
  end
  inherited SQLQuery: TADOQuery
    Left = 2
    Top = 234
  end
  inherited DataSource1: TDataSource
    Left = 30
    Top = 234
  end
end
