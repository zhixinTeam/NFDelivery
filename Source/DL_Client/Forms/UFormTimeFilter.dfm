object fFormTimeFilter: TfFormTimeFilter
  Left = 542
  Top = 195
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 366
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 212
    Width = 399
    Height = 154
    Align = alBottom
    TabOrder = 0
    TabStop = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnSave: TButton
      Left = 252
      Top = 118
      Width = 62
      Height = 22
      Caption = #20445#23384
      TabOrder = 5
      OnClick = BtnSaveClick
    end
    object BtnExit: TButton
      Left = 319
      Top = 118
      Width = 62
      Height = 22
      Caption = #36820#22238
      ModalResult = 2
      TabOrder = 6
    end
    object ItemID: TcxButtonEdit
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = ItemIDPropertiesButtonClick
      TabOrder = 0
      Width = 288
    end
    object EditStart: TcxTimeEdit
      Left = 81
      Top = 61
      EditValue = 0d
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditEnd: TcxTimeEdit
      Left = 81
      Top = 86
      EditValue = 0d
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object BtnAdd: TButton
      Left = 11
      Top = 118
      Width = 62
      Height = 22
      Caption = #28155#21152
      TabOrder = 3
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 78
      Top = 118
      Width = 62
      Height = 22
      Caption = #21024#38500
      TabOrder = 4
      OnClick = BtnDelClick
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #26085#26399#35774#23450
        object dxLayoutControl1Item5: TdxLayoutItem
          Caption = #26102#38388#32534#21495':'
          Control = ItemID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #24320#22987#26102#38388':'
          Control = EditStart
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #32467#26463#26102#38388
          Control = EditEnd
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item6: TdxLayoutItem
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnAdd
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item7: TdxLayoutItem
          Caption = 'Button2'
          ShowCaption = False
          Control = BtnDel
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnSave
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button2'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object dxLayoutControl2: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 399
    Height = 217
    Align = alTop
    TabOrder = 1
    TabStop = False
    LookAndFeel = FDM.dxLayoutWeb1
    object ListInfo: TcxListView
      Left = 11
      Top = 11
      Width = 366
      Height = 190
      Align = alClient
      Columns = <
        item
          Caption = #32534#21495
          Width = 120
        end
        item
          Caption = #36215#22987#26102#38388
          Width = 130
        end
        item
          Caption = #32467#26463#26102#38388
          Width = 110
        end>
      ParentFont = False
      SmallImages = FDM.ImageBar
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = ListInfoClick
    end
    object dxLayoutControl2Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl2Item1: TdxLayoutItem
        Control = ListInfo
        ControlOptions.ShowBorder = False
      end
    end
  end
end
