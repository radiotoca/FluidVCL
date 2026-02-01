unit FluidColorBoxUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes,
  System.Math, Vcl.GraphUtil;

type
  TFluidColorBox = class(TCustomControl)
  private
    FHue: Double; // 0.0 - 1.0
    FSat: Double; // 0.0 - 1.0
    FVal: Double; // 0.0 - 1.0
    FBorderColor: TColor;
    FBorderRadius: Integer;
    FOnColorChange: TNotifyEvent;

    FIsDraggingMain: Boolean;
    FIsDraggingHue: Boolean;

    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderRadius(const Value: Integer);
    function GetSelectedColor: TColor;
    procedure SetSelectedColor(const Value: TColor);

    // HSV Helpers
    procedure ColorToHSV(C: TColor; var H, S, V: Double);
    function HSVToColor(H, S, V: Double): TColor;

    // Internal Geometry Helpers
    function GetMainBoxRect: TGPRectF;
    function GetHueSliderRect: TGPRectF;
    function ColorToGPColor(const Value: TColor): TGPColor;
    procedure UpdateFromMouse(X, Y: Integer);

    // Manual RoundRect implementation for TGPGraphicsPath compatibility
    procedure AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;

    property SelectedColor: TColor read GetSelectedColor write SetSelectedColor;
    function GetColorHex: string;
    function GetColorRGB: string;
    procedure SetHSV(AHue, ASat, AVal: Double);
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor default clGray;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 8;
    property OnColorChange: TNotifyEvent read FOnColorChange write FOnColorChange;

    property Align;
    property Anchors;
    property Visible;
    property Enabled;
    property Color;
    property ParentColor;
    property ParentShowHint;
    property ShowHint;
    property TabStop;
    property TabOrder;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TFluidColorBox]);
end;

{ TFluidColorBox }

constructor TFluidColorBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csDoubleClicks];
  Width := 320;
  Height := 280;
  FHue := 0;
  FSat := 1.0;
  FVal := 1.0;
  FBorderColor := $00444444;
  FBorderRadius := 8;
  DoubleBuffered := True;
end;

procedure TFluidColorBox.ColorToHSV(C: TColor; var H, S, V: Double);
var
  R, G, B: Byte;
  MaxV, MinV, Diff: Byte;
  RGBVal: LongInt;
begin
  RGBVal := ColorToRGB(C);
  R := GetRValue(RGBVal);
  G := GetGValue(RGBVal);
  B := GetBValue(RGBVal);

  MaxV := Max(R, Max(G, B));
  MinV := Min(R, Min(G, B));
  Diff := MaxV - MinV;
  V := MaxV / 255.0;
  if MaxV = 0 then S := 0 else S := Diff / MaxV;

  if Diff = 0 then H := 0
  else begin
    if MaxV = R then H := (G - B) / Diff
    else if MaxV = G then H := 2 + (B - R) / Diff
    else H := 4 + (R - G) / Diff;
    H := H / 6.0;
    if H < 0 then H := H + 1.0;
  end;
end;

function TFluidColorBox.HSVToColor(H, S, V: Double): TColor;
var
  Hi: Integer;
  f, p, q, t: Double;
  r, g, b: Byte;
begin
  if S = 0 then begin
    r := Round(V * 255); g := r; b := r;
  end else begin
    Hi := Floor(H * 6);
    f := (H * 6) - Hi;
    p := V * (1 - S);
    q := V * (1 - f * S);
    t := V * (1 - (1 - f) * S);
    case Hi of
      0, 6: begin r := Round(V * 255); g := Round(t * 255); b := Round(p * 255); end;
      1: begin r := Round(q * 255); g := Round(V * 255); b := Round(p * 255); end;
      2: begin r := Round(p * 255); g := Round(V * 255); b := Round(t * 255); end;
      3: begin r := Round(p * 255); g := Round(q * 255); b := Round(V * 255); end;
      4: begin r := Round(t * 255); g := Round(p * 255); b := Round(V * 255); end;
      5: begin r := Round(V * 255); g := Round(p * 255); b := Round(q * 255); end;
      else begin r := 0; g := 0; b := 0; end;
    end;
  end;
  Result := RGB(r, g, b);
end;

