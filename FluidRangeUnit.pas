unit FluidRangeUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.Math;

type
  TActiveThumb = (atNone, atMin, atMax);
  TThumbShape = (tsCircle, tsSquare, tsRectPortrait, tsRectLandscape, tsTriangleUp, tsTriangleDown, tsTriangleLeft, tsTriangleRight);
  TBubblePosition = (bpTop, bpBottom, bpLeft, bpRight);
  TRangeOrientation = (roHorizontal, roVertical);

  TFluidRange = class(TCustomControl)
  private
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FPositionMin: Integer;
    FTrackHeight: Integer;
    FThumbSize: Integer;
    FTrackRounding: Integer;
    FThumbShape: TThumbShape;
    FThumbShapeMin: TThumbShape;
    FOrientation: TRangeOrientation;

    // Ticks & Snapping
    FShowTicks: Boolean;
    FTickFrequency: Integer;
    FTickColor: TColor;
    FSnapToTicks: Boolean;

    // Dual Mode
    FIsDualMode: Boolean;

    // Colors
    FTrackColor: TColor;
    FActiveTrackColor: TColor;
    FThumbColor: TColor;
    FThumbHoverColor: TColor;
    FThumbBorderColor: TColor;
    FTrackBorderColor: TColor;
    FBubbleColor: TColor;
    FBubbleTextColor: TColor;

    // Interaction State
    FActiveThumb: TActiveThumb;
    FIsDragging: Boolean;
    FIsHovering: Boolean;
    FShowValueBubble: Boolean;
    FBubblePosition: TBubblePosition;

    // Events
    FOnChange: TNotifyEvent;

    procedure SetMin(Value: Integer);
    procedure SetMax(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure SetPositionMin(Value: Integer);
    procedure SetTrackHeight(Value: Integer);
    procedure SetThumbSize(Value: Integer);
    procedure SetTrackRounding(Value: Integer);
    procedure SetTrackColor(Value: TColor);
    procedure SetActiveTrackColor(Value: TColor);
    procedure SetThumbColor(Value: TColor);
    procedure SetThumbHoverColor(Value: TColor);
    procedure SetThumbBorderColor(Value: TColor);
    procedure SetTrackBorderColor(Value: TColor);
    procedure SetBubbleColor(Value: TColor);
    procedure SetBubbleTextColor(Value: TColor);
    procedure SetIsDualMode(Value: Boolean);
    procedure SetShowTicks(Value: Boolean);
    procedure SetTickFrequency(Value: Integer);
    procedure SetTickColor(Value: TColor);
    procedure SetThumbShape(Value: TThumbShape);
    procedure SetThumbShapeMin(Value: TThumbShape);
    procedure SetBubblePosition(Value: TBubblePosition);
    procedure SetOrientation(Value: TRangeOrientation);

    function PositionToPixels(Pos: Integer): Integer;
    function PixelsToPosition(Coord: Integer): Integer;
    function ColorToGPColor(const Value: TColor): TGPColor;
    procedure UpdateValue(X, Y: Integer);
    procedure DrawThumbShape(Graphics: TGPGraphics; Rect: TGPRectF; Shape: TThumbShape; Brush: TGPBrush; Pen: TGPPen);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Position: Integer read FPosition write SetPosition default 80;
    property PositionMin: Integer read FPositionMin write SetPositionMin default 20;
    property IsDualMode: Boolean read FIsDualMode write SetIsDualMode default False;
    property Orientation: TRangeOrientation read FOrientation write SetOrientation default roHorizontal;

    property TrackHeight: Integer read FTrackHeight write SetTrackHeight default 6;
    property ThumbSize: Integer read FThumbSize write SetThumbSize default 18;
    property TrackRounding: Integer read FTrackRounding write SetTrackRounding default 3;
    property ThumbShape: TThumbShape read FThumbShape write SetThumbShape default tsCircle;
    property ThumbShapeMin: TThumbShape read FThumbShapeMin write SetThumbShapeMin default tsCircle;

    property ShowTicks: Boolean read FShowTicks write SetShowTicks default False;
    property TickFrequency: Integer read FTickFrequency write SetTickFrequency default 10;
    property TickColor: TColor read FTickColor write SetTickColor default clSilver;
    property SnapToTicks: Boolean read FSnapToTicks write FSnapToTicks default False;

    property TrackColor: TColor read FTrackColor write SetTrackColor default clSilver;
    property ActiveTrackColor: TColor read FActiveTrackColor write SetActiveTrackColor default clHighlight;
    property ThumbColor: TColor read FThumbColor write SetThumbColor default clWhite;
    property ThumbHoverColor: TColor read FThumbHoverColor write SetThumbHoverColor default clWhite;
    property ThumbBorderColor: TColor read FThumbBorderColor write SetThumbBorderColor default clGray;
    property TrackBorderColor: TColor read FTrackBorderColor write SetTrackBorderColor default clNone;
    property BubbleColor: TColor read FBubbleColor write SetBubbleColor default clBlack;
    property BubbleTextColor: TColor read FBubbleTextColor write SetBubbleTextColor default clWhite;

    property ShowValueBubble: Boolean read FShowValueBubble write FShowValueBubble default True;
    property BubblePosition: TBubblePosition read FBubblePosition write SetBubblePosition default bpTop;

    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TFluidRange]);
