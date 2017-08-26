inherited fFormCardTemp: TfFormCardTemp
  Left = 426
  Top = 177
  Caption = #20020#26102#19994#21153
  ClientHeight = 469
  ClientWidth = 410
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 410
    Height = 469
    inherited BtnOK: TButton
      Left = 264
      Top = 436
      Caption = #30830#23450
      TabOrder = 15
    end
    inherited BtnExit: TButton
      Left = 334
      Top = 436
      TabOrder = 16
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 186
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 6
      OnKeyPress = EditTruckKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [3]
      Left = 23
      Top = 161
      AutoSize = False
      ParentFont = False
      Properties.LineOptions.Alignment = cxllaBottom
      Properties.LineOptions.Visible = True
      Transparent = True
      Height = 20
      Width = 287
    end
    object EditCard: TcxTextEdit [4]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 7
      OnKeyPress = EditCardKeyPress
      Width = 121
    end
    object EditCusID: TcxComboBox [5]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.OnChange = EditCusIDPropertiesChange
      TabOrder = 0
      Width = 121
    end
    object EditCusName: TcxTextEdit [6]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditOrgin: TcxTextEdit [7]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Width = 121
    end
    object EditMID: TcxComboBox [8]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.OnChange = EditMIDPropertiesChange
      TabOrder = 3
      Width = 121
    end
    object EditMName: TcxTextEdit [9]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 4
      Width = 121
    end
    object EditMemo: TcxTextEdit [10]
      Left = 81
      Top = 261
      ParentFont = False
      TabOrder = 9
      Width = 121
    end
    object EditMuilti: TcxCheckBox [11]
      Left = 23
      Top = 351
      Caption = #31995#32479#22797#30917
      ParentFont = False
      TabOrder = 11
      Transparent = True
      Width = 121
    end
    object EditCardType: TcxCheckBox [12]
      Left = 23
      Top = 325
      Caption = #38271#26399#21345
      ParentFont = False
      TabOrder = 10
      Transparent = True
      Width = 121
    end
    object EditBack: TcxCheckBox [13]
      Left = 23
      Top = 403
      Caption = #20498#36710#19979#30917
      ParentFont = False
      TabOrder = 13
      Transparent = True
      Width = 194
    end
    object EditPre: TcxCheckBox [14]
      Left = 23
      Top = 377
      Caption = #39044#32622#30382#37325
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 121
    end
    object EditPoundStation: TcxComboBox [15]
      Left = 81
      Top = 236
      ParentFont = False
      TabOrder = 8
      Width = 121
    end
    object EditTruckOut: TcxCheckBox [16]
      Left = 222
      Top = 403
      Caption = #36710#36742#20986#21378
      ParentFont = False
      State = cbsChecked
      TabOrder = 14
      Transparent = True
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditCusName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #20179#24211#22320#22336':'
          Control = EditOrgin
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #29289#26009#32534#21495':'
          Control = EditMID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditMName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#33337#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30913#21345#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = #25351#23450#22320#30917':'
          Control = EditPoundStation
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #22791'    '#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group3: TdxLayoutGroup [1]
        Caption = #38468#21152#20449#24687
        object dxLayout1Item12: TdxLayoutItem
          Caption = 'cxCheckBox2'
          ShowCaption = False
          Control = EditCardType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = EditMuilti
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = EditPre
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Item14: TdxLayoutItem
            Caption = 'cxCheckBox3'
            ShowCaption = False
            Control = EditBack
            ControlOptions.ShowBorder = False
          end
          object dxLayout1Item17: TdxLayoutItem
            Caption = 'cxCheckBox1'
            ShowCaption = False
            Control = EditTruckOut
            ControlOptions.ShowBorder = False
          end
        end
      end
    end
  end
  object ComPort1: TComPort
    BaudRate = br9600
    Port = 'COM1'
    Parity.Bits = prNone
    StopBits = sbOneStopBit
    DataBits = dbEight
    Events = [evRxChar, evTxEmpty, evRxFlag, evRing, evBreak, evCTS, evDSR, evError, evRLSD, evRx80Full]
    FlowControl.OutCTSFlow = False
    FlowControl.OutDSRFlow = False
    FlowControl.ControlDTR = dtrDisable
    FlowControl.ControlRTS = rtsDisable
    FlowControl.XonXoffOut = False
    FlowControl.XonXoffIn = False
    Timeouts.ReadTotalMultiplier = 10
    Timeouts.ReadTotalConstant = 100
    OnRxChar = ComPort1RxChar
    Left = 22
    Top = 156
  end
end