procedure TFluidColorBox.AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
var D: Single;
begin
  D := Radius * 2;
  if D > Rect.Width then D := Rect.Width;
  if D > Rect.Height then D := Rect.Height;
  Path.Reset;
  Path.AddArc(Rect.X, Rect.Y, D, D, 180, 90);
  Path.AddLine(Rect.X + Radius, Rect.Y, Rect.X + Rect.Width - Radius, Rect.Y);
  Path.AddArc(Rect.X + Rect.Width - D, Rect.Y, D, D, 270, 90);
  Path.AddLine(Rect.X + Rect.Width, Rect.Y + Radius, Rect.X + Rect.Width, Rect.Y + Rect.Height - Radius);
  Path.AddArc(Rect.X + Rect.Width - D, Rect.Y + Rect.Height - D, D, D, 0, 90);
  Path.AddLine(Rect.X + Rect.Width - Radius, Rect.Y + Rect.Height, Rect.X + Radius, Rect.Y + Rect.Height);
  Path.AddArc(Rect.X, Rect.Y + Rect.Height - D, D, D, 90, 90);
  Path.AddLine(Rect.X, Rect.Y + Rect.Height - Radius, Rect.X, Rect.Y + Radius);
  Path.CloseFigure;
end;

function TFluidColorBox.ColorToGPColor(const Value: TColor): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

function TFluidColorBox.GetColorHex: string;
var C: TColor;
begin
  C := GetSelectedColor;
  Result := Format('#%.2x%.2x%.2x', [GetRValue(C), GetGValue(C), GetBValue(C)]);
end;

function TFluidColorBox.GetColorRGB: string;
var C: TColor;
begin
  C := GetSelectedColor;
  Result := Format('%d, %d, %d', [GetRValue(C), GetGValue(C), GetBValue(C)]);
end;

function TFluidColorBox.GetSelectedColor: TColor;
begin
  Result := HSVToColor(FHue, FSat, FVal);
end;

procedure TFluidColorBox.SetSelectedColor(const Value: TColor);
begin
  ColorToHSV(Value, FHue, FSat, FVal);
  Invalidate;
end;

procedure TFluidColorBox.SetHSV(AHue, ASat, AVal: Double);
begin
  FHue := EnsureRange(AHue, 0.0, 1.0);
  FSat := EnsureRange(ASat, 0.0, 1.0);
  FVal := EnsureRange(AVal, 0.0, 1.0);
  Invalidate;
end;

function TFluidColorBox.GetMainBoxRect: TGPRectF;
begin
  Result.X := 10;
  Result.Y := 10;
  Result.Width := Width - 50;
  Result.Height := Height - 20;
end;

function TFluidColorBox.GetHueSliderRect: TGPRectF;
begin
  Result.X := Width - 30;
  Result.Y := 10;
  Result.Width := 20;
  Result.Height := Height - 20;
end;

procedure TFluidColorBox.UpdateFromMouse(X, Y: Integer);
var
  MainR, HueR: TGPRectF;
begin
  MainR := GetMainBoxRect;
  HueR := GetHueSliderRect;

  if FIsDraggingMain then
  begin
    FSat := EnsureRange((X - MainR.X) / MainR.Width, 0.0, 1.0);
    FVal := 1.0 - EnsureRange((Y - MainR.Y) / MainR.Height, 0.0, 1.0);
  end
  else if FIsDraggingHue then
  begin
    FHue := EnsureRange((Y - HueR.Y) / HueR.Height, 0.0, 1.0);
  end;

  Invalidate;
  if Assigned(FOnColorChange) then
    FOnColorChange(Self);
end;

procedure TFluidColorBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MainR, HueR: TGPRectF;
begin
  if Button <> mbLeft then Exit;
  MainR := GetMainBoxRect;
  HueR := GetHueSliderRect;

  if (X >= MainR.X) and (X <= MainR.X + MainR.Width) and (Y >= MainR.Y) and (Y <= MainR.Y + MainR.Height) then
    FIsDraggingMain := True
  else if (X >= HueR.X) and (X <= HueR.X + HueR.Width) and (Y >= HueR.Y) and (Y <= HueR.Y + HueR.Height) then
    FIsDraggingHue := True;

  if FIsDraggingMain or FIsDraggingHue then
  begin
    UpdateFromMouse(X, Y);
    SetCapture(Handle);
  end;
end;

procedure TFluidColorBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FIsDraggingMain or FIsDraggingHue then
    UpdateFromMouse(X, Y);
end;

procedure TFluidColorBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FIsDraggingMain := False;
  FIsDraggingHue := False;
  ReleaseCapture;
end;