end;

constructor TFluidRange.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];
  Width := 200;
  Height := 60;
  FMin := 0;
  FMax := 100;
  FPosition := 80;
  FPositionMin := 20;
  FIsDualMode := False;
  FOrientation := roHorizontal;
  FTrackHeight := 6;
  FThumbSize := 18;
  FTrackRounding := 3;
  FThumbShape := tsCircle;
  FThumbShapeMin := tsCircle;
  FTrackColor := $E0E0E0;
  FActiveTrackColor := $FF8800;
  FThumbColor := clWhite;
  FThumbHoverColor := $F5F5F5;
  FThumbBorderColor := $B0B0B0;
  FTrackBorderColor := clNone;
  FBubbleColor := $333333;
  FBubbleTextColor := clWhite;
  FShowValueBubble := True;
  FBubblePosition := bpTop;
  FShowTicks := True;
  FTickFrequency := 10;
  FTickColor := $C0C0C0;
  FSnapToTicks := True;
  DoubleBuffered := True;
end;

function TFluidRange.ColorToGPColor(const Value: TColor): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

function TFluidRange.PositionToPixels(Pos: Integer): Integer;
var
  Range: Integer;
  EffectiveLength: Integer;
begin
  Range := FMax - FMin;
  if Range <= 0 then Exit(FThumbSize div 2);

  if FOrientation = roHorizontal then
    EffectiveLength := Width - FThumbSize
  else
    EffectiveLength := Height - FThumbSize;

  Result := Round((EffectiveLength * (Pos - FMin)) / Range) + (FThumbSize div 2);

  if FOrientation = roVertical then
    Result := Height - Result;
end;

function TFluidRange.PixelsToPosition(Coord: Integer): Integer;
var
  Range: Integer;
  EffectiveLength: Integer;
  Pos: Integer;
begin
  Range := FMax - FMin;

  if FOrientation = roHorizontal then
    EffectiveLength := Width - FThumbSize
  else
    EffectiveLength := Height - FThumbSize;

  if EffectiveLength <= 0 then Exit(FMin);

  if FOrientation = roVertical then
    Coord := Height - Coord;

  Pos := FMin + Round((Coord - (FThumbSize / 2)) * Range / EffectiveLength);

  if FSnapToTicks and (FTickFrequency > 0) then
    Pos := Round((Pos - FMin) / FTickFrequency) * FTickFrequency + FMin;

  Result := EnsureRange(Pos, FMin, FMax);
end;

procedure TFluidRange.DrawThumbShape(Graphics: TGPGraphics; Rect: TGPRectF; Shape: TThumbShape; Brush: TGPBrush; Pen: TGPPen);
var
  Path: TGPGraphicsPath;
  Points: array[0..2] of TGPPointF;
