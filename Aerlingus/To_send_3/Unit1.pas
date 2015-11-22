unit Unit1;

interface

uses
  SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls, Spin, ComCtrls, Buttons, ExtCtrls, Grids, SHDocVw, inifiles;

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
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbDepartingFromChange(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure dtDepartDateChange(Sender: TObject);
    procedure dtReturnDateChange(Sender: TObject);
  private
//May remove 2 variables calmly
    strlDepartingFrom : TStringList;
    strlDependences : TStringList;

    procedure CopyDataToGrid(strlData: TStringList);
    function Init_ryanair: Boolean;
    function Init_airberlin: Boolean;
    function Init_Corendon: Boolean;
    function Init_Transavia: Boolean;
    function Init_Jetairfly: Boolean;
    function Init_Pegasus: Boolean;
    function Init_Vueling: Boolean;
    function Init_Wizzair: Boolean;
    function Init_AerLingus: Boolean;

  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses
   Ryanair, Airberlin, Corendon, Transavia, Jetairfly, Pegasus, WizzAir, AerLingus;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //May remove 4 lines calmly or change to yours visible components
  strlDepartingFrom := TStringList.Create; //list of 'from' airports
  strlDependences := TStringList.Create;   //list of 'to' airports
  dtDepartDate.Date := Date+1;             // departure date
  dtReturnDate.Date := Date+7;             // return date

  // Default Date = 'today'/'next week'
  // Default WizzAir
  RadioGroup1.ItemIndex := 8;
  RadioGroup1Click(RadioGroup1);
end;

//May remove whole procedure, 31 lines calmly
procedure TForm1.cbDepartingFromChange(Sender: TObject);
var
  strSelectedValue,strDependences,strDependence : string;
  cblbGoingToTempValues : TStringList;
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

//May remove whole procedure, 5 lines calmly
procedure TForm1.RadioGroup1Click(Sender: TObject);
begin
  if radiogroup1.itemindex=0 then
    Init_Ryanair;
  if radiogroup1.itemindex=1 then
    Init_Airberlin;
  if radiogroup1.itemindex=2 then
    Init_Corendon;
  if radiogroup1.itemindex=3 then
    Init_Transavia;
  if radiogroup1.itemindex=4 then
    Init_Jetairfly;
  if radiogroup1.itemindex=5 then
    Init_Pegasus;
  if radiogroup1.itemindex=6 then
    Init_Vueling;
  if RadioGroup1.ItemIndex = 7 then
    Init_Wizzair;
  if RadioGroup1.ItemIndex = 8 then
    Init_AerLingus;
end;

////////////////////////////////////////////////////////

procedure TForm1.CopyDataToGrid(strlData: TStringList);
var
  I : Integer;
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



function TForm1.Init_ryanair : Boolean;
var
   I: Integer;
   Ini : TIniFile;
   IniPath: string;
begin
  //result:=false;
  IniPath := ExtractFileDir(Application.ExeName) + '\data\ryanair.ini';
  if not FileExists(IniPath) then begin
    MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
    Halt(0);
  end;

  Ini := TIniFile.Create(IniPath);
  try
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
    for I := strlDepartingFrom.Count-1 downto 0 do begin
      if Length(strlDepartingFrom.Strings[I])>1 then begin
        if strlDepartingFrom.Strings[I][1] = 's' then begin
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
        else begin
          strlDepartingFrom[I] := Copy(strlDepartingFrom[I], 2, Length(strlDepartingFrom[I])-1);
          if strlDepartingFrom[I][Length(strlDepartingFrom[I])] <> ',' then
            strlDepartingFrom[I] := strlDepartingFrom[I] + ',';
          strlDependences.Add(strlDepartingFrom[I]);
          strlDepartingFrom.Delete(I);
        end;
      end;
    end;
    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do begin
      cbDepartingFrom.Items.Add(
      strlDepartingFrom.Values[strlDepartingFrom.Names[i]]+
         ' (' + strlDepartingFrom.Names[i] + ')' );
    end;
    cbDepartingFrom.ItemIndex := 26;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 27;

    Result := True;
  finally
    Ini.Free;
  end;
end;

function TForm1.Init_Transavia: Boolean;
var
  i:Integer;
  ini : Tinifile;
  iniPath:string;
begin
  //result:=false;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Transavia.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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

//einde {sub}function Init : Boolean;

    {--------------------------------------------------------------------------}

function TForm1.Init_airberlin : Boolean;
var
  i:Integer;
  ini : Tinifile;
  iniPath:string;
begin
//result:=false;
IniPath:=extractfiledir(Application.ExeName)+'\data\airberlin.ini';
if not FileExists(IniPath) then
  begin
    MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
    Halt(0);
  end;
ini := TIniFile.Create(IniPath);
try
// language section: Grid
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

//        if pos(bestemmingkode+',',bestemmingen)=0 then exit;

//       !!!!!

        result:=true;
  finally
    ini.free;
  end;
end;

function TForm1.Init_Corendon: Boolean;
var
  i:Integer;
  ini : Tinifile;
  iniPath:string;
begin
//  result:=false;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Corendon.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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

function TForm1.Init_Jetairfly: Boolean;
var
  i:Integer;
  ini : Tinifile;
  iniPath:string;
begin
//  result:=false;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Jetairfly.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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

function TForm1.Init_Pegasus: Boolean;
var
  i:Integer;
  ini : Tinifile;
  iniPath:string;
begin
//  result:=false;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Pegasus.ini';
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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

function TForm1.Init_Vueling: Boolean;
var
  I: Integer;
  Ini : TIniFile;
  IniPath: string;
begin
  //result:=false;
  IniPath := ExtractFileDir(Application.ExeName) + '\data\Vueling.ini';
    if not FileExists(IniPath) then begin
      MessageDlg('Unable to proceed, can`t find file'#13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
      Halt(0);
    end;
  Ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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
    if (Length(strlDepartingFrom.Strings[I])>1) then begin
      if (strlDepartingFrom.Strings[I][1] = 's') then begin
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
    Ini.free;
  end;
end;

function TForm1.Init_Wizzair: Boolean;
var
  I: Integer;
  Ini : TIniFile;
  IniPath: string;
  S: string;
begin
  //Result := False;
  IniPath := ExtractFileDir(Application.ExeName)+'\data\WizzAir.ini';
  if not FileExists(IniPath) then begin
    MessageDlg('Unable to proceed, can`t find file' + #13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
    Halt(0);
  end;

  Ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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
    Ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do begin
      if (Length(strlDepartingFrom.Strings[i]) > 1) then begin
        S := strlDepartingFrom.Strings[i];
        if (S[1] = 's') then begin
          S := Trim(Copy(S, 2, Length(S)-1));
          S := StringReplace(S, '[', '', [rfReplaceAll]);
          S := StringReplace(S, ']', '', [rfReplaceAll]);
          S := StringReplace(S, ';', ',', [rfReplaceAll]);
          if (S[Length(S)] in [',', ';']) then
            S := Copy(S, 1, Length(S) - 1);
          strlDepartingFrom[i] := S;
        end
        else begin
          S := Copy(S, 2, Length(S)-1);
          if S[Length(S)] <> ',' then
            S := S + ',';
          strlDependences.Add(S);
          strlDepartingFrom.Delete(I);
        end;
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do begin
      with strlDepartingFrom do begin
        cbDepartingFrom.Items.Add(Values[Names[I]] + ' (' + Names[I] + ')');
      end;
    end;
    cbDepartingFrom.ItemIndex := 11;
    cbDepartingFromChange(cbDepartingFrom);
    cbGoingTo.ItemIndex := 1;

    Result := True;
  finally
    Ini.Free;
  end;
end;

function TForm1.Init_AerLingus: Boolean;
var
  I: Integer;
  Ini : TIniFile;
  IniPath: string;
  S: string;
begin
  //Result := False;
  IniPath := ExtractFileDir(Application.ExeName)+'\data\AerLingus.ini';
  if not FileExists(IniPath) then begin
    MessageDlg('Unable to proceed, can`t find file' + #13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
    Halt(0);
  end;

  Ini := TIniFile.Create(IniPath);
  try
    // language section: Grid
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
    Ini.ReadSectionValues('Dependences', strlDepartingFrom);
    for I := strlDepartingFrom.Count-1 downto 0 do begin
      if (Length(strlDepartingFrom.Strings[i]) > 1) then begin
        S := strlDepartingFrom.Strings[i];
        if (S[1] = 's') then begin
          S := Trim(Copy(S, 2, Length(S)-1));
          S := StringReplace(S, '[', '', [rfReplaceAll]);
          S := StringReplace(S, ']', '', [rfReplaceAll]);
          S := StringReplace(S, ';', ',', [rfReplaceAll]);
          if (S[Length(S)] in [',', ';']) then
            S := Copy(S, 1, Length(S) - 1);
          strlDepartingFrom[i] := S;
        end
        else begin
          S := Copy(S, 2, Length(S)-1);
          if S[Length(S)] <> ',' then
            S := S + ',';
          strlDependences.Add(S);
          strlDepartingFrom.Delete(I);
        end;
      end;
    end;

    cbDepartingFrom.Items.Clear;
    for I := 0 to strlDepartingFrom.Count - 1 do begin
      with strlDepartingFrom do begin
        cbDepartingFrom.Items.Add(Values[Names[I]] + ' (' + Names[I] + ')');
      end;
    end;
    with cbDepartingFrom do
      ItemIndex:= Items.IndexOf('Amsterdam (AMS)');
    cbDepartingFromChange(cbDepartingFrom);

    with cbGoingTo do
      ItemIndex:= Items.IndexOf('Dublin (DUB)');

    dtDepartDate.DateTime:= EncodeDate(2011, 4, 10);
    dtReturnDate.DateTime:= dtDepartDate.DateTime + 10;

    chbFlexible.Checked := False;
    seAdults.Value:= 2;
    seChildren.Value:= 2;
    seInfants.Value:= 2;

    Result := True;
  finally
    Ini.Free;
  end;
end;

//einde function Init_Corendon : Boolean;

procedure TForm1.btnStartClick(Sender: TObject);
var
    vertrekkode, bestemmingkode: string;
    bestemmingen: string;
    Date_Depart, Date_Return: TDateTime;
    ini: TIniFile;
    IniPath: string;
    strlData: TStringList;
    {--------------------------------------------------------------------------}
begin
    //May change 7 lines calmly according to your rules
    if seAdults.Value < seInfants.Value then begin
      ShowMessage('The number of infants cannot be greater than the number'
             +chr(10)+chr(13)+'of adults.  If you need to change the number of infants '
             +chr(10)+chr(13)+'non this booking, please contact the Reservations Centre.');
      Exit;
    end;
    //May change 5 lines calmly according to your rules
    if (Trunc(dtDepartDate.Date) > Trunc(dtReturnDate.Date))
      and rbReturn.Checked and not chbFlexible.Checked then
    begin
      ShowMessage('Depart date more than Return date');
      Exit;
    end;

    //May remove 5 lines calmly
    date_depart := Trunc(dtDepartDate.Date);
    if rbReturn.Checked then
      date_return := Trunc(dtReturnDate.Date)
    else
      date_return := Trunc(dtDepartDate.Date);
    //May change 9 lines according to rules of 'flexible dates'
    if chbFlexible.Checked then begin
      date_depart := date_depart - 2;
      date_return := date_return + 3;
      if Trunc(date_depart) < Trunc(Date) then
        date_depart := Date;
      if Trunc(date_return) < Trunc(Date) then
        date_return := Date;
    end;

    //May remove 5 lines calmly
    if not chbFlexible.Checked and (Trunc(date_depart) = Trunc(date_return)) then
      Date_Return := Date_Return + 1;

    //Source
    //vertrekkode := cbDepartingFrom.Text;
    //vertrekkode := Copy(vertrekkode, Length(vertrekkode) - 3, 3);

    //Source - possible the same algorithm  - you may remove 4 lines calmly
    vertrekkode := cbDepartingFrom.Text;
    while Pos('(', vertrekkode) > 0 do
      Delete(vertrekkode, 1, Pos('(', vertrekkode));
    vertrekkode := Trim(StringReplace(vertrekkode,')', '', [rfReplaceAll]));

    //bestemmingkode := cbGoingTo.Text;
    //bestemmingkode := Copy(bestemmingkode, Length(bestemmingkode) - 3, 3);

    // Destination - possible the same algorithm -  you may remove 4 lines calmly
    bestemmingkode := cbGoingTo.Text;
    while Pos('(', bestemmingkode) > 0 do
      Delete(bestemmingkode, 1, Pos('(', bestemmingkode));
    bestemmingkode := Trim(StringReplace(bestemmingkode,')', '', [rfReplaceAll]));

    {.$REGION 'Ryanair'}
      if radiogroup1.itemindex = 0 then begin
        IniPath := ExtractFileDir(Application.ExeName) + '\data\ryanair.ini';
        // change the verification below according to your rules
        if not FileExists(IniPath) then begin
          MessageDlg('Unable to proceed, can`t find file'#13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
          Halt(0);
        end;
        Ini := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\data\ryanair.ini');
        try
          bestemmingen := Ini.ReadString('Dependences','a' + vertrekkode, '');
        finally
          Ini.Free;
        end;
        if Pos(bestemmingkode + ',', bestemmingen) = 0 then begin
          ShowMessage('Something going wrong');
          Exit;
        end;
  //      !!!!!!
  
  //      strlData := TStringList.Create; //removed
    //        Init_ryanair;    //removed
  
        //may change property of object sgResult according to your rules
        sgResults.Visible := False;
        strldata := GetRyanAir(
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
          sgResults.Visible := True;
      end;
  
    {.$ENDREGION}
    
    {.$REGION 'AirBerlin'}
    if radiogroup1.itemindex = 1 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\airberlin.ini';
      //Ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then begin
        MessageDlg('Unable to proceed, can`t find file'#13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
        Halt(0);
      end;
      Ini := TIniFile.Create(IniPath);
      try
        bestemmingen := Ini.ReadString('Dependences','a' + vertrekkode, '');
      finally
        Ini.Free;
      end;
      if Pos(bestemmingkode + ',', bestemmingen + ',') = 0 then begin
        ShowMessage('Something going wrong');
        Exit;
      end;
//     !!!!!!

        //strlData.create;  incorrect
      strlData := TStringList.Create;
//        Init_airberlin;

        //may change property of object sgResult according to your rules
        sgResults.Visible := False;
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
        sgResults.Visible := True;
    end;
    {.$ENDREGION}

    {.$REGION 'Corendon.com'}

    // Corendon.com
    if radiogroup1.itemindex = 2 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\Corendon.ini';
      // change the verification below according to your rules
      if not FileExists(IniPath) then
      begin
        MessageDlg('Unable to proceed, can`t find file'#13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
        Halt(0);
      end;
      Ini := TIniFile.Create(IniPath);
      try
        bestemmingen := Ini.ReadString('Dependences','a' + vertrekkode, '');
      finally
        Ini.free;
      end;
      if Pos(bestemmingkode + ',', bestemmingen + ',') = 0 then begin
        ShowMessage('Something going wrong');
        Exit;
      end;
//     !!!!!!

        //strlData.create;  incorrect
        strlData := TStringList.Create;
//        Init_airberlin;

        //may change property of object sgResult according to your rules
        sgResults.Visible := False;
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
        sgResults.Visible := True;
    end;

    {.$ENDREGION}

    {.$REGION 'Transavia.com'}

    // Transavia.com
    if radiogroup1.itemindex = 3 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\Transavia.ini';
      //Ini := TIniFile.Create(IniPath);
      // change the verification below according to your rules
      if not FileExists(IniPath) then begin
        MessageDlg('Unable to proceed, can`t find file'#13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
        Halt(0);
      end;
      Ini := TIniFile.Create(IniPath);
      try
        bestemmingen := Ini.ReadString('Dependences','a' + vertrekkode, '');
      finally
        Ini.Free;
      end;
      if Pos(bestemmingkode + ',', bestemmingen + ',') = 0 then begin
        ShowMessage('Something going wrong');
        Exit;
      end;
      //     !!!!!!

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible := False;
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
      sgResults.Visible := True;
    end;
    {.$ENDREGION}


    {.$REGION 'Jetairfly.com'}

    // Jetairfly.com
    if radiogroup1.itemindex = 4 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\Jetairfly.ini';
      //ini := TIniFile.Create(IniPath);
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

    {.$ENDREGION}

    {.$REGION 'www.flypgs.com'}

    // www.flypgs.com
    if radiogroup1.itemindex=5 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Pegasus.ini';
      //ini := TIniFile.Create(IniPath);
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

    {.$ENDREGION}

    {.$REGION 'www.Vueling.com'}

    // www.Vueling.com
    if radiogroup1.itemindex=6 then
    begin
      IniPath:=extractfiledir(Application.ExeName)+'\data\Vueling.ini';
      //ini := TIniFile.Create(IniPath);
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

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible:=true;
    end;
    {.$ENDREGION}

    {.$REGION 'www.WizzAir.com'}

    // www.WizzAir.com
    if radiogroup1.itemindex = 7 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\WizzAir.ini';
      // change the verification below according to your rules
      if not FileExists(IniPath) then begin
        MessageDlg('Unable to proceed, can`t find file' + #13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
        Halt(0);
      end;

      Ini := TIniFile.Create(IniPath);
      try
        bestemmingen := Ini.ReadString('Dependences', 'a' + vertrekkode, '');
      finally
        Ini.Free;
      end;

      if Pos(bestemmingkode + ',' , bestemmingen + ',') = 0 then begin
        ShowMessage('Something going wrong');
        Exit;
      end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible := False;
      GetVueling(strldata,
          rbReturn.Checked,          //uit functieaanroep
          chbFlexible.Checked,        //uit functieaanroep
          vertrekkode,    //uit functieaanroep
          date_depart,        //uit functieaanroep
          bestemmingkode, //uit functieaanroep
          date_return,         //uit functieaanroep
          seAdults.Value,             //uit scherm
          seChildren.Value,           //uit scherm
          seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible := True;
    end;
    {.$ENDREGION}


    {.$REGION 'www.AerLingus.com'}

    // www.AerLingus.com
    if radiogroup1.itemindex = 8 then begin
      IniPath := ExtractFileDir(Application.ExeName) + '\data\AerLingus.ini';
      // change the verification below according to your rules
      if not FileExists(IniPath) then begin
        MessageDlg('Unable to proceed, can`t find file' + #13#10 + '"' + IniPath + '"', mtError, [mbOK], 0);
        Halt(0);
      end;

      Ini := TIniFile.Create(IniPath);
      try
        bestemmingen := Ini.ReadString('Dependences', 'a' + vertrekkode, '');
      finally
        Ini.Free;
      end;

      if Pos(bestemmingkode + ',' , bestemmingen + ',') = 0 then begin
        ShowMessage('Something going wrong');
        Exit;
      end;


    //May remove 5 lines calmly
    date_depart := Trunc(dtDepartDate.Date);
    if rbReturn.Checked then
      date_return:= Trunc(dtReturnDate.Date)
    else
      date_return:= Trunc(dtDepartDate.Date);
    //May change 9 lines according to rules of 'flexible dates'
    if chbFlexible.Checked then begin
      date_depart:= date_depart - 2;
      date_return:= date_return + 3;
      if Trunc(date_depart) < Trunc(Date) then
        date_depart:= Date;
      if Trunc(date_return) < Trunc(Date) then
        date_return:= Date;
    end;

      //strlData.create;  incorrect
      strlData := TStringList.Create;

      //may change property of object sgResult according to your rules
      sgResults.Visible := False;
      GetAerLingus(strldata,
          rbReturn.Checked,          //uit functieaanroep
          chbFlexible.Checked,        //uit functieaanroep
          vertrekkode,    //uit functieaanroep
          date_depart,        //uit functieaanroep
          bestemmingkode, //uit functieaanroep
          date_return,         //uit functieaanroep
          seAdults.Value,             //uit scherm
          seChildren.Value,           //uit scherm
          seInfants.Value);     //uit scherm

      CopyDataToGrid(strlData);
      //may change property of object sgResult according to your rules
      sgResults.Visible := True;
    end;
    {.$ENDREGION}
end;

end.
