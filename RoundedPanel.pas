unit RoundedPanel;

interface

uses
  System.Classes, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics,
  Winapi.Windows, Winapi.Messages;

type
  TRoundedPanel = class(TPanel)
  private
    FCornerRadius: Integer;
    FBorderColor: TColor;
    FBorderHoverColor: TColor;
    FBorderWidth: Integer;
    FHoverColor: TColor;
    FIsHovered: Boolean;
    FBorderEnabled: Boolean;
    FHoverEnabled: Boolean;
    procedure SetCornerRadius(const Value: Integer);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderHoverColor(const Value: TColor);
    procedure SetBorderWidth(const Value: Integer);
    procedure SetHoverColor(const Value: TColor);
    procedure SetBorderEnabled(const Value: Boolean);
    procedure SetHoverEnabled(const Value: Boolean);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override; // for virtual implementation
  published
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 20;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clSilver;
    property BorderHoverColor: TColor read FBorderHoverColor write SetBorderHoverColor default clBlack;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 2;
    property HoverColor: TColor read FHoverColor write SetHoverColor default clBtnFace;
    property BorderEnabled: Boolean read FBorderEnabled write SetBorderEnabled default True;
    property HoverEnabled: Boolean read FHoverEnabled write SetHoverEnabled default True;
    property Color default clBtnFace;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TRoundedPanel]);
end;

{ TRoundedPanel }

constructor TRoundedPanel.Create(AOwner: TComponent);
begin
  inherited;
  FCornerRadius := 20;
  FBorderColor := clSilver;
  FBorderHoverColor := clBlack;
  FBorderWidth := 2;
  FHoverColor := clBtnFace;
  FIsHovered := False;
  FBorderEnabled := True;
  FHoverEnabled := True;
  ParentColor := True;
  DoubleBuffered := True;
end;

procedure TRoundedPanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if FHoverEnabled then
  begin
    FIsHovered := True;
    Invalidate;
  end;
end;

procedure TRoundedPanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverEnabled then
  begin
    FIsHovered := False;
    Invalidate;
  end;
end;

procedure TRoundedPanel.Resize;
var
  Rgn: HRGN;
begin
  inherited;
  if FCornerRadius > 0 then
  begin
    Rgn := CreateRoundRectRgn(0, 0, Width + 1, Height + 1, FCornerRadius, FCornerRadius);
    SetWindowRgn(Handle, Rgn, True);
  end
  else
    SetWindowRgn(Handle, 0, True); // reset if no radius
end;

procedure TRoundedPanel.Paint;
var
  R: TRect;
  BrushColor: TColor;
begin
  inherited; // let TPanel paint background + children

  R := ClientRect;

  // pick background color (hover or normal)
  if FHoverEnabled and FIsHovered then
    BrushColor := FHoverColor
  else
    BrushColor := Color;

  // fill rounded area
  Canvas.Brush.Color := BrushColor;
  Canvas.Pen.Color := BrushColor;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  // draw border if enabled
  if FBorderEnabled then
  begin
    Canvas.Pen.Width := FBorderWidth;
    if FHoverEnabled and FIsHovered then
      Canvas.Pen.Color := FBorderHoverColor
    else
      Canvas.Pen.Color := FBorderColor;

    Canvas.Brush.Style := bsClear;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);
  end;
end;

procedure TRoundedPanel.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedPanel.SetBorderHoverColor(const Value: TColor);
begin
  if FBorderHoverColor <> Value then
  begin
    FBorderHoverColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedPanel.SetBorderWidth(const Value: Integer);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    Invalidate;
  end;
end;

procedure TRoundedPanel.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    Invalidate;
    Resize; // re-apply mask
  end;
end;

procedure TRoundedPanel.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then
  begin
    FHoverColor := Value;
    Invalidate;
  end;
end;

procedure TRoundedPanel.SetBorderEnabled(const Value: Boolean);
begin
  if FBorderEnabled <> Value then
  begin
    FBorderEnabled := Value;
    Invalidate;
  end;
end;

procedure TRoundedPanel.SetHoverEnabled(const Value: Boolean);
begin
  if FHoverEnabled <> Value then
  begin
    FHoverEnabled := Value;
    Invalidate;
  end;
end;

end.

