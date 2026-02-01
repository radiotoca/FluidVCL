unit RoundedMemoUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes,
  System.Math;

type
  TMemoBorderStyle = (mbsSolid, mbsDashed, mbsDotted);

  TControlAccess = class(TControl);

  TRoundedMemo = class(TCustomControl)
  private
    FMemo: TMemo;
    FBorderColor: TColor;
    FBorderRadius: Integer;
    FBorderThickness: Single;
    FInnerPadding: Integer;
    FBorderStyle: TMemoBorderStyle;
    FOnChange: TNotifyEvent;
    FAutoHeight: Boolean;
    FMaxAutoLines: Integer;

    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderRadius(const Value: Integer);
    procedure SetBorderThickness(const Value: Single);
    procedure SetInnerPadding(const Value: Integer);
    procedure SetBorderStyle(const Value: TMemoBorderStyle);
    procedure SetAutoHeight(const Value: Boolean);
    procedure SetMaxAutoLines(const Value: Integer);

    function GetLines: TStrings;
    procedure SetLines(const Value: TStrings);
    function GetText: string;
    procedure SetText(const Value: string);

    procedure MemoChange(Sender: TObject);
    procedure MemoEnter(Sender: TObject);
    procedure MemoExit(Sender: TObject);

    function ColorToGPColor(const Value: TColor): TGPColor;
    procedure AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
    procedure UpdateLayout;
    procedure UpdateRegion;

    procedure CMCursorChanged(var Message: TMessage); message CM_CURSORCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CNCtlColorMemo(var Message: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure CNStaticColor(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Memo: TMemo read FMemo;
  published
    property Lines: TStrings read GetLines write SetLines;
    property Text: string read GetText write SetText;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $00CCCCCC;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 10;
    property BorderThickness: Single read FBorderThickness write SetBorderThickness;
    property BorderStyle: TMemoBorderStyle read FBorderStyle write SetBorderStyle default mbsSolid;
    property InnerPadding: Integer read FInnerPadding write SetInnerPadding default 8;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default False;
    property MaxAutoLines: Integer read FMaxAutoLines write SetMaxAutoLines default 10;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;

    property Align;
    property Anchors;
    property Color default clWhite;
    property ParentColor default False;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnClick;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedMemo]);
end;

constructor TRoundedMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];

  FBorderColor := $00CCCCCC;
  FBorderRadius := 10;
  FBorderThickness := 1.5;
  FInnerPadding := 8;
  FAutoHeight := False; // Default False for Memos as they are usually fixed size
  FMaxAutoLines := 10;
  Color := clWhite;
  Width := 250;
  Height := 100;

  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.BorderStyle := bsNone;
  FMemo.ScrollBars := ssNone;
  FMemo.OnChange := MemoChange;
  FMemo.OnEnter := MemoEnter;
  FMemo.OnExit := MemoExit;
  FMemo.Color := Color;
  FMemo.TabStop := True;
end;

procedure TRoundedMemo.Loaded;
begin
  inherited;
  UpdateLayout;
end;

procedure TRoundedMemo.UpdateLayout;
var
  L, T, W, H, CalculatedHeight: Integer;
  DC: HDC;
  SaveFont: HFONT;
  Metrics: TTextMetric;
  LineCount: Integer;
begin
  if not Assigned(FMemo) or not HandleAllocated then Exit;

  // 1. Calculate Single Line Height
  DC := GetDC(FMemo.Handle);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    H := Metrics.tmHeight + Metrics.tmExternalLeading;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(FMemo.Handle, DC);
  end;

  // 2. Handle AutoHeight logic based on line count
  if FAutoHeight then
  begin
    LineCount := Max(1, FMemo.Lines.Count);
    if LineCount > FMaxAutoLines then LineCount := FMaxAutoLines;

    CalculatedHeight := (H * LineCount) + (FInnerPadding * 2) + Ceil(FBorderThickness * 2);

    if Height <> CalculatedHeight then
    begin
      Height := CalculatedHeight;
      UpdateRegion;
    end;

    // Enable scrollbars only if we exceed MaxAutoLines
    if FMemo.Lines.Count > FMaxAutoLines then
      FMemo.ScrollBars := ssVertical
    else
      FMemo.ScrollBars := ssNone;
  end;

  // 3. Position the internal Memo
  L := FInnerPadding + (FBorderRadius div 3) + Ceil(FBorderThickness);
  W := Width - (L * 2);
  T := FInnerPadding + Ceil(FBorderThickness);

  FMemo.SetBounds(L, T, Max(10, W), Height - (T * 2));
end;

procedure TRoundedMemo.UpdateRegion;
var
  Rgn: HRGN;
