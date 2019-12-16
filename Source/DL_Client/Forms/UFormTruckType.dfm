inherited fFormTruckType: TfFormTruckType
  Left = 482
  Top = 252
  ClientHeight = 188
  ClientWidth = 423
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 423
    Height = 188
    inherited BtnOK: TButton
      Left = 277
      Top = 155
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 347
      Top = 155
      TabOrder = 4
    end
    object ChkUseControl: TcxCheckBox [2]
      Left = 23
      Top = 36
      Caption = #21551#29992#36710#36742#31867#22411#24635#25511#21046
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditValue: TcxTextEdit [3]
      Left = 81
      Top = 123
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditType: TcxTextEdit [4]
      Left = 81
      Top = 98
      TabOrder = 1
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #36710#36742#31867#22411#24635#25511#21046
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkUseControl
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #25511#21046#21442#25968
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#36724#31867#22411':'
          Control = EditType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #38480' '#36733' '#37327':'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
