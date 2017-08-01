inherited fFormShipPound: TfFormShipPound
  Left = 356
  Top = 353
  ClientHeight = 426
  ClientWidth = 649
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 649
    Height = 426
    inherited BtnOK: TButton
      Left = 503
      Top = 393
      TabOrder = 21
    end
    inherited BtnExit: TButton
      Left = 573
      Top = 393
      TabOrder = 22
    end
    object EditCusName: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 0
      Width = 300
    end
    object EditStock: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 4
      Width = 125
    end
    object EditPici: TcxTextEdit [4]
      Left = 444
      Top = 111
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 6
      Width = 121
    end
    object EditYuShu: TcxComboBox [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.AutoSelect = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.MaxLength = 100
      TabOrder = 2
      Width = 300
    end
    object EditFengQian: TcxTextEdit [6]
      Left = 81
      Top = 136
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 7
      Width = 121
    end
    object EditMemo: TcxTextEdit [7]
      Left = 81
      Top = 335
      ParentFont = False
      Properties.MaxLength = 500
      TabOrder = 20
      Width = 121
    end
    object cxLabel1: TcxLabel [8]
      Left = 23
      Top = 161
      AutoSize = False
      Caption = #31354#33337':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 175
    end
    object EditKW: TcxTextEdit [9]
      Left = 81
      Top = 194
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 9
      Width = 121
    end
    object EditKZ: TcxTextEdit [10]
      Left = 253
      Top = 194
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 10
      Width = 121
    end
    object EditKT: TcxTextEdit [11]
      Left = 425
      Top = 194
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 11
      Width = 121
    end
    object cxLabel2: TcxLabel [12]
      Left = 23
      Top = 219
      AutoSize = False
      Caption = #37325#33337':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Horz = taLeftJustify
      Properties.Alignment.Vert = taVCenter
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 28
      Width = 517
      AnchorY = 233
    end
    object EditZLW: TcxTextEdit [13]
      Left = 81
      Top = 252
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 13
      Width = 121
    end
    object EditZLZ: TcxTextEdit [14]
      Left = 253
      Top = 252
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 14
      Width = 121
    end
    object EditZLT: TcxTextEdit [15]
      Left = 425
      Top = 252
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 15
      Width = 121
    end
    object EditZRT: TcxTextEdit [16]
      Left = 425
      Top = 277
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 18
      Width = 121
    end
    object EditZRZ: TcxTextEdit [17]
      Left = 253
      Top = 277
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 17
      Width = 121
    end
    object EditZRW: TcxTextEdit [18]
      Left = 81
      Top = 277
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 16
      Width = 121
    end
    object cxLabel3: TcxLabel [19]
      Left = 23
      Top = 302
      AutoSize = False
      Caption = #20854#23427':'
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
    object EditBill: TcxTextEdit [20]
      Left = 444
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      Width = 121
    end
    object EditShip: TcxTextEdit [21]
      Left = 444
      Top = 61
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditValue: TcxTextEdit [22]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 5
      Width = 300
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
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #23458#25143#21517#31216':'
              Control = EditCusName
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item21: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #25552#36135#21333#21495':'
              Control = EditBill
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group11: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item4: TdxLayoutItem
              Caption = #36816#36755#21333#20301':'
              Control = EditYuShu
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item22: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #25215#36816#33337#21517':'
              Control = EditShip
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #20135#21697#21517#31216':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group12: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item23: TdxLayoutItem
            Caption = #20135#21697#20928#37325':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #25209#27425#32534#21495':'
            Control = EditPici
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #23553#31614#32534#21495':'
          Control = EditFengQian
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
              Caption = #33337#23614':'
              Control = EditKW
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item11: TdxLayoutItem
              Caption = #33337#20013':'
              Control = EditKZ
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item12: TdxLayoutItem
              Caption = #33337#22836':'
              Control = EditKT
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
                Caption = #24038#33337#23614':'
                Control = EditZLW
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item15: TdxLayoutItem
                Caption = #24038#33337#20013':'
                Control = EditZLZ
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item16: TdxLayoutItem
                Caption = #24038#33337#22836':'
                Control = EditZLT
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Group8: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayout1Item19: TdxLayoutItem
                  Caption = #21491#33337#23614':'
                  Control = EditZRW
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item18: TdxLayoutItem
                  Caption = #21491#33337#20013':'
                  Control = EditZRZ
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item17: TdxLayoutItem
                  Caption = #21491#33337#22836':'
                  Control = EditZRT
                  ControlOptions.ShowBorder = False
                end
              end
              object dxLayout1Item20: TdxLayoutItem
                ShowCaption = False
                Control = cxLabel3
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item7: TdxLayoutItem
                Caption = #22791#27880#20449#24687':'
                Control = EditMemo
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
      end
    end
  end
end
