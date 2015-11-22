program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  AirBerlin in 'AirBerlin.pas',
  Ryanair in 'Ryanair.pas',
  Corendon in 'Corendon.pas',
  Transavia in 'Transavia.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
