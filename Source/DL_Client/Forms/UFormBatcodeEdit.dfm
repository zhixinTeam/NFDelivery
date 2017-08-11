inherited fFormBatcodeEdit: TfFormBatcodeEdit
  Left = 476
  Top = 336
  ClientHeight = 361
  ClientWidth = 477
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 477
    Height = 361
    inherited BtnOK: TButton
      Left = 331
      Top = 328
      TabOrder = 16
    end
    inherited BtnExit: TButton
      Left = 401
      Top = 328
      TabOrder = 17
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      TabOrder = 2
      Width = 116
    end
    object EditBatch: TcxTextEdit [3]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.MaxLength = 100
      TabOrder = 0
      Width = 125
    end
    object EditRund: TcxTextEdit [4]
      Left = 269
      Top = 182
      ParentFont = False
      TabOrder = 9
      Text = '0'
      Width = 121
    end
    object EditStock: TcxComboBox [5]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 18
      Properties.ItemHeight = 20
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 1
      Width = 121
    end
    object EditInit: TcxTextEdit [6]
      Left = 269
      Top = 157
      ParentFont = False
      TabOrder = 7
      Text = '0'
      Width = 271
    end
    object EditPlan: TcxTextEdit [7]
      Left = 81
      Top = 157
      ParentFont = False
      TabOrder = 6
      Text = '2000'
      Width = 125
    end
    object EditWarn: TcxTextEdit [8]
      Left = 81
      Top = 182
      ParentFont = False
      TabOrder = 8
      Text = '5'
      Width = 125
    end
    object Check1: TcxCheckBox [9]
      Left = 11
      Top = 328
      Caption = #26159#21542#21551#29992
      ParentFont = False
      TabOrder = 15
      Transparent = True
      Width = 121
    end
    object EditBrand: TcxComboBox [10]
      Left = 269
      Top = 111
      ParentFont = False
      Properties.AutoSelect = False
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      TabOrder = 4
      Width = 121
    end
    object cxLabel1: TcxLabel [11]
      Left = 23
      Top = 136
      AutoSize = False
      ParentFont = False
      Style.Edges = []
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 16
      Width = 280
    end
    object EditType: TcxComboBox [12]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.AutoSelect = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ItemHeight = 20
      TabOrder = 3
      Width = 125
    end
    object EditDays: TcxTextEdit [13]
      Left = 81
      Top = 207
      ParentFont = False
      TabOrder = 10
      Text = '3'
      Width = 125
    end
    object cxLabel2: TcxLabel [14]
      Left = 211
      Top = 207
      Caption = #27880': '#20174#32534#21495#21551#29992#24320#22987','#36807#26399#33258#21160#23553#23384'.'
      ParentFont = False
      Style.Edges = []
      Transparent = True
    end
    object cxLabel3: TcxLabel [15]
      Left = 23
      Top = 232
      AutoSize = False
      ParentFont = False
      Style.Edges = []
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 16
      Width = 400
    end
    object EditCusName: TcxButtonEdit [16]
      Left = 81
      Top = 278
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 80
      Properties.OnButtonClick = EditCusNamePropertiesButtonClick
      TabOrder = 14
      OnKeyPress = EditCusNameKeyPress
      Width = 121
    end
    object EditCusID: TcxTextEdit [17]
      Left = 81
      Top = 253
      Properties.MaxLength = 20
      TabOrder = 13
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25209' '#27425' '#21495':'
          Control = EditBatch
          ControlOptions.ShowBorder = False
        end
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
        object dxLayout1Group5: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item13: TdxLayoutItem
            AutoAligns = [aaVertical]
            Caption = #25552#36135#31867#22411':'
            Control = EditType
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item11: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #27700#27877#21697#29260':'
            Control = EditBrand
            ControlOptions.ShowBorder = False
          end
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayout1Item7: TdxLayoutItem
              Caption = #35745#21010#24635#37327':'
              Control = EditPlan
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21021#22987#24050#21457':'
              Control = EditInit
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group4: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Group8: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object dxLayout1Item8: TdxLayoutItem
                Caption = #39044#35686'('#20313'):'
                Control = EditWarn
                ControlOptions.ShowBorder = False
              end
              object dxLayout1Item3: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = #36864' '#36135' '#37327':'
                Control = EditRund
                ControlOptions.ShowBorder = False
              end
            end
            object dxLayout1Group7: TdxLayoutGroup
              ShowCaption = False
              Hidden = True
              ShowBorder = False
              object dxLayout1Group6: TdxLayoutGroup
                ShowCaption = False
                Hidden = True
                LayoutDirection = ldHorizontal
                ShowBorder = False
                object dxLayout1Item14: TdxLayoutItem
                  Caption = #26377#25928#22825#25968':'
                  Control = EditDays
                  ControlOptions.ShowBorder = False
                end
                object dxLayout1Item15: TdxLayoutItem
                  Caption = 'cxLabel2'
                  ShowCaption = False
                  Control = cxLabel2
                  ControlOptions.ShowBorder = False
                end
              end
              object dxLayout1Item16: TdxLayoutItem
                ShowCaption = False
                Control = cxLabel3
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
        object dxLayout1Item18: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
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
