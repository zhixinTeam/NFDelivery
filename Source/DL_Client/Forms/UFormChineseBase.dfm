inherited fFormChineseBase: TfFormChineseBase
  Left = 717
  Top = 310
  ClientHeight = 235
  ClientWidth = 375
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 375
    Height = 235
    inherited BtnOK: TButton
      Left = 229
      Top = 202
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 299
      Top = 202
      TabOrder = 7
    end
    object EditSource: TcxTextEdit [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 50
      TabOrder = 1
      Width = 116
    end
    object EditPrintCode: TcxTextEdit [3]
      Left = 81
      Top = 145
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = True
      TabOrder = 3
      Width = 125
    end
    object EditValue: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object cxCheckValid: TcxCheckBox [5]
      Left = 11
      Top = 202
      Caption = #35268#21017#26377#25928
      ParentFont = False
      State = cbsChecked
      TabOrder = 5
      Transparent = True
      Width = 121
    end
    object EditMemo: TcxTextEdit [6]
      Left = 81
      Top = 170
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditName: TcxButtonEdit [7]
      Left = 81
      Top = 36
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      TabOrder = 0
      OnKeyPress = EditNameKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #21306#22495#27969#21521':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21306#22495#20195#30721':'
          Control = EditSource
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #21943#30721#20869#23481':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #38468#21152#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #27721#23383#32534#30721':'
          Control = EditPrintCode
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #22791'    '#27880':'
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