begin
  if not HandleAllocated then Exit;
  Rgn := CreateRoundRectRgn(0, 0, Width + 1, Height + 1, FBorderRadius * 2, FBorderRadius * 2);
  if SetWindowRgn(Handle, Rgn, True) = 0 then
    DeleteObject(Rgn);
end;

procedure TRoundedMemo.Paint;
var
  Graphics: TGPGraphics;
  Path: TGPGraphicsPath;
  GPRect: TGPRectF;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  ParentBg: TColor;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    if (Parent <> nil) and not ParentColor then
      ParentBg := TControlAccess(Parent).Color
    else
      ParentBg := clBtnFace;
    Graphics.Clear(ColorToGPColor(ParentBg));

    GPRect.X := FBorderThickness / 2;
    GPRect.Y := FBorderThickness / 2;
    GPRect.Width := Width - FBorderThickness;
    GPRect.Height := Height - FBorderThickness;

    Path := TGPGraphicsPath.Create;
    try
      AddRoundRectToPath(Path, GPRect, FBorderRadius);

      Brush := TGPSolidBrush.Create(ColorToGPColor(Color));
      Graphics.FillPath(Brush, Path);
      Brush.Free;

      Pen := TGPPen.Create(ColorToGPColor(FBorderColor), FBorderThickness);
      try
        case FBorderStyle of
          mbsDashed: Pen.SetDashStyle(DashStyleDash);
          mbsDotted: Pen.SetDashStyle(DashStyleDot);
          else Pen.SetDashStyle(DashStyleSolid);
        end;
        Graphics.DrawPath(Pen, Path);
      finally
        Pen.Free;
      end;
    finally
      Path.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

procedure TRoundedMemo.AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
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

function TRoundedMemo.ColorToGPColor(const Value: TColor): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

procedure TRoundedMemo.CNCtlColorMemo(var Message: TWMCtlColorEdit);
begin
  SetBkColor(Message.ChildDC, ColorToRGB(Color));
  Message.Result := CreateSolidBrush(ColorToRGB(Color));
end;

procedure TRoundedMemo.CNStaticColor(var Message: TWMCtlColorStatic);
begin
  SetBkColor(Message.ChildDC, ColorToRGB(Color));
  Message.Result := CreateSolidBrush(ColorToRGB(Color));
end;

procedure TRoundedMemo.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRoundedMemo.SetAutoHeight(const Value: Boolean);
begin
  if FAutoHeight <> Value then
  begin
    FAutoHeight := Value;
    UpdateLayout;
  end;
end;

procedure TRoundedMemo.SetMaxAutoLines(const Value: Integer);
begin
  if FMaxAutoLines <> Value then
  begin
    FMaxAutoLines := Value;
    UpdateLayout;
  end;
end;

procedure TRoundedMemo.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TRoundedMemo.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    UpdateRegion;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedMemo.SetBorderThickness(const Value: Single);
begin
  if FBorderThickness <> Value then
  begin
    FBorderThickness := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedMemo.SetInnerPadding(const Value: Integer);
begin
  if FInnerPadding <> Value then
  begin
    FInnerPadding := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedMemo.SetBorderStyle(const Value: TMemoBorderStyle);
begin
  if FBorderStyle <> Value then begin FBorderStyle := Value; Invalidate; end;
end;

procedure TRoundedMemo.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FMemo) then
  begin
    FMemo.Font.Assign(Font);
    UpdateLayout;
  end;
end;

procedure TRoundedMemo.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FMemo) then FMemo.Color := Color;
  Invalidate;
end;

function TRoundedMemo.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

procedure TRoundedMemo.SetLines(const Value: TStrings);
begin
  FMemo.Lines.Assign(Value);
end;

procedure TRoundedMemo.SetText(const Value: string);
begin
  FMemo.Text := Value;
end;

function TRoundedMemo.GetText: string;
begin
  Result := FMemo.Text;
end;

procedure TRoundedMemo.MemoChange(Sender: TObject);
begin
  if FAutoHeight then UpdateLayout;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRoundedMemo.MemoEnter(Sender: TObject);
begin
  Invalidate;
end;

procedure TRoundedMemo.MemoExit(Sender: TObject);
begin
  Invalidate;
end;

procedure TRoundedMemo.Resize;
begin
  inherited;
  UpdateRegion;
  UpdateLayout;
end;

procedure TRoundedMemo.WMSetFocus(var Message: TWMSetFocus);
begin
  FMemo.SetFocus;
end;

procedure TRoundedMemo.CMCursorChanged(var Message: TMessage);
begin
  inherited;
  FMemo.Cursor := Cursor;
end;

end.
