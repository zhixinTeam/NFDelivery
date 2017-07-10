inherited fFormCardProvide: TfFormCardProvide
  Left = 203
  Top = 158
  Caption = #20379#24212#30913#21345
  ClientHeight = 487
  ClientWidth = 398
  Position = poMainFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 398
    Height = 487
    inherited BtnOK: TButton
      Left = 252
      Top = 454
      Caption = #30830#23450
      TabOrder = 15
    end
    inherited BtnExit: TButton
      Left = 322
      Top = 454
      TabOrder = 16
    end
    object EditTruck: TcxTextEdit [2]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 7
      OnKeyPress = EditTruckKeyPress
      Width = 121
    end
    object cxLabel1: TcxLabel [3]
      Left = 23
      Top = 186
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
      Top = 236
      ParentFont = False
      Properties.MaxLength = 15
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsOffice11
      TabOrder = 8
      OnKeyPress = EditCardKeyPress
      Width = 121
    end
    object EditCardType: TcxCheckBox [5]
      Left = 23
      Top = 343
      Caption = #38271#26399#21345
      ParentFont = False
      TabOrder = 11
      Transparent = True
      Width = 121
    end
    object EditBack: TcxCheckBox [6]
      Left = 23
      Top = 421
      Caption = #20498#36710#19979#30917
      ParentFont = False
      TabOrder = 14
      Transparent = True
      Width = 121
    end
    object EditMuilti: TcxCheckBox [7]
      Left = 23
      Top = 369
      Caption = #31995#32479#22797#30917
      ParentFont = False
      TabOrder = 12
      Transparent = True
      Width = 121
    end
    object EditPName: TcxButtonEdit [8]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      TabOrder = 0
      Width = 121
    end
    object EditMName: TcxTextEdit [9]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 1
      Width = 121
    end
    object EditValue: TcxTextEdit [10]
      Left = 81
      Top = 86
      ParentFont = False
      TabOrder = 2
      Text = '0'
      Width = 121
    end
    object EditOrder: TcxTextEdit [11]
      Left = 81
      Top = 111
      ParentFont = False
      TabOrder = 3
      Width = 121
    end
    object EditOValue: TcxTextEdit [12]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 4
      Text = '0'
      Width = 121
    end
    object EditMemo: TcxTextEdit [13]
      Left = 81
      Top = 286
      ParentFont = False
      TabOrder = 10
      Width = 121
    end
    object EditArea: TcxTextEdit [14]
      Left = 81
      Top = 161
      ParentFont = False
      TabOrder = 5
      Width = 121
    end
    object EditPre: TcxCheckBox [15]
      Left = 23
      Top = 395
      Caption = #39044#32622#30382#37325
      ParentFont = False
      TabOrder = 13
      Transparent = True
      Width = 121
    end
    object EditPoundStation: TcxComboBox [16]
      Left = 81
      Top = 261
      TabOrder = 9
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = #35746#21333#20449#24687
        object dxLayout1Item3: TdxLayoutItem
          Caption = #20379#24212#21830#21517':'
          Control = EditPName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item10: TdxLayoutItem
          Caption = #21407#26448#26009#21517':'
          Control = EditMName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #20379#24212'('#21544'):'
          Control = EditValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item12: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = EditOrder
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item13: TdxLayoutItem
          Caption = #35746' '#21333' '#37327':'
          Control = EditOValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item15: TdxLayoutItem
          Caption = #30719'    '#28857':'
          Control = EditArea
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30913#21345#32534#21495':'
          Control = EditCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item17: TdxLayoutItem
          Caption = #25351#23450#22320#30917':'
          Control = EditPoundStation
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item14: TdxLayoutItem
          Caption = #22791'    '#27880':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
      end
      object dxLayout1Group2: TdxLayoutGroup [1]
        Caption = #38468#21152#21442#25968
        object dxLayout1Item9: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = EditCardType
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = EditMuilti
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item16: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = EditPre
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = 'cxCheckBox2'
          ShowCaption = False
          Control = EditBack
          ControlOptions.ShowBorder = False
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
    Left = 14
    Top = 12
  end
end
