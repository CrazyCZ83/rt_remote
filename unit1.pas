unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, MouseAndKeyInput, LCLType, Process

;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  AProcess: TProcess;
  AStringList: TStringList;
  s,a: string;
  OutputStream: TStream;
  BytesRead: LongInt;
  Buffer: array [1..2048] of byte;

implementation

{$R *.lfm}

{ TForm1 }

Procedure GetWinId;
begin
  s := AStringList[AStringList.Count-2];
  s := copy (s, pos ('0x', s), length (s));
  s := copy (s, 1, pos (' ', s)-1);
  Form1.Edit1.Text := s;

end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  // MouseInput.Click(mbLeft,[],120,120);
  AProcess := TProcess.Create(nil);
  AProcess.Executable := '/usr/bin/xwininfo';
  //AProcess.Parameters.Add('-root');
//  AProcess.Parameters.Add('-all');
  AProcess.Parameters.Add('-children');
  AProcess.Options := AProcess.Options + [poWaitOnExit, poUsePipes];

  AProcess.Execute;

  AStringList := TStringList.Create;
  AStringList.LoadFromStream(AProcess.Output);

  Form1.Memo1.Lines.Clear;

  if AStringList.Count > 0 then
  begin
    Form1.Memo1.Lines := AStringList;
    GetWinId;
  end
    else Form1.Memo1.Lines.Add ('Program not found');

//  AStringList.SaveToFile('/root/output.txt');

  AProcess.Free;

end;

procedure TForm1.Button2Click(Sender: TObject);

begin
  if Form1.Edit1.Text = '' then
  begin
    Application.MessageBox('Nedrive vyberte okno pro zachytavani', 'Chyba', 0);
    Exit;
  end;
  //Application.MessageBox('OK', 'Chyba', 0);
  OutputStream := TMemoryStream.Create;
  AProcess := TProcess.Create(nil);
  AProcess.Executable := '/usr/bin/xev';
  AProcess.Parameters.Add('-id');
  AProcess.Parameters.Add(Form1.Edit1.Text);
  AProcess.Options := AProcess.Options + [poUsePipes];
  AProcess.Execute;
  repeat
    BytesRead := AProcess.Output.Read(Buffer, 255);
    Application.ProcessMessages;
    Form1.Refresh;
    OutputStream.Write(Buffer, BytesRead);
    OutputStream.Position:=0;
    Form1.Memo1.Lines.Add(OutputStream.ToString);
    Application.ProcessMessages;
  until false;



end;



end.

