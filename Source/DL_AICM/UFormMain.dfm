object fFormMain: TfFormMain
  Left = 389
  Top = 224
  BorderStyle = bsNone
  Caption = #29992#25143#33258#21161#19994#21153
  ClientHeight = 539
  ClientWidth = 952
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 952
    Height = 92
    Align = alTop
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 0
    object LabelTop: TLabel
      Left = 0
      Top = 0
      Width = 904
      Height = 92
      Align = alClient
      Alignment = taCenter
      Caption = #27426#36814#20351#29992#33258#21161#26426#21462#21345#31995#32479
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -32
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Layout = tlCenter
      OnDblClick = LabelTopDblClick
    end
    object Panel1: TPanel
      Left = 904
      Top = 0
      Width = 48
      Height = 92
      Align = alRight
      BevelOuter = bvNone
      Caption = 'Panel1'
      Color = clBlack
      TabOrder = 0
      object Image1: TImage
        Left = 0
        Top = 0
        Width = 48
        Height = 92
        Align = alClient
        Picture.Data = {
          0A544A504547496D6167654A020000FFD8FFE000104A46494600010101004800
          480000FFDB004300080606070605080707070909080A0C140D0C0B0B0C191213
          0F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F2739
          3D38323C2E333432FFC0000B080110019001011100FFC4001500010100000000
          000000000000000000000008FFC4001410010000000000000000000000000000
          0000FFDA0008010100003F009FC0000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000007FFFD9}
        Stretch = True
      end
      object LabelDec: TcxLabel
        Left = 0
        Top = 0
        Align = alClient
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clRed
        Style.Font.Height = -32
        Style.Font.Name = 'MS Sans Serif'
        Style.Font.Style = [fsBold]
        Style.IsFontAssigned = True
        Properties.Alignment.Vert = taVCenter
        Properties.Orientation = cxoLeft
        Transparent = True
        AnchorY = 46
      end
    end
  end
  object PanelRight: TPanel
    Left = 792
    Top = 92
    Width = 160
    Height = 447
    Align = alRight
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 1
    DesignSize = (
      160
      447)
    object ImageRight: TImage
      Left = 0
      Top = 0
      Width = 160
      Height = 447
      Align = alClient
      Picture.Data = {
        0A544A504547496D6167654A020000FFD8FFE000104A46494600010101004800
        480000FFDB004300080606070605080707070909080A0C140D0C0B0B0C191213
        0F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F2739
        3D38323C2E333432FFC0000B080110019001011100FFC4001500010100000000
        000000000000000000000008FFC4001410010000000000000000000000000000
        0000FFDA0008010100003F009FC0000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000007FFFD9}
      Stretch = True
    end
    object BtnSCard: TSpeedButton
      Left = 0
      Top = 163
      Width = 161
      Height = 70
      AllowAllUp = True
      Anchors = []
      Caption = #21150#29702#30913#21345
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = ButtonClick
    end
    object BtnPrint: TSpeedButton
      Left = 0
      Top = 260
      Width = 161
      Height = 70
      AllowAllUp = True
      Anchors = []
      Caption = #25171#21360#21270#39564#21333
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = ButtonClick
    end
    object BtnReturn: TSpeedButton
      Left = 0
      Top = 355
      Width = 161
      Height = 70
      AllowAllUp = True
      Anchors = []
      Caption = #36820#22238#20027#30028#38754
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = BtnReturnClick
    end
  end
  object PanelWork: TPanel
    Left = 0
    Top = 92
    Width = 792
    Height = 447
    Align = alClient
    BevelOuter = bvNone
    Color = clBlack
    TabOrder = 2
    object ImageWork: TImage
      Left = 0
      Top = 0
      Width = 792
      Height = 447
      Align = alClient
      Picture.Data = {
        0A544A504547496D6167654A020000FFD8FFE000104A46494600010101004800
        480000FFDB004300080606070605080707070909080A0C140D0C0B0B0C191213
        0F141D1A1F1E1D1A1C1C20242E2720222C231C1C2837292C30313434341F2739
        3D38323C2E333432FFC0000B080110019001011100FFC4001500010100000000
        000000000000000000000008FFC4001410010000000000000000000000000000
        0000FFDA0008010100003F009FC0000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000000000007FFFD9}
      Stretch = True
    end
  end
  object TimerDec: TTimer
    OnTimer = TimerDecTimer
    Left = 552
    Top = 16
  end
  object ComReader: TComPort
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
    OnRxChar = ComReaderRxChar
    Left = 584
    Top = 16
  end
end
