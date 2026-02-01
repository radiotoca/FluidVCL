object FluidColorPickerDialog: TFluidColorPickerDialog
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Color Picker'
  ClientHeight = 408
  ClientWidth = 680
  Color = 2829099
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 14737632
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object lblOld: TLabel
    Left = 418
    Top = 59
    Width = 19
    Height = 15
    Caption = 'Old'
  end
  object lblNew: TLabel
    Left = 418
    Top = 19
    Width = 24
    Height = 15
    Caption = 'New'
  end
  object ColorBox: TFluidColorBox
    Left = 15
    Top = 15
    Width = 330
    Height = 330
    BorderColor = 3815994
    BorderRadius = 6
    OnColorChange = ColorBoxColorChange
    Color = 2829099
    ParentColor = False
    TabStop = True
    TabOrder = 3
  end
  object pnlComparison: TPanel
    Left = 360
    Top = 15
    Width = 50
    Height = 80
    BevelOuter = bvNone
    Color = 3355443
    ParentBackground = False
    TabOrder = 0
    object shpOldColor: TShape
      Left = 0
      Top = 40
      Width = 50
      Height = 40
      Align = alBottom
      Brush.Color = clGray
      Pen.Style = psClear
    end
    object shpNewColor: TShape
      Left = 0
      Top = 0
      Width = 50
      Height = 40
      Align = alTop
      Brush.Color = clHighlight
      Pen.Style = psClear
    end
  end
  object pnlInputs: TPanel
    Left = 360
    Top = 105
    Width = 305
    Height = 240
    BevelOuter = bvNone
    ParentBackground = False
    ParentColor = True
    TabOrder = 1
    object lblHex: TLabel
      Left = 0
      Top = 5
      Width = 25
      Height = 15
      Caption = 'HEX:'
    end
    object lblRGB: TLabel
      Left = 0
      Top = 45
      Width = 25
      Height = 15
      Caption = 'RGB:'
    end
    object lblRGBA: TLabel
      Left = 0
      Top = 85
      Width = 33
      Height = 15
      Caption = 'RGBA:'
    end
    object lblHSL: TLabel
      Left = 0
      Top = 125
      Width = 24
      Height = 15
      Caption = 'HSL:'
    end
    object lblHSV: TLabel
      Left = 0
      Top = 165
      Width = 25
      Height = 15
      Caption = 'HSV:'
    end
    object edtHex: TRoundedEdit
      Left = 45
      Top = 2
      Width = 76
      Height = 23
      Text = '#4285F4'
      BorderColor = clGray
      BorderRadius = 8
      BorderThickness = 2.000000000000000000
      InnerPadding = 10
      AutoHeight = False
      OnChange = edtHexChange
      Color = 6579300
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TabStop = False
    end
    object edtR: TEdit
      Left = 45
      Top = 42
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Text = '66'
      OnChange = RGBChange
    end
    object edtG: TEdit
      Left = 100
      Top = 42
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      Text = '133'
      OnChange = RGBChange
    end
    object edtB: TEdit
      Left = 155
      Top = 42
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      Text = '244'
      OnChange = RGBChange
    end
    object edtRA: TEdit
      Left = 45
      Top = 82
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 4
      Text = '66'
    end
    object edtGA: TEdit
      Left = 100
      Top = 82
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
      Text = '133'
    end
    object edtBA: TEdit
      Left = 155
      Top = 82
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 6
      Text = '244'
    end
    object edtAlpha: TEdit
      Left = 210
      Top = 82
      Width = 50
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 7
      Text = '255'
    end
    object edtH: TEdit
      Left = 45
      Top = 122
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 8
      Text = '214'#176
    end
    object edtS: TEdit
      Left = 110
      Top = 122
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 9
      Text = '90%'
    end
    object edtL: TEdit
      Left = 175
      Top = 122
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 10
      Text = '96%'
    end
    object edtHV: TEdit
      Left = 45
      Top = 162
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 11
      Text = '214'#176
    end
    object edtSV: TEdit
      Left = 110
      Top = 162
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 12
      Text = '90%'
    end
    object edtVV: TEdit
      Left = 175
      Top = 162
      Width = 60
      Height = 23
      Alignment = taCenter
      Color = 2039583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 13
      Text = '96%'
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 359
    Width = 680
    Height = 49
    Align = alBottom
    BevelOuter = bvNone
    Color = 2368548
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 391
    object btnOK: TButton
      Left = 505
      Top = 12
      Width = 80
      Height = 28
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 590
      Top = 12
      Width = 80
      Height = 28
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
