inherited fFormBatcode: TfFormBatcode
  Left = 421
  Top = 108
  ClientHeight = 478
  ClientWidth = 497
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 497
    Height = 478
    inherited BtnOK: TButton
      Left = 351
      Top = 445
      TabOrder = 22
    end
    inherited BtnExit: TButton
      Left = 421
      Top = 445
      TabOrder = 23
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
      Properties.MaxLength = 15
      TabOrder = 2
      Width = 135
    end
    object EditStock: TcxComboBox [4]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 18
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 0
      Width = 121
    end
    object EditInc: TcxTextEdit [5]
      Left = 279
      Top = 111
      ParentFont = False
      TabOrder = 5
      Text = '1'
      Width = 271
    end
    object EditBase: TcxTextEdit [6]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 4
      Text = '1'
      Width = 135
    end
    object EditLen: TcxTextEdit [7]
      Left = 279
      Top = 86
      ParentFont = False
      TabOrder = 3
      Text = '6'
      Width = 135
    end
    object Check1: TcxCheckBox [8]
      Left = 23
      Top = 211
      Caption = #20351#29992#26085#26399#32534#30721
      ParentFont = False
      TabOrder = 9
      Transparent = True
      Width = 121
    end
    object EditLow: TcxTextEdit [9]
      Left = 81
      Top = 312
      ParentFont = False
      TabOrder = 12
      Text = '80'
      Width = 135
    end
    object EditHigh: TcxTextEdit [10]
      Left = 81
      Top = 337
      ParentFont = False
      TabOrder = 14
      Text = '100'
      Width = 135
    end
    object Check2: TcxCheckBox [11]
      Left = 23
      Top = 412
      Caption = #26032#24180#26102#33258#21160#37325#32622','#32534#21495#22522#25968#20174'1'#24320#22987#35745#25968'.'
      ParentFont = False
      TabOrder = 20
      Transparent = True
      Width = 121
    end
    object cxLabel1: TcxLabel [12]
      Left = 221
      Top = 312
      Caption = #27880':'#35813#20540#20026#30334#20998#27604'(%),'#36229#36807#35813#20540#25552#37266'.'
      ParentFont = False
      Transparent = True
    end
    object cxLabel2: TcxLabel [13]
      Left = 221
      Top = 337
      Caption = #27880':'#35813#20540#20026#30334#20998#27604'(%),'#36229#36807#35813#20540#26356#25442#32534#21495'.'
      ParentFont = False
      Transparent = True
    end
    object EditValue: TcxTextEdit [14]
      Left = 81
      Top = 287
      ParentFont = False
      TabOrder = 10
      Text = '0'
      Width = 135
    end
    object cxLabel3: TcxLabel [15]
      Left = 221
      Top = 287
      Caption = #27880':'#27599#22810#23569#21544#26816#27979#19968#27425'.'
      ParentFont = False
      Transparent = True
    end
    object EditWeek: TcxTextEdit [16]
      Left = 81
      Top = 362
      ParentFont = False
      TabOrder = 16
      Text = '20'
      Width = 135
    end
    object cxLabel4: TcxLabel [17]
      Left = 221
      Top = 362
      Caption = #27880':'#20174#31532#19968#36710#21551#29992#24320#22987#19981#36229#36807#22810#23569#22825'.'
      ParentFont = False
      Transparent = True
    end
    object EditType: TcxComboBox [18]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 6
      Width = 121
    end
    object EditBatcode: TcxTextEdit [19]
      Left = 81
      Top = 387
      ParentFont = False
      TabOrder = 17
      Width = 121
    end
    object cxLabel5: TcxLabel [20]
      Left = 221
      Top = 383
      Caption = #27880':'#24403#21069#27491#22312#20351#29992#30340#25209#27425#21495','#22914#38656#35843#25972#35831#26356#26032
      ParentFont = False
      Transparent = True
    end
    object EditLineGroup: TcxComboBox [21]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      TabOrder = 7
      Width = 121
    end
    object ChkValid: TcxCheckBox [22]
      Left = 11
      Top = 445
      Caption = #25209#27425#21495#26377#25928
      ParentFont = False
      State = cbsChecked
      TabOrder = 21
      Width = 121
    end
    object EditBrand: TcxComboBox [23]
      Left = 81
      Top = 186
      Properties.DropDownListStyle = lsFixedList
      TabOrder = 8
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
          object dxLayout1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item5: TdxLayoutItem
              AutoAligns = [aaVertical]
              Caption = #32534#21495#21069#32512':'
              Control = EditPrefix
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #32534#21495#38271#24230':'
              Control = EditLen
              ControlOptions.ShowBorder = False
            end
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
          object dxLayout1Item3: TdxLayoutItem
            Caption = #25552#36135#31867#22411':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item22: TdxLayoutItem
            Caption = #32534#21495#20998#32452':'
            Control = EditLineGroup
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item24: TdxLayoutItem
            Caption = #25351#23450#21697#29260
            Control = EditBrand
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item10: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = Check1
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        Caption = #32534#21495#21464#26356
        object dxLayout1Group9: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item16: TdxLayoutItem
            Caption = #26816' '#27979' '#37327':'
            Control = EditValue
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item17: TdxLayoutItem
            Caption = 'cxLabel3'
            ShowCaption = False
            Control = cxLabel3
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item11: TdxLayoutItem
              Caption = #36229#21457#25552#37266':'
              Control = EditLow
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item14: TdxLayoutItem
              Caption = 'cxLabel1'
              ShowCaption = False
              Control = cxLabel1
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group8: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group10: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item12: TdxLayoutItem
                AutoAligns = [aaVertical]
                Caption = #36229#21457#19978#38480':'
                Control = EditHigh
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item15: TdxLayoutItem
                Caption = 'cxLabel2'
                ShowCaption = False
                Control = cxLabel2
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group11: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Group4: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                ShowBorder = False
                object dxLayout1Item18: TdxLayoutItem
                  Caption = #32534#21495#21608#26399':'
                  Control = EditWeek
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item20: TdxLayoutItem
                  Caption = #24403#21069#25209#27425':'
                  Control = EditBatcode
                  ControlOptions.ShowBorder = False
                end
              end
              object dxLayout1Group12: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                ShowBorder = False
                object dxLayout1Item19: TdxLayoutItem
                  Caption = 'cxLabel4'
                  ShowCaption = False
                  Control = cxLabel4
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item21: TdxLayoutItem
                  Caption = 'cxLabel5'
                  ShowCaption = False
                  Control = cxLabel5
                  ControlOptions.ShowBorder = False
                end
              end
            end
          end
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check2
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item23: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = ChkValid
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
