inherited fFormTruck: TfFormTruck
  Left = 492
  Top = 186
  ClientHeight = 394
  ClientWidth = 355
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 355
    Height = 394
    inherited BtnOK: TButton
      Left = 209
      Top = 361
      TabOrder = 13
    end
    inherited BtnExit: TButton
      Left = 279
      Top = 361
      TabOrder = 14
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 0
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
    object CheckValid: TcxCheckBox [5]
      Left = 23
      Top = 276
      Caption = #36710#36742#20801#35768#24320#21333'.'
      ParentFont = False
      TabOrder = 8
      Transparent = True
      Width = 80
    end
    object CheckVerify: TcxCheckBox [6]
      Left = 23
      Top = 328
      Caption = #39564#35777#36710#36742#24050#21040#20572#36710#22330'.'
      ParentFont = False
      TabOrder = 11
      Transparent = True
      Width = 165
    end
    object CheckUserP: TcxCheckBox [7]
      Left = 23
      Top = 302
      Caption = #36710#36742#20351#29992#39044#32622#30382#37325'.'
      ParentFont = False
      TabOrder = 9
      Transparent = True
      Width = 165
    end
    object CheckVip: TcxCheckBox [8]
      Left = 193
      Top = 302
      Caption = 'VIP'#36710#36742
      ParentFont = False
      TabOrder = 10
      Transparent = True
      Width = 100
    end
    object CheckGPS: TcxCheckBox [9]
      Left = 193
      Top = 328
      Caption = #24050#23433#35013'GPS'
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 100
    end
    object EditValue: TcxTextEdit [10]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Text = '0.00'
      Width = 121
    end
    object EditMValueMax: TcxTextEdit [11]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditWarnPValue: TcxTextEdit [12]
      Left = 81
      Top = 186
      ParentFont = False
      TabOrder = 6
      Text = '0.00'
      Width = 121
    end
    object EditHz: TcxTextEdit [13]
      Left = 81
      Top = 161
      ParentFont = False
      TabOrder = 5
      Width = 121
    end
    object EditType: TcxComboBox [14]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      TabOrder = 7
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36710#20027#22995#21517':'
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
          object dxLayout1Item11: TdxLayoutItem
            Caption = #39044#32622#30382#37325':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #27611#37325#19978#38480':'
          Control = EditMValueMax
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          Caption = #26680#36733#19978#38480':'
          Control = EditHz
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #39044#35686#30382#37325':'
          Control = EditWarnPValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = #36710#36724#31867#22411':'
          Control = EditType
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #36710#36742#21442#25968
        object dxLayout1Item4: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = CheckValid
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item6: TdxLayoutItem
            ShowCaption = False
            Control = CheckUserP
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckVip
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item7: TdxLayoutItem
            Caption = 'cxCheckBox2'
            ShowCaption = False
            Control = CheckVerify
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = CheckGPS
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
