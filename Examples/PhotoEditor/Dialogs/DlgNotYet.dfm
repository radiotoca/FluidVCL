object NotYet: TNotYet
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'NotYet'
  ClientHeight = 157
  ClientWidth = 407
  Color = 2566183
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.SheetOfGlass = True
  Position = poMainFormCenter
  OnPaint = FormPaint
  TextHeight = 15
  object RoundedPanel1: TRoundedPanel
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 397
    Height = 147
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
    object Label1: TLabel
      Left = 1
      Top = 80
      Width = 400
      Height = 15
      Alignment = taCenter
      AutoSize = False
      Caption = 'This feature has not yet been implemented. Please be patient.'
    end
    object pnlTop: TPanel
      Left = 1
      Top = 1
      Width = 395
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      Color = 2829354
      ParentBackground = False
      TabOrder = 0
      OnMouseDown = pnlTopMouseDown
      DesignSize = (
        395
        41)
      object RoundedSpeedButton7: TRoundedSpeedButton
        Left = 364
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
      object Label2: TLabel
        Left = 23
        Top = 13
        Width = 74
        Height = 15
        Caption = 'Woah, buddy!'
      end
    end
  end
end
