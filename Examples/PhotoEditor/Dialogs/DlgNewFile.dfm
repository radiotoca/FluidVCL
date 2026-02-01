object NewFile: TNewFile
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'NewFile'
  ClientHeight = 236
  ClientWidth = 364
  Color = 2566183
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.SheetOfGlass = True
  Position = poMainFormCenter
  OnPaint = FormPaint
  OnShow = FormShow
  TextHeight = 15
  object RoundedPanel1: TRoundedPanel
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 354
    Height = 226
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    BorderWidth = 1
    Caption = 'RoundedPanel1'
    Color = 3092785
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 0
    CornerRadius = 27
    BorderEnabled = False
    HoverEnabled = False
    DesignSize = (
      354
      226)
    object LabelWidth: TLabel
      Left = 24
      Top = 93
      Width = 35
      Height = 15
      Caption = 'Width:'
    end
    object LabelName: TLabel
      Left = 24
      Top = 64
      Width = 35
      Height = 15
      Caption = 'Name:'
    end
    object LabelBackgroundContents: TLabel
      Left = 24
      Top = 122
      Width = 67
      Height = 15
      Caption = 'Background:'
    end
    object RoundedSpeedButton1: TRoundedSpeedButton
      Left = 234
      Top = 168
      Width = 97
      Height = 33
      Cursor = crHandPoint
      AllowAllUp = True
      Caption = 'Get to it'
      Flat = True
      OnClick = RoundedSpeedButton1Click
      Color = 2829354
      HoverColor = 3947320
      ModalResult = 1
    end
    object pnlTop: TPanel
      Left = 1
      Top = 1
      Width = 352
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      Color = 2829354
      ParentBackground = False
      TabOrder = 0
      OnMouseDown = pnlTopMouseDown
      DesignSize = (
        352
        41)
      object RoundedSpeedButton7: TRoundedSpeedButton
        Left = 321
        Top = 8
        Width = 23
        Height = 22
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        Caption = 'X'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = 18
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = RoundedSpeedButton7Click
        Color = 3947320
        HoverColor = 5987421
        DownColor = 3290164
        BorderRadius = 5
        ExplicitLeft = 368
      end
      object Label1: TLabel
        Left = 23
        Top = 13
        Width = 60
        Height = 15
        Caption = 'New Image'
      end
    end
    object EditWidth: TEdit
      Left = 152
      Top = 89
      Width = 49
      Height = 23
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 2829354
      TabOrder = 1
      Text = '640'
    end
    object EditHeight: TEdit
      Left = 224
      Top = 89
      Width = 41
      Height = 23
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 2829354
      TabOrder = 2
      Text = '480'
    end
    object EditName: TEdit
      Left = 152
      Top = 60
      Width = 179
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 2829354
      TabOrder = 3
      Text = 'Untitled-1'
    end
    object ComboBoxBackgroundContents: TComboBox
      Left = 152
      Top = 118
      Width = 179
      Height = 23
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemIndex = 0
      ParentColor = True
      TabOrder = 4
      Text = 'White'
      Items.Strings = (
        'White'
        'Black'
        'Transparent')
    end
  end
end
