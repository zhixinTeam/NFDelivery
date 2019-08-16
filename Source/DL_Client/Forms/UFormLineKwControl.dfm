inherited fFormLineKwControl: TfFormLineKwControl
  Left = 482
  Top = 252
  ClientHeight = 166
  ClientWidth = 414
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 414
    Height = 166
    inherited BtnOK: TButton
      Left = 268
      Top = 133
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 338
      Top = 133
      TabOrder = 4
    end
    object EditLine: TcxComboBox [2]
      Left = 81
      Top = 76
      ParentFont = False
      TabOrder = 0
      Width = 121
    end
    object EditKw: TcxTextEdit [3]
      Left = 81
      Top = 101
      TabOrder = 1
      Width = 121
    end
    object cxLabel1: TcxLabel [4]
      Left = 207
      Top = 101
      Caption = #26684#24335':(1,3,5,7)'
      ParentFont = False
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #35013#36710#32447#24211#20301#25511#21046
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #25511#21046#21442#25968
        object dxLayout1Item5: TdxLayoutItem
          Caption = #36890#36947#21517#31216':'
          Control = EditLine
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item3: TdxLayoutItem
            Caption = #24211#20301#20851#31995':'
            Control = EditKw
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item4: TdxLayoutItem
            Caption = 'cxLabel1'
            ShowCaption = False
            Control = cxLabel1
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
