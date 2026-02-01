unit RoundedGroupBoxUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes;

type
  TControlAccess = class(Vcl.Controls.TControl);

  TRoundedGroupBox = class(TCustomControl)
  private
    FBorderRadius: Integer;
    FBorderThickness: Single;
    FBorderColor: TColor;
    FBackgroundColor: TColor;
    FShowCaption: Boolean;

    procedure SetBorderRadius(const Value: Integer);
    procedure SetBorderThickness(const Value: Single);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBackgroundColor(const Value: TColor);
    procedure SetShowCaption(const Value: Boolean);

    function ColorToGPColor(const Value: TColor): TGPColor;
    function VclFontStyleToGPFontStyle(AStyle: TFontStyles): Integer;
    procedure UpdateRegion;
  protected
    procedure Paint; override;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Resize; override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 10;
    property BorderThickness: Single read FBorderThickness write SetBorderThickness;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $00CCCCCC;
    property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor default clWhite;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;

    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property Anchors;
    property Align;
    property Padding;
    property Color;
    property ParentColor;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedGroupBox]);
end;

constructor TRoundedGroupBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := 200;
  Height := 150;
  FBorderRadius := 10;
  FBorderThickness := 1.5; // Slightly thicker default for better visibility
  FBorderColor := $00CCCCCC;
  FBackgroundColor := clWhite;
  FShowCaption := True;

  Padding.Left := 10;
  Padding.Top := 25;
  Padding.Right := 10;
  Padding.Bottom := 10;
end;

procedure TRoundedGroupBox.UpdateRegion;
var
  R: TRect;
  hRgn: Winapi.Windows.HRGN;
begin
  if not HandleAllocated then Exit;
  R := ClientRect;
  {
    We create the region slightly larger (Right+1, Bottom+1) than the control
    or exactly at the boundary. To avoid the OS clipping our anti-aliased
    GDI+ border, the border must be drawn slightly inside this region.
  }
  hRgn := Winapi.Windows.CreateRoundRectRgn(R.Left, R.Top, R.Right + 1, R.Bottom + 1, FBorderRadius * 2, FBorderRadius * 2);
  if hRgn <> 0 then
  begin
    if Winapi.Windows.SetWindowRgn(Handle, hRgn, True) = 0 then
      Winapi.Windows.DeleteObject(hRgn);
  end;
end;

procedure TRoundedGroupBox.CreateWnd;
begin
  inherited;
  UpdateRegion;
end;

procedure TRoundedGroupBox.Resize;
begin
  inherited;
  UpdateRegion;
end;

function TRoundedGroupBox.VclFontStyleToGPFontStyle(AStyle: TFontStyles): Integer;
var
  StyleValue: Integer;
begin
  StyleValue := 0;
  if (fsBold in AStyle) then StyleValue := StyleValue + 1;
  if (fsItalic in AStyle) then StyleValue := StyleValue + 2;
  if (fsUnderline in AStyle) then StyleValue := StyleValue + 4;
  if (fsStrikeOut in AStyle) then StyleValue := StyleValue + 8;
  Result := StyleValue;
end;

function TRoundedGroupBox.ColorToGPColor(const Value: TColor): TGPColor;
var
  RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

