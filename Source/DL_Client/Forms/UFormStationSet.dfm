inherited fFormStationSet: TfFormStationSet
  Left = 312
  Top = 312
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 101
  ClientWidth = 266
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 266
    Height = 101
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 106
      Top = 68
      Width = 72
      Height = 22
      Caption = #30830#23450
      TabOrder = 1
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 183
      Top = 68
      Width = 72
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 2
    end
    object cxComboBox1: TcxComboBox
      Left = 93
      Top = 36
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        #39044#21046
        #19981#39044#21046)
      TabOrder = 0
      Text = #39044#21046
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #39044#21046#30382#37325
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = #20999#25442#27169#24335#20026':'
          Control = cxComboBox1
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button1'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item5: TdxLayoutItem
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
end
