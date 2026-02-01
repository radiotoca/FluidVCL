object Capture: TCapture
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Capture'
  ClientHeight = 481
  ClientWidth = 846
  Color = 2566183
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWhite
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  GlassFrame.SheetOfGlass = True
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnPaint = FormPaint
  OnShow = FormShow
  TextHeight = 15
  object RoundedPanel1: TRoundedPanel
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 836
    Height = 471
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
      836
      471)
    object btnCapture: TRoundedSpeedButton
      Left = 723
      Top = 67
      Width = 91
      Height = 33
      Cursor = crHandPoint
      AllowAllUp = True
      Anchors = [akTop, akRight]
      Caption = 'Capture'
      Flat = True
      OnClick = btnCaptureClick
      Color = 2829354
      HoverColor = 3947320
      ModalResult = 1
    end
    object LabelStatus: TLabel
      Left = 24
      Top = 448
      Width = 62
      Height = 15
      Anchors = [akLeft, akBottom]
      Caption = 'LabelStatus'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsItalic]
      GlowSize = 1
      ParentFont = False
    end
    object LabelResolution: TLabel
      Left = 520
      Top = 448
      Width = 171
      Height = 15
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      AutoSize = False
      Caption = 'LabelResolution'
      ExplicitTop = 578
    end
    object pnlTop: TPanel
      Left = 1
      Top = 1
      Width = 834
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      Color = 2829354
      ParentBackground = False
      TabOrder = 0
      OnMouseDown = pnlTopMouseDown
      DesignSize = (
        834
        41)
      object RoundedSpeedButton7: TRoundedSpeedButton
        Left = 803
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
        Width = 51
        Height = 15
        Caption = 'Capture...'
      end
    end
    object PanelVideo: TRoundedPanel
      Left = 24
      Top = 67
      Width = 667
      Height = 375
      Anchors = [akLeft, akTop, akRight, akBottom]
      Color = clBlack
      DoubleBuffered = True
      ParentBackground = False
      ParentDoubleBuffered = False
      TabOrder = 1
      BorderColor = 3355443
    end
    object ComboBoxDevices: TComboBox
      Left = 723
      Top = 222
      Width = 91
      Height = 23
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Visible = False
      OnChange = ComboBoxDevicesChange
    end
    object ComboBoxFormats: TComboBox
      Left = 723
      Top = 259
      Width = 91
      Height = 23
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Visible = False
      OnChange = ComboBoxFormatsChange
    end
    object Button1: TButton
      Left = 709
      Top = 336
      Width = 75
      Height = 25
      Caption = 'Button1'
      TabOrder = 4
      Visible = False
      OnClick = Button1Click
    end
  end
  object TimerVideoUpdate: TTimer
    Enabled = False
    Left = 613
    Top = 376
  end
end
