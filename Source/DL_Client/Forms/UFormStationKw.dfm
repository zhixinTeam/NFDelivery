inherited fFormStationKw: TfFormStationKw
  Left = 433
  Top = 126
  ClientHeight = 293
  ClientWidth = 424
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 424
    Height = 293
    inherited BtnOK: TButton
      Left = 278
      Top = 260
      Enabled = False
      TabOrder = 8
    end
    inherited BtnExit: TButton
      Left = 348
      Top = 260
      TabOrder = 9
    end
    object EditKID: TcxTextEdit [2]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      Width = 125
    end
    object EditPValue: TcxTextEdit [3]
      Left = 81
      Top = 136
      ParentFont = False
      Style.BorderStyle = ebsSingle
      TabOrder = 4
      Width = 121
    end
    object EditMValue: TcxTextEdit [4]
      Left = 81
      Top = 186
      ParentFont = False
      Style.BorderStyle = ebsSingle
      TabOrder = 6
      Width = 121
    end
    object EditTruck: TcxTextEdit [5]
      Left = 81
      Top = 111
      ParentFont = False
      Style.BorderStyle = ebsSingle
      TabOrder = 3
      Width = 121
    end
    object EditMID: TcxComboBox [6]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      Width = 121
    end
    object EditPID: TcxComboBox [7]
      Left = 81
      Top = 36
      ParentFont = False
      Properties.ReadOnly = False
      Style.BorderStyle = ebsSingle
      TabOrder = 0
      Width = 320
    end
    object EditPDate: TcxDateEdit [8]
      Left = 81
      Top = 161
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderStyle = ebsSingle
      TabOrder = 5
      Width = 121
    end
    object EditMDate: TcxDateEdit [9]
      Left = 81
      Top = 211
      ParentFont = False
      Properties.Kind = ckDateTime
      Style.BorderStyle = ebsSingle
      TabOrder = 7
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        AutoAligns = []
        Caption = #30917#21333#20449#24687
        object dxLayout1Item5: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditPID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #29289#26009#21517#31216':'
          Control = EditMID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item9: TdxLayoutItem
          Caption = #20179#24211#24211#20301':'
          Control = EditKID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #36710#29260#21495#30721':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item6: TdxLayoutItem
          Caption = #30382'    '#37325':'
          Control = EditPValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item8: TdxLayoutItem
          Caption = #30382#37325#26102#38388':'
          Control = EditPDate
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = #27611'    '#37325':'
          Control = EditMValue
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item11: TdxLayoutItem
          Caption = #27611#37325#26102#38388':'
          Control = EditMDate
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
