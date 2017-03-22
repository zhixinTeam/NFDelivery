inherited fFrameStationStandard: TfFrameStationStandard
  Width = 770
  Height = 425
  inherited ToolBar1: TToolBar
    Width = 770
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 193
    Width = 770
    Height = 232
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 770
    Height = 126
    object EditID: TcxButtonEdit [0]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      Width = 121
    end
    object cxTextEdit1: TcxTextEdit [1]
      Left = 81
      Top = 93
      Hint = 'T.S_TruckPreFix'
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 265
      Top = 93
      Hint = 'T.S_Value'
      TabOrder = 2
      Width = 121
    end
    object cxTextEdit3: TcxTextEdit [3]
      Left = 449
      Top = 93
      Hint = 'T.S_StockName'
      TabOrder = 3
      Width = 121
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #36710#21410#21069#32512':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36710#21410#21069#32512':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item2: TdxLayoutItem
          Caption = #36710#21410#26631#37325':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = cxTextEdit3
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 185
    Width = 770
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 770
    inherited TitleBar: TcxLabel
      Caption = #36710#21410#26631#37325#26723#26696#31649#29702
      Style.IsFontAssigned = True
      Width = 770
      AnchorX = 385
      AnchorY = 11
    end
  end
end
