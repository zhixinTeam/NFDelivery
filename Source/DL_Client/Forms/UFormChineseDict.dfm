inherited fFormChineseDict: TfFormChineseDict
  Left = 576
  Top = 350
  ClientHeight = 234
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 234
    inherited BtnOK: TButton
      Left = 229
      Top = 201
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 201
      TabOrder = 7
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 1
      Properties.OnChange = EditNamePropertiesChange
      TabOrder = 0
      Width = 116
    end
    object EditPrefix: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 100
      Properties.OnChange = EditNamePropertiesChange
      TabOrder = 1
      Text = '@R'
      Width = 125
    end
    object cxCheckValid: TcxCheckBox [4]
      Left = 11
      Top = 201
      Caption = #35268#21017#26377#25928
      ParentFont = False
      State = cbsChecked
      TabOrder = 5
      Transparent = True
      Width = 121
    end
    object EditValue: TcxTextEdit [5]
      Left = 81
      Top = 144
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditMemo: TcxTextEdit [6]
      Left = 81
      Top = 169
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditCode: TcxTextEdit [7]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.OnChange = EditNamePropertiesChange
      TabOrder = 2
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21943#30721#27721#23383':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21943#30721#21069#32512':'
          Control = EditPrefix
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #21943#30721#24207#21015':'
          Control = EditCode
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #38468#21152#21442#25968
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21943#30721#32534#30721':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #21943#30721#22791#27880':'
          Control = EditMemo
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
