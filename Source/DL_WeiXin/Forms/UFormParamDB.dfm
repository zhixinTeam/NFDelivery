inherited fFormParamDB: TfFormParamDB
  Left = 397
  Top = 302
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #25968#25454#24211
  ClientHeight = 336
  ClientWidth = 497
  OldCreateOrder = True
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 6
    Top = 11
    Width = 54
    Height = 12
    Caption = #21442#25968#21015#34920':'
  end
  object Label2: TLabel
    Left = 156
    Top = 26
    Width = 30
    Height = 12
    Caption = #26631#35782':'
  end
  object Label3: TLabel
    Left = 328
    Top = 26
    Width = 30
    Height = 12
    Caption = #21517#31216':'
  end
  object Bevel1: TBevel
    Left = 4
    Top = 301
    Width = 487
    Height = 5
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object Label4: TLabel
    Left = 156
    Top = 73
    Width = 66
    Height = 12
    Caption = #26381#21153#22120#22320#22336':'
  end
  object Label5: TLabel
    Left = 328
    Top = 73
    Width = 66
    Height = 12
    Caption = #26381#21153#22120#31471#21475':'
  end
  object Label6: TLabel
    Left = 156
    Top = 167
    Width = 66
    Height = 12
    Caption = #25968#25454#24211#21517#31216':'
  end
  object Label7: TLabel
    Left = 156
    Top = 120
    Width = 54
    Height = 12
    Caption = #30331#24405#29992#25143':'
  end
  object Label8: TLabel
    Left = 328
    Top = 120
    Width = 54
    Height = 12
    Caption = #29992#25143#23494#30721':'
  end
  object Label9: TLabel
    Left = 328
    Top = 167
    Width = 78
    Height = 12
    Caption = #24037#20316#23545#35937#20010#25968':'
  end
  object Label10: TLabel
    Left = 156
    Top = 214
    Width = 66
    Height = 12
    Caption = #36830#25509#23383#31526#20018':'
  end
  object ListParam: TListBox
    Left = 6
    Top = 26
    Width = 140
    Height = 273
    Style = lbOwnerDrawFixed
    ItemHeight = 20
    TabOrder = 0
    OnClick = ListParamClick
  end
  object BtnAdd: TButton
    Left = 6
    Top = 309
    Width = 44
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #28155#21152
    TabOrder = 10
    OnClick = BtnAddClick
  end
  object BtnDel: TButton
    Left = 52
    Top = 309
    Width = 44
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #21024#38500
    TabOrder = 11
    OnClick = BtnDelClick
  end
  object EditID: TEdit
    Left = 156
    Top = 40
    Width = 160
    Height = 20
    TabOrder = 1
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
    OnKeyPress = EditIDKeyPress
  end
  object EditName: TEdit
    Left = 328
    Top = 40
    Width = 160
    Height = 20
    TabOrder = 2
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object BtnExit: TButton
    Left = 427
    Top = 309
    Width = 60
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 13
  end
  object BtnOK: TButton
    Left = 363
    Top = 309
    Width = 60
    Height = 20
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 12
    OnClick = BtnOKClick
  end
  object EditIP: TEdit
    Left = 156
    Top = 87
    Width = 160
    Height = 20
    TabOrder = 3
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object EditPort: TEdit
    Left = 328
    Top = 87
    Width = 160
    Height = 20
    TabOrder = 4
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object EditDB: TEdit
    Left = 156
    Top = 182
    Width = 160
    Height = 20
    TabOrder = 7
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object EditUser: TEdit
    Left = 156
    Top = 134
    Width = 160
    Height = 20
    TabOrder = 5
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object EditPwd: TEdit
    Left = 328
    Top = 135
    Width = 160
    Height = 20
    PasswordChar = '*'
    TabOrder = 6
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object EditWorker: TEdit
    Left = 328
    Top = 182
    Width = 160
    Height = 20
    TabOrder = 8
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object MemoConn: TMemo
    Left = 156
    Top = 230
    Width = 332
    Height = 69
    ScrollBars = ssVertical
    TabOrder = 9
    OnChange = EditIDChange
    OnKeyDown = OnCtrlKeyDown
  end
  object BtnConnect: TButton
    Left = 280
    Top = 408
    Width = 64
    Height = 20
    Caption = #27979#35797
    TabOrder = 14
  end
end
