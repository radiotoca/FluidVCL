unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, GroupablePanelUnit, System.Generics.Collections,
  Vcl.StdCtrls, Vcl.Imaging.pnglang, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    GroupablePanel1: TGroupablePanel;
    GroupablePanel5: TGroupablePanel;
    GroupablePanel6: TGroupablePanel;
    GroupablePanel7: TGroupablePanel;
    GroupablePanel8: TGroupablePanel;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Image1: TImage;
    GroupablePanel2: TGroupablePanel;
    Label5: TLabel;
    Label6: TLabel;
    Image2: TImage;
    GroupablePanel3: TGroupablePanel;
    Label7: TLabel;
    Label8: TLabel;
    Image3: TImage;
    GroupablePanel4: TGroupablePanel;
    Label9: TLabel;
    Label10: TLabel;
    Image4: TImage;
    Label11: TLabel;
    GroupablePanel9: TGroupablePanel;
    GroupablePanel10: TGroupablePanel;
    GroupablePanel11: TGroupablePanel;
    GroupablePanel12: TGroupablePanel;
    Button3: TButton;
    lblHeader: TLabel;
    procedure SelectGroupA(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ProcessSelectedByGroupID(const AGroupID: string);
    function GetSelectedByGroupID(const AGroupID: string): TList<TGroupablePanel>;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.ProcessSelectedByGroupID(const AGroupID: string);
var
  i: Integer;
  Control: TControl;
  Panel: TGroupablePanel;
  SelectedNames: TStringList;
  DisplayMsg: string;
begin
  SelectedNames := TStringList.Create;
  try
    // Iterate through the container's controls
    for i := 0 to ControlCount - 1 do
    begin
      Control := Controls[i];

      if Control is TGroupablePanel then
      begin
        Panel := TGroupablePanel(Control);

        // Filter: Is it selected AND part of the passed AGroupID?
        if Panel.Down and SameText(Panel.GroupID, AGroupID) then
        begin
          SelectedNames.Add('• ' + Panel.Name); // Added a bullet point for better formatting
        end;
      end;
    end;

    // Build and display the message dialog
    if SelectedNames.Count > 0 then
    begin
      DisplayMsg := Format('The following items in group "%s" are selected:' + sLineBreak + sLineBreak + '%s',
                           [AGroupID, SelectedNames.Text]);
      ShowMessage(DisplayMsg);
    end
    else
    begin
      ShowMessage(Format('No items selected in group "%s".', [AGroupID]));
    end;

  finally
    SelectedNames.Free;
  end;
end;

// A generic function that returns a list of panels for a specific GroupID parameter
function TForm1.GetSelectedByGroupID(const AGroupID: string): TList<TGroupablePanel>;
var
  i: Integer;
begin
  Result := TList<TGroupablePanel>.Create;
  for i := 0 to ControlCount - 1 do
  begin
    if (Controls[i] is TGroupablePanel) then
    begin
      if TGroupablePanel(Controls[i]).Down and
         SameText(TGroupablePanel(Controls[i]).GroupID, AGroupID) then
      begin
        Result.Add(TGroupablePanel(Controls[i]));
      end;
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////////////

procedure TForm1.Button1Click(Sender: TObject);
begin
  ProcessSelectedByGroupID('GroupA');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ProcessSelectedByGroupID('GroupB');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  ProcessSelectedByGroupID('GroupC');
end;

procedure TForm1.SelectGroupA(Sender: TObject);
begin
  if (Sender is TControl) and (TControl(Sender).Parent is TGroupablePanel) then
  begin
     TGroupablePanel(TControl(Sender).Parent).Down := True;
  end;
end;

end.
