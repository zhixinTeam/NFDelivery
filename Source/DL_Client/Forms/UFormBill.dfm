inherited fFormBill: TfFormBill
  Left = 700
  Top = 217
  Caption = 'P'
  ClientHeight = 454
  ClientWidth = 423
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 423
    Height = 454
    inherited BtnOK: TButton
      Left = 277
      Top = 421
      Caption = #24320#21333
      TabOrder = 14
    end
    inherited BtnExit: TButton
      Left = 347
      Top = 421
      TabOrder = 15
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 373
      Height = 165
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 295
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
    end
    object EditTruck: TcxTextEdit [3]
      Left = 81
      Top = 306
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 5
      OnKeyPress = EditLadingKeyPress
      Width = 115
    end
    object EditLading: TcxComboBox [4]
      Left = 81
      Top = 206
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'T=T'#12289#33258#25552
        'S=S'#12289#36865#36135
        'X=X'#12289#36816#21368)
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditFQ: TcxTextEdit [5]
      Left = 260
      Top = 281
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 7
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditType: TcxComboBox [6]
      Left = 81
      Top = 231
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#26632#21488
        'V=V'#12289'VIP'
        'S=S'#12289#33337#36816)
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 120
    end
    object EditValue: TcxTextEdit [7]
      Left = 260
      Top = 306
      ParentFont = False
      TabOrder = 8
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditPack: TcxComboBox [8]
      Left = 81
      Top = 281
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 18
      Properties.Items.Strings = (
        'C=C'#12289#26222#36890
        'Z=Z'#12289#32440#34955
        'T=T'#12289#28034#33180#34955
        'R=R'#12289#26089#24378#22411
        'F=F'#12289#22797#21512#34955)
      TabOrder = 4
      OnKeyPress = EditLadingKeyPress
      Width = 110
    end
    object EditBrand: TcxTextEdit [9]
      Left = 260
      Top = 256
      ParentFont = False
      TabOrder = 6
      Width = 121
    end
    object EditLineGroup: TcxComboBox [10]
      Left = 81
      Top = 256
      ParentFont = False
      TabOrder = 3
      Width = 116
    end
    object EditMemo: TcxTextEdit [11]
      Left = 81
      Top = 356
      ParentFont = False
      TabOrder = 11
      Width = 121
    end
    object EditPoundStation: TcxComboBox [12]
      Left = 81
      Top = 331
      ParentFont = False
      TabOrder = 9
      Width = 121
    end
    object PrintHY: TcxCheckBox [13]
      Left = 11
      Top = 421
      Caption = #25171#21360#21270#39564#21333
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 95
    end
    object SnapTruck: TcxCheckBox [14]
      Left = 111
      Top = 421
      Caption = #36827#21378#36827#34892#36710#29260#35782#21035
      ParentFont = False
      State = cbsChecked
      TabOrder = 13
      Width = 121
    end
    object EditHisValueMax: TcxTextEdit [15]
      Left = 295
      Top = 331
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 10
      Width = 85
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group5: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item12: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #25552#36135#26041#24335':'
              Control = EditLading
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #25552#36135#36890#36947':'
              Control = EditType
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Group6: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item10: TdxLayoutItem
                Caption = #36890#36947#20998#32452':'
                Control = EditLineGroup
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item7: TdxLayoutItem
                Caption = #21253#35013#31867#22411':'
                Control = EditPack
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item9: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #25552#36135#36710#36742':'
                Control = EditTruck
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item8: TdxLayoutItem
                Caption = #27700#27877#21697#29260':'
                Control = EditBrand
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item5: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #25209#27425#32534#21495':'
                Control = EditFQ
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item4: TdxLayoutItem
                Caption = #25552#36135#37327#21544':'
                Control = EditValue
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item13: TdxLayoutItem
            Caption = #25351#23450#22320#30917':'
            Control = EditPoundStation
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item16: TdxLayoutItem
            Caption = #21382#21490#26368#22823#25552#36135#37327
            Control = EditHisValueMax
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item14: TdxLayoutItem [0]
          ShowCaption = False
          Control = PrintHY
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem [1]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = SnapTruck
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
