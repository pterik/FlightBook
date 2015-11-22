unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, StdCtrls, Spin, ComCtrls, Buttons,
  SHDocVw, inifiles, OleCtrls;

type
  TForm1 = class(TForm)
    pn_controls: TPanel;
    lbDepartDate: TLabel;
    lbReturnDate: TLabel;
    lbDepartingFrom: TLabel;
    lbGoingTo: TLabel;
    pn_ReturnOneWay: TPanel;
    rbReturn: TRadioButton;
    rbOneWay: TRadioButton;
    chbFlexible: TCheckBox;
    btnStart: TBitBtn;
    dtDepartDate: TDateTimePicker;
    dtReturnDate: TDateTimePicker;
    gbNumberOfPassengers: TGroupBox;
    lbAdults: TLabel;
    lbChildren: TLabel;
    lbInfants: TLabel;
    seChildren: TSpinEdit;
    seInfants: TSpinEdit;
    seAdults: TSpinEdit;
    cbGoingTo: TComboBox;
    cbDepartingFrom: TComboBox;
    sgResults: TStringGrid;
    RadioGroup1: TRadioGroup;
    lbl1: TLabel;
    chk1: TCheckBox;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbDepartingFromChange(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure dtDepartDateChange(Sender: TObject);
    procedure dtReturnDateChange(Sender: TObject);
    procedure chk1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
//May remove 2 variables calmly
    strlDepartingFrom : TStringList;
    strlDependences : TStringList;

    procedure CopyDataToGrid(strlData: TStringList);
    procedure CopyDataToGridForAirbaltic(strlData: TStringList);
    function initialiseren_ryanair: boolean;
    function initialiseren_airberlin: boolean;
    function initialiseren_Corendon: boolean;
    function initialiseren_Transavia: boolean;
    function initialiseren_Jetairfly: boolean;
    function initialiseren_Pegasus: boolean;
    function initialiseren_Vueling: boolean;
    function initialiseren_Easyjet: boolean;
    function initialiseren_Airbaltic: boolean;
    procedure CopyDataToGridForBrusselsAirlines(strlData: TStringList);
    function initialiseren_BrusselsAirlines: Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
   Ryanair, Airberlin, Corendon, Transavia, Jetairfly, Pegasus, Vueling, Easyjet,
   Airbaltic, BrusselsAirlines;


procedure TForm1.CopyDataToGridForAirbaltic(strlData: TStringList);
var
  I : integer;
  str, cell, new_cell : string;
  forward_date,forward_time : string;
  return_date,return_time : string;
begin
  // Prepare Grid
  sgResults.ColCount := 10;
  sgResults.ColWidths[0] := 60;
  sgResults.ColWidths[1] := 80;
  sgResults.ColWidths[2] := 70;
  sgResults.ColWidths[3] := 70;
  sgResults.ColWidths[4] := 60;
  sgResults.ColWidths[5] := 70;
  sgResults.ColWidths[6] := 70;
  sgResults.ColWidths[7] := 70;
  sgResults.ColWidths[8] := 60;
  sgResults.ColWidths[9] := 70;
  sgResults.RowCount := 2;

  for I := 0 to 10 do
    sgResults.Cells[I,1] := '';
  self.Refresh;
  Application.ProcessMessages;

  if Assigned(strlData) and (strlData.Count > 0) then
  begin
    sgResults.RowCount := strlData.Count+1;
    for I := 1 to strlData.Count do
    begin
      str := strlData[I-1]+'|';

      // type
      sgResults.Cells[0,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // forward depart_date
      forward_date := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // forward depart_time
      forward_time := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // forward arrival_date
      cell := Trim(forward_date);
      new_cell := Trim(copy(str,1,pos('|',str)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[2,I] := cell;
      Delete(str,1,pos('|',str));

      // forward arrival_time
      cell := Trim(forward_time);
      new_cell := Trim(copy(str,1,pos('|',str)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[3,I] := cell;
      Delete(str,1,pos('|',str));

      // forward flight no
      sgResults.Cells[1,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // via forward
      sgResults.Cells[4,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // Return ...
      // return depart_date
      return_date := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // return depart_time
      return_time := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // return arrival_date
      cell := Trim(return_date);
      new_cell := Trim(copy(str,1,pos('|',str)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[6,I] := cell;
      Delete(str,1,pos('|',str));

      // return arrival_time
      cell := Trim(return_time);
      new_cell := Trim(copy(str,1,pos('|',str)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[7,I] := cell;
      Delete(str,1,pos('|',str));

      // return flight no
      sgResults.Cells[5,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));


      // via return
      sgResults.Cells[8,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // total_price
      sgResults.Cells[9,I] := copy(str,1,pos('|',str)-1);
      
    end;
  end;
end;

procedure TForm1.CopyDataToGrid(strlData: TStringList);
var
  I : integer;
  str, via : string;
begin
  // Prepare Grid
  sgResults.ColCount := 8;
  sgResults.ColWidths[0] := 60;
  sgResults.ColWidths[1] := 60;
  sgResults.ColWidths[2] := 80;
  sgResults.ColWidths[3] := 80;
  sgResults.ColWidths[4] := 80;
  sgResults.ColWidths[5] := 80;
  sgResults.ColWidths[6] := 100;
  sgResults.ColWidths[7] := 100;
  sgResults.RowCount := 2;

  for I := 0 to 8 do
    sgResults.Cells[I,1] := '';
  self.Refresh;
  Application.ProcessMessages;

  if Assigned(strlData) and (strlData.Count > 0) then
  begin
    sgResults.RowCount := strlData.Count+1;
    for I := 1 to strlData.Count do
    begin
      str := strlData[I-1]+'|';

      // type
      sgResults.Cells[0,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // depart_date
      sgResults.Cells[2,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // depart_time
      sgResults.Cells[3,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // arrival_date
      sgResults.Cells[4,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // arrival_time
      sgResults.Cells[5,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // flight no
      sgResults.Cells[1,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // total_price
      sgResults.Cells[6,I] := copy(str,1,pos('|',str)-1);
      Delete(str,1,pos('|',str));

      // Via
      via := copy(str,1,pos('|',str)-1);
      sgResults.Cells[7,I] := via;
      Delete(str,1,pos('|',str));

    end;
  end;
end;

procedure TForm1.dtDepartDateChange(Sender: TObject);
begin
  if dtReturnDate.Date < dtDepartDate.Date then
    dtReturnDate.Date := dtDepartDate.Date;
end;

procedure TForm1.dtReturnDateChange(Sender: TObject);
begin
  if dtDepartDate.Date > dtReturnDate.Date then
    dtDepartDate.Date := dtReturnDate.Date;
end;

function TForm1.initialiseren_ryanair : boolean;
var
   i:integer;
   ini : tinifile;
   iniPath:string;
begin
  result:=false;
  try
  IniPath:=extractfiledir(Application.ExeName)+'\data\ryanair.ini';
  if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);

    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
      if Length(strlDepartingFrom.Strings[I])>1 then
        if strlDepartingFrom.Strings[I][1] = 's' then
          begin
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
          strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                          strlDepartingFrom[I],
                          '[','',[rfReplaceAll]),
                          ']','',[rfReplaceAll]),
                          ';',',',[rfReplaceAll]));
          if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
            or
             (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
            strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
          end
       else
          begin
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
          if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
            strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
          strlDependences.Add(strlDepartingFrom[I]);
          strlDepartingFrom.Delete(I);
          end;
    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
        strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
        ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 26;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 27;

    result:=true;
  finally
    ini.free;
  end;
end;

function TForm1.initialiseren_Transavia: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Transavia.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := '';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 4;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 3;
    result:=true;
  finally
    ini.free;
  end;
end;

//einde {sub}function initialiseren : boolean;

    {--------------------------------------------------------------------------}

function TForm1.initialiseren_airberlin : boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\airberlin.ini';
    if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := 'Via';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if Length(strlDepartingFrom.Strings[I])>1 then
      if strlDepartingFrom.Strings[I][1] = 's' then
        begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                        strlDepartingFrom[I],
                        '[','',[rfReplaceAll]),
                        ']','',[rfReplaceAll]),
                        ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
          or
           (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
        end
       else
        begin
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
          if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
            strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
          strlDependences.Add(strlDepartingFrom[I]);
          strlDepartingFrom.Delete(I);
        end;
    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 48;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 144;
    result:=true;
  finally
  ini.free;
  end;
end;

function TForm1.initialiseren_Corendon: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Corendon.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := 'Via';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 0;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 2;
    result:=true;
  finally
    ini.free;
  end;
end;
function TForm1.initialiseren_Jetairfly: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Jetairfly.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := 'Via';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 16;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 6;
    result:=true;

  finally
    ini.free;
  end;
end;

function TForm1.initialiseren_Pegasus: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Pegasus.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := 'Via';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 3;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 21;
    result:=true;

  finally
    ini.free;
  end;
end;

function TForm1.initialiseren_Vueling: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Vueling.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := 'Via';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 1;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 2;

    result:=true;

  finally
    ini.free;
  end;
end;

function TForm1.initialiseren_Easyjet: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Easyjet.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 8;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Flight #';
    sgResults.Cells[2,0] := 'Depart date';
    sgResults.Cells[3,0] := 'Depart time';
    sgResults.Cells[4,0] := 'Arrival date';
    sgResults.Cells[5,0] := 'Arrival time';
    sgResults.Cells[6,0] := 'Total price';
    sgResults.Cells[7,0] := '';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 4;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 9;

    result:=true;

  finally
    ini.free;
  end;
end;

function TForm1.initialiseren_Airbaltic: boolean;
var
  i:integer;
  ini : Tinifile;
  iniPath:string;
begin
  result:=false;
  try
    IniPath:=extractfiledir(Application.ExeName)+'\data\Airbaltic.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 10;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Forward flight #';
    sgResults.Cells[2,0] := 'Forward date';
    sgResults.Cells[3,0] := 'Forward time';
    sgResults.Cells[4,0] := 'Via forward';
    sgResults.Cells[5,0] := 'Return flight #';
    sgResults.Cells[6,0] := 'Return date';
    sgResults.Cells[7,0] := 'Return  time';
    sgResults.Cells[8,0] := 'Via return';
    sgResults.Cells[9,0] := 'Total price';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[I])>1) then
    begin
      if (strlDepartingFrom.Strings[I][1] = 's') then
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        strlDepartingFrom[I] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[I],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ',')
           or
          (strlDepartingFrom.Strings[I][Length(strlDepartingFrom.Strings[I])] = ';') then
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 1, Length(strlDepartingFrom[I])-1);
      end
      else
      begin
        strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
        if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
          strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
        strlDependences.Add(strlDepartingFrom[I]);
        strlDepartingFrom.Delete(I);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do
    begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 6;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 16;
//    chbFlexible.Checked := false;

//    dtDepartDate.DateTime := EncodeDate(2011,1,14);
//    dtReturnDate.DateTime := EncodeDate(2011,1,28);

    result:=true;

  finally
    ini.free;
  end;
end;

procedure TForm1.CopyDataToGridForBrusselsAirlines(strlData: TStringList);
var
  i : Integer;
  s, cell, new_cell,
  forward_date, forward_time,
  return_date, return_time: string;
begin
  // Prepare Grid
  sgResults.ColCount := 10;
  sgResults.ColWidths[0] := 60;
  sgResults.ColWidths[1] := 80;
  sgResults.ColWidths[2] := 70;
  sgResults.ColWidths[3] := 70;
  sgResults.ColWidths[4] := 60;
  sgResults.ColWidths[5] := 70;
  sgResults.ColWidths[6] := 70;
  sgResults.ColWidths[7] := 70;
  sgResults.ColWidths[8] := 60;
  sgResults.ColWidths[9] := 70;
  sgResults.RowCount := 2;

  for i := 0 to 10 do
    sgResults.Cells[i,1] := '';
  Self.Refresh;
  Application.ProcessMessages;

  if Assigned(strlData) and (strlData.Count > 0) then
  begin
    sgResults.RowCount := strlData.Count+1;
    for i := 1 to strlData.Count do
    begin
      s := strlData[i-1]+'|';

      // type
      sgResults.Cells[0,i] := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // forward depart_date
      forward_date := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // forward depart_time
      forward_time := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // forward arrival_date
      cell := Trim(forward_date);
      new_cell := Trim(Copy(s, 1, Pos('|', s)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[2,i] := cell;
      Delete(s, 1, Pos('|', s));

      // forward arrival_time
      cell := Trim(forward_time);
      new_cell := Trim(Copy(s, 1, Pos('|', s)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[3,i] := cell;
      Delete(s, 1, Pos('|', s));

      // forward flight no
      sgResults.Cells[1,i] := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // via forward
      sgResults.Cells[4,i] := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // Return ...
      // return depart_date
      return_date := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // return depart_time
      return_time := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // return arrival_date
      cell := Trim(return_date);
      new_cell := Trim(Copy(s, 1, Pos('|', s)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[6,i] := cell;
      Delete(s, 1, Pos('|', s));

      // return arrival_time
      cell := Trim(return_time);
      new_cell := Trim(Copy(s, 1, Pos('|', s)-1));
      if (new_cell <> '') and (cell <> new_cell) then
      begin
        if cell <> '' then
          cell := cell +'/';
        cell := cell + new_cell;
      end;
      sgResults.Cells[7,i] := cell;
      Delete(s, 1, Pos('|', s));

      // return flight no
      sgResults.Cells[5,i] := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));


      // via return
      sgResults.Cells[8,i] := Copy(s, 1, Pos('|', s)-1);
      Delete(s, 1, Pos('|', s));

      // total_price
      sgResults.Cells[9,i] := Copy(s, 1, Pos('|', s)-1);

    end;
  end;
end;

function TForm1.initialiseren_BrusselsAirlines: Boolean;
var
  i: Integer;
  ini : Tinifile;
  iniPath: string;
begin
  Result := False;
  try
    IniPath := ExtractFileDir(Application.ExeName)+'\data\BrusselsAirlines.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
    // language section: Grid
    sgResults.ColCount := 10;
    sgResults.Cells[0,0] := 'Type';
    sgResults.Cells[1,0] := 'Forward flight #';
    sgResults.Cells[2,0] := 'Forward date';
    sgResults.Cells[3,0] := 'Forward time';
    sgResults.Cells[4,0] := 'Via forward';
    sgResults.Cells[5,0] := 'Return flight #';
    sgResults.Cells[6,0] := 'Return date';
    sgResults.Cells[7,0] := 'Return  time';
    sgResults.Cells[8,0] := 'Via return';
    sgResults.Cells[9,0] := 'Total price';

    //May remove 40 lines calmly
    // but be sure cbDepartingFrom.Text and cbGoingTo.text store correct names of airports
    strlDepartingFrom.Clear;
    strlDependences.Clear;
    ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for i := strlDepartingFrom.Count-1 downto 0 do
    if (Length(strlDepartingFrom.Strings[i])>1) then
    begin
      if (strlDepartingFrom.Strings[i][1] = 's') then
      begin
        strlDepartingFrom[i] := Copy(strlDepartingFrom[i], 2, Length(strlDepartingFrom[i])-1);
        strlDepartingFrom[i] := Trim(StringReplace(StringReplace(StringReplace(
                strlDepartingFrom[i],
                '[','',[rfReplaceAll]),
                ']','',[rfReplaceAll]),
                ';',',',[rfReplaceAll]));
        if (strlDepartingFrom.Strings[i][Length(strlDepartingFrom.Strings[i])] = ',')
           or
          (strlDepartingFrom.Strings[i][Length(strlDepartingFrom.Strings[i])] = ';') then
          strlDepartingFrom[i] := Copy(strlDepartingFrom[i], 1, Length(strlDepartingFrom[i])-1);
      end
      else
      begin
        strlDepartingFrom[i] := Copy(strlDepartingFrom[i], 2, Length(strlDepartingFrom[i])-1);
        if strlDepartingFrom[i][Length(strlDepartingFrom[i])] <> ',' then
          strlDepartingFrom[i] := strlDepartingFrom[i] + ',';
        strlDependences.Add(strlDepartingFrom[i]);
        strlDepartingFrom.Delete(i);
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for i := 0 to strlDepartingFrom.Count - 1 do
      begin
        cbDepartingFrom.Items.Add(
        strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
           ' (' + strlDepartingFrom.Names[i] + ')' );
      end;
    cbDepartingFrom.ItemIndex := 18;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 16;

    Result := True;

  finally
    ini.Free;
  end;
end;

//einde function initialiseren_Corendon : boolean;

procedure TForm1.btnStartClick(Sender: TObject);
var
    vertrekkode,
    bestemmingkode : string;
    bestemmingen : string;
    Date_Depart, Date_Return:TDateTime;
    ini:TIniFile;
    IniPath:string;
    strlData: TStringList;
    i : integer;
    str : string;
    {--------------------------------------------------------------------------}
begin
    //May change 7 lines calmly according to your rules
    if seAdults.Value < seInfants.Value then
    begin
      ShowMessage('The number of infants cannot be greater than the number'
             +chr(10)+chr(13)+'of adults.  If you need to change the number of infants '
             +chr(10)+chr(13)+'non this booking, please contact the Reservations Centre.');
      exit;
    end;
    //May change 5 lines calmly according to your rules
    if (trunc(dtDepartDate.Date)>trunc(dtReturnDate.Date)) and rbReturn.Checked and not chbFlexible.Checked then
    begin
      ShowMessage('Depart date more than Return date');
      exit;
    end;

    //May remove 5 lines calmly
    date_depart := trunc(dtDepartDate.Date);
    if rbReturn.Checked then
      date_return := trunc(dtReturnDate.Date)
     else
      date_return := trunc(dtDepartDate.Date);
    //May change 9 lines according to rules of 'flexible dates'
    if chbFlexible.Checked then
    begin
      date_depart := date_depart - 2;
      date_return := date_return + 3;
      if trunc(date_depart)<trunc(Date) then
        date_depart:=Date;
      if trunc(date_return)<trunc(Date) then
        date_return:=Date;
    end;

    //May remove 5 lines calmly
    if not chbFlexible.Checked and
      (trunc(date_depart) = trunc(date_return)) then
    begin
      date_return := date_return+1 ;
    end;

    //Source
    vertrekkode:=cbDepartingFrom.text;
    vertrekkode:=copy(vertrekkode,length(vertrekkode)-3,3);


    //Source - possible the same algorithm  - you may remove 4 lines calmly
    vertrekkode := cbDepartingFrom.Text;
    while pos('(', vertrekkode) > 0 do
      delete(vertrekkode,1,pos('(', vertrekkode));
    vertrekkode := Trim(StringReplace(vertrekkode,')','',[rfReplaceAll]));

    bestemmingkode:=cbGoingTo.text;
    bestemmingkode:=copy(bestemmingkode,length(bestemmingkode)-3,3);

    // Destination - possible the same algorithm -  you may remove 4 lines calmly
    bestemmingkode := cbGoingTo.Text;
    while pos('(', bestemmingkode) > 0 do
      delete(bestemmingkode,1,pos('(', bestemmingkode));
    bestemmingkode := Trim(StringReplace(bestemmingkode,')','',[rfReplaceAll]));

    if  radiogroup1.itemindex=0 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\ryanair.ini';
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(extractfiledir(Application.ExeName)+'\data\ryanair.ini');
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen)=0 then begin ShowMessage('Something going wrong'); exit; end;
//      !!!!!!

//      strlData := TStringList.Create; //removed
  //        initialiseren_ryanair;    //removed

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      strldata:=GetRyanAir(
                rbReturn.checked,          //uit functieaanroep
                chbFlexible.checked,        //uit functieaanroep
                vertrekkode,    //uit functieaanroep
                date_Depart,        //uit functieaanroep
                bestemmingkode, //uit functieaanroep
                date_Return,         //uit functieaanroep
                seAdults.Value,             //uit scherm
                seChildren.Value,           //uit scherm
                seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
        //may change property of object sgResult according to your rules
        sgResults.Visible:=true;
    end;

    if radiogroup1.itemindex=1 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\airberlin.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;
//     !!!!!!

        //strlData.create;  incorrect
        strlData := TStringList.Create;
//        initialiseren_airberlin;

        //may change property of object sgResult according to your rules
        sgResults.Visible:=false;
        GetAirBerlin(strldata,
                rbReturn.checked,          //uit functieaanroep
                chbFlexible.checked,        //uit functieaanroep
                vertrekkode,    //uit functieaanroep
                date_depart,        //uit functieaanroep
                bestemmingkode, //uit functieaanroep
                date_return,         //uit functieaanroep
                seAdults.Value,             //uit scherm
                seChildren.Value,           //uit scherm
                seInfants.Value);     //uit scherm

        CopyDataToGrid(strlData);
        //may change property of object sgResult according to your rules
        sgResults.Visible:=true;
    end;

    // Corendon.com
    if radiogroup1.itemindex=2 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Corendon.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;
//     !!!!!!

        //strlData.create;  incorrect
        strlData := TStringList.Create;
//        initialiseren_airberlin;

        //may change property of object sgResult according to your rules
        sgResults.Visible:=false;
        GetCorendon(strldata,
                rbReturn.checked,          //uit functieaanroep
                chbFlexible.checked,        //uit functieaanroep
                vertrekkode,    //uit functieaanroep
                date_depart,        //uit functieaanroep
                bestemmingkode, //uit functieaanroep
                date_return,         //uit functieaanroep
                seAdults.Value,             //uit scherm
                seChildren.Value,           //uit scherm
                seInfants.Value);     //uit scherm

        CopyDataToGrid(strlData);
        //may change property of object sgResult according to your rules
        sgResults.Visible:=true;
    end;


    // Transavia.com
    if radiogroup1.itemindex=3 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Transavia.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;
      //     !!!!!!

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetTransavia(strldata,
              rbReturn.checked,          //uit functieaanroep
              chbFlexible.checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    // Jetairfly.com
    if radiogroup1.itemindex=4 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Jetairfly.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetJetairfly(strldata,
              rbReturn.checked,          //uit functieaanroep
              chbFlexible.checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    
    // www.flypgs.com
    if radiogroup1.itemindex=5 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Pegasus.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetPegasus(strldata,
              rbReturn.checked,          //uit functieaanroep
              chbFlexible.checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    
    // www.Vueling.com
    if radiogroup1.itemindex=6 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Vueling.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetVueling(strldata,
              rbReturn.checked,          //uit functieaanroep
              chbFlexible.checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value);     //uit scherm

      // Sort
      strldata.Sort;
      for i := 0 to strldata.Count - 1 do
      begin
        str := strldata[i];
        if pos('|',Str) > 0 then
          Delete(Str,1,pos('|',Str));
        strldata[i] := str;
      end;
      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;


    // www.Easyjet.com CHEP
    if radiogroup1.itemindex=7 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Easyjet.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetEasyjetCHEAP(strldata,
              rbReturn.checked,    //uit functieaanroep
              chbFlexible.checked, //uit functieaanroep
              vertrekkode,         //uit functieaanroep
              date_depart,         //uit functieaanroep
              bestemmingkode,      //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,      //uit scherm
              seChildren.Value,    //uit scherm
              seInfants.Value);     //uit scherm

      // Sort
      strldata.Sort;
      for i := 0 to strldata.Count - 1 do
      begin
        str := strldata[i];
        if pos('|',Str) > 0 then
          Delete(Str,1,pos('|',Str));
        strldata[i] := str;
      end;
      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    // www.Easyjet.com SLOW
    if radiogroup1.itemindex=8 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Easyjet.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetEasyjetSLOW(strldata,
              rbReturn.checked,    //uit functieaanroep
              chbFlexible.checked, //uit functieaanroep
              vertrekkode,         //uit functieaanroep
              date_depart,         //uit functieaanroep
              bestemmingkode,      //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,      //uit scherm
              seChildren.Value,    //uit scherm
              seInfants.Value);

      // Sort
      strldata.Sort;
      for i := 0 to strldata.Count - 1 do
      begin
        str := strldata[i];
        if pos('|',Str) > 0 then
          Delete(Str,1,pos('|',Str));
        strldata[i] := str;
      end;
      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    // www.Airbaltic.com
    if radiogroup1.itemindex=9 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Airbaltic.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
        Halt(0);
      end;
      ini := TIniFile.Create(IniPath);
      bestemmingen:=ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.free;
      if pos(bestemmingkode+',',bestemmingen+',')=0 then begin ShowMessage('Something going wrong'); exit; end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible:=false;
      GetAirbaltic(strldata,
              rbReturn.checked,          //uit functieaanroep
              chbFlexible.checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value,3);     //uit scherm

      // Sort
      strldata.Sort;
      for i := 0 to strldata.Count - 1 do
      begin
        str := strldata[i];
        if pos('|',Str) > 0 then
          Delete(Str,1,pos('|',Str));
        strldata[i] := str;
      end;
      CopyDataToGridForAirbaltic(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;

    // www.BrusselsAirlines.com
    if radiogroup1.itemindex = 10 then
    begin
      IniPath := ExtractFileDir(Application.ExeName)+'\data\BrusselsAirlines.ini';
      ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then
        begin
          MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
          Halt(0);
        end;
//      ini := TIniFile.Create(IniPath);
      bestemmingen := ini.ReadString('Dependences','a'+vertrekkode,'');
      ini.Free;
      if Pos(bestemmingkode+',',bestemmingen+',') = 0 then
        begin
          ShowMessage('Something going wrong');
          Exit;
        end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible := False;
      GetBrusselsAirlines(strldata,
              rbReturn.Checked,          //uit functieaanroep
              chbFlexible.Checked,        //uit functieaanroep
              vertrekkode,    //uit functieaanroep
              date_depart,        //uit functieaanroep
              bestemmingkode, //uit functieaanroep
              date_return,         //uit functieaanroep
              seAdults.Value,             //uit scherm
              seChildren.Value,           //uit scherm
              seInfants.Value);     //uit scherm

      // Sort
//      strldata.Sort;
      for i := 0 to strldata.Count - 1 do
        begin
          str := strldata[i];
          if Pos('|', Str) > 0 then
            Delete(Str, 1, Pos('|', Str));
          strldata[i] := str;
        end;

      CopyDataToGridForBrusselsAirlines(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible := True;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Caption := 'Testing BrusselsAirlines';
  Form1.lbl1.Caption := '';

  //May remove 4 lines calmly or change to yours visible components
  strlDepartingFrom := TStringList.Create; //list of 'from' airports
  strlDependences := TStringList.Create;   //list of 'to' airports
  dtDepartDate.Date := Date+1;             // departure date
  dtReturnDate.Date := Date+7;             // return date

  // Default Date = 'today'/'next week'
end;

//May remove whole procedure, 31 lines calmly
procedure TForm1.cbDepartingFromChange(Sender: TObject);
var
  strSelectedValue,strDependences,strDependence : string;
  cblbGoingToTempValues : TStringList;
  i: Integer;
  ini: TIniFile;
  IniPath, name: string;
begin
//May remove whole procedure, 27 lines calmly
  strSelectedValue := cbDepartingFrom.Text;
  while pos('(', strSelectedValue) > 0 do
    delete(strSelectedValue,1,pos('(', strSelectedValue));
  strSelectedValue := Trim(StringReplace(strSelectedValue,')','',[rfReplaceAll]));
  cblbGoingToTempValues := TStringList.Create;
  try
    // Data => StringList
    strDependences := strlDependences.Values[strSelectedValue];
    while pos(',',strDependences) > 0 do
    begin
      strDependence := copy(strDependences, 1, pos(',',strDependences)-1);
      delete(strDependences, 1, pos(',',strDependences));
      cblbGoingToTempValues.Add(
              strlDepartingFrom.Values[strDependence]+' ('+strDependence+')');
    end;

    // it is necessary for BrusselsAirlines, since some dependences without names
    strDependence := '';
    IniPath := ExtractFileDir(Application.ExeName) + '\data\BrusselsAirlines.ini';
    ini := TIniFile.Create(IniPath);
    for i := 0 to cblbGoingToTempValues.Count-1 do
      if (cblbGoingToTempValues[i] <> '') and (cblbGoingToTempValues[i][1] = ' ')
        and (cblbGoingToTempValues[i][2] = '(') then
        begin
          strDependence := Copy(cblbGoingToTempValues[i], 3, 3);
          name := ini.ReadString('Dependences_without_name', strDependence, '');
          cblbGoingToTempValues[i] := name + ' (' + strDependence + ')';
        end;
    ini.Free;

    // sort
    cblbGoingToTempValues.sort;
    // StringList => Control
    cbGoingTo.Items.Clear;
    cbGoingTo.Items.Assign(cblbGoingToTempValues);
    cbGoingTo.ItemIndex := -1;
  finally
    cblbGoingToTempValues.destroy;
  end;
end;

//May remove whole procedure, 5 lines calmly
procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  if radiogroup1.itemindex=0 then
    initialiseren_Ryanair;
  if radiogroup1.itemindex=1 then
    initialiseren_Airberlin;
  if radiogroup1.itemindex=2 then
    initialiseren_Corendon;
  if radiogroup1.itemindex=3 then
    initialiseren_Transavia;
  if radiogroup1.itemindex=4 then
    initialiseren_Jetairfly;
  if radiogroup1.itemindex=5 then
    initialiseren_Pegasus;
  if radiogroup1.itemindex=6 then
    initialiseren_Vueling;
  if radiogroup1.itemindex=7 then
    initialiseren_Easyjet;
  if radiogroup1.itemindex=8 then
    initialiseren_Easyjet;
  if radiogroup1.itemindex=9 then
    initialiseren_Airbaltic;
  if radiogroup1.itemindex = 10 then
    initialiseren_BrusselsAirlines;
end;

procedure TForm1.chk1Click(Sender: TObject);
begin
  if ParamWebBrowser <> nil then
    case chk1.Checked of
      True:
        begin
          ParamWebBrowser.Height := Form1.ClientHeight - pn_controls.Height;
          ParamWebBrowser.Visible := True;
        end;
      False:
        begin
          ParamWebBrowser.Height := 1;
          ParamWebBrowser.Visible := False;
        end;
    end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if ParamWebBrowser <> nil then
    if chk1.Checked then
      begin
        ParamWebBrowser.Height := Form1.ClientHeight - pn_controls.Height;
        ParamWebBrowser.Visible := True;
      end;
end;

end.
