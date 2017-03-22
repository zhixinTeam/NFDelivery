inherited fFormStationStandard: TfFormStationStandard
  Left = 586
  Top = 381
  ClientHeight = 257
  ClientWidth = 375
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 257
    inherited BtnOK: TButton
      Left = 229
      Top = 224
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 224
      TabOrder = 8
    end
    object EditValue: TcxTextEdit [2]
      Left = 81
      Top = 161
      ParentFont = False
      TabOrder = 5
      Text = '0.00'
      Width = 121
    end
    object CheckValid: TcxCheckBox [3]
      Left = 11
      Top = 224
      Caption = #35268#21017#26377#25928
      ParentFont = False
      State = cbsChecked
      TabOrder = 6
      Transparent = True
      Width = 121
    end
    object EditPreFix: TcxTextEdit [4]
      Left = 81
      Top = 36
      TabOrder = 0
      Width = 121
    end
    object EditStockID: TcxComboBox [5]
      Left = 81
      Top = 61
      Properties.OnEditValueChanged = EditStockIDPropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    object EditStockName: TcxTextEdit [6]
      Left = 81
      Top = 86
      TabOrder = 2
      Width = 121
    end
    object EditCusID: TcxComboBox [7]
      Left = 81
      Top = 111
      Properties.OnEditValueChanged = EditStockIDPropertiesEditValueChanged
      TabOrder = 3
      Width = 121
    end
    object EditCusName: TcxTextEdit [8]
      Left = 81
      Top = 136
      TabOrder = 4
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #36710#21410#21069#32512':'
          Control = EditPreFix
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditStockID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #26631' '#37325' '#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
