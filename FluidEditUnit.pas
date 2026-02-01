unit FluidEditUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.StdCtrls, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes,
  System.Math, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg, Winapi.ActiveX, RoundedEditUnit;

type
  TGPImageAccessor = class(TGPImage);

  TControlAccess = class(TControl);

  TButtonPosition = (bpLeft, bpRight, bpNone);
  TButtonGlyphPosition = (gpCenter, gpLeft, gpRight);

  TFluidEdit = class(TRoundedEdit)
  private
    FButtonColor: TColor;
    FButtonColorDown: TColor;
    FButtonColorHovered: TColor;
    FButtonPosition: TButtonPosition;
    FButtonGlyph: TGPImage;
    FButtonPicture: TPicture;
    FButtonGlyphPosition: TButtonGlyphPosition;
    FButtonGlyphStretch: Boolean;
    FButtonGlyphPadding: Integer;
    FButtonText: string;
    FButtonWidth: Integer;

    // Placeholder Properties
    FPlaceholderText: string;
    FPlaceholderTextColor: TColor;

    FIsHovered: Boolean;
    FIsDown: Boolean;
    FOnButtonClick: TNotifyEvent;
    FOnButtonMouseEnter: TNotifyEvent;
    FOnButtonMouseLeave: TNotifyEvent;

    procedure SetButtonColor(const Value: TColor);
    procedure SetButtonColorDown(const Value: TColor);
    procedure SetButtonColorHovered(const Value: TColor);
    procedure SetButtonPosition(const Value: TButtonPosition);
    procedure SetButtonGlyphPosition(const Value: TButtonGlyphPosition);
    procedure SetButtonGlyphStretch(const Value: Boolean);
    procedure SetButtonGlyphPadding(const Value: Integer);
    procedure SetButtonText(const Value: string);
    procedure SetButtonWidth(const Value: Integer);
    procedure SetButtonPicture(const Value: TPicture);
    procedure SetPlaceholderText(const Value: string);
    procedure SetPlaceholderTextColor(const Value: TColor);

    procedure UpdateGPImageFromPicture;
    function GetButtonRect: TRect;
    function ColorToGPColorAlpha(Value: TColor; Alpha: Byte = 255): TGPColor;
    procedure PictureChanged(Sender: TObject);
    function CreateGPImageFromStream(Stream: TStream): TGPImage;
    procedure AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
    function GetParentBackgroundColor: TColor;
  protected
    procedure Paint; override;
    procedure UpdateLayout;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadGlyphFromFile(const FileName: string);
  published
    property ButtonColor: TColor read FButtonColor write SetButtonColor default clBtnFace;
    property ButtonColorDown: TColor read FButtonColorDown write SetButtonColorDown default clBtnShadow;
    property ButtonColorHovered: TColor read FButtonColorHovered write SetButtonColorHovered default clSilver;
    property ButtonPosition: TButtonPosition read FButtonPosition write SetButtonPosition default bpRight;
    property ButtonGlyphPosition: TButtonGlyphPosition read FButtonGlyphPosition write SetButtonGlyphPosition default gpCenter;
    property ButtonGlyphStretch: Boolean read FButtonGlyphStretch write SetButtonGlyphStretch default False;
    property ButtonGlyphPadding: Integer read FButtonGlyphPadding write SetButtonGlyphPadding default 4;
    property ButtonPicture: TPicture read FButtonPicture write SetButtonPicture;
    property ButtonText: string read FButtonText write SetButtonText;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 35;

    // Placeholder Properties
    property PlaceholderText: string read FPlaceholderText write SetPlaceholderText;
    property PlaceholderTextColor: TColor read FPlaceholderTextColor write SetPlaceholderTextColor default clGrayText;

    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property OnButtonMouseEnter: TNotifyEvent read FOnButtonMouseEnter write FOnButtonMouseEnter;
    property OnButtonMouseLeave: TNotifyEvent read FOnButtonMouseLeave write FOnButtonMouseLeave;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TFluidEdit]);
end;

