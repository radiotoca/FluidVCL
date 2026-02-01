unit FluidColorPickerDialogUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  FluidColorBoxUnit, System.UITypes, System.Math, Vcl.GraphUtil, RoundedEditUnit;

type
  TFluidColorPickerDialog = class(TForm)
    pnlBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    ColorBox: TFluidColorBox;
    pnlComparison: TPanel;
    shpNewColor: TShape;
    shpOldColor: TShape;
    pnlInputs: TPanel;
    lblHex: TLabel;
    edtHex: TRoundedEdit;
    lblRGB: TLabel;
    edtR: TEdit;
    edtG: TEdit;
    edtB: TEdit;
    lblRGBA: TLabel;
    edtRA: TEdit;
    edtGA: TEdit;
    edtBA: TEdit;
    edtAlpha: TEdit;
    lblHSL: TLabel;
    edtH: TEdit;
    edtS: TEdit;
    edtL: TEdit;
    lblHSV: TLabel;
    edtHV: TEdit;
    edtSV: TEdit;
    edtVV: TEdit;
    lblOld: TLabel;
    lblNew: TLabel;
    procedure ColorBoxColorChange(Sender: TObject);
    procedure edtHexChange(Sender: TObject);
    procedure RGBChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FUpdating: Boolean;
    FOriginalColor: TColor;
    procedure UpdateTextInputs;
  public
    property OriginalColor: TColor read FOriginalColor write FOriginalColor;
  end;

var
  FluidColorPickerDialog: TFluidColorPickerDialog;

implementation

{$R *.dfm}

procedure TFluidColorPickerDialog.FormCreate(Sender: TObject);
begin
  FUpdating := False;
end;

procedure TFluidColorPickerDialog.FormShow(Sender: TObject);
begin
  shpOldColor.Brush.Color := FOriginalColor;
  ColorBox.SelectedColor := FOriginalColor;
  UpdateTextInputs;
end;

procedure TFluidColorPickerDialog.ColorBoxColorChange(Sender: TObject);
begin
  if FUpdating then Exit;
  UpdateTextInputs;
end;

procedure TFluidColorPickerDialog.UpdateTextInputs;
var
  C: TColor;
  H, L, S: Word;
  NewHex: string;
  SavedStart, SavedLen: Integer;
begin
  FUpdating := True;
  try
    C := ColorBox.SelectedColor;
    shpNewColor.Brush.Color := C;

    // Hex - Preserve cursor position if the user is typing
    NewHex := ColorBox.GetColorHex;
    if not SameText(edtHex.Text, NewHex) then
    begin
      if edtHex.Focused then
      begin
        SavedStart := edtHex.SelStart;
        SavedLen := edtHex.SelLength;
        edtHex.Text := NewHex;
        edtHex.SelStart := SavedStart;
        edtHex.SelLength := SavedLen;
      end
      else
        edtHex.Text := NewHex;
    end;

    // RGB
    edtR.Text := GetRValue(C).ToString;
    edtG.Text := GetGValue(C).ToString;
    edtB.Text := GetBValue(C).ToString;

    // RGBA (Simulated Alpha at 255 for now)
    edtRA.Text := edtR.Text;
    edtGA.Text := edtG.Text;
    edtBA.Text := edtB.Text;
    edtAlpha.Text := '255';

    // HSL
    ColorRGBToHLS(C, H, L, S);
    edtH.Text := Format('%d°', [Round((H / 240) * 360)]);
    edtS.Text := Format('%d%%', [Round((S / 240) * 100)]);
    edtL.Text := Format('%d%%', [Round((L / 240) * 100)]);

    // HSV (Approximate for display)
    edtHV.Text := edtH.Text;
    edtSV.Text := edtS.Text;
    edtVV.Text := edtL.Text;

  finally
    FUpdating := False;
  end;
end;

procedure TFluidColorPickerDialog.edtHexChange(Sender: TObject);
var
  NewColor: TColor;
  HexStr: string;
begin
  if FUpdating then Exit;

  HexStr := edtHex.Text;
  // Valid length and starts with #
  if (Length(HexStr) = 7) and (HexStr[1] = '#') then
  begin
    try
      NewColor := RGB(
        StrToInt('$' + Copy(HexStr, 2, 2)),
        StrToInt('$' + Copy(HexStr, 4, 2)),
        StrToInt('$' + Copy(HexStr, 6, 2))
      );

      if ColorBox.SelectedColor <> NewColor then
      begin
        ColorBox.SelectedColor := NewColor;
        UpdateTextInputs;
      end;
    except
      // Invalid hex input
    end;
  end;
end;

procedure TFluidColorPickerDialog.RGBChange(Sender: TObject);
var
  R, G, B: Integer;
begin
  if FUpdating then Exit;

  if TryStrToInt(edtR.Text, R) and TryStrToInt(edtG.Text, G) and TryStrToInt(edtB.Text, B) then
  begin
    ColorBox.SelectedColor := RGB(EnsureRange(R, 0, 255), EnsureRange(G, 0, 255), EnsureRange(B, 0, 255));
    UpdateTextInputs;
  end;
end;

end.
