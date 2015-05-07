inherited fFormMine: TfFormMine
  Left = 576
  Top = 350
  ClientHeight = 314
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 314
    inherited BtnOK: TButton
      Left = 229
      Top = 281
      TabOrder = 9
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 281
      TabOrder = 10
    end
    object EditMine: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 0
      OnKeyPress = EditMineKeyPress
      Width = 116
    end
    object EditOwner: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 1
      Width = 125
    end
    object EditPhone: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object cxCheckValid: TcxCheckBox [5]
      Left = 11
      Top = 281
      Caption = #30719#28857#26377#25928
      ParentFont = False
      State = cbsChecked
      TabOrder = 8
      Transparent = True
      Width = 121
    end
    object EditCusID: TcxTextEdit [6]
      Left = 81
      Top = 149
      TabOrder = 3
      OnKeyPress = EditCusNameKeyPress
      Width = 121
    end
    object EditCusName: TcxTextEdit [7]
      Left = 81
      Top = 174
      TabOrder = 4
      OnKeyPress = EditCusNameKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [8]
      Left = 81
      Top = 199
      TabOrder = 5
      OnKeyPress = EditStockKeyPress
      Width = 121
    end
    object EditStockName: TcxTextEdit [9]
      Left = 81
      Top = 224
      TabOrder = 6
      OnKeyPress = EditStockKeyPress
      Width = 121
    end
    object EditArea: TcxTextEdit [10]
      Left = 81
      Top = 249
      TabOrder = 7
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #30719#28857#21517#31216':'
          Control = EditMine
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32852' '#31995' '#20154':'
            Control = EditOwner
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32852#31995#26041#24335':'
            Control = EditPhone
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #38468#21152#21442#25968
        object dxLayout1Item6: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStockName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #21306#22495#21517#31216':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = cxCheckValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
