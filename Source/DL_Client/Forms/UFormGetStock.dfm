inherited fFormGetStock: TfFormGetStock
  Left = 503
  Width = 448
  Height = 309
  BorderStyle = bsSizeable
  Constraints.MinHeight = 220
  Constraints.MinWidth = 400
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 432
    Height = 271
    inherited BtnOK: TButton
      Left = 286
      Top = 238
      Caption = #30830#23450
      TabOrder = 1
    end
    inherited BtnExit: TButton
      Left = 356
      Top = 238
      TabOrder = 2
    end
    object ListStock: TcxListView [2]
      Left = 23
      Top = 36
      Width = 417
      Height = 145
      Columns = <
        item
          Caption = #32534#21495
          Width = 100
        end
        item
          Caption = #21517#31216
          Width = 220
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = ListStockDblClick
      OnKeyPress = ListStockKeyPress
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item6: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = #26597#35810#32467#26524':'
          ShowCaption = False
          Control = ListStock
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
