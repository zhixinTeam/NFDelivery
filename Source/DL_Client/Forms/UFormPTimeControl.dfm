inherited fFormPTimeControl: TfFormPTimeControl
  Left = 482
  Top = 252
  ClientHeight = 274
  ClientWidth = 414
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 414
    Height = 274
    inherited BtnOK: TButton
      Left = 268
      Top = 241
      TabOrder = 6
    end
    inherited BtnExit: TButton
      Left = 338
      Top = 241
      TabOrder = 7
    end
    object CheckValid: TcxCheckBox [2]
      Left = 23
      Top = 208
      Caption = #26377#25928
      ParentFont = False
      TabOrder = 5
      Transparent = True
      Width = 80
    end
    object ChkUseXz: TcxCheckBox [3]
      Left = 23
      Top = 36
      Caption = #21551#29992#21407#26448#26009#36827#21378#26102#38388#25511#21046
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxComboBox [4]
      Left = 81
      Top = 108
      ParentFont = False
      Properties.Alignment.Horz = taCenter
      Properties.IncrementalSearch = False
      Properties.OnChange = EditStockPropertiesChange
      TabOrder = 1
      Width = 121
    end
    object EditBegin: TcxTimeEdit [5]
      Left = 81
      Top = 133
      EditValue = 0d
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditEnd: TcxTimeEdit [6]
      Left = 81
      Top = 158
      EditValue = 0.999988425925926d
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditMemo: TcxTextEdit [7]
      Left = 81
      Top = 183
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #21407#26448#26009#36827#21378#26102#38388#24635#25511#21046
        object dxLayout1Item3: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkUseXz
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #21407#26448#26009#36827#21378#26102#38388#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36215#22987#26102#38388':'
          Control = EditBegin
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #32467#26463#26102#38388':'
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #25511#21046#22791#27880':'
          Control = EditMemo
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
