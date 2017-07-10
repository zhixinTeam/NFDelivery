inherited fFrameBillHaulBack: TfFrameBillHaulBack
  Width = 1065
  Height = 513
  inherited ToolBar1: TToolBar
    Width = 1065
    inherited BtnAdd: TToolButton
      Caption = #21150#21345
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 205
    Width = 1065
    Height = 308
    inherited cxView1: TcxGridDBTableView
      PopupMenu = PMenu1
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 1065
    Height = 138
    object EditTruck: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    object cxTextEdit1: TcxTextEdit [1]
      Left = 81
      Top = 94
      Hint = 'T.H_ID'
      ParentFont = False
      TabOrder = 4
      Width = 115
    end
    object cxTextEdit4: TcxTextEdit [2]
      Left = 259
      Top = 94
      Hint = 'T.H_Truck'
      ParentFont = False
      TabOrder = 5
      Width = 115
    end
    object EditDate: TcxButtonEdit [3]
      Left = 443
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 2
      Width = 176
    end
    object Edit1: TcxTextEdit [4]
      Left = 621
      Top = 94
      Hint = 'T.H_MName'
      ParentFont = False
      TabOrder = 7
      Width = 176
    end
    object CheckDelete: TcxCheckBox [5]
      Left = 624
      Top = 36
      Caption = #26597#35810#24050#21024#38500
      ParentFont = False
      TabOrder = 3
      Transparent = True
      OnClick = CheckDeleteClick
      Width = 105
    end
    object EditCusName: TcxButtonEdit [6]
      Left = 259
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [7]
      Left = 437
      Top = 94
      Hint = 'T.H_CusName'
      ParentFont = False
      TabOrder = 6
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          ShowCaption = False
          Control = CheckDelete
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21333#25454#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = Edit1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 197
    Width = 1065
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 1065
    inherited TitleBar: TcxLabel
      Caption = #22238#31354#21150#21345#35760#24405#26597#35810
      Style.IsFontAssigned = True
      Width = 1065
      AnchorX = 533
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Left = 4
    Top = 236
  end
  inherited DataSource1: TDataSource
    Left = 32
    Top = 236
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 4
    Top = 264
    object N2: TMenuItem
      Caption = #21150#29702'IC'#30913#21345
      OnClick = N2Click
    end
    object N1: TMenuItem
      Caption = #27880#38144'IC'#30913#21345
      OnClick = N1Click
    end
  end
end