constructor TFluidEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Default values
  FButtonColor := clBtnFace;
  FButtonColorDown := clBtnShadow;
  FButtonColorHovered := clSilver;
  FButtonPosition := bpRight;
  FButtonGlyphPosition := gpCenter;
  FButtonGlyphStretch := False;
  FButtonGlyphPadding := 4;
  FButtonWidth := 35;

  // Requirement: Default font color black
  Font.Color := clBlack;

  FButtonPicture := TPicture.Create;
  FButtonPicture.OnChange := PictureChanged;
  FButtonGlyph := nil;

  // Requirement: Placeholder defaults
  FPlaceholderTextColor := clGrayText;
end;

destructor TFluidEdit.Destroy;
begin
  FButtonPicture.Free;
  if Assigned(FButtonGlyph) then FButtonGlyph.Free;
  inherited;
end;

function TFluidEdit.GetParentBackgroundColor: TColor;
begin
  if (Parent <> nil) then
    Result := TControlAccess(Parent).Color
  else
    Result := clBtnFace;
end;

procedure TFluidEdit.PictureChanged(Sender: TObject);
begin
  UpdateGPImageFromPicture;
  Invalidate;
end;

function TFluidEdit.CreateGPImageFromStream(Stream: TStream): TGPImage;
var
  Adapter: IStream;
  NativeImg: GpImage;
begin
  Result := nil;
  NativeImg := nil;
  Adapter := TStreamAdapter.Create(Stream, soReference);
  if GdipLoadImageFromStream(Adapter, NativeImg) = Ok then
  begin
    Result := TGPImage.Create;
    TGPImageAccessor(Result).nativeImage := NativeImg;
  end;
end;

procedure TFluidEdit.UpdateGPImageFromPicture;
var
  Stream: TMemoryStream;
begin
  if Assigned(FButtonGlyph) then FreeAndNil(FButtonGlyph);

  if (FButtonPicture.Graphic <> nil) and not FButtonPicture.Graphic.Empty then
  begin
    Stream := TMemoryStream.Create;
    try
      FButtonPicture.Graphic.SaveToStream(Stream);
      Stream.Position := 0;
      FButtonGlyph := CreateGPImageFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

