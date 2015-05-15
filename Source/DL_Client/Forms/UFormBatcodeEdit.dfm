inherited fFormBatcodeEdit: TfFormBatcodeEdit
  Left = 476
  Top = 336
  ClientHeight = 240
  ClientWidth = 397
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 397
    Height = 240
    inherited BtnOK: TButton
      Left = 251
      Top = 207
      TabOrder = 9
    end
    inherited BtnExit: TButton
      Left = 321
      Top = 207
      TabOrder = 10
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 2
      Width = 116
    end
    object EditBatch: TcxTextEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 0
      Width = 125
    end
    object EditRund: TcxTextEdit [4]
      Left = 259
      Top = 161
      ParentFont = False
      TabOrder = 7
      Text = '0'
      Width = 121
    end
    object EditStock: TcxComboBox [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 18
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    object EditInit: TcxTextEdit [6]
      Left = 259
      Top = 136
      ParentFont = False
      TabOrder = 5
      Text = '0'
      Width = 271
    end
    object EditPlan: TcxTextEdit [7]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 4
      Text = '2000'
      Width = 115
    end
    object EditWarn: TcxTextEdit [8]
      Left = 81
      Top = 161
      ParentFont = False
      TabOrder = 6
      Text = '5'
      Width = 115
    end
    object Check1: TcxCheckBox [9]
      Left = 11
      Top = 207
      Caption = #26159#21542#21551#29992
      ParentFont = False
      TabOrder = 8
      Transparent = True
      Width = 121
    end
    object EditBrand: TcxComboBox [10]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25209' '#27425' '#21495':'
          Control = EditBatch
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #29289#26009#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #27700#27877#21697#29260':'
          Control = EditBrand
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              Caption = #35745#21010#24635#37327':'
              Control = EditPlan
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21021#22987#24050#21457':'
              Control = EditInit
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              Caption = #39044' '#35686' '#37327':'
              Control = EditWarn
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item3: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #36864' '#36135' '#37327':'
              Control = EditRund
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item10: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
