inherited fFormPoundDispatch: TfFormPoundDispatch
  Left = 312
  Top = 312
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 149
  ClientWidth = 313
  OldCreateOrder = True
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 313
    Height = 149
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 153
      Top = 116
      Width = 72
      Height = 22
      Caption = #30830#23450
      TabOrder = 2
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 230
      Top = 116
      Width = 72
      Height = 22
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 3
    end
    object EditPound: TcxComboBox
      Left = 81
      Top = 36
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 22
      Properties.OnChange = EditPoundPropertiesChange
      TabOrder = 0
      Width = 121
    end
    object EditStation: TcxComboBox
      Left = 81
      Top = 61
      Properties.DropDownListStyle = lsEditFixedList
      Properties.ItemHeight = 22
      TabOrder = 1
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #30917#31449#35843#24230
        object dxLayoutControl1Item6: TdxLayoutItem
          Caption = #22320#30917#21517#31216':'
          Control = EditPound
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #20351#29992#22320#28857':'
          Control = EditStation
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
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
