unit GroupablePanelUnit;

interface

uses
  System.Math, System.UITypes, Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.GDIPOBJ, Winapi.GDIPAPI;

type
  TGroupablePanel = class(TPanel)
  private
    FNormalColor: TColor;
    FHoverColor: TColor;
    FHoverSelectedColor: TColor;
    FDownColor: TColor;
    FBorderColor: TColor;
    FBorderWidth: Integer;
    FBorderRadius: Integer;
    FDown: Boolean;
    FGroupID: string;
    FIsHovered: Boolean;
    FAllowDeselect: Boolean;
    FAllowMultiple: Boolean;
    FAntiAliased: Boolean;
    FControlSafety: Boolean;
    procedure SetNormalColor(const Value: TColor);
    procedure SetHoverColor(const Value: TColor);
    procedure SetHoverSelectedColor(const Value: TColor);
    procedure SetDownColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderWidth(const Value: Integer);
    procedure SetBorderRadius(const Value: Integer);
    procedure SetDown(const Value: Boolean);
    procedure SetGroupID(const Value: string);
    procedure SetAllowDeselect(const Value: Boolean);
    procedure SetAllowMultiple(const Value: Boolean);
    procedure SetAntiAliased(const Value: Boolean);
    procedure SetControlSafety(const Value: Boolean);
    procedure UpdateControl;
    procedure UpdateRegion;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    function ColorToGPColor(const Value: TColor): TGPColor;
    procedure TurnSiblingsOff;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure Click; override;
    procedure Resize; override;
    procedure CreateHandle; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Down: Boolean read FDown write SetDown default False;
    property GroupID: string read FGroupID write SetGroupID;
    property AllowDeselect: Boolean read FAllowDeselect write SetAllowDeselect default False;
    property AllowMultiple: Boolean read FAllowMultiple write SetAllowMultiple default False;
    property AntiAliased: Boolean read FAntiAliased write SetAntiAliased default False;
    property ControlSafety: Boolean read FControlSafety write SetControlSafety default False;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBlack;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property Color: TColor read FNormalColor write SetNormalColor default clBtnFace;
    property HoverColor: TColor read FHoverColor write SetHoverColor default clHighlight;
    property HoverSelectedColor: TColor read FHoverSelectedColor write SetHoverSelectedColor default clHighlight;
    property DownColor: TColor read FDownColor write SetDownColor default clBtnShadow;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 12;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('FluidVCL', [TGroupablePanel]);
end;

{ TGroupablePanel }

constructor TGroupablePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FNormalColor := clBtnFace;
  FHoverColor := clHighlight;
  FHoverSelectedColor := clHighlight;
  FDownColor := clBtnShadow;
  FBorderColor := clGray;
  FBorderWidth := 1;
  FBorderRadius := 12;
  FDown := False;
  FGroupID := '';
  FIsHovered := False;
  FAllowDeselect := False;
  FAllowMultiple := False;
  FAntiAliased := True;
  FControlSafety := False;

  BevelOuter := bvNone;
  BevelInner := bvNone;
  FullRepaint := True;
  ParentColor := True;
  ControlStyle := ControlStyle + [csClickEvents, csOpaque];
end;

destructor TGroupablePanel.Destroy;
begin
  inherited Destroy;
end;

function TGroupablePanel.ColorToGPColor(const Value: TColor): TGPColor;
var
  RGBValue: LongInt;
begin
  RGBValue := ColorToRGB(Value);
  Result := MakeColor(255, GetRValue(RGBValue), GetGValue(RGBValue), GetBValue(RGBValue));
end;

procedure TGroupablePanel.CreateHandle;
begin
  inherited;
  UpdateRegion;
end;

procedure TGroupablePanel.Resize;
begin
  inherited;
  UpdateRegion;
end;

procedure TGroupablePanel.UpdateRegion;
var
  Rgn: HRGN;
begin
  if not HandleAllocated then Exit;

  Rgn := CreateRoundRectRgn(0, 0, Width + 1, Height + 1, FBorderRadius * 2, FBorderRadius * 2);

  if Rgn <> 0 then
  begin
    if SetWindowRgn(Handle, Rgn, True) = 0 then
      DeleteObject(Rgn);
  end;
end;

procedure TGroupablePanel.TurnSiblingsOff;
var
  I: Integer;
  Sibling: TControl;
  Target: TGroupablePanel;
begin
  if (Parent <> nil) then
  begin
    for I := 0 to Parent.ControlCount - 1 do
    begin
      Sibling := Parent.Controls[I];
      if (Sibling is TGroupablePanel) and (Sibling <> Self) then
      begin
        Target := TGroupablePanel(Sibling);
        if SameText(Target.GroupID, FGroupID) and (FGroupID <> '') then
        begin
          if Target.Down then
          begin
            Target.FDown := False;
            Target.UpdateControl;
          end;
        end;
      end;
    end;
  end;
end;

procedure TGroupablePanel.Click;
var
  CtrlPressed: Boolean;
