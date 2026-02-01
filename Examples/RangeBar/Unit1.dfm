object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Fluid Range Component - Dark Mode Showcase'
  ClientHeight = 508
  ClientWidth = 816
  Color = 3223855
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 14737632
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object lblHeader: TLabel
    Left = 30
    Top = 20
    Width = 222
    Height = 25
    Caption = 'FluidRange VCL Showcase'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Segoe UI Semibold'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblDual: TLabel
    Left = 30
    Top = 70
    Width = 198
    Height = 15
    Caption = 'Dual Range: Inward Facing Triangles'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblTicks: TLabel
    Left = 30
    Top = 175
    Width = 162
    Height = 15
    Caption = 'Snapped Ticks: Material Style'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblRect: TLabel
    Left = 30
    Top = 285
    Width = 186
    Height = 15
    Caption = 'Portrait Thumbs: Bottom Bubbles'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblMinimal: TLabel
    Left = 30
    Top = 405
    Width = 87
    Height = 15
    Caption = 'Minimalist: Slim'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblWarning: TLabel
    Left = 370
    Top = 405
    Width = 145
    Height = 15
    Caption = 'Alert Style: Triangle Down'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 679
    Top = 28
    Width = 82
    Height = 15
    Caption = 'Vertical Sliders'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 14737632
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object RangeDual: TFluidRange
    Left = 30
    Top = 95
    Width = 640
    Height = 55
    IsDualMode = True
    TrackHeight = 10
    ThumbSize = 22
    ThumbShape = tsTriangleLeft
    ThumbShapeMin = tsTriangleRight
    ShowTicks = True
    TickFrequency = 0
    TickColor = clBlack
    SnapToTicks = True
    TrackColor = 4539717
    ActiveTrackColor = 16746496
    ThumbColor = 13684944
    ThumbHoverColor = clWhitesmoke
    ThumbBorderColor = 6316128
    TrackBorderColor = clBlack
    BubbleColor = 3355443
  end
  object RangeTicks: TFluidRange
    Left = 30
    Top = 196
    Width = 640
    Height = 69
    Position = 50
    TrackHeight = 4
    ShowTicks = True
    TickFrequency = 5
    TickColor = clGray
    SnapToTicks = True
    TrackColor = 3815994
    ActiveTrackColor = 4905361
    ThumbColor = 4905361
    ThumbHoverColor = clWhitesmoke
    ThumbBorderColor = clNone
    TrackBorderColor = clBlack
    BubbleColor = 3355443
  end
  object RangeRect: TFluidRange
    Left = 30
    Top = 310
    Width = 640
    Height = 70
    Position = 65
    TrackHeight = 2
    ThumbSize = 24
    ThumbShape = tsRectPortrait
    ShowTicks = True
    TickFrequency = 0
    TickColor = clBlack
    SnapToTicks = True
    TrackColor = 5263440
    ActiveTrackColor = 6184703
    ThumbColor = 14737632
    ThumbHoverColor = clWhitesmoke
    ThumbBorderColor = 11579568
    TrackBorderColor = clBlack
    BubbleColor = 3355443
    BubblePosition = bpBottom
  end
  object RangeSlim: TFluidRange
    Left = 30
    Top = 440
    Width = 300
    Height = 40
    Position = 30
    TrackHeight = 11
    ThumbSize = 20
    ThumbShape = tsRectLandscape
    ShowTicks = True
    TickFrequency = 0
    TickColor = clBlack
    SnapToTicks = True
    TrackColor = 4013373
    ActiveTrackColor = clSilver
    ThumbHoverColor = clWhitesmoke
    ThumbBorderColor = 2105376
    TrackBorderColor = clBlack
    BubbleColor = 3355443
    ShowValueBubble = False
  end
  object RangeWarning: TFluidRange
    Left = 370
    Top = 430
    Width = 300
    Height = 59
    Position = 90
    ThumbSize = 20
    ThumbShape = tsTriangleDown
    ShowTicks = True
    TickFrequency = 0
    TickColor = clBlack
    SnapToTicks = True
    TrackColor = 4013373
    ActiveTrackColor = 4605695
    ThumbColor = 4605695
    ThumbHoverColor = clOrange
    ThumbBorderColor = clWhite
    TrackBorderColor = clBlack
    BubbleColor = 3355443
  end
  object FluidRange1: TFluidRange
    Left = 688
    Top = 56
    Width = 17
    Height = 424
    Orientation = roVertical
    TrackRounding = 15
    ThumbShape = tsRectPortrait
    ShowTicks = True
    TickFrequency = 0
    TickColor = clWhite
    SnapToTicks = True
    TrackColor = 14737632
    ActiveTrackColor = 14737632
    ThumbHoverColor = cl3DDkShadow
    ThumbBorderColor = 11579568
    TrackBorderColor = clBlack
    BubbleColor = 3355443
    ShowValueBubble = False
    BubblePosition = bpLeft
  end
  object FluidRange2: TFluidRange
    Left = 736
    Top = 56
    Width = 33
    Height = 424
    Orientation = roVertical
    TrackHeight = 10
    ThumbSize = 25
    TrackRounding = 5
    TickFrequency = 0
    TickColor = clWhite
    TrackColor = 5197647
    ActiveTrackColor = clRed
    ThumbColor = clRed
    ThumbHoverColor = clMaroon
    ThumbBorderColor = clMaroon
    TrackBorderColor = clBlack
    BubbleColor = 3355443
    ShowValueBubble = False
  end
end
