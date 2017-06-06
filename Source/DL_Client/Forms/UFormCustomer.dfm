inherited fFormCustomer: TfFormCustomer
  Left = 242
  Top = 205
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 360
  ClientWidth = 445
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 445
    Height = 360
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = FDM.dxLayoutWeb1
    object EditPhone: TcxTextEdit
      Left = 81
      Top = 61
      Hint = 'T.C_Addr'
      ParentFont = False
      Properties.MaxLength = 100
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 208
    end
    object EditMemo: TcxMemo
      Left = 81
      Top = 111
      Hint = 'T.C_Memo'
      ParentFont = False
      Properties.MaxLength = 50
      Properties.ScrollBars = ssVertical
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.Edges = [bBottom]
      TabOrder = 4
      Height = 45
      Width = 385
    end
    object InfoList1: TcxMCListBox
      Left = 23
      Top = 243
      Width = 438
      Height = 131
      HeaderSections = <
        item
          Text = #20449#24687#39033
          Width = 105
        end
        item
          AutoSize = True
          Text = #20869#23481
          Width = 329
        end>
      ParentFont = False
      Style.BorderStyle = cbsOffice11
      Style.Edges = [bLeft, bTop, bRight, bBottom]
      TabOrder = 9
    end
    object InfoItems: TcxComboBox
      Left = 81
      Top = 193
      ParentFont = False
      Properties.DropDownRows = 15
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 20
      Properties.MaxLength = 30
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.ButtonStyle = btsHotFlat
      Style.PopupBorderStyle = epbsSingle
      TabOrder = 5
      Width = 100
    end
    object EditInfo: TcxTextEdit
      Left = 81
      Top = 218
      ParentFont = False
      Properties.MaxLength = 50
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 120
    end
    object BtnAdd: TButton
      Left = 376
      Top = 193
      Width = 46
      Height = 18
      Caption = #28155#21152
      TabOrder = 6
      OnClick = BtnAddClick
    end
    object BtnDel: TButton
      Left = 377
      Top = 218
      Width = 45
      Height = 17
      Caption = #21024#38500
      TabOrder = 8
      OnClick = BtnDelClick
    end
    object BtnOK: TButton
      Left = 289
      Top = 327
      Width = 70
      Height = 22
      Caption = #20445#23384
      TabOrder = 11
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 364
      Top = 327
      Width = 70
      Height = 22
      Caption = #21462#28040
      TabOrder = 12
      OnClick = BtnExitClick
    end
    object cxTextEdit2: TcxTextEdit
      Left = 81
      Top = 86
      Hint = 'T.C_LiXiRen'
      ParentFont = False
      Properties.MaxLength = 50
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 160
    end
    object cxTextEdit3: TcxTextEdit
      Left = 304
      Top = 86
      Hint = 'T.C_Phone'
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 3
      Width = 121
    end
    object Check1: TcxCheckBox
      Left = 11
      Top = 327
      Hint = 'T.C_XuNi'
      Caption = #38750#27491#24335#23458#25143': '#27491#24120#26597#35810#26102#19981#20104#26174#31034'.'
      ParentFont = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 10
      Transparent = True
      Width = 218
    end
    object EditName: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'T.C_Name'
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = False
      Properties.OnButtonClick = EditNamePropertiesButtonClick
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      Style.HotTrack = False
      Style.ButtonStyle = btsHotFlat
      TabOrder = 0
      OnKeyPress = EditNameKeyPress
      Width = 121
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Group8: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Group7: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayoutControl1Item12: TdxLayoutItem
              Caption = #23458#25143#21517#31216':'
              Control = EditName
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item3: TdxLayoutItem
              Caption = #32852#31995#22320#22336':'
              Control = EditPhone
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group6: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item13: TdxLayoutItem
              Caption = #32852' '#31995' '#20154':'
              Control = cxTextEdit2
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item14: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #32852#31995#30005#35805':'
              Control = cxTextEdit3
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #38468#21152#20449#24687
        object dxLayoutControl1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object dxLayoutControl1Group13: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item6: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449' '#24687' '#39033':'
              Control = InfoItems
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item8: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button1'
              ShowCaption = False
              Control = BtnAdd
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayoutControl1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            LayoutDirection = ldHorizontal
            ShowBorder = False
            object dxLayoutControl1Item7: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #20449#24687#20869#23481':'
              Control = EditInfo
              ControlOptions.ShowBorder = False
            end
            object dxLayoutControl1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahRight
              Caption = 'Button2'
              ShowCaption = False
              Control = BtnDel
              ControlOptions.ShowBorder = False
            end
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Control = InfoList1
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayoutControl1Group5: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avBottom
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item10: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button3'
          ShowCaption = False
          Control = BtnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item11: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahRight
          Caption = 'Button4'
          ShowCaption = False
          Control = BtnExit
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
