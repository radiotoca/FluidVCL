unit RoundedEditUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Forms, Winapi.GDIPOBJ, Winapi.GDIPAPI, System.UITypes,
  System.Math;

type
  TEditBorderStyle = (ebsSolid, ebsDashed, ebsDotted);

  TControlAccess = class(TControl);

  TRoundedEdit = class(TCustomControl)
  private
    FEdit: TEdit;
    FBorderColor: TColor;
    FBorderRadius: Integer;
    FBorderThickness: Single;
    FInnerPadding: Integer;
    FBorderStyle: TEditBorderStyle;
    FOnChange: TNotifyEvent;
    FAutoHeight: Boolean;

    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderRadius(const Value: Integer);
    procedure SetBorderThickness(const Value: Single);
    procedure SetInnerPadding(const Value: Integer);
    procedure SetBorderStyle(const Value: TEditBorderStyle);
    procedure SetAutoHeight(const Value: Boolean);
    procedure SetText(const Value: string);
    function GetText: string;

    // Selection property accessors
    function GetSelLength: Integer;
    procedure SetSelLength(const Value: Integer);
    function GetSelStart: Integer;
    procedure SetSelStart(const Value: Integer);
    function GetSelText: string;
    procedure SetSelText(const Value: string);

    procedure EditChange(Sender: TObject);
    procedure EditEnter(Sender: TObject);
    procedure EditExit(Sender: TObject);

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
    procedure CNCtlColorEdit(var Message: TWMCtlColorEdit); message CN_CTLCOLOREDIT;
    procedure CNStaticColor(var Message: TWMCtlColorStatic); message CN_CTLCOLORSTATIC;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SelectAll;
    property Edit: TEdit read FEdit;

    // Selection properties
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
  published
    property Text: string read GetText write SetText;
    property BorderColor: TColor read FBorderColor write SetBorderColor default $00CCCCCC;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 10;
    property BorderThickness: Single read FBorderThickness write SetBorderThickness;
    property BorderStyle: TEditBorderStyle read FBorderStyle write SetBorderStyle default ebsSolid;
    property InnerPadding: Integer read FInnerPadding write SetInnerPadding default 8;
    property AutoHeight: Boolean read FAutoHeight write SetAutoHeight default True;
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
  RegisterComponents('FluidVCL', [TRoundedEdit]);
end;

{ TRoundedEdit }

constructor TRoundedEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];

  FBorderColor := $00CCCCCC;
  FBorderRadius := 10;
  FBorderThickness := 1.5;
  FInnerPadding := 8;
  FAutoHeight := True;
  Color := clWhite;
  Width := 200;

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.OnChange := EditChange;
  FEdit.OnEnter := EditEnter;
  FEdit.OnExit := EditExit;
  FEdit.Color := Color;
  FEdit.TabStop := True;
end;

procedure TRoundedEdit.Loaded;
begin
  inherited;
  UpdateLayout;
end;

procedure TRoundedEdit.UpdateLayout;
var
  L, T, W, H, CalculatedHeight: Integer;
  DC: HDC;
  SaveFont: HFONT;
  Metrics: TTextMetric;
begin
  if not Assigned(FEdit) or not HandleAllocated then Exit;

  // Calculate Font Height
  DC := GetDC(FEdit.Handle);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    H := Metrics.tmHeight;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(FEdit.Handle, DC);
  end;

  // Adjust Parent Height if AutoHeight is enabled
  if FAutoHeight then
  begin
    CalculatedHeight := H + (FInnerPadding * 2) + Ceil(FBorderThickness * 2);
    if Height <> CalculatedHeight then
    begin
      Height := CalculatedHeight;
      UpdateRegion;
    end;
  end;

  // Position the internal Edit
  L := FInnerPadding + (FBorderRadius div 3) + Ceil(FBorderThickness);
  W := Width - (L * 2);
  T := (Self.Height - H) div 2;

  FEdit.SetBounds(L, T, Max(10, W), H);
end;

