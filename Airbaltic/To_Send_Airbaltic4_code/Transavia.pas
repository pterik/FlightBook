unit Transavia;
interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetTransavia(
            paramOutData: TStringList;
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer);
function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;

const
  constIsDemoMode = false;

implementation

uses Forms, Controls, Dialogs;

procedure GetTransavia(
            paramOutData: TStringList;
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer);
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;

  i,j,k,table_index,table_index_price : integer;
  strHTML,strRow : String;
  htmlRow : IHTMLTableRow;
  DocSelect   : IHTMLElementCollection;
  DocElement  : IHtmlElement;
  Doc         : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  total_price,
  str, via : string;
  depart_date_dt, arrival_date_dt : TDateTime;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  dwDateConvertDay,dwDateConvertMonth,dwDateConvertYear : word;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  TransaviaStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
  dbl : double;

begin
  // set english month names
  ShortMonthNames[1] := 'Jan';
  ShortMonthNames[2] := 'Feb';
  ShortMonthNames[3] := 'Mar';
  ShortMonthNames[4] := 'Apr';
  ShortMonthNames[5] := 'May';
  ShortMonthNames[6] := 'Jun';
  ShortMonthNames[7] := 'Jul';
  ShortMonthNames[8] := 'Aug';
  ShortMonthNames[9] := 'Sep';
  ShortMonthNames[10] := 'Oct';
  ShortMonthNames[11] := 'Nov';
  ShortMonthNames[12] := 'Dec';

  try
// Don`t forget to insert   uses Forms;  above
    ParamWebBrowser := TWebBrowser.Create(Application.mainForm);
    TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser'+IntToStr(Application.mainform.ComponentCount);
    TWinControl(ParamWebBrowser).Parent:= Application.mainForm;
    ParamWebBrowser.Height := 800;
    ParamWebBrowser.Visible := true;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := true;
    ParamWebBrowser.Update;
    Application.ProcessMessages;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Transavia.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    TransaviaStartURL  := ini.ReadString('main','TransaviaStartURL', 'nil');
    ini.free;
    if TransaviaStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter TransaviaStartURL in Transavia.ini');
      exit; //please change the code according to your rules
    end;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    mainPageTime := 0;
    totalPriceTime := 0;
    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart;

      //forward
      EncodedDataString :=
        'lang=en&'+
