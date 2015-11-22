unit Pegasus;
interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetPegasus(
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

procedure GetPegasus(
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

  i,j,k,div_index,innerdiv_index : integer;
  strHTML        : String;
  DocSelect      : IHTMLElementCollection;
  DocElement     : IHtmlElement;
  DocSelectDiv   : IHTMLElementCollection;
  DocElementDiv  : IHTMLElement;
  DocSelectInnerDiv   : IHTMLElementCollection;
  DocElementInnerDiv  : IHTMLElement;
  DocElementFullTotalFare : IHTMLElement;
  Doc            : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str, via : string;
  price, last_forward_price : double;
  depart_date_dt,
  arrival_date_dt : TDateTime;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  dwDateConvertDay,dwDateConvertMonth,dwDateConvertYear : word;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  PegasusStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
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

  ParamWebBrowser := TWebBrowser.Create(Application.mainForm);
  try
// Don`t forget to insert   uses Forms;  above
    TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser'+IntToStr(Application.mainform.ComponentCount);
    TWinControl(ParamWebBrowser).Parent:= Application.mainForm;
    ParamWebBrowser.Height := 800;
    ParamWebBrowser.Visible := true;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := false;
    ParamWebBrowser.Update;
    Application.HandleMessage;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Pegasus.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    PegasusStartURL  := ini.ReadString('main','PegasusStartURL', 'nil');
    ini.free;
    if PegasusStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter PegasusStartURL in Pegasus.ini');
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
'TRIPTYPE='+if_str(returnflight,'R','O')+'&'+
'DEPPORT='+airport_depart+'&'+
'ARRPORT='+airport_destination+'&'+
//'SEGMENTTYPE=10&'+
'OnlineTicket$ddlGidisGun='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
'OnlineTicket$ddlGidisAyYil='+DateTimeToStringRet('mm',loc_date_depart)+'-'+
                              DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
'DEPDATE='+DateTimeToStringRet('dd',loc_date_depart)+'/'+
           DateTimeToStringRet('mm',loc_date_depart)+'/'+
           DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
'OnlineTicket$ddlDonusGun='+DateTimeToStringRet('dd',loc_date_return)+'&'+
'OnlineTicket$ddlDonusAyYil='+DateTimeToStringRet('mm',loc_date_return)+'-'+
                              DateTimeToStringRet('yyyy',loc_date_return)+'&'+
'RETDATE='+DateTimeToStringRet('dd',loc_date_return)+'/'+
           DateTimeToStringRet('mm',loc_date_return)+'/'+
           DateTimeToStringRet('yyyy',loc_date_return)+'&'+
'ADULT='+IntToStr(adults)+'&'+
'CHILD='+IntToStr(children)+'&'+
'INFANT='+IntToStr(infants)+'&'+
'STUDENT=0&'+
'SOLDIER=0&'+
'clickedButton=btnSearch&'+
'resetErrors=T&'+
'TXT_PNR_NO_CHECKIN=&'+
'TXT_NAME_CHECKIN=&'+
'TXT_SURNAME_CHECKIN=&'+
'TXT_PNR_NO_s=&'+
'TXT_SURNAME_s=&'+
'TXT_PNR_NO=&'+
'TXT_SURNAME=';

      // The PostData OleVariant needs to be an array of bytes
      // as large as the string (minus the 0 terminator)
      PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);

      // Now, move the Ordinal value of the character into the PostData array
      for i := 1 to length(EncodedDataString) do
        PostData[i-1] := ord(EncodedDataString[i]);

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      ticks := GetTickCount;
      // Naviagate to blank page
      paramWebBrowser.Navigate('about:blank');
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      paramWebBrowser.Navigate(PegasusStartURL, EmptyParam, EmptyParam, PostData, Headers);
      // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      mainPageTime := mainPageTime+(GetTickCount-ticks);
      
      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
        last_forward_price := 0;

        DocSelectDiv := (Doc.all.tags('DIV')as IHTMLElementCollection);
        for div_index := 0 to DocSelectDiv.length - 1 do
        begin
          DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

          flight_type := '';

          //(DocElementDiv as IHTMLElement).
          if (Pos('THREEDAYSVIEWDEP', UpperCase(DocElementDiv.id))>0) then
            flight_type := 'forward';
          if (Pos('THREEDAYSVIEWRET', UpperCase(DocElementDiv.id))>0) then
            flight_type := 'reverse';


          if flight_type <> '' then
          begin
            DocSelectInnerDiv := ((DocElementDiv.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
            for innerdiv_index := 0 to DocSelectInnerDiv.length - 1 do
            begin
              DocElementInnerDiv := DocSelectInnerDiv.Item(innerdiv_index,EmptyParam) as IHTMLElement;

              depart_time := '';
              if (Pos('ITEM', UpperCase(DocElementInnerDiv.className))>0) and
                 (DocElementInnerDiv.parentElement <> nil) and
                 //(DocElementInnerDiv.parentElement is IHTMLElement) and
                 (Pos('DATEITEM', UpperCase(DocElementInnerDiv.parentElement.className))>0) and
                 (Pos('SELECTED', UpperCase(DocElementInnerDiv.parentElement.className))>0) then
              begin
                // Get Date
                strHTML := DocElementInnerDiv.parentElement.innerHTML;
                Str := '';
                if pos('/LABEL',UpperCase(strHTML)) >0 then
                  Str := Copy(strHTML,1,pos('/LABEL',UpperCase(strHTML))-1);
                While (pos('>',UpperCase(Str)) >0)
                  and (pos('<',UpperCase(Str)) >0) do
                begin
                  Delete(Str,pos('<',UpperCase(Str)),pos('>',UpperCase(Str))-pos('<',UpperCase(Str))+1);
                end;
                Str := StringReplace(Str, '<', '',[rfReplaceAll, rfIgnoreCase]);
                if Length(Str)>10 then
                  Str := Copy(Str,1,10);

                depart_date := Trim(Str);
                arrival_date := Trim(Str);

                // Get time
                DocSelect := ((DocElementInnerDiv.all as IHTMLElementCollection).tags('SPAN')as IHTMLElementCollection);
                for I := 0 to DocSelect.length - 1 do
                begin
                  DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                  if (Pos('TIME', UpperCase(DocElement.className))>0) then
                  begin
                    strHTML := DocElement.innerHTML;
                    if pos('ARRIVAL',UpperCase(strHTML)) >0 then
                    begin
                      depart_time := Copy(strHTML,1,pos('ARRIVAL',UpperCase(strHTML))-1);
                      Delete(strHTML,1,pos('ARRIVAL',UpperCase(strHTML))-1);
                      arrival_time := strHTML;
                      //
                      depart_time := StringReplace(depart_time, 'Departure', '',[rfReplaceAll, rfIgnoreCase]);
                      arrival_time := StringReplace(arrival_time, 'Arrival', '',[rfReplaceAll, rfIgnoreCase]);
                      depart_time := Trim(depart_time);
                      arrival_time := Trim(arrival_time);
                    end;
                  end;
                end;

                // Via
                strHTML := DocElementInnerDiv.innerHTML;
                if pos('FLTINFO',UpperCase(strHTML)) >0 then
                begin
                  Delete(strHTML,1,pos('FLTINFO',UpperCase(strHTML))+Length('FLTINFO')-1);
                  strHTML := StringReplace(strHTML, 'via', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, 'div', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '/', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '<', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '>', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, 'via', '',[rfReplaceAll, rfIgnoreCase]);
                  via := Trim(strHTML);
                end;

                // FlightNum
                flight_no := '';
                strHTML := DocElementInnerDiv.innerHTML;
                if pos('FLIGHTINFO',UpperCase(strHTML)) >0 then
                begin
                  Delete(strHTML,1,pos('FLIGHTINFO',UpperCase(strHTML))+Length('FLIGHTINFO')-1);
                  strHTML := StringReplace(strHTML, '"', '''',[rfReplaceAll, rfIgnoreCase]);
                  while (strHTML[1] = ' ')or(strHTML[1] = '(')or(strHTML[1] = '''') do
                    Delete(strHTML,1,1);
                  if pos('''',UpperCase(strHTML)) >0 then
                      flight_no := Copy(strHTML,1,pos('''',UpperCase(strHTML))-1);
                end;

                // Get price
                price := 0;
                if flight_no <> '' then
                begin
                
                  // Get price: find "fullTotalFare" input
                  DocElement := nil;
                  DocSelect := (Doc.all.tags('INPUT')as IHTMLElementCollection);
                  for I := 0 to DocSelect.length - 1 do
                  begin
                    DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                    if (Pos('FULLTOTALFARE', UpperCase(DocElement.id))>0) then
                    begin
                      // clear "fullTotalFare"
                      (DocElement as IHTMLInputElement).value := '';
                      break;
                    end;
                  end;
                  // Get price: click radio button and wait price
                  DocSelect := ((DocElementInnerDiv.all as IHTMLElementCollection).tags('INPUT')as IHTMLElementCollection);
                  for I := 0 to DocSelect.length - 1 do
                  begin
                    DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                    (DocElement as IHTMLInputElement).checked := true;
                    DocElement.click;
                    break;
                  end;
                  // wait
                  ticks := GetTickCount;
                  price := 0;
                  IsSuccess := false;
                  if depart_time <> '' then
                  repeat
                    Application.HandleMessage;
                    Sleep(50);
                    DocSelect := (Doc.all.tags('INPUT')as IHTMLElementCollection);
                    for I := 0 to DocSelect.length - 1 do
                    begin
                      DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                      if (Pos('FULLTOTALFARE', UpperCase(DocElement.id))>0) then
                      begin
                        // found "module-light" div
                        if (DocElement as IHTMLInputElement).value <> '' then
                        begin
                          Str := (DocElement as IHTMLInputElement).value;
                          Str := StringReplace(Str, ',', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                          Str := StringReplace(Str, '.', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                          if not TryStrToFloat(Str, price) then
                            price := 0;
                          
                          //(DocElement as IHTMLInputElement).value := '';
                          IsSuccess := true;
                        end;
                        break;
                      end;
                    end;
                  until IsSuccess or ((GetTickCount-ticks)>1000*60);
                  mainPageTime := mainPageTime+(GetTickCount-ticks);

                end;


                if depart_time <> '' then
                if price <> 0 then
                begin
                  if flight_type = 'forward' then
                  begin
                    last_forward_price := price
                  end
                   else
                    price := price - last_forward_price;

                  paramOutData.add(
                        flight_type+'|'+
                        depart_date+'|'+
                        depart_time+'|'+
                        arrival_date+'|'+
                        arrival_time+'|'+
                        flight_no+'|'+
                        FloatToStr(price)+'|'+
                        via
                        );
                end;

              end;
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

