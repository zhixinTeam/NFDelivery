inherited fFormPoundAdjust: TfFormPoundAdjust
  Left = 666
  Top = 245
  ClientHeight = 426
  ClientWidth = 513
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 513
    Height = 426
    inherited BtnOK: TButton
      Left = 367
      Top = 393
      TabOrder = 17
    end
    inherited BtnExit: TButton
      Left = 437
      Top = 393
      TabOrder = 18
    end
    object EditCusName: TcxTextEdit [2]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 2
      Width = 300
    end
    object EditTruck: TcxTextEdit [3]
      Left = 279
      Top = 136
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = False
      TabOrder = 5
      Width = 165
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 186
      AutoSize = False
      Caption = #30382#37325':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 200
    end
    object EditPValue: TcxTextEdit [5]
      Left = 81
      Top = 219
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 8
      Width = 135
    end
    object cxLabel2: TcxLabel [6]
      Left = 23
      Top = 244
      AutoSize = False
      Caption = #27611#37325':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 258
    end
    object EditMValue: TcxTextEdit [7]
      Left = 81
      Top = 277
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 11
      Width = 135
    end
    object cxLabel3: TcxLabel [8]
      Left = 23
      Top = 302
      AutoSize = False
      Caption = #29366#24577':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 633
      AnchorY = 316
    end
    object EditID: TcxTextEdit [9]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 121
    end
    object EditStock: TcxTextEdit [10]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.MaxLength = 80
      Properties.ReadOnly = False
      TabOrder = 4
      Width = 135
    end
    object EditStatus: TcxComboBox [11]
      Left = 81
      Top = 335
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        'I=I'#12289#36827#21378
        'O=O'#12289#20986#21378
        'P=P'#12289#31216#30382#37325
        'M=M'#12289#31216#27611#37325
        'S=S'#12289#36865#36135#20013
        'F=F'#12289#25918#28784#22788
        'Z=Z'#12289#26632#21488
        'X=X'#12289#29616#22330#39564#25910)
      TabOrder = 14
      Width = 135
    end
    object EditNext: TcxComboBox [12]
      Left = 279
      Top = 335
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 20
      Properties.Items.Strings = (
        'I=I'#12289#36827#21378
        'O=O'#12289#20986#21378
        'P=P'#12289#31216#30382#37325
        'M=M'#12289#31216#27611#37325
        'S=S'#12289#36865#36135#20013
        'F=F'#12289#25918#28784#22788
        'Z=Z'#12289#26632#21488
        'X=X'#12289#29616#22330#39564#25910)
      TabOrder = 15
      Width = 165
    end
    object EditMDate: TcxDateEdit [13]
      Left = 279
      Top = 277
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 12
      Width = 165
    end
    object EditPDate: TcxDateEdit [14]
      Left = 279
      Top = 219
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 9
      Width = 165
    end
    object EditMemo: TcxTextEdit [15]
      Left = 81
      Top = 360
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 16
      Width = 121
    end
    object EditCusID: TcxTextEdit [16]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditStockno: TcxTextEdit [17]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditRID: TcxTextEdit [18]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.OnChange = EditRIDPropertiesChange
      TabOrder = 6
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group10: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item21: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #30917#21333#32534#21495':'
              Control = EditID
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              Caption = #23458#25143#32534#21495':'
              Control = EditCusID
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #23458#25143#21517#31216':'
              Control = EditCusName
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item11: TdxLayoutItem
              Caption = #29289#26009#32534#21495':'
              Control = EditStockno
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item22: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #29289#26009#21517#31216':'
              Control = EditStock
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item5: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #36710#33337#21495#30721':'
              Control = EditTruck
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #35760#24405#32534#21495':'
          Control = EditRID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item10: TdxLayoutItem
              Caption = #37325#37327'('#21544'):'
              Control = EditPValue
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item15: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #36807#30917#26102#38388':'
              Control = EditPDate
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Item13: TdxLayoutItem
            ShowCaption = False
            Control = cxLabel2
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Group5: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group6: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item14: TdxLayoutItem
                Caption = #37325#37327'('#21544'):'
                Control = EditMValue
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item7: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #36807#30917#26102#38388':'
                Control = EditMDate
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Item20: TdxLayoutItem
                ShowCaption = False
                Control = cxLabel3
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Group3: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayout1Item4: TdxLayoutItem
                  Caption = #24403#21069#29366#24577':'
                  Control = EditStatus
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item23: TdxLayoutItem
                  AutoAligns = [aaVertical]
                  AlignHorz = ahClient
                  Caption = #19979#19968#29366#24577':'
                  Control = EditNext
                  ControlOptions.ShowBorder = False
                end
              end
            end
          end
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #25551#36848#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object BtnSelect: TButton
    Left = 14
    Top = 391
    Width = 65
    Height = 22
    Caption = #36873#25321#29289#26009
    TabOrder = 1
    OnClick = BtnSelectClick
  end
end