//        'country=EU&'+
//        'country=EU&'+
        'adults='+IntToStr(adults)+'&'+
        'children='+IntToStr(children)+'&'+
        'infants='+IntToStr(infants)+'&'+
        'from='+airport_depart+'&'+
        'ojTo=&'+
        'fromDay='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
        'fromMonth='+     DateTimeToStringRet('yyyy',loc_date_depart)+'-'+
                          DateTimeToStringRet('mm',loc_date_depart)+'&'+
        'to='+airport_destination+'&'+
        'ojFrom=&'+
        'toDay='+DateTimeToStringRet('dd',loc_date_return)+'&'+
        'toMonth='+     DateTimeToStringRet('yyyy',loc_date_return)+'-'+
                          DateTimeToStringRet('mm',loc_date_return)+'&'+
        'trip='+if_str(returnflight,'retour','single')+'&'+
        'jsform=true';

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      ticks := GetTickCount;
      // Naviagate to blank page
      paramWebBrowser.Navigate('about:blank');
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      paramWebBrowser.Navigate(TransaviaStartURL+EncodedDataString, EmptyParam, EmptyParam, EmptyParam, Headers);
        // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      mainPageTime := mainPageTime+(GetTickCount-ticks);

      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
        for i := 0 to DocSelect.length-1 do
        begin
          DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
          if Pos(UpperCase('flightday'), UpperCase(DocElement.className))>0 then
          begin
            strHTML := DocElement.innerHTML;

            if Pos(UpperCase(' '+DateTimeToStringRet('dd',loc_date_depart)+
                             ' '+DateTimeToStringRet('mmm',loc_date_depart)
                            ), UpperCase(strHTML))>0 then
            begin
              flight_type := '-';
              if DocElement.parentElement <> nil then
                if UpperCase('hc') = UpperCase(DocElement.parentElement.id) then
                  flight_type := 'forward';
              if DocElement.parentElement <> nil then
                if DocElement.parentElement.parentElement <> nil then
                  if UpperCase('hc') = UpperCase(DocElement.parentElement.parentElement.id) then
                    flight_type := 'forward';
              if DocElement.parentElement <> nil then
                if UpperCase('tc') = UpperCase(DocElement.parentElement.id) then
                  flight_type := 'reverse';
              if DocElement.parentElement <> nil then
                if DocElement.parentElement.parentElement <> nil then
                  if UpperCase('backfl') = UpperCase(DocElement.parentElement.parentElement.id) then
                    flight_type := 'reverse';

              str := strHTML+'|||'+' '+DateTimeToStringRet('dd',loc_date_return)+
                               ' '+DateTimeToStringRet('mmm',loc_date_return)+'|||';

              // date
              if pos('</H3>',UpperCase(strHTML)) >0 then
                str := Copy(strHTML,1,pos('</H3>',UpperCase(strHTML)));
              if pos('>',str) >0 then
                Delete(str,1,pos('>',str));
              if pos(' ',str) >0 then
                Delete(str,1,pos(' ',str));
              if pos('<',str) >0 then
                str := Copy(str,1,pos('<',str)-1);
              depart_date := str;
              arrival_date := str;

              while pos('</LI>',UpperCase(strHTML)) >0 do
              begin
                // flight_no / Time
                str := strHTML;
                if pos('TIMERS',UpperCase(str)) >0 then
                  Delete(str,1,pos('TIMERS',UpperCase(str)));
                if pos('>',str) >0 then
                  Delete(str,1,pos('>',str));
                if pos('|',str) >0 then
                  Delete(str,1,pos('|',str));
                str := StringReplace(str, '"', '',[rfReplaceAll, rfIgnoreCase]);
                flight_no := Copy(str,1,pos('>',str)-1);
                // Time
                if Pos('DEP',UpperCase(str)) >0 then
                  depart_time := Copy(str,1,Pos('DEP',UpperCase(str))-1);
                if Pos('ARR',UpperCase(str)) >0 then
                  arrival_time := Copy(str,1,Pos('ARR',UpperCase(str))-1);
                depart_time := StringReplace(depart_time, ' ', '',[rfReplaceAll, rfIgnoreCase]);
                arrival_time := StringReplace(arrival_time, ' ', '',[rfReplaceAll, rfIgnoreCase]);
                depart_time := StringReplace(depart_time, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                arrival_time := StringReplace(arrival_time, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                while Pos('>',depart_time) >0 do
                  Delete(depart_time,1,Pos('>',depart_time));
                while Pos('>',arrival_time) >0 do
                  Delete(arrival_time,1,Pos('>',arrival_time));

                // Price
                str := strHTML;
                if pos('</DIV>',UpperCase(str)) >0 then
                  Delete(str,1,pos('</DIV>',UpperCase(str)));
                if pos('LABEL',UpperCase(str)) >0 then
                  Delete(str,1,pos('LABEL',UpperCase(str))+5);
                if pos('>',str) >0 then
                  Delete(str,1,pos('>',str));
                if pos('</LABEL>',UpperCase(str)) >0 then
                  str := Copy(str,1,pos('</LABEL>',UpperCase(str))-1);
                str := StringReplace(str, '<b>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '</b>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '<span>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '</span>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '<strong>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '</strong>', '',[rfReplaceAll, rfIgnoreCase]);
                str := StringReplace(str, '  ', ' ',[rfReplaceAll, rfIgnoreCase]);
                total_price := Trim(str);

                //if IsSuccess then
                  paramOutData.add(
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      total_price
                      );

                Delete(strHTML,1,pos('</LI>',UpperCase(strHTML))+5);
              end;  // <li>

            end;
          end;
        end;

        Doc.close;
      end
       else
        paramOutData.Add('InternalError');

      if (loc_date_depart = date_return) then
        break;

      if flexible then
        loc_date_depart := loc_date_depart + 1
       else
        loc_date_depart := date_return;
    end;

  finally
    ParamWebBrowser.Free;
  end;
end;

function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;

function TryStrToInt(str : string; out Value: Integer) : Boolean;
begin
  try
    Value := StrToInt(str);
    result := true;
  except
    result := false;
  end;
end;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
begin
  try
    Value := StrToFloat(str);
    result := true;
  except
    result := false;
  end;
end;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
begin
  if Expression then
    Result := TrueValue
   else
    Result := FalseValue;
end;

end.
