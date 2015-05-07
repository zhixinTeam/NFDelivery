inherited fFormGetMine: TfFormGetMine
  Left = 503
  Width = 448
  Height = 309
  BorderStyle = bsSizeable
  Constraints.MinHeight = 220
  Constraints.MinWidth = 400
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 432
    Height = 271
    inherited BtnOK: TButton
      Left = 286
      Top = 238
      Caption = #30830#23450
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 356
      Top = 238
      TabOrder = 5
    end
    object EditMine: TcxButtonEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditCIDPropertiesButtonClick
      TabOrder = 0
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object ListMine: TcxListView [3]
      Left = 23
      Top = 82
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #30719#28857#32534#21495
          Width = 70
        end
        item
          Caption = #32852#31995#20154
          Width = 70
        end
        item
          Caption = #32852#31995#26041#24335
          Width = 70
        end
        item
          Caption = #23458#25143#21517#31216
        end>
      HideSelection = False
      ParentFont = False
      PopupMenu = PMenu1
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 2
      ViewStyle = vsReport
      OnDblClick = ListMineDblClick
      OnKeyPress = ListMineKeyPress
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 61
      Caption = #26597#35810#32467#26524':'
      ParentFont = False
      Transparent = True
    end
    object Check1: TcxCheckBox [5]
      Left = 11
      Top = 238
      Caption = #26174#31034#20840#37096#30719#28857
      ParentFont = False
      TabOrder = 3
      Transparent = True
      OnClick = Check1Click
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26597#35810#26465#20214
        object dxLayout1Item5: TdxLayoutItem
          Caption = #30719#28857#21517#31216':'
          Control = EditMine
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26597#35810#32467#26524':'
          ShowCaption = False
          Control = ListMine
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem [0]
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object PMenu1: TPopupMenu
    AutoHotkeys = maManual
    Left = 28
    Top = 104
    object N1: TMenuItem
      Caption = #32852' '#31995' '#20154
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #32852#31995#26041#24335
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object N4: TMenuItem
      Tag = 10
      Caption = #38544#34255#30719#28857
      OnClick = N4Click
    end
    object N5: TMenuItem
      Tag = 20
      Caption = #26174#31034#30719#28857
      OnClick = N4Click
    end
  end
end
