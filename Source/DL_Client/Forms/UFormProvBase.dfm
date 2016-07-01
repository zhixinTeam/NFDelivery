inherited fFormProvBase: TfFormProvBase
  Left = 451
  Top = 243
  ClientHeight = 294
  ClientWidth = 430
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 430
    Height = 294
    AutoControlTabOrders = False
    inherited BtnOK: TButton
      Left = 284
      Top = 261
      Caption = #24320#21333
      TabOrder = 3
    end
    inherited BtnExit: TButton
      Left = 354
      Top = 261
      TabOrder = 5
    end
    object EditMate: TcxTextEdit [2]
      Left = 81
      Top = 111
      ParentFont = False
      Properties.MaxLength = 15
      Properties.ReadOnly = True
      TabOrder = 0
      OnKeyPress = EditLadingKeyPress
      Width = 125
    end
    object EditProvider: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.ReadOnly = True
      TabOrder = 1
      OnKeyPress = EditLadingKeyPress
      Width = 121
    end
    object EditTruck: TcxButtonEdit [4]
      Left = 81
      Top = 220
      ParentFont = False
      Properties.Buttons = <
        item
          Default = True
          Kind = bkEllipsis
        end>
      Properties.OnButtonClick = EditTruckPropertiesButtonClick
      TabOrder = 2
      OnKeyPress = EditLadingKeyPress
      Width = 320
    end
    object EditMateID: TcxTextEdit [5]
      Left = 281
      Top = 111
      ParentFont = False
      TabOrder = 8
      Width = 121
    end
    object EditProID: TcxTextEdit [6]
      Left = 81
      Top = 61
      ParentFont = False
      TabOrder = 9
      Width = 121
    end
    object EditOrder: TcxTextEdit [7]
      Left = 81
      Top = 36
      ParentFont = False
      TabOrder = 10
      Width = 121
    end
    object EditOrign: TcxTextEdit [8]
      Left = 81
      Top = 136
      ParentFont = False
      TabOrder = 11
      Width = 121
    end
    object EditValue: TcxTextEdit [9]
      Left = 281
      Top = 136
      ParentFont = False
      TabOrder = 12
      Text = '0.00'
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        object dxLayout1Item5: TdxLayoutItem
          Caption = #35746#21333#32534#21495':'
          Control = EditOrder
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #20379#24212#32534#21495':'
          Control = EditProID
          ControlOptions.ShowBorder = False
        end
        object dxlytmLayout1Item3: TdxLayoutItem
          Caption = #20379' '#24212' '#21830':'
          Control = EditProvider
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Group4: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayout1Group2: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item9: TdxLayoutItem
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = #21407' '#26448' '#26009':'
              Control = EditMate
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item6: TdxLayoutItem
              Caption = #30719'    '#28857':'
              Control = EditOrign
              ControlOptions.ShowBorder = False
            end
          end
          object dxLayout1Group3: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayout1Item3: TdxLayoutItem
              Caption = #21407#26448#26009#32534#21495':'
              Control = EditMateID
              ControlOptions.ShowBorder = False
            end
            object dxLayout1Item7: TdxLayoutItem
              Caption = #35746'  '#21333'  '#37327':'
              Control = EditValue
              ControlOptions.ShowBorder = False
            end
          end
        end
      end
      object dxGroup2: TdxLayoutGroup [1]
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Caption = #25552#21333#20449#24687
        LayoutDirection = ldHorizontal
        object dxlytmLayout1Item12: TdxLayoutItem
          Caption = #36816#36755#36710#36742':'
          Control = EditTruck
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