begin
  case Shape of
    tsCircle: Graphics.FillEllipse(Brush, Rect);
    tsSquare, tsRectPortrait, tsRectLandscape: Graphics.FillRectangle(Brush, Rect);
    tsTriangleUp, tsTriangleDown, tsTriangleLeft, tsTriangleRight:
      begin
        Path := TGPGraphicsPath.Create;
        try
          case Shape of
            tsTriangleUp: begin
              Points[0] := MakePoint(Rect.X + Rect.Width / 2, Rect.Y);
              Points[1] := MakePoint(Rect.X, Rect.Y + Rect.Height);
              Points[2] := MakePoint(Rect.X + Rect.Width, Rect.Y + Rect.Height);
            end;
            tsTriangleDown: begin
              Points[0] := MakePoint(Rect.X, Rect.Y);
              Points[1] := MakePoint(Rect.X + Rect.Width, Rect.Y);
              Points[2] := MakePoint(Rect.X + Rect.Width / 2, Rect.Y + Rect.Height);
            end;
            tsTriangleLeft: begin
              Points[0] := MakePoint(Rect.X + Rect.Width, Rect.Y);
              Points[1] := MakePoint(Rect.X, Rect.Y + Rect.Height / 2);
              Points[2] := MakePoint(Rect.X + Rect.Width, Rect.Y + Rect.Height);
            end;
            tsTriangleRight: begin
              Points[0] := MakePoint(Rect.X, Rect.Y);
              Points[1] := MakePoint(Rect.X + Rect.Width, Rect.Y + Rect.Height / 2);
              Points[2] := MakePoint(Rect.X, Rect.Y + Rect.Height);
            end;
          end;
          Path.AddPolygon(PGPPointF(@Points), 3);
          Graphics.FillPath(Brush, Path);
          if Assigned(Pen) then Graphics.DrawPath(Pen, Path);
        finally
          Path.Free;
        end;
        Exit;
      end;
  end;

  if Assigned(Pen) then
  begin
    case Shape of
      tsCircle: Graphics.DrawEllipse(Pen, Rect);
      tsSquare, tsRectPortrait, tsRectLandscape: Graphics.DrawRectangle(Pen, Rect);
    end;
  end;
end;

procedure TFluidRange.UpdateValue(X, Y: Integer);
var
  NewPos, Coord: Integer;
begin
  if FOrientation = roHorizontal then Coord := X else Coord := Y;
  NewPos := PixelsToPosition(Coord);

  case FActiveThumb of
    atMin:
      begin
        if NewPos > FPosition then NewPos := FPosition;
        if NewPos <> FPositionMin then
        begin
          FPositionMin := NewPos;
          if Assigned(FOnChange) then FOnChange(Self);
          Invalidate;
        end;
      end;
    atMax:
      begin
        if FIsDualMode and (NewPos < FPositionMin) then NewPos := FPositionMin;
        if NewPos <> FPosition then
        begin
          FPosition := NewPos;
          if Assigned(FOnChange) then FOnChange(Self);
          Invalidate;
        end;
      end;
  end;
end;

procedure TFluidRange.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DistMin, DistMax, Coord: Integer;
begin
  if Button = mbLeft then
  begin
    if FOrientation = roHorizontal then Coord := X else Coord := Y;

    DistMax := Abs(Coord - PositionToPixels(FPosition));
    if FIsDualMode then
    begin
      DistMin := Abs(Coord - PositionToPixels(FPositionMin));
      if DistMin < DistMax then FActiveThumb := atMin else FActiveThumb := atMax;
    end
    else
      FActiveThumb := atMax;

    FIsDragging := True;
    UpdateValue(X, Y);
    MouseCapture := True;
  end;
  inherited;
end;

procedure TFluidRange.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FIsDragging then
    UpdateValue(X, Y);
  inherited;
end;

procedure TFluidRange.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FIsDragging := False;
  FActiveThumb := atNone;
  MouseCapture := False;
  Invalidate;
  inherited;
end;

