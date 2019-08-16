inherited fFormPoundControl: TfFormPoundControl
  Left = 482
  Top = 252
  ClientHeight = 211
  ClientWidth = 414
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 414
    Height = 211
    inherited BtnOK: TButton
      Left = 268
      Top = 178
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 338
      Top = 178
      TabOrder = 5
    end
    object CheckValid: TcxCheckBox [2]
      Left = 23
      Top = 145
      Caption = #25511#21046#26377#25928
      ParentFont = False
      TabOrder = 3
      Transparent = True
      Width = 80
    end
    object ChkUseControl: TcxCheckBox [3]
      Left = 23
      Top = 36
      Caption = #21551#29992#36807#30917#29289#26009#24635#25511#21046
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxComboBox [4]
      Left = 81
      Top = 120
      ParentFont = False
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 2
      Width = 121
    end
    object EditPoundStation: TcxComboBox [5]
      Left = 81
      Top = 95
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36807#30917#29289#26009#24635#25511#21046
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkUseControl
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #25511#21046#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          Caption = #22320#30917#21517#31216':'
          Control = EditPoundStation
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
