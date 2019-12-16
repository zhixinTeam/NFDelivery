object fFormHYRecord: TfFormHYRecord
  Left = 429
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 616
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 12
  object dxLayoutControl1: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 470
    Height = 616
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    AutoControlTabOrders = False
    LookAndFeel = FDM.dxLayoutWeb1
    object BtnOK: TButton
      Left = 314
      Top = 582
      Width = 70
      Height = 23
      Caption = #20445#23384
      TabOrder = 0
      OnClick = BtnOKClick
    end
    object BtnExit: TButton
      Left = 389
      Top = 582
      Width = 70
      Height = 23
      Caption = #21462#28040
      TabOrder = 1
      OnClick = BtnExitClick
    end
    object EditID: TcxButtonEdit
      Left = 81
      Top = 36
      Hint = 'E.R_SerialNo'
      HelpType = htKeyword
      HelpKeyword = 'NU'
      ParentFont = False
      Properties.Buttons = <
        item
          Kind = bkEllipsis
        end>
      Properties.MaxLength = 15
      Properties.OnButtonClick = EditIDPropertiesButtonClick
      TabOrder = 2
      Width = 121
    end
    object EditStock: TcxComboBox
      Left = 81
      Top = 61
      Hint = 'E.R_PID'
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 20
      Properties.ImmediateDropDown = False
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 18
      Properties.MaxLength = 15
      Properties.OnEditValueChanged = EditStockPropertiesEditValueChanged
      TabOrder = 4
      Width = 128
    end
    object wPanel: TPanel
      Left = 23
      Top = 143
      Width = 415
      Height = 262
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 3
      object Label17: TLabel
        Left = 6
        Top = 253
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label18: TLabel
        Left = 6
        Top = 222
        Width = 72
        Height = 12
        Caption = '3'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Label25: TLabel
        Left = 205
        Top = 253
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#21387#24378#24230':'
        Transparent = True
      end
      object Label26: TLabel
        Left = 205
        Top = 222
        Width = 78
        Height = 12
        Caption = '28'#22825#25239#25240#24378#24230':'
        Transparent = True
      end
      object Bevel2: TBevel
        Left = 6
        Top = 205
        Width = 400
        Height = 7
        Shape = bsBottomLine
      end
      object Label32: TLabel
        Left = 6
        Top = 7
        Width = 54
        Height = 12
        Caption = #28903' '#22833' '#37327':'
      end
      object Label24: TLabel
        Left = 6
        Top = 32
        Width = 54
        Height = 12
        Caption = #27687' '#21270' '#38209':'
        Transparent = True
      end
      object Label31: TLabel
        Left = 6
        Top = 58
        Width = 54
        Height = 12
        Caption = #19977#27687#21270#30827':'
      end
      object Label23: TLabel
        Left = 6
        Top = 86
        Width = 54
        Height = 12
        Caption = #27695' '#31163' '#23376':'
        Transparent = True
      end
      object Label34: TLabel
        Left = 6
        Top = 111
        Width = 66
        Height = 12
        Caption = #28216#31163#27687#21270#38041':'
        Transparent = True
      end
      object Label19: TLabel
        Left = 6
        Top = 136
        Width = 54
        Height = 12
        Caption = #30897' '#21547' '#37327':'
        Transparent = True
      end
      object Label50: TLabel
        Left = 4
        Top = 165
        Width = 72
        Height = 12
        Caption = #29087#26009#20013#30340'C3A:'
        Transparent = True
      end
      object Label51: TLabel
        Left = 4
        Top = 190
        Width = 54
        Height = 12
        Caption = #27700#28342#24615#38124':'
        Transparent = True
      end
      object Label20: TLabel
        Left = 159
        Top = 8
        Width = 54
        Height = 12
        Caption = #19981' '#28342' '#29289':'
        Transparent = True
      end
      object Label30: TLabel
        Left = 303
        Top = 10
        Width = 54
        Height = 12
        Caption = #23433' '#23450' '#24615':'
        Transparent = True
      end
      object Label39: TLabel
        Left = 159
        Top = 34
        Width = 54
        Height = 12
        Caption = #38041' '#30789' '#27604':'
        Transparent = True
      end
      object Label40: TLabel
        Left = 302
        Top = 35
        Width = 54
        Height = 12
        Caption = #20445' '#27700' '#29575':'
        Transparent = True
      end
      object Label38: TLabel
        Left = 159
        Top = 61
        Width = 54
        Height = 12
        Caption = #30789' '#37240' '#30416':'
        Transparent = True
      end
      object Label41: TLabel
        Left = 302
        Top = 58
        Width = 54
        Height = 12
        Caption = #30707#33167#31181#31867':'
        Transparent = True
      end
      object Label52: TLabel
        Left = 159
        Top = 86
        Width = 66
        Height = 12
        Caption = '0.08mm'#31579#20313':'
        Transparent = True
      end
      object Label42: TLabel
        Left = 302
        Top = 84
        Width = 54
        Height = 12
        Caption = #30707' '#33167' '#37327':'
      end
      object Label29: TLabel
        Left = 159
        Top = 111
        Width = 54
        Height = 12
        Caption = #27604#34920#38754#31215':'
        Transparent = True
      end
      object Label43: TLabel
        Left = 302
        Top = 110
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#31867':'
      end
      object Label21: TLabel
        Left = 158
        Top = 137
        Width = 54
        Height = 12
        Caption = #31264'    '#24230':'
        Transparent = True
      end
      object Label44: TLabel
        Left = 302
        Top = 136
        Width = 54
        Height = 12
        Caption = #28151#21512#26448#37327':'
        Transparent = True
      end
      object Label27: TLabel
        Left = 159
        Top = 164
        Width = 54
        Height = 12
        Caption = #21021#20957#26102#38388':'
        Transparent = True
      end
      object Label22: TLabel
        Left = 304
        Top = 165
        Width = 54
        Height = 12
        Caption = #32454'    '#24230':'
        Transparent = True
      end
      object Label28: TLabel
        Left = 159
        Top = 190
        Width = 54
        Height = 12
        Caption = #32456#20957#26102#38388':'
        Transparent = True
      end
      object cxTextEdit29: TcxTextEdit
        Left = 76
        Top = 217
        Hint = 'E.R_3DZhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 0
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit30: TcxTextEdit
        Left = 76
        Top = 242
        Hint = 'E.R_3DYa1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 3
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit31: TcxTextEdit
        Left = 284
        Top = 217
        Hint = 'E.R_28Zhe1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 9
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit32: TcxTextEdit
        Left = 284
        Top = 242
        Hint = 'E.R_28Ya1'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 12
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit33: TcxTextEdit
        Left = 324
        Top = 217
        Hint = 'E.R_28Zhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 10
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit34: TcxTextEdit
        Left = 363
        Top = 217
        Hint = 'E.R_28Zhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 11
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit35: TcxTextEdit
        Left = 324
        Top = 242
        Hint = 'E.R_28Ya2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 13
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit36: TcxTextEdit
        Left = 363
        Top = 242
        Hint = 'E.R_28Ya3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 14
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit37: TcxTextEdit
        Left = 116
        Top = 217
        Hint = 'E.R_3DZhe2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 1
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit38: TcxTextEdit
        Left = 116
        Top = 242
        Hint = 'E.R_3DYa2'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 4
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit39: TcxTextEdit
        Left = 156
        Top = 217
        Hint = 'E.R_3DZhe3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 2
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit40: TcxTextEdit
        Left = 156
        Top = 242
        Hint = 'E.R_3DYa3'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bRight, bBottom]
        TabOrder = 5
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit41: TcxTextEdit
        Left = 76
        Top = 259
        Hint = 'E.R_3DYa4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 6
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit42: TcxTextEdit
        Left = 116
        Top = 259
        Hint = 'E.R_3DYa5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 7
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit43: TcxTextEdit
        Left = 156
        Top = 259
        Hint = 'E.R_3DYa6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 8
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit47: TcxTextEdit
        Left = 284
        Top = 259
        Hint = 'E.R_28Ya4'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bTop, bBottom]
        TabOrder = 15
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit48: TcxTextEdit
        Left = 324
        Top = 259
        Hint = 'E.R_28Ya5'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 16
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxTextEdit49: TcxTextEdit
        Left = 363
        Top = 259
        Hint = 'E.R_28Ya6'
        ParentFont = False
        Properties.MaxLength = 20
        Style.Edges = [bLeft, bRight, bBottom]
        TabOrder = 17
        OnKeyPress = cxTextEdit17KeyPress
        Width = 42
      end
      object cxGroupBox1: TcxGroupBox
        Left = 5
        Top = 292
        Caption = #28151#21512#26448#25530#21152#37327'(%)'
        ParentFont = False
        TabOrder = 18
        Height = 208
        Width = 418
        object Label45: TLabel
          Left = 8
          Top = 20
          Width = 78
          Height = 12
          Caption = #31881'    '#29028'   '#28784
        end
        object Label46: TLabel
          Left = 220
          Top = 19
          Width = 72
          Height = 12
          Caption = #30707#28784#30707'('#24223#30707')'
        end
        object Label47: TLabel
          Left = 8
          Top = 44
          Width = 78
          Height = 12
          Caption = #27700'         '#28195
        end
        object Label48: TLabel
          Left = 220
          Top = 43
          Width = 72
          Height = 12
          Caption = #30707'        '#33167
        end
        object Label49: TLabel
          Left = 8
          Top = 66
          Width = 78
          Height = 12
          Caption = #21161'    '#30952'   '#21058
        end
        object Label1: TLabel
          Left = 220
          Top = 68
          Width = 72
          Height = 12
          Caption = #29028'   '#30712'   '#30707
        end
        object Label2: TLabel
          Left = 8
          Top = 92
          Width = 78
          Height = 12
          Caption = #20854'         '#23427
        end
        object Label3: TLabel
          Left = 220
          Top = 92
          Width = 72
          Height = 12
          Caption = #29123' '#29028' '#28809'  '#28195
        end
        object Label4: TLabel
          Left = 8
          Top = 117
          Width = 78
          Height = 12
          Caption = #36873'  '#30719' '#31881'  '#26411
        end
        object Label5: TLabel
          Left = 220
          Top = 117
          Width = 72
          Height = 12
          Caption = #30707'   '#28784'   '#28195
        end
        object EditFMH: TcxTextEdit
          Left = 96
          Top = 16
          Hint = 'E.R_FMH'
          ParentFont = False
          TabOrder = 0
          Width = 92
        end
        object EditSHS: TcxTextEdit
          Left = 296
          Top = 16
          Hint = 'E.R_SHS'
          ParentFont = False
          TabOrder = 1
          Width = 92
        end
        object EditSZ: TcxTextEdit
          Left = 96
          Top = 40
          Hint = 'E.R_SZ'
          ParentFont = False
          TabOrder = 2
          Width = 92
        end
        object EditSG: TcxTextEdit
          Left = 296
          Top = 40
          Hint = 'E.R_SG'
          ParentFont = False
          TabOrder = 3
          Width = 92
        end
        object EditZMJ: TcxTextEdit
          Left = 96
          Top = 64
          Hint = 'E.R_ZMJ'
          ParentFont = False
          TabOrder = 4
          Width = 92
        end
        object cxTextEdit1: TcxTextEdit
          Left = 296
          Top = 64
          Hint = 'E.R_MGS'
          ParentFont = False
          TabOrder = 5
          Width = 92
        end
        object cxTextEdit2: TcxTextEdit
          Left = 96
          Top = 88
          Hint = 'E.R_HHCOther'
          ParentFont = False
          TabOrder = 6
          Width = 92
        end
        object cxTextEdit3: TcxTextEdit
          Left = 297
          Top = 88
          Hint = 'E.R_MZ'
          ParentFont = False
          TabOrder = 7
          Width = 92
        end
        object cxTextEdit4: TcxTextEdit
          Left = 96
          Top = 112
          Hint = 'E.R_XKFM'
          ParentFont = False
          TabOrder = 8
          Width = 92
        end
        object cxTextEdit5: TcxTextEdit
          Left = 297
          Top = 112
          Hint = 'E.R_SHZ'
          ParentFont = False
          TabOrder = 9
          Width = 92
        end
      end
      object cxTextEdit24: TcxTextEdit
        Left = 61
        Top = 2
        Hint = 'E.R_ShaoShi'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 19
        Width = 75
      end
      object cxTextEdit17: TcxTextEdit
        Left = 61
        Top = 27
        Hint = 'E.R_MgO'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 20
        Width = 75
      end
      object cxTextEdit23: TcxTextEdit
        Left = 61
        Top = 53
        Hint = 'E.R_SO3'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 21
        Width = 75
      end
      object cxTextEdit18: TcxTextEdit
        Left = 61
        Top = 80
        Hint = 'E.R_CL'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 22
        Width = 75
      end
      object cxTextEdit45: TcxTextEdit
        Left = 71
        Top = 106
        Hint = 'E.R_YLiGai'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 23
        Width = 64
      end
      object cxTextEdit22: TcxTextEdit
        Left = 61
        Top = 131
        Hint = 'E.R_Jian'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 24
        Width = 75
      end
      object cxTextEdit59: TcxTextEdit
        Left = 78
        Top = 159
        Hint = 'E.R_C3A'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 25
        Width = 59
      end
      object cxTextEdit60: TcxTextEdit
        Left = 63
        Top = 184
        Hint = 'E.R_SRXGE'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 26
        Width = 75
      end
      object cxTextEdit21: TcxTextEdit
        Left = 214
        Top = 3
        Hint = 'E.R_BuRong'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 27
        Width = 75
      end
      object cxTextEdit25: TcxTextEdit
        Left = 355
        Top = 5
        Hint = 'E.R_AnDing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 28
        Width = 75
      end
      object cxTextEdit53: TcxTextEdit
        Left = 214
        Top = 29
        Hint = 'E.R_GaiGui'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 29
        Width = 75
      end
      object cxTextEdit54: TcxTextEdit
        Left = 355
        Top = 30
        Hint = 'E.R_Water'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 30
        Width = 75
      end
      object cxTextEdit52: TcxTextEdit
        Left = 214
        Top = 56
        Hint = 'E.R_KuangWu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 31
        Width = 75
      end
      object cxTextEdit55: TcxTextEdit
        Left = 355
        Top = 53
        Hint = 'E.R_SGType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 32
        Width = 75
      end
      object cxTextEdit61: TcxTextEdit
        Left = 223
        Top = 81
        Hint = 'E.R_SY'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 33
        Width = 65
      end
      object cxTextEdit56: TcxTextEdit
        Left = 355
        Top = 79
        Hint = 'E.R_SGValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 34
        Width = 75
      end
      object cxTextEdit26: TcxTextEdit
        Left = 214
        Top = 106
        Hint = 'E.R_BiBiao'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 35
        Width = 75
      end
      object cxTextEdit57: TcxTextEdit
        Left = 355
        Top = 105
        Hint = 'E.R_HHCType'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 36
        Width = 75
      end
      object cxTextEdit20: TcxTextEdit
        Left = 213
        Top = 132
        Hint = 'E.R_ChouDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 37
        Width = 75
      end
      object cxTextEdit58: TcxTextEdit
        Left = 355
        Top = 131
        Hint = 'E.R_HHCValue'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 38
        Width = 75
      end
      object cxTextEdit28: TcxTextEdit
        Left = 214
        Top = 159
        Hint = 'E.R_ChuNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 39
        Width = 75
      end
      object cxTextEdit19: TcxTextEdit
        Left = 355
        Top = 160
        Hint = 'E.R_XiDu'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 40
        Width = 75
      end
      object cxTextEdit27: TcxTextEdit
        Left = 214
        Top = 185
        Hint = 'E.R_ZhongNing'
        ParentFont = False
        Properties.MaxLength = 20
        TabOrder = 41
        Width = 75
      end
    end
    object EditDate: TcxDateEdit
      Left = 81
      Top = 86
      Hint = 'E.R_Date'
      ParentFont = False
      Properties.Kind = ckDateTime
      TabOrder = 5
      Width = 155
    end
    object EditMan: TcxTextEdit
      Left = 287
      Top = 86
      Hint = 'E.R_Man'
      ParentFont = False
      TabOrder = 6
      Width = 120
    end
    object dxLayoutControl1Group_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object dxLayoutControl1Group1: TdxLayoutGroup
        Caption = #22522#26412#20449#24687
        object dxLayoutControl1Item1: TdxLayoutItem
          Caption = #27700#27877#32534#21495':'
          Control = EditID
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item12: TdxLayoutItem
          AutoAligns = [aaVertical]
          AlignHorz = ahClient
          Caption = #25152#23646#21697#31181':'
          Control = EditStock
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Group3: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Item2: TdxLayoutItem
            Caption = #21462#26679#26085#26399':'
            Control = EditDate
            ControlOptions.ShowBorder = False
          end
          object dxLayoutControl1Item3: TdxLayoutItem
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            Caption = #24405#20837#20154':'
            Control = EditMan
            ControlOptions.ShowBorder = False
          end
        end
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #26816#39564#25968#25454
        object dxLayoutControl1Item4: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avClient
          Caption = 'Panel1'
          ShowCaption = False
          Control = wPanel
          ControlOptions.AutoColor = True
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