procedure TFluidRange.Paint;
var
  Graphics: TGPGraphics;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  PXMin, PXMax: Integer;
  TrackR, ActiveR: TGPRectF;
  TickVal: Integer;
  TickPX: Integer;

  procedure DrawThumb(Pos: Integer; IsActive: Boolean; ThumbKind: TActiveThumb);
  var
    LocalThumbR, BubbleR: TGPRectF;
    LBrush: TGPSolidBrush;
    LPen: TGPPen;
    W, H: Single;
    TargetColor: TColor;
    CurrentShape: TThumbShape;
    BubbleX, BubbleY: Integer;
    BubbleText: string;
    TextSize: TSize;
    Path: TGPGraphicsPath;
  begin
    W := FThumbSize;
    H := FThumbSize;

    if ThumbKind = atMin then CurrentShape := FThumbShapeMin else CurrentShape := FThumbShape;

    case CurrentShape of
      tsRectPortrait: W := FThumbSize * 0.7;
      tsRectLandscape: H := FThumbSize * 0.7;
    end;

    if FOrientation = roHorizontal then
      LocalThumbR := MakeRect(Single(Pos - (W / 2)), Single((Height - H) / 2), W, H)
    else
      LocalThumbR := MakeRect(Single((Width - W) / 2), Single(Pos - (H / 2)), W, H);

    TargetColor := ifthen(FIsHovering or IsActive, FThumbHoverColor, FThumbColor);
    LBrush := TGPSolidBrush.Create(ColorToGPColor(TargetColor));
    LPen := nil;
    if FThumbBorderColor <> clNone then
      LPen := TGPPen.Create(ColorToGPColor(FThumbBorderColor), 1);

    try
      DrawThumbShape(Graphics, LocalThumbR, CurrentShape, LBrush, LPen);
    finally
      LBrush.Free;
      if Assigned(LPen) then LPen.Free;
    end;

    if IsActive and FShowValueBubble then
    begin
       BubbleText := IntToStr(ifthen(ThumbKind = atMin, FPositionMin, FPosition));
       Canvas.Font.Name := 'Segoe UI';
       Canvas.Font.Size := 8;
       Canvas.Font.Style := [fsBold];
       TextSize := Canvas.TextExtent(BubbleText);

       W := TextSize.cx + 10;
       H := TextSize.cy + 4;

       if FOrientation = roHorizontal then
       begin
         BubbleX := Pos - (Round(W) div 2);
         if FBubblePosition in [bpTop, bpLeft] then
           BubbleY := Round(LocalThumbR.Y) - Round(H) - 4
         else
           BubbleY := Round(LocalThumbR.Y + LocalThumbR.Height) + 4;
       end
       else
       begin
         BubbleY := Pos - (Round(H) div 2);
         if FBubblePosition in [bpTop, bpLeft] then
           BubbleX := Round(LocalThumbR.X) - Round(W) - 4
         else
           BubbleX := Round(LocalThumbR.X + LocalThumbR.Width) + 4;
       end;

       BubbleR := MakeRect(Single(BubbleX), Single(BubbleY), W, H);

       LBrush := TGPSolidBrush.Create(ColorToGPColor(FBubbleColor));
       Path := TGPGraphicsPath.Create;
       try
         Path.AddArc(BubbleR.X, BubbleR.Y, 4, 4, 180, 90);
         Path.AddArc(BubbleR.X + BubbleR.Width - 4, BubbleR.Y, 4, 4, 270, 90);
         Path.AddArc(BubbleR.X + BubbleR.Width - 4, BubbleR.Y + BubbleR.Height - 4, 4, 4, 0, 90);
         Path.AddArc(BubbleR.X, BubbleR.Y + BubbleR.Height - 4, 4, 4, 90, 90);
         Path.CloseFigure;
         Graphics.FillPath(LBrush, Path);
       finally
         LBrush.Free;
         Path.Free;
       end;

       Canvas.Brush.Style := bsClear;
       Canvas.Font.Color := FBubbleTextColor;
       Canvas.TextOut(BubbleX + 5, BubbleY + 2, BubbleText);
    end;
  end;

begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    // Calculate Pixels
    PXMax := PositionToPixels(FPosition);
    if FIsDualMode then
      PXMin := PositionToPixels(FPositionMin)
    else
      PXMin := PositionToPixels(FMin);

    // 1. Draw Ticks
    if FShowTicks and (FTickFrequency > 0) then
    begin
      Pen := TGPPen.Create(ColorToGPColor(FTickColor), 1);
      try
        TickVal := FMin;
        while TickVal <= FMax do
        begin
          TickPX := PositionToPixels(TickVal);
          if FOrientation = roHorizontal then
            Graphics.DrawLine(Pen, TickPX, (Height div 2) - 10, TickPX, (Height div 2) + 10)
          else
            Graphics.DrawLine(Pen, (Width div 2) - 10, TickPX, (Width div 2) + 10, TickPX);
          TickVal := TickVal + FTickFrequency;
        end;
      finally
        Pen.Free;
      end;
    end;

    // 2. Setup Track Geometry
    if FOrientation = roHorizontal then
    begin
      TrackR := MakeRect(Single(FThumbSize / 2), Single((Height - FTrackHeight) / 2),
                         Single(Width - FThumbSize), Single(FTrackHeight));
      ActiveR := MakeRect(Single(PXMin), Single((Height - FTrackHeight) / 2),
                          Single(PXMax - PXMin), Single(FTrackHeight));
    end
    else
    begin
      TrackR := MakeRect(Single((Width - FTrackHeight) / 2), Single(FThumbSize / 2),
                         Single(FTrackHeight), Single(Height - FThumbSize));
      // Vertical Fill Logic: PXMax is closer to 0 (top), PXMin is further (bottom)
      ActiveR := MakeRect(Single((Width - FTrackHeight) / 2), Single(PXMax),
                          Single(FTrackHeight), Single(PXMin - PXMax));
    end;

    // 3. Draw Track
    Brush := TGPSolidBrush.Create(ColorToGPColor(FTrackColor));
    Graphics.FillRectangle(Brush, TrackR);
    Brush.Free;

    // 4. Draw Active Range
    Brush := TGPSolidBrush.Create(ColorToGPColor(FActiveTrackColor));
    Graphics.FillRectangle(Brush, ActiveR);
    Brush.Free;

    // 5. Draw Thumbs
    if FIsDualMode then DrawThumb(PXMin, FActiveThumb = atMin, atMin);
    DrawThumb(PXMax, FActiveThumb = atMax, atMax);

  finally
    Graphics.Free;
  end;
