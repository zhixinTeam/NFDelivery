inherited fFormWXAccount: TfFormWXAccount
  Left = 523
  Top = 464
  ClientHeight = 213
  ClientWidth = 377
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 12
  inherited dxLayout1: TdxLayoutControl
    Width = 377
    Height = 213
    inherited BtnOK: TButton
      Left = 231
      Top = 180
      Caption = #30830#23450
      TabOrder = 5
    end
    inherited BtnExit: TButton
      Left = 301
      Top = 180
      TabOrder = 6
    end
    object EditName: TcxTextEdit [2]
      Left = 81
      Top = 61
      ParentFont = False
      Properties.MaxLength = 64
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 1
      OnKeyPress = EditNameKeyPress
      Width = 121
    end
    object EditMemo: TcxTextEdit [3]
      Left = 81
      Top = 86
      ParentFont = False
      Properties.MaxLength = 100
      Properties.ReadOnly = False
      Style.BorderColor = clWindowFrame
      Style.BorderStyle = ebsSingle
      TabOrder = 2
      OnKeyPress = OnCtrlKeyPress
      Width = 121
    end
    object Check1: TcxCheckBox [4]
      Left = 23
      Top = 111
      Caption = #26159#21542#26377#25928
      ParentFont = False
      TabOrder = 3
      Transparent = True
      Width = 121
    end
    object EditCusID: TcxTextEdit [5]
      Left = 81
      Top = 36
      ParentFont = False
      Style.HotTrack = False
      TabOrder = 0
      Width = 121
    end
    object Check2: TcxCheckBox [6]
      Left = 23
      Top = 137
      Caption = #20851#32852#23458#25143
      ParentFont = False
      Style.HotTrack = False
      TabOrder = 4
      Transparent = True
      Width = 121
    end
    inherited dxLayout1Group_Root: TdxLayoutGroup
      inherited dxGroup1: TdxLayoutGroup
        Caption = ''
        object dxLayout1Item6: TdxLayoutItem
          Caption = #23458#25143#32534#21495':'
          Control = EditCusID
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item3: TdxLayoutItem
          Caption = #23458#25143#21517#31216':'
          Control = EditName
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item4: TdxLayoutItem
          Caption = #22791#27880#20449#24687':'
          Control = EditMemo
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item5: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check1
          ControlOptions.ShowBorder = False
        end
        object dxLayout1Item7: TdxLayoutItem
          Caption = 'cxCheckBox1'
          ShowCaption = False
          Control = Check2
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
