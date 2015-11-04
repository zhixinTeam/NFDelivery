inherited fFormBatcode: TfFormBatcode
  Left = 476
  Top = 336
  ClientHeight = 222
  ClientWidth = 397
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 397
    Height = 222
    inherited BtnOK: TButton
      Left = 251
      Top = 189
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 321
      Top = 189
      TabOrder = 9
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 80
      TabOrder = 1
      Width = 116
    end
    object EditPrefix: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 5
      TabOrder = 2
      Width = 125
    end
    object EditInter: TcxTextEdit [4]
      Left = 259
      Top = 136
      ParentFont = False
      TabOrder = 6
      Text = '1'
      Width = 121
    end
    object EditStock: TcxComboBox [5]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 18
      Properties.ItemHeight = 20
      TabOrder = 0
      Width = 121
    end
    object EditInc: TcxTextEdit [6]
      Left = 259
      Top = 111
      ParentFont = False
      TabOrder = 4
      Text = '1'
      Width = 271
    end
    object EditBase: TcxTextEdit [7]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Text = '1'
      Width = 115
    end
    object EditLen: TcxTextEdit [8]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 5
      Text = '6'
      Width = 115
    end
    object Check1: TcxCheckBox [9]
      Left = 11
      Top = 189
      Caption = #20351#29992#26085#26399#32534#30721
      ParentFont = False
      TabOrder = 7
      Transparent = True
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
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
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Item5: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #32534#21495#21069#32512':'
            Control = EditPrefix
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              Caption = #32534#21495#22522#25968':'
              Control = EditBase
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #32534#21495#22686#37327':'
              Control = EditInc
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item8: TdxLayoutItem
              Caption = #32534#21495#38271#24230':'
              Control = EditLen
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item3: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #26102#38271'('#22825'):'
              Control = EditInter
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