end;

procedure TFluidRange.SetOrientation(Value: TRangeOrientation);
var
  Tmp: Integer;
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    if not (csLoading in ComponentState) then
    begin
      Tmp := Width;
      Width := Height;
      Height := Tmp;
    end;

    // Auto-adjust bubble position
    if (FOrientation = roVertical) and (FBubblePosition in [bpTop, bpBottom]) then
      FBubblePosition := bpLeft
    else if (FOrientation = roHorizontal) and (FBubblePosition in [bpLeft, bpRight]) then
      FBubblePosition := bpTop;

    Invalidate;
  end;
end;

procedure TFluidRange.SetMin(Value: Integer); begin FMin := Value; Invalidate; end;
procedure TFluidRange.SetMax(Value: Integer); begin FMax := Value; Invalidate; end;
procedure TFluidRange.SetPosition(Value: Integer); begin FPosition := EnsureRange(Value, FMin, FMax); Invalidate; end;
procedure TFluidRange.SetPositionMin(Value: Integer); begin FPositionMin := EnsureRange(Value, FMin, FMax); Invalidate; end;
procedure TFluidRange.SetIsDualMode(Value: Boolean); begin FIsDualMode := Value; Invalidate; end;
procedure TFluidRange.SetTrackHeight(Value: Integer); begin FTrackHeight := Value; Invalidate; end;
procedure TFluidRange.SetThumbSize(Value: Integer); begin FThumbSize := Value; Invalidate; end;
procedure TFluidRange.SetTrackRounding(Value: Integer); begin FTrackRounding := Value; Invalidate; end;
procedure TFluidRange.SetTrackColor(Value: TColor); begin FTrackColor := Value; Invalidate; end;
procedure TFluidRange.SetActiveTrackColor(Value: TColor); begin FActiveTrackColor := Value; Invalidate; end;
procedure TFluidRange.SetThumbColor(Value: TColor); begin FThumbColor := Value; Invalidate; end;
procedure TFluidRange.SetThumbHoverColor(Value: TColor); begin FThumbHoverColor := Value; Invalidate; end;
procedure TFluidRange.SetThumbBorderColor(Value: TColor); begin FThumbBorderColor := Value; Invalidate; end;
procedure TFluidRange.SetTrackBorderColor(Value: TColor); begin FTrackBorderColor := Value; Invalidate; end;
procedure TFluidRange.SetBubbleColor(Value: TColor); begin FBubbleColor := Value; Invalidate; end;
procedure TFluidRange.SetBubbleTextColor(Value: TColor); begin FBubbleTextColor := Value; Invalidate; end;
procedure TFluidRange.SetShowTicks(Value: Boolean); begin FShowTicks := Value; Invalidate; end;
procedure TFluidRange.SetTickFrequency(Value: Integer); begin FTickFrequency := Value; Invalidate; end;
procedure TFluidRange.SetTickColor(Value: TColor); begin FTickColor := Value; Invalidate; end;
procedure TFluidRange.SetThumbShape(Value: TThumbShape); begin FThumbShape := Value; Invalidate; end;
procedure TFluidRange.SetThumbShapeMin(Value: TThumbShape); begin FThumbShapeMin := Value; Invalidate; end;
procedure TFluidRange.SetBubblePosition(Value: TBubblePosition); begin FBubblePosition := Value; Invalidate; end;

procedure TFluidRange.Resize; begin inherited; Invalidate; end;
procedure TFluidRange.CMMouseEnter(var Message: TMessage); begin inherited; FIsHovering := True; Invalidate; end;
procedure TFluidRange.CMMouseLeave(var Message: TMessage); begin inherited; FIsHovering := False; Invalidate; end;

end.
