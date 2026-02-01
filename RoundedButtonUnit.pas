unit RoundedButtonUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes,
  System.Math;

type
  TButtonState = (bsNormal, bsHover, bsDown);

  TControlAccess = class(TControl);

  TRoundedButton = class(TCustomControl)
  private
    FState: TButtonState;
    FBorderRadius: Integer;
    FBorderThickness: Single;
    FBorderColor: TColor;
    FColorNormal: TColor;
    FColorHover: TColor;
    FColorDown: TColor;
    FWordWrap: Boolean;
    FOnClick: TNotifyEvent;

    procedure SetBorderRadius(const Value: Integer);
    procedure SetBorderThickness(const Value: Single);
    procedure SetBorderColor(const Value: TColor);
    procedure SetColorNormal(const Value: TColor);
    procedure SetColorHover(const Value: TColor);
    procedure SetColorDown(const Value: TColor);
    procedure SetWordWrap(const Value: Boolean);

    function ColorToGPColor(const Value: TColor): TGPColor;
    function VclFontStyleToGPFontStyle(AStyle: TFontStyles): Integer;
    procedure AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
    procedure UpdateRegion;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption;
    property ColorNormal: TColor read FColorNormal write SetColorNormal default $00F2F2F2;
    property ColorHover: TColor read FColorHover write SetColorHover default $00E0E0E0;
    property ColorDown: TColor read FColorDown write SetColorDown default $00CCCCCC;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $00BBBBBB;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 8;
    property BorderThickness: Single read FBorderThickness write SetBorderThickness;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;

    property Font;
    property ParentFont;
    property Enabled;
    property Visible;
    property Anchors;
    property Align;
    property TabOrder;
    property TabStop default True;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown;
    property OnMouseUp;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedButton]);
end;

constructor TRoundedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];

  Width := 100;
  Height := 35;
  FState := bsNormal;

  FColorNormal := $00F2F2F2;
  FColorHover := $00E0E0E0;
  FColorDown := $00CCCCCC;
  FBorderColor := $00BBBBBB;
  FBorderRadius := 8;
  FBorderThickness := 1.2;
  FWordWrap := False;

  TabStop := True;
  Cursor := crHandPoint;
end;

function TRoundedButton.VclFontStyleToGPFontStyle(AStyle: TFontStyles): Integer;
begin
  Result := FontStyleRegular;
  if fsBold in AStyle then Result := Result or FontStyleBold;
  if fsItalic in AStyle then Result := Result or FontStyleItalic;
  if fsUnderline in AStyle then Result := Result or FontStyleUnderline;
  if fsStrikeOut in AStyle then Result := Result or FontStyleStrikeout;
end;

procedure TRoundedButton.UpdateRegion;
var
  Rgn: HRGN;
begin
  if not HandleAllocated then Exit;
  Rgn := CreateRoundRectRgn(0, 0, Width + 1, Height + 1, FBorderRadius * 2, FBorderRadius * 2);
  if SetWindowRgn(Handle, Rgn, True) = 0 then
    DeleteObject(Rgn);
end;