procedure TRoundedEdit.UpdateRegion;
var
  Rgn: HRGN;
begin
  if not HandleAllocated then Exit;
  Rgn := CreateRoundRectRgn(0, 0, Width + 1, Height + 1, FBorderRadius * 2, FBorderRadius * 2);
  if SetWindowRgn(Handle, Rgn, True) = 0 then
    DeleteObject(Rgn);
end;

procedure TRoundedEdit.Paint;
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
          ebsDashed: Pen.SetDashStyle(DashStyleDash);
          ebsDotted: Pen.SetDashStyle(DashStyleDot);
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

procedure TRoundedEdit.AddRoundRectToPath(Path: TGPGraphicsPath; Rect: TGPRectF; Radius: Single);
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

function TRoundedEdit.ColorToGPColor(const Value: TColor): TGPColor;
var RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

procedure TRoundedEdit.CNCtlColorEdit(var Message: TWMCtlColorEdit);
begin
  SetBkColor(Message.ChildDC, ColorToRGB(Color));
  Message.Result := CreateSolidBrush(ColorToRGB(Color));
end;

procedure TRoundedEdit.CNStaticColor(var Message: TWMCtlColorStatic);
begin
  SetBkColor(Message.ChildDC, ColorToRGB(Color));
  Message.Result := CreateSolidBrush(ColorToRGB(Color));
end;

procedure TRoundedEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TRoundedEdit.SetAutoHeight(const Value: Boolean);
begin
  if FAutoHeight <> Value then
  begin
    FAutoHeight := Value;
    UpdateLayout;
  end;
end;

procedure TRoundedEdit.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then begin FBorderColor := Value; Invalidate; end;
end;

procedure TRoundedEdit.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    UpdateRegion;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedEdit.SetBorderThickness(const Value: Single);
begin
  if FBorderThickness <> Value then
  begin
    FBorderThickness := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedEdit.SetInnerPadding(const Value: Integer);
begin
  if FInnerPadding <> Value then
  begin
    FInnerPadding := Value;
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TRoundedEdit.SetBorderStyle(const Value: TEditBorderStyle);
begin
  if FBorderStyle <> Value then begin FBorderStyle := Value; Invalidate; end;
end;

procedure TRoundedEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FEdit) then
  begin
    FEdit.Font.Assign(Font);
    UpdateLayout;
  end;
end;

procedure TRoundedEdit.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if Assigned(FEdit) then FEdit.Color := Color;
  Invalidate;
end;

procedure TRoundedEdit.SetText(const Value: string);
begin
  FEdit.Text := Value;
end;

function TRoundedEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

{ Selection Property Implementations }

function TRoundedEdit.GetSelLength: Integer;
begin
  Result := FEdit.SelLength;
end;

procedure TRoundedEdit.SetSelLength(const Value: Integer);
begin
  FEdit.SelLength := Value;
end;

function TRoundedEdit.GetSelStart: Integer;
begin
  Result := FEdit.SelStart;
end;

procedure TRoundedEdit.SetSelStart(const Value: Integer);
begin
  FEdit.SelStart := Value;
end;

function TRoundedEdit.GetSelText: string;
begin
  Result := FEdit.SelText;
end;

procedure TRoundedEdit.SetSelText(const Value: string);
begin
  FEdit.SelText := Value;
end;

procedure TRoundedEdit.SelectAll;
begin
  FEdit.SelectAll;
end;

{ Event Handlers }

procedure TRoundedEdit.EditChange(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRoundedEdit.EditEnter(Sender: TObject);
begin
  Invalidate;
end;

procedure TRoundedEdit.EditExit(Sender: TObject);
begin
  Invalidate;
end;

procedure TRoundedEdit.Resize;
begin
  inherited;
  UpdateRegion;
  UpdateLayout;
end;

procedure TRoundedEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  FEdit.SetFocus;
end;

procedure TRoundedEdit.CMCursorChanged(var Message: TMessage);
begin
  inherited;
  FEdit.Cursor := Cursor;
end;

end.
