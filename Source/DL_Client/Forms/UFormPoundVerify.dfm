inherited fFormPoundVerify: TfFormPoundVerify
  Left = 445
  Top = 157
  ClientHeight = 370
  ClientWidth = 396
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 396
    Height = 370
    inherited BtnOK: TButton
      Left = 250
      Top = 337
      TabOrder = 9
    end
    inherited BtnExit: TButton
      Left = 320
      Top = 337
      TabOrder = 10
    end
    object EditPID: TcxButtonEdit [2]
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
    object EditStockNO: TcxComboBox [3]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditLineGroup: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditTruck: TcxTextEdit [5]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditMemo: TcxMemo [6]
      Left = 23
      Top = 182
      Lines.Strings = (
        '')
      ParentFont = False
      TabOrder = 6
      Height = 89
      Width = 185
    end
    object cxLabel1: TcxLabel [7]
      Left = 23
      Top = 161
      Caption = #22791#27880#21407#22240':'
      ParentFont = False
      Transparent = True
    end
    object EditPValue: TcxTextEdit [8]
      Left = 81
      Top = 276
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 7
      Width = 121
    end
    object EditMValue: TcxTextEdit [9]
      Left = 81
      Top = 301
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 8
      Width = 121
    end
    object EditBill: TcxTextEdit [10]
      Left = 81
      Top = 136
      TabOrder = 4
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #30917#21333#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = #30917#21333#32534#21495':'
          Control = EditPID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStockNO
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #25918#28784#20179#24211':'
          Control = EditLineGroup
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = #25209' '#27425' '#21495':'
          Control = EditBill
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #30382#37325'('#21544'):'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #27611#37325'('#21544'):'
          Control = EditMValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