procedure TFluidColorBox.Paint;
var
  Graphics: TGPGraphics;
  MainR, HueR: TGPRectF;
  Path: TGPGraphicsPath;
  LBrush: TGPLinearGradientBrush;
  HueColors: array[0..6] of TGPColor;
  Positions: array[0..6] of Single;
  I: Integer;
  IndY, IndX: Single;
  BorderPen: TGPPen;
  HueBaseColor: TColor;
  P1, P2: TGPPointF;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.Clear(ColorToGPColor(Color));

    MainR := GetMainBoxRect;
    HueR := GetHueSliderRect;
    BorderPen := TGPPen.Create(ColorToGPColor(FBorderColor), 1.2);

    // --- 1. Main Saturation/Value Box ---
    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectToPath(Path, MainR, FBorderRadius);
      Graphics.SetClip(Path);

      // Background color is the pure Hue at 100% Sat and 100% Val
      HueBaseColor := HSVToColor(FHue, 1.0, 1.0);
      Graphics.Clear(ColorToGPColor(HueBaseColor));

      // White Horizontal Gradient (Saturation)
      P1 := MakePoint(MainR.X, MainR.Y);
      P2 := MakePoint(MainR.X + MainR.Width, MainR.Y);
      LBrush := TGPLinearGradientBrush.Create(P1, P2, MakeColor(255, 255, 255, 255), MakeColor(0, 255, 255, 255));
      Graphics.FillRectangle(LBrush, MainR);
      LBrush.Free;

      // Black Vertical Gradient (Value/Brightness)
      P2 := MakePoint(MainR.X, MainR.Y + MainR.Height);
      LBrush := TGPLinearGradientBrush.Create(P1, P2, MakeColor(0, 0, 0, 0), MakeColor(255, 0, 0, 0));
      Graphics.FillRectangle(LBrush, MainR);
      LBrush.Free;

      Graphics.ResetClip;
      Graphics.DrawPath(BorderPen, Path);
    finally
      Path.Free;
    end;

    // --- 2. Hue Slider ---
    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectToPath(Path, HueR, FBorderRadius);
      Graphics.SetClip(Path);

      P1 := MakePoint(HueR.X, HueR.Y);
      P2 := MakePoint(HueR.X, HueR.Y + HueR.Height);
      LBrush := TGPLinearGradientBrush.Create(P1, P2, MakeColor(255, 255, 0, 0), MakeColor(255, 255, 0, 0));

      HueColors[0] := MakeColor(255, 255, 0, 0);
      HueColors[1] := MakeColor(255, 255, 255, 0);
      HueColors[2] := MakeColor(255, 0, 255, 0);
      HueColors[3] := MakeColor(255, 0, 255, 255);
      HueColors[4] := MakeColor(255, 0, 0, 255);
      HueColors[5] := MakeColor(255, 255, 0, 255);
      HueColors[6] := MakeColor(255, 255, 0, 0);

      for I := 0 to 6 do Positions[I] := I / 6.0;
      LBrush.SetInterpolationColors(@HueColors[0], @Positions[0], 7);

      Graphics.FillRectangle(LBrush, HueR);
      LBrush.Free;

      Graphics.ResetClip;
      Graphics.DrawPath(BorderPen, Path);
    finally
      Path.Free;
    end;

    // --- 3. Indicators ---
    IndX := MainR.X + (FSat * MainR.Width);
    IndY := MainR.Y + ((1.0 - FVal) * MainR.Height);

    Graphics.DrawEllipse(TGPPen.Create(MakeColor(150, 0, 0, 0), 2), IndX - 6, IndY - 6, 12, 12);
    Graphics.DrawEllipse(TGPPen.Create(MakeColor(255, 255, 255, 255), 2), IndX - 5, IndY - 5, 10, 10);

    IndY := HueR.Y + (FHue * HueR.Height);
    Graphics.DrawEllipse(TGPPen.Create(MakeColor(150, 0, 0, 0), 2), HueR.X - 3, IndY - 6, HueR.Width + 6, 12);
    Graphics.DrawEllipse(TGPPen.Create(MakeColor(255, 255, 255, 255), 2), HueR.X - 2, IndY - 5, HueR.Width + 4, 10);

    BorderPen.Free;
  finally
    Graphics.Free;
  end;
end;

procedure TFluidColorBox.Resize;
begin
  inherited;
  Invalidate;
end;

procedure TFluidColorBox.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TFluidColorBox.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then begin
    FBorderRadius := Value;
    Invalidate;
  end;
end;

end.
