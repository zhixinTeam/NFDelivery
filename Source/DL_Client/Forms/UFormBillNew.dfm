inherited fFormBillNew: TfFormBillNew
  Left = 520
  Top = 194
  ClientHeight = 313
  ClientWidth = 419
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 419
    Height = 313
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 273
      Top = 280
      Caption = #24320#21333
      TabOrder = 7
    end
    inherited BtnExit: TButton
      Left = 343
      Top = 280
      TabOrder = 9
    end
    object EditValue: TcxTextEdit [2]
      Left = 272
      Top = 231
      ParentFont = False
      TabOrder = 6
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCus: TcxTextEdit [3]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = False
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditCName: TcxTextEdit [4]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditStock: TcxTextEdit [5]
      Left = 81
      Top = 156
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 128
    end
    object EditSName: TcxTextEdit [6]
      Left = 81
      Top = 181
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 3
      OnKeyPress = EditLadingKeyPress
      Width = 304
    end
    object EditTruck: TcxButtonEdit [7]
      Left = 81
      Top = 231
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 128
    end
    object EditType: TcxComboBox [8]
      Left = 272
      Top = 206
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object ListStock: TcxComboBox [9]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.ReadOnly = False
      Properties.OnChange = ListStockPropertiesChange
      TabOrder = 12
      Width = 121
    end
    object EditPack: TcxComboBox [10]
      Left = 81
      Top = 206
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#32440#34955
        'T=T'#12289#28034#33180#34955
        'R=R'#12289#26089#24378#22411)
      TabOrder = 13
      Width = 128
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem
          Caption = #29289#26009#21015#34920':'
          Control = ListStock
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCus
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item4: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCName
          ControlOptions.ShowBorder = False
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        object dxGroupLayout1Group7: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxlytmLayout1Item9: TdxLayoutItem
            Caption = #27700#27877#32534#21495':'
            Control = EditStock
            ControlOptions.ShowBorder = False
          end
          object dxlytmLayout1Item10: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #27700#27877#21517#31216':'
            Control = EditSName
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item3: TdxLayoutItem
              Caption = #21253#35013#31867#22411':'
              Control = EditPack
              ControlOptions.ShowBorder = False
            end
            object dxlytmLayout1Item13: TdxLayoutItem
              Caption = #25552#36135#36890#36947':'
              Control = EditType
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxGroupLayout1Group6: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxlytmLayout1Item12: TdxLayoutItem
            Caption = #25552#36135#36710#36742':'
            Control = EditTruck
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item8: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #21150#29702#21544#25968':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
end
