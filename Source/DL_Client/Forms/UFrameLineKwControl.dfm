inherited fFrameLineKwControl: TfFrameLineKwControl
  Width = 830
  Height = 422
  inherited ToolBar1: TToolBar
    Width = 830
    inherited BtnAdd: TToolButton
      OnClick = BtnAddClick
    end
    inherited BtnEdit: TToolButton
      OnClick = BtnEditClick
    end
    inherited BtnDel: TToolButton
      OnClick = BtnDelClick
    end
  end
  inherited cxGrid1: TcxGrid
    Top = 199
    Width = 830
    Height = 223
  end
  inherited dxLayout1: TdxLayoutControl
    Width = 830
    Height = 132
    object EditID: TcxButtonEdit [0]
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
      Width = 105
    end
    object cxTextEdit1: TcxTextEdit [1]
      Left = 81
      Top = 93
      Hint = 'T.D_Value'
      ParentFont = False
      TabOrder = 1
      Width = 105
    end
    object cxTextEdit2: TcxTextEdit [2]
      Left = 249
      Top = 93
      Hint = 'T.D_ParamB'
      ParentFont = False
      TabOrder = 2
      Width = 150
    end
    inherited dxGroup1: TdxLayoutGroup
      inherited GroupSearch1: TdxLayoutGroup
        object dxLayout1Item1: TdxLayoutItem
          Caption = #36890#36947#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
      end
      inherited GroupDetail1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #36890#36947#32534#21495':'
          Control = cxTextEdit1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #24211#20301#20851#31995':'
          Control = cxTextEdit2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  inherited cxSplitter1: TcxSplitter
    Top = 191
    Width = 830
  end
  inherited TitlePanel1: TZnBitmapPanel
    Width = 830
    inherited TitleBar: TcxLabel
      Caption = #35013#36710#32447#24211#20301#20998#32452#25511#21046
      Style.IsFontAssigned = True
      Width = 830
      AnchorX = 415
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
end