function TFluidEdit.ColorToGPColorAlpha(Value: TColor; Alpha: Byte): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(Alpha, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

function TFluidEdit.GetButtonRect: TRect;
begin
  if FButtonPosition = bpNone then Exit(Rect(0,0,0,0));
  if FButtonPosition = bpLeft then
    Result := Rect(0, 0, FButtonWidth, Height)
  else
    Result := Rect(Width - FButtonWidth, 0, Width, Height);
end;

procedure TFluidEdit.AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
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

procedure TFluidEdit.UpdateLayout;
var
  L, R, T, MetricsHeight: Integer;
  DC: HDC;
  SaveFont: HFONT;
  Metrics: TTextMetric;
begin
  if not Assigned(Edit) or not HandleAllocated then Exit;

  DC := GetDC(Edit.Handle);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    MetricsHeight := Metrics.tmHeight;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(Edit.Handle, DC);
  end;

  L := InnerPadding + (BorderRadius div 3) + Ceil(BorderThickness);
  R := Width - L;

  if FButtonPosition = bpLeft then
    L := FButtonWidth + 4
  else if FButtonPosition = bpRight then
    R := Width - FButtonWidth - 4;

  T := (Self.Height - MetricsHeight) div 2;
  Edit.SetBounds(L, T, Max(10, R - L), MetricsHeight);
end;

procedure TFluidEdit.Paint;
var
  Graphics: TGPGraphics;
  BtnRect: TRect;
  BtnPath, BorderPath: TGPGraphicsPath;
  Brush: TGPSolidBrush;
  Pen: TGPPen;
  TargetColor: TColor;
  GlyphX, GlyphY, DrawW, DrawH: Single;
  OrigW, OrigH: Integer;
  AspectRatio: Double;
  TextR: TRect;
  TextFlags: Cardinal;
  R: TGPRectF;
  Offset: Single;
  PlaceholderRect: TRect;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    Graphics.SetInterpolationMode(InterpolationModeHighQualityBicubic);
    Graphics.SetPixelOffsetMode(PixelOffsetModeHighQuality);

    Graphics.Clear(ColorToGPColorAlpha(GetParentBackgroundColor));

    Offset := (BorderThickness / 2) - 0.5;
    R := MakeRect(Offset, Offset, Width - BorderThickness, Height - BorderThickness);

    // 1. Draw Main Background
    BorderPath := TGPGraphicsPath.Create;
    AddRoundRectToPath(BorderPath, R, BorderRadius);

    Brush := TGPSolidBrush.Create(ColorToGPColorAlpha(Color));
    Graphics.FillPath(Brush, BorderPath);
    Brush.Free;

    // 2. Draw Button
    if FButtonPosition <> bpNone then
    begin
      BtnRect := GetButtonRect;
      TargetColor := FButtonColor;
      if FIsDown then TargetColor := FButtonColorDown
      else if FIsHovered then TargetColor := FButtonColorHovered;

      BtnPath := TGPGraphicsPath.Create;
      if FButtonPosition = bpLeft then
      begin
        BtnPath.AddArc(R.X, R.Y, BorderRadius*2, BorderRadius*2, 180, 90);
        BtnPath.AddLine(R.X + BorderRadius, R.Y, BtnRect.Right, R.Y);
        BtnPath.AddLine(BtnRect.Right, R.Y + R.Height, R.X + BorderRadius, R.Y + R.Height);
        BtnPath.AddArc(R.X, R.Y + R.Height - BorderRadius*2, BorderRadius*2, BorderRadius*2, 90, 90);
      end
      else
      begin
        BtnPath.AddLine(BtnRect.Left, R.Y, R.X + R.Width - BorderRadius, R.Y);
        BtnPath.AddArc(R.X + R.Width - BorderRadius*2, R.Y, BorderRadius*2, BorderRadius*2, 270, 90);
        BtnPath.AddArc(R.X + R.Width - BorderRadius*2, R.Y + R.Height - BorderRadius*2, BorderRadius*2, BorderRadius*2, 0, 90);
        BtnPath.AddLine(R.X + R.Width - BorderRadius, R.Y + R.Height, BtnRect.Left, R.Y + R.Height);
      end;
      BtnPath.CloseFigure;

      Brush := TGPSolidBrush.Create(ColorToGPColorAlpha(TargetColor));
      Graphics.FillPath(Brush, BtnPath);
      Brush.Free;
      BtnPath.Free;

      if Assigned(FButtonGlyph) then
      begin
        OrigW := FButtonGlyph.GetWidth;
        OrigH := FButtonGlyph.GetHeight;
        if FButtonGlyphStretch then
        begin
          DrawW := BtnRect.Width - (FButtonGlyphPadding * 2);
          DrawH := BtnRect.Height - (FButtonGlyphPadding * 2);
          AspectRatio := OrigW / OrigH;
          if (DrawW / DrawH) > AspectRatio then DrawW := DrawH * AspectRatio
          else DrawH := DrawW / AspectRatio;
        end
        else
        begin
          DrawW := OrigW;
          DrawH := OrigH;
        end;

        GlyphY := (Height - DrawH) / 2;
        case FButtonGlyphPosition of
          gpLeft:   GlyphX := BtnRect.Left + FButtonGlyphPadding;
          gpRight:  GlyphX := BtnRect.Right - DrawW - FButtonGlyphPadding;
          gpCenter: GlyphX := BtnRect.Left + (BtnRect.Width - DrawW) / 2;
        end;
        Graphics.DrawImage(FButtonGlyph, GlyphX, GlyphY, DrawW, DrawH);
      end;

      if FButtonText <> '' then
      begin
        Canvas.Font.Assign(Self.Font);
        Canvas.Brush.Style := bsClear;
        TextR := BtnRect;
        InflateRect(TextR, -2, 0);
        TextFlags := DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX;
        case FButtonGlyphPosition of
          gpLeft:   TextFlags := TextFlags or DT_RIGHT;
          gpRight:  TextFlags := TextFlags or DT_LEFT;
          gpCenter: TextFlags := TextFlags or DT_CENTER;
        end;
        DrawText(Canvas.Handle, PChar(FButtonText), -1, TextR, TextFlags);
      end;
    end;

    // 3. Draw Placeholder Text (Requirement: only when empty AND unfocused)
    if (FPlaceholderText <> '') and (Edit.Text = '') and (not Edit.Focused) then
    begin
      Canvas.Font.Assign(Self.Font);
      Canvas.Font.Color := FPlaceholderTextColor;
      Canvas.Brush.Style := bsClear;
      PlaceholderRect := Edit.BoundsRect;
      // Slight horizontal offset to align with TEdit internal margin
      OffsetRect(PlaceholderRect, 1, 0);
      DrawText(Canvas.Handle, PChar(FPlaceholderText), -1, PlaceholderRect, DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
    end;

    // 4. Draw Border
    Pen := TGPPen.Create(ColorToGPColorAlpha(BorderColor), BorderThickness);
    case BorderStyle of
      ebsDashed: Pen.SetDashStyle(DashStyleDash);
      ebsDotted: Pen.SetDashStyle(DashStyleDot);
    end;
    Graphics.DrawPath(Pen, BorderPath);

    Pen.Free;
    BorderPath.Free;
  finally
    Graphics.Free;
  end;
end;

procedure TFluidEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var InBtn: Boolean;
begin
  inherited;
  InBtn := PtInRect(GetButtonRect, Point(X, Y));
  if InBtn <> FIsHovered then
  begin
    FIsHovered := InBtn;
    if FIsHovered then begin if Assigned(FOnButtonMouseEnter) then FOnButtonMouseEnter(Self); end
    else begin if Assigned(FOnButtonMouseLeave) then FOnButtonMouseLeave(Self); end;
    Invalidate;
  end;
end;

procedure TFluidEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and PtInRect(GetButtonRect, Point(X, Y)) then
  begin
    FIsDown := True;
    Invalidate;
  end;
  inherited;
end;

procedure TFluidEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FIsDown then
  begin
    FIsDown := False;
    Invalidate;
    if PtInRect(GetButtonRect, Point(X, Y)) then
      if Assigned(FOnButtonClick) then FOnButtonClick(Self);
  end;
  inherited;
end;

procedure TFluidEdit.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FIsHovered then
  begin
    FIsHovered := False;
    if Assigned(FOnButtonMouseLeave) then FOnButtonMouseLeave(Self);
    Invalidate;
  end;
end;

procedure TFluidEdit.Resize;
begin
  inherited;
  UpdateLayout;
end;

procedure TFluidEdit.LoadGlyphFromFile(const FileName: string);
begin
  FButtonPicture.LoadFromFile(FileName);
end;

procedure TFluidEdit.SetButtonColor(const Value: TColor);
begin
  if FButtonColor <> Value then begin FButtonColor := Value; Invalidate; end;
end;

procedure TFluidEdit.SetButtonColorDown(const Value: TColor);
begin
  if FButtonColorDown <> Value then FButtonColorDown := Value;
end;

procedure TFluidEdit.SetButtonColorHovered(const Value: TColor);
begin
  if FButtonColorHovered <> Value then FButtonColorHovered := Value;
end;

procedure TFluidEdit.SetButtonGlyphPosition(const Value: TButtonGlyphPosition);
begin
  if FButtonGlyphPosition <> Value then begin FButtonGlyphPosition := Value; Invalidate; end;
end;

procedure TFluidEdit.SetButtonGlyphStretch(const Value: Boolean);
begin
  if FButtonGlyphStretch <> Value then begin FButtonGlyphStretch := Value; Invalidate; end;
end;

procedure TFluidEdit.SetButtonGlyphPadding(const Value: Integer);
begin
  if FButtonGlyphPadding <> Value then begin FButtonGlyphPadding := Value; Invalidate; end;
end;

procedure TFluidEdit.SetButtonPosition(const Value: TButtonPosition);
begin
  if FButtonPosition <> Value then
  begin
    FButtonPosition := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TFluidEdit.SetButtonText(const Value: string);
begin
  if FButtonText <> Value then begin FButtonText := Value; Invalidate; end;
end;

procedure TFluidEdit.SetButtonWidth(const Value: Integer);
begin
  if FButtonWidth <> Value then
  begin
    FButtonWidth := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TFluidEdit.SetButtonPicture(const Value: TPicture);
begin
  FButtonPicture.Assign(Value);
end;

procedure TFluidEdit.SetPlaceholderText(const Value: string);
begin
  if FPlaceholderText <> Value then
  begin
    FPlaceholderText := Value;
    Invalidate;
  end;
end;

procedure TFluidEdit.SetPlaceholderTextColor(const Value: TColor);
begin
  if FPlaceholderTextColor <> Value then
  begin
    FPlaceholderTextColor := Value;
    Invalidate;
  end;
end;

end.