begin
  CtrlPressed := (GetKeyState(VK_CONTROL) and $8000) <> 0;

  if FControlSafety then
  begin
    if CtrlPressed then
      SetDown(not FDown)
    else
    begin
      TurnSiblingsOff;
      SetDown(True);
    end;
  end
  else
  begin
    if FDown then
    begin
      if FAllowDeselect or FAllowMultiple then
        SetDown(False);
    end
    else
    begin
      if not FAllowMultiple then
        TurnSiblingsOff;
      SetDown(True);
    end;
  end;

  inherited Click;
end;

procedure TGroupablePanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) then
    UpdateControl;
end;

procedure TGroupablePanel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FIsHovered := True;
  UpdateControl;
end;

procedure TGroupablePanel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FIsHovered := False;
  UpdateControl;
end;

procedure TGroupablePanel.SetBorderColor(const Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetBorderWidth(const Value: Integer);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetNormalColor(const Value: TColor);
begin
  if FNormalColor <> Value then
  begin
    FNormalColor := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetHoverColor(const Value: TColor);
begin
  if FHoverColor <> Value then
  begin
    FHoverColor := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetHoverSelectedColor(const Value: TColor);
begin
  if FHoverSelectedColor <> Value then
  begin
    FHoverSelectedColor := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetDownColor(const Value: TColor);
begin
  if FDownColor <> Value then
  begin
    FDownColor := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetBorderRadius(const Value: Integer);
begin
  if FBorderRadius <> Value then
  begin
    FBorderRadius := Value;
    UpdateRegion;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetDown(const Value: Boolean);
begin
  if FDown <> Value then
  begin
    if Value and (not FAllowMultiple) then
      TurnSiblingsOff;

    FDown := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetGroupID(const Value: string);
begin
  if FGroupID <> Value then
  begin
    FGroupID := Value;
    if FDown and (not FAllowMultiple) then TurnSiblingsOff;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetAllowDeselect(const Value: Boolean);
begin
  FAllowDeselect := Value;
end;

procedure TGroupablePanel.SetAllowMultiple(const Value: Boolean);
begin
  if FAllowMultiple <> Value then
  begin
    FAllowMultiple := Value;
    if (not FAllowMultiple) and FDown then
      TurnSiblingsOff;
  end;
end;

procedure TGroupablePanel.SetAntiAliased(const Value: Boolean);
begin
  if FAntiAliased <> Value then
  begin
    FAntiAliased := Value;
    UpdateControl;
  end;
end;

procedure TGroupablePanel.SetControlSafety(const Value: Boolean);
begin
  FControlSafety := Value;
end;

procedure TGroupablePanel.UpdateControl;
begin
  Invalidate;
end;

procedure TGroupablePanel.Paint;
var
  Graphics: TGPGraphics;
  Path: TGPGraphicsPath;
  Pen: TGPPen;
  Brush: TGPSolidBrush;
  R: TGPRectF;
  ControlColor: TColor;
  Radius: Single;
  Offset: Single;
begin
  Graphics := TGPGraphics.Create(Canvas.Handle);
  try
    if FAntiAliased then
      Graphics.SetSmoothingMode(SmoothingModeAntiAlias)
    else
      Graphics.SetSmoothingMode(SmoothingModeNone);

    if FIsHovered and FDown then
      ControlColor := FHoverSelectedColor
    else if FIsHovered then
      ControlColor := FHoverColor
    else if FDown then
      ControlColor := FDownColor
    else
      ControlColor := FNormalColor;

    Offset := (FBorderWidth / 2) + 0.5;

    R.X := Offset;
    R.Y := Offset;
    R.Width := ClientWidth - (Offset * 2);
    R.Height := ClientHeight - (Offset * 2);

    Radius := FBorderRadius;
    if Radius > R.Width / 2 then Radius := R.Width / 2;
    if Radius > R.Height / 2 then Radius := R.Height / 2;

    Path := TGPGraphicsPath.Create;
    try
      if Radius > 0 then
      begin
        Path.AddArc(R.X, R.Y, Radius * 2, Radius * 2, 180, 90);
        Path.AddArc(R.X + R.Width - (Radius * 2), R.Y, Radius * 2, Radius * 2, 270, 90);
        Path.AddArc(R.X + R.Width - (Radius * 2), R.Y + R.Height - (Radius * 2), Radius * 2, Radius * 2, 0, 90);
        Path.AddArc(R.X, R.Y + R.Height - (Radius * 2), Radius * 2, Radius * 2, 90, 90);
        Path.CloseFigure;
      end
      else
        Path.AddRectangle(R);

      Brush := TGPSolidBrush.Create(ColorToGPColor(ControlColor));
      try
        Graphics.FillPath(Brush, Path);
      finally
        Brush.Free;
      end;

      inherited Paint;

      if FBorderWidth > 0 then
      begin
        Pen := TGPPen.Create(ColorToGPColor(FBorderColor), FBorderWidth);
        try
          Pen.SetLineJoin(LineJoinRound);
          Graphics.DrawPath(Pen, Path);
        finally
          Pen.Free;
        end;
      end;
    finally
      Path.Free;
    end;
  finally
    Graphics.Free;
  end;
end;

end.
