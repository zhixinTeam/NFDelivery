inherited fFormRFIDCard: TfFormRFIDCard
  Caption = #20851#32852#30005#23376#26631#31614
  ClientHeight = 203
  ClientWidth = 354
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 354
    Height = 203
    inherited BtnOK: TButton
      Left = 208
      Top = 170
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 278
      Top = 170
      TabOrder = 6
    end
    object edtTruck: TcxTextEdit [2]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = True
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object chkValue: TcxCheckBox [3]
      Left = 11
      Top = 170
      Caption = #21551#29992#30005#23376#26631#31614
      ParentFont = False
      State = cbsChecked
      Style.HotTrack = False
      TabOrder = 4
      Transparent = True
      Width = 105
    end
    object cxLabel1: TcxLabel [4]
      Left = 23
      Top = 86
      AutoSize = False
      Caption = #22914#26524#20351#29992#36828#31243#35835#21345#22120#33719#21462#26631#31614#21495','#35831#36873#25321#35774#22791':'
      ParentFont = False
      Style.Edges = []
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 27
      Width = 246
      AnchorY = 100
    end
    object EditReaders: TcxComboBox [5]
      Left = 81
      Top = 118
      ParentFont = False
      Properties.DropDownListStyle = lsEditFixedList
      Properties.DropDownRows = 15
      Properties.IncrementalSearch = False
      Properties.ItemHeight = 22
      TabOrder = 3
      Width = 121
    end
    object edtRFIDCard: TcxButtonEdit [6]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.ReadOnly = True
      Properties.OnButtonClick = edtRFIDCardPropertiesButtonClick
      TabOrder = 1
      OnKeyPress = edtRFIDCardKeyPress
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item6: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = edtTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #30005#23376#26631#31614':'
          Control = edtRFIDCard
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = 'cxLabel1'
          ShowCaption = False
          Control = cxLabel1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #35774#22791#20301#32622':'
          Control = EditReaders
          ControlOptions.ShowBorder = False
        end
      end
      inherited dxLayout1Group1: TdxLayoutGroup
        object dxLayout1Item4: TdxLayoutItem [0]
          Control = chkValue
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object tmrReadCard: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrReadCardTimer
    Left = 16
    Top = 28
  end
end
