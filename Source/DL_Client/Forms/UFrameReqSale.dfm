inherited fFrameReqSale: TfFrameReqSale
  Width = 985
  Height = 516
  inherited ToolBar1: TToolBar
    Width = 985
    inherited BtnAdd: TToolButton
      Caption = #24320#21333
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      Visible = False
    end
    inherited BtnDel: TToolButton
      Visible = False
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 202
    Width = 985
    Height = 314
    inherited cxView1: TcxGridDBTableView
      OnCustomDrawCell = cxView1CustomDrawCell
    end
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 985
    Height = 135
    object cxTextEdit1: TcxTextEdit [0]
      Left = 259
      Top = 93
      Hint = 'T.custname'
      ParentFont = False
      TabOrder = 5
      Width = 115
    end
    object EditName: TcxButtonEdit [1]
      Left = 259
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 1
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 437
      Top = 93
      Hint = 'T.invname'
      ParentFont = False
      TabOrder = 6
      Width = 115
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 627
      Top = 93
      Hint = 'T.NPLANNUM'
      ParentFont = False
      TabOrder = 7
      Width = 115
    end
    object EditDate: TcxButtonEdit [4]
      Left = 615
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditDatePropertiesButtonClick
      TabOrder = 3
      Width = 175
    end
    object EditID: TcxButtonEdit [5]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 115
    end
    object cxTextEdit4: TcxTextEdit [6]
      Left = 81
      Top = 93
      Hint = 'T.VBILLCODE'
      ParentFont = False
      TabOrder = 4
      Width = 115
    end
    object EditTruck: TcxButtonEdit [7]
      Left = 431
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item7: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #26085#26399#31579#36873':'
          Control = EditDate
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item8: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = cxTextEdit4
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item1: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #25552#36135#21697#31181':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #35746#21333#37327'('#21544'):'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 194
    Width = 985
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 985
    inherited TitleBar: TcxLabel
      Caption = #38144#21806#35746#21333#30003#35831#21333
      Style.IsFontAssigned = True
      Width = 985
      AnchorX = 493
      AnchorY = 11
    end
  end
  inherited SQLQuery: TADOQuery
    Top = 234
  end
  inherited DataSource1: TDataSource
    Top = 234
  end
end
