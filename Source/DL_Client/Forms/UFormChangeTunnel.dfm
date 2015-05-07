inherited fFormChangeTunnel: TfFormChangeTunnel
  Left = 445
  Top = 234
  Width = 486
  Height = 566
  BorderStyle = bsSizeable
  Caption = #23450#36947#35013#36710
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 478
    Height = 539
    inherited BtnOK: TButton
      Left = 332
      Top = 506
      Caption = #30830#23450
      TabOrder = 4
    end
    inherited BtnExit: TButton
      Left = 402
      Top = 506
      TabOrder = 5
    end
    object ListInfo: TcxMCListBox [2]
      Left = 23
      Top = 36
      Width = 432
      Height = 135
      Delimiter = ','
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 74
        end
        item
          AutoSize = True
          Text = #20449#24687#20869#23481
          Width = 354
        end>
      ParentFont = False
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 0
      OnClick = ListInfoClick
    end
    object ListZTLines: TcxListView [3]
      Left = 23
      Top = 258
      Width = 350
      Height = 115
      Columns = <
        item
          Caption = #32534#21495
          Width = 80
        end
        item
          Alignment = taCenter
          Caption = #21517#31216
          Width = 100
        end
        item
          Caption = #31867#22411
          Width = 80
        end
        item
          Caption = #29366#24577
        end
        item
          Caption = #21697#31181#21517#31216
        end>
      HideSelection = False
      ParentFont = False
      ReadOnly = True
      RowSelect = True
      SmallImages = FDM.ImageBar
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 3
      ViewStyle = vsReport
      OnSelectItem = ListZTLinesSelectItem
    end
    object EditTName: TcxTextEdit [4]
      Left = 81
      Top = 201
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 110
    end
    object EditTunnel: TcxTextEdit [5]
      Left = 81
      Top = 176
      ParentFont = False
      Properties.ReadOnly = True
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 105
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #26632#36947#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          Caption = 'cxMCListBox1'
          ShowCaption = False
          Control = ListInfo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object LayItem1: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #36890#36947#32534#21495':'
            Control = EditTunnel
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item5: TdxLayoutItem
            Caption = #36890#36947#21517#31216':'
            Control = EditTName
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26632#36947#21015#34920
        object dxLayout1Item7: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'cxListView1'
          ShowCaption = False
          Control = ListZTLines
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
