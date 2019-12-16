inherited fFormStockMatch: TfFormStockMatch
  Left = 482
  Top = 252
  ClientHeight = 191
  ClientWidth = 423
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 423
    Height = 191
    inherited BtnOK: TButton
      Left = 277
      Top = 158
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 347
      Top = 158
      TabOrder = 4
    end
    object CheckValid: TcxCheckBox [2]
      Left = 23
      Top = 125
      Caption = #25511#21046#26377#25928
      ParentFont = False
      TabOrder = 2
      Transparent = True
      Width = 80
    end
    object EditStock: TcxComboBox [3]
      Left = 81
      Top = 100
      ParentFont = False
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 1
      Width = 121
    end
    object EditID: TcxTextEdit [4]
      Left = 81
      Top = 75
      TabOrder = 0
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21697#31181#20998#32452
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #20998#32452#21442#25968
        object dxLayout1Item3: TdxLayoutItem
          Caption = #20998#32452#21517#31216':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