procedure TRoundedGroupBox.Paint;
var
  Graphics: TGPGraphics;
  BorderPath, FillPath: TGPGraphicsPath;
  GPRect, LayoutRect, MeasureRect, BoundingBox: TGPRectF;
  Pen: TGPPen;
  Brush, FontBrush: TGPSolidBrush;
  GPFont: TGPFont;
  ParentBg: TColor;
  CaptionOffset, TextWidth, TextPadding, D, Inset: Single;
  CaptionText: WideString;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

    if (Parent <> nil) then ParentBg := TControlAccess(Parent).Color else ParentBg := clBtnFace;
    Graphics.Clear(ColorToGPColor(ParentBg));

    CaptionText := WideString(Caption);
    GPFont := nil;
    TextWidth := 0;
    TextPadding := 6;

    if FShowCaption and (CaptionText <> '') then
    begin
      GPFont := TGPFont.Create(WideString(Font.Name), Font.Size, VclFontStyleToGPFontStyle(Font.Style), UnitPoint);
      MeasureRect.X := 0; MeasureRect.Y := 0; MeasureRect.Width := Width; MeasureRect.Height := Height;
      Graphics.MeasureString(CaptionText, -1, GPFont, MeasureRect, nil, BoundingBox);
      TextWidth := BoundingBox.Width;
    end;

    CaptionOffset := 0;
    if Assigned(GPFont) then CaptionOffset := BoundingBox.Height / 2;

    {
      CRITICAL ADJUSTMENT:
      GDI+ pens draw centered on the path. To prevent the outer half of the pen
      from being clipped by the Window Region at the Right and Bottom, we
      must inset the rectangle by the full border thickness.
    }
    Inset := FBorderThickness + 1;
    GPRect.X := Inset / 2;
    GPRect.Y := CaptionOffset + (Inset / 2);
    GPRect.Width := Width - Inset;
    GPRect.Height := Height - GPRect.Y - (Inset / 2);

    D := FBorderRadius * 2;
    if D < 1 then D := 1;

    // Fill the background
    FillPath := TGPGraphicsPath.Create;
    try
      FillPath.AddArc(GPRect.X, GPRect.Y, D, D, 180, 90);
      FillPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y, D, D, 270, 90);
      FillPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y + GPRect.Height - D, D, D, 0, 90);
      FillPath.AddArc(GPRect.X, GPRect.Y + GPRect.Height - D, D, D, 90, 90);
      FillPath.CloseFigure;
      Brush := TGPSolidBrush.Create(ColorToGPColor(FBackgroundColor));
      Graphics.FillPath(Brush, FillPath);
      Brush.Free;
    finally
      FillPath.Free;
    end;

    // Draw the border path
    BorderPath := TGPGraphicsPath.Create;
    try
      if Assigned(GPFont) and (TextWidth > 0) then
      begin
        BorderPath.AddArc(GPRect.X, GPRect.Y, D, D, 180, 90);
        // Top line segment 1 (before text)
        BorderPath.AddLine(GPRect.X + FBorderRadius, GPRect.Y, FBorderRadius + TextPadding, GPRect.Y);
        // Start new figure after text gap
        BorderPath.StartFigure;
        BorderPath.AddLine(FBorderRadius + TextPadding + TextWidth + TextPadding, GPRect.Y, GPRect.X + GPRect.Width - FBorderRadius, GPRect.Y);
        BorderPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y, D, D, 270, 90);
        BorderPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y + GPRect.Height - D, D, D, 0, 90);
        BorderPath.AddArc(GPRect.X, GPRect.Y + GPRect.Height - D, D, D, 90, 90);
        BorderPath.AddLine(GPRect.X, GPRect.Y + GPRect.Height - FBorderRadius, GPRect.X, GPRect.Y + FBorderRadius);
      end
      else
      begin
        BorderPath.AddArc(GPRect.X, GPRect.Y, D, D, 180, 90);
        BorderPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y, D, D, 270, 90);
        BorderPath.AddArc(GPRect.X + GPRect.Width - D, GPRect.Y + GPRect.Height - D, D, D, 0, 90);
        BorderPath.AddArc(GPRect.X, GPRect.Y + GPRect.Height - D, D, D, 90, 90);
        BorderPath.CloseFigure;
      end;

      Pen := TGPPen.Create(ColorToGPColor(FBorderColor), FBorderThickness);
      Pen.SetLineJoin(LineJoinRound);
      Graphics.DrawPath(Pen, BorderPath);
      Pen.Free;

      if Assigned(GPFont) then
      begin
        FontBrush := TGPSolidBrush.Create(ColorToGPColor(Font.Color));
        try
          LayoutRect.X := FBorderRadius + TextPadding;
          LayoutRect.Y := 0;
          LayoutRect.Width := TextWidth + 5;
          LayoutRect.Height := BoundingBox.Height;
          Graphics.DrawString(CaptionText, -1, GPFont, LayoutRect, nil, FontBrush);
        finally
          FontBrush.Free;
        end;
      end;
    finally
      BorderPath.Free;
      if Assigned(GPFont) then GPFont.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

procedure TRoundedGroupBox.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TRoundedGroupBox.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRoundedGroupBox.SetBackgroundColor(const Value: TColor);
begin
  if FBackgroundColor <> Value then begin FBackgroundColor := Value; Invalidate; end;
end;

procedure TRoundedGroupBox.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TRoundedGroupBox.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then begin FBorderRadius := Value; UpdateRegion; Invalidate; end;
end;

procedure TRoundedGroupBox.SetBorderThickness(const Value: Single);
begin
  if FBorderThickness <> Value then begin FBorderThickness := Value; Invalidate; end;
end;

procedure TRoundedGroupBox.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then begin FShowCaption := Value; Invalidate; end;
end;

end.