procedure TRoundedButton.Paint;
var
  Graphics: TGPGraphics;
  Path: TGPGraphicsPath;
  GPRect: TGPRectF;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  CurrentColor: TColor;
  ParentBg: TColor;
  FontBrush: TGPSolidBrush;
  GPFont: TGPFont;
  LayoutRect: TGPRectF;
  StringFormat: TGPStringFormat;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);

    if (Parent <> nil) then ParentBg := TControlAccess(Parent).Color else ParentBg := clBtnFace;
    Graphics.Clear(ColorToGPColor(ParentBg));

    case FState of
      bsHover: CurrentColor := FColorHover;
      bsDown:  CurrentColor := FColorDown;
    else
      CurrentColor := FColorNormal;
    end;

    if not Enabled then CurrentColor := clBtnFace;

    GPRect.X := FBorderThickness / 2;
    GPRect.Y := FBorderThickness / 2;
    GPRect.Width := Width - FBorderThickness;
    GPRect.Height := Height - FBorderThickness;

    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectToPath(Path, GPRect, FBorderRadius);

      Brush := TGPSolidBrush.Create(ColorToGPColor(CurrentColor));
      Graphics.FillPath(Brush, Path);
      Brush.Free;

      Pen := TGPPen.Create(ColorToGPColor(FBorderColor), FBorderThickness);
      Graphics.DrawPath(Pen, Path);
      Pen.Free;

      if Caption <> '' then
      begin
        // Using the WideString constructor as per your library definition
        GPFont := TGPFont.Create(WideString(Font.Name),
                                 Font.Size,
                                 VclFontStyleToGPFontStyle(Font.Style),
                                 UnitPoint);

        FontBrush := TGPSolidBrush.Create(ColorToGPColor(Font.Color));
        StringFormat := TGPStringFormat.Create;
        try
          StringFormat.SetAlignment(StringAlignmentCenter);
          StringFormat.SetLineAlignment(StringAlignmentCenter);
          if not FWordWrap then
            StringFormat.SetFormatFlags(StringFormatFlagsNoWrap);

          LayoutRect.X := FBorderRadius;
          LayoutRect.Y := 0;
          LayoutRect.Width := Width - (FBorderRadius * 2);
          LayoutRect.Height := Height;

          Graphics.DrawString(Caption, -1, GPFont, LayoutRect, StringFormat, FontBrush);
        finally
          StringFormat.Free;
          FontBrush.Free;
          GPFont.Free;
        end;
      end;
    finally
      Path.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

procedure TRoundedButton.AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
var D: Single;
begin
  D := Radius * 2;
  if D <= 0 then D := 0.1;
  if D > Rect.Width then D := Rect.Width;
  if D > Rect.Height then D := Rect.Height;

  Path.AddArc(Rect.X, Rect.Y, D, D, 180, 90);
  Path.AddArc(Rect.X + Rect.Width - D, Rect.Y, D, D, 270, 90);
  Path.AddArc(Rect.X + Rect.Width - D, Rect.Y + Rect.Height - D, D, D, 0, 90);
  Path.AddArc(Rect.X, Rect.Y + Rect.Height - D, D, D, 90, 90);
  Path.CloseFigure;
end;

function TRoundedButton.ColorToGPColor(const Value: TColor): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

procedure TRoundedButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled then
  begin
    FState := bsDown;
    Invalidate;
  end;
end;

procedure TRoundedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MousePt: TPoint;
begin
  inherited;
  if (FState = bsDown) and Enabled then
  begin
    MousePt := Point(X, Y);
    if PtInRect(ClientRect, MousePt) then
    begin
      FState := bsHover;
      if Assigned(FOnClick) then FOnClick(Self);
    end
    else
      FState := bsNormal;

    Invalidate;
  end;
end;

procedure TRoundedButton.CMMouseEnter(var Message: TMessage);
begin
  if Enabled then
  begin
    FState := bsHover;
    Invalidate;
  end;
end;

procedure TRoundedButton.CMMouseLeave(var Message: TMessage);
begin
  if Enabled then
  begin
    FState := bsNormal;
    Invalidate;
  end;
end;

procedure TRoundedButton.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TRoundedButton.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRoundedButton.Resize;
begin
  inherited;
  UpdateRegion;
  Invalidate;
end;

procedure TRoundedButton.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    UpdateRegion;
    Invalidate;
  end;
end;

procedure TRoundedButton.SetBorderThickness(const Value: Single);
begin
  if FBorderThickness <> Value then begin FBorderThickness := Value; Invalidate; end;
end;

procedure TRoundedButton.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TRoundedButton.SetColorNormal(const Value: TColor);
begin
  if FColorNormal <> Value then begin FColorNormal := Value; Invalidate; end;
end;

procedure TRoundedButton.SetColorHover(const Value: TColor);
begin
  if FColorHover <> Value then begin FColorHover := Value; Invalidate; end;
end;

procedure TRoundedButton.SetColorDown(const Value: TColor);
begin
  if FColorDown <> Value then begin FColorDown := Value; Invalidate; end;
end;

procedure TRoundedButton.SetWordWrap(const Value: Boolean);
begin
  if FWordWrap <> Value then begin FWordWrap := Value; Invalidate; end;
end;

procedure TRoundedButton.CMDialogChar(var Message: TCMDialogChar);
begin
  if IsAccel(Message.CharCode, Caption) and Enabled then
  begin
    Click;
    Message.Result := 1;
  end
  else
    inherited;
end;

end.
