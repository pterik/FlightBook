unit Vueling;
interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw, 
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetVueling(
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

procedure GetVueling(
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
  DocSelectTR    : IHTMLElementCollection;
  DocElementTR   : IHTMLElement;
  DocElementTRTyped   : IHTMLTableRow;
  DocElementFullTotalFare : IHTMLElement;
  Doc            : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str, via : string;
  price, price_for_infant : double;
  depart_date_dt,
  arrival_date_dt : TDateTime;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  dwDateConvertDay,dwDateConvertMonth,dwDateConvertYear : word;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  VuelingStartURL: string;
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
    ParamWebBrowser.Silent := true;
    ParamWebBrowser.Update;
    Application.HandleMessage;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Vueling.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    VuelingStartURL  := ini.ReadString('main','VuelingStartURL', 'nil');
    ini.free;
    if VuelingStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter VuelingStartURL in Vueling.ini');
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
          'event=search&'+
          'module=SB&'+
          'page=SEARCH&'+
          'language=ES&'+
          'mode=&'+
          'sid=&'+
          'ref=&'+
          'travel=2&'+//if_str(returnflight,'2','1')+'&'+
          'from1='+airport_depart+'&'+
          'to1='+airport_destination+'&'+
          'from2='+airport_destination+'&'+
          'to2='+airport_depart+'&'+
          'departDay1='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
          'departMonth1='+DateTimeToStringRet('yyyy',loc_date_depart)+''+
                     DateTimeToStringRet('mm',loc_date_depart)+'&'+
          //'displayDate1=Martes 05 Octubre, 2010&'+//?????????
          'displayDate1='+DateTimeToStringRet('dd mmm yyyy',loc_date_depart)+'&'+

          'depart1FlexBy=0000&'+
          'departDay2='+DateTimeToStringRet('dd',loc_date_return)+'&'+
          'departMonth2='+DateTimeToStringRet('yyyy',loc_date_return)+''+
                     DateTimeToStringRet('mm',loc_date_return)+'&'+
          //'displayDate2=Martes 05 Octubre, 2010&'+//?????????
          'displayDate2='+DateTimeToStringRet('dd mmm yyyy',loc_date_return)+'&'+
          'depart2FlexBy=0000&'+
          'fechas=0000&'+
          'ADULT='+IntToStr(adults)+'&'+
          'defaultADULT=-1&'+
          'CHILD='+IntToStr(children)+'&'+
          'defaultCHILD=-1&'+
          'INFANT='+IntToStr(infants)+'&'+
          'defaultINFANT=-1&'+
          'toCity1='+airport_destination+'&'+ // ???
          'toCity2='+airport_depart+'&'+      // ???
          'departDate1='+DateTimeToStringRet('yyyy',loc_date_depart)+''+
                     DateTimeToStringRet('mm',loc_date_depart)+''+
                     DateTimeToStringRet('dd',loc_date_depart)+'&'+
          'departDate2='+DateTimeToStringRet('yyyy',loc_date_return)+''+
                     DateTimeToStringRet('mm',loc_date_return)+''+
                     DateTimeToStringRet('dd',loc_date_return)+'&'+
          'numberMarkets=2&'+
          'cualquier=&'+
          'nom_cualquier=&'+
          'm1_cualquier=&'+
          'm2_cualquier=&'+
          'frdisc=&'+
          'mode_orig=&';
          //'mode_TESTAB	MQkqIRc4U1Q5IicHfAFRVi0pIQ==&'+
          //'mode_TESTABClassB	NgALARIoU1Q5NlFifWYlIygvQA==&'+

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
      paramWebBrowser.Navigate(VuelingStartURL, EmptyParam, EmptyParam, PostData, Headers);
      // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      mainPageTime := mainPageTime+(GetTickCount-ticks);
      
      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        DocSelectDiv := (Doc.all.tags('DIV')as IHTMLElementCollection);
        for div_index := 0 to DocSelectDiv.length - 1 do
        begin
          DocElementDiv := DocSelectDiv.Item(div_index,EmptyParam) as IHTMLElement;

          flight_type := '';

          //(DocElementDiv as IHTMLElement).
          if (Pos('RESULTS0', UpperCase(DocElementDiv.id))>0) then
          begin
            flight_type := 'forward';
            depart_date := DateTimeToStringRet('dd mmm yyyy',loc_date_return);
            arrival_date := DateTimeToStringRet('dd mmm yyyy',loc_date_return);
          end;
          if (Pos('RESULTS1', UpperCase(DocElementDiv.id))>0) and returnflight then
          begin
            flight_type := 'reverse';
            depart_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);
            arrival_date := DateTimeToStringRet('dd mmm yyyy',loc_date_depart);
          end;

          if flight_type <> '' then
          begin
            DocSelectTR := ((DocElementDiv.all as IHTMLElementCollection).tags('TR')as IHTMLElementCollection);
            for innerdiv_index := 0 to DocSelectTR.length - 1 do
            begin
              DocElementTR := DocSelectTR.Item(innerdiv_index,EmptyParam) as IHTMLElement;
              DocElementTRTyped := DocElementTR as IHTMLTableRow;

              if
//                 (Pos('CONNFLIGHT', UpperCase(DocElementTR.className))>0) and
//                 (Pos('SEPARACION', UpperCase(DocElementTR.className))<=0) and
                 (DocElementTRTyped.cells.length > 3)then
              begin
                // Get time
                strHTML := (DocElementTRTyped.cells.item(3, 3) as HTMLTableCell).innerHTML;
                // Parse text
                if pos('<BR>',UpperCase(strHTML)) >0 then
                  depart_time := Copy(strHTML,1,pos('<BR>',UpperCase(strHTML))-1);
                if pos('<BR>',UpperCase(strHTML)) >0 then
                  Delete(strHTML,1,pos('<BR>',UpperCase(strHTML))-1+Length('<br>'));
                arrival_time := strHTML;
                //-
                while pos('>', depart_time)>0 do
                  Delete(depart_time,1,pos('>', depart_time));
                if pos('<', arrival_time)>0 then
                  arrival_time := Copy(arrival_time,1,pos('<',UpperCase(arrival_time))-1);
                //-
                depart_time := StringReplace(depart_time, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                arrival_time := StringReplace(arrival_time, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                depart_time := Trim(depart_time);
                arrival_time := Trim(arrival_time);

                // Via: arrival time
                via := '';
                if DocElementTRTyped.cells.length>6 then
                  strHTML := (DocElementTRTyped.cells.item(6, 6) as HTMLTableCell).innerHTML
                 else
                  strHTML := '';

                if pos('<BR>',UpperCase(strHTML)) >0 then
                begin
//                  // Via: get time
//                  if pos('<BR>',UpperCase(strHTML)) >0 then
//                    str := Copy(strHTML,1,pos('<BR>',UpperCase(strHTML))-1);
//                  while pos('>', str)>0 do
//                    Delete(depart_time,1,pos('>', str));
                  if pos('<BR>',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('<BR>',UpperCase(strHTML))-1+Length('<BR>'));
                  arrival_time := strHTML;
                  //-
                  if pos('<', arrival_time)>0 then
                    arrival_time := Copy(arrival_time,1,pos('<',UpperCase(arrival_time))-1);
                  //-
                  arrival_time := StringReplace(arrival_time, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                  arrival_time := Trim(arrival_time);

                  // Via: get city
                  if DocElementTRTyped.cells.length>7 then
                    strHTML := (DocElementTRTyped.cells.item(7, 7) as HTMLTableCell).innerHTML
                   else
                    strHTML := '';
                  if pos('(',UpperCase(strHTML)) >0 then
                  begin
                    if pos('(',UpperCase(strHTML)) >0 then
                      Delete(strHTML,1,pos('(',UpperCase(strHTML))-1+Length('('));
                    if pos(')',UpperCase(strHTML)) >0 then
                      strHTML := Copy(strHTML,1,pos(')',UpperCase(strHTML))-1);

                    via := strHTML;
                    via := StringReplace(via, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                    via := Trim(via);
                  end;
                end;

                // FlightNum
                flight_no := '';
                DocSelect := ((DocElementTR.all as IHTMLElementCollection).tags('INPUT')as IHTMLElementCollection);
                for I := 0 to DocSelect.length - 1 do
                begin
                  DocElement := DocSelect.Item(i,EmptyParam) as IHTMLElement;
                  if (DocElement as IHTMLInputElement).type_ = 'radio' then
                  begin
                    strHTML := (DocElement as IHTMLInputElement).value;
                    // -
                    if pos(' ', strHTML) > 0 then
                      Delete(strHTML, 1, pos(' ', strHTML));
                    strHTML := Trim(strHTML);
                    if pos(UpperCase(if_str(flight_type = 'forward',airport_depart,airport_destination)),UpperCase(strHTML)) >0 then
                    begin
                      Str := Copy(strHTML,1,pos(UpperCase(if_str(flight_type = 'forward',airport_depart,airport_destination)),UpperCase(strHTML))-1);
                      Str := Trim(Str);
                      flight_no := Trim(Str);
                      // -
                      if pos(' ', strHTML) > 0 then
                      begin
                        Delete(strHTML, 1, pos(' ', strHTML));
                        if pos(UpperCase(if_str(flight_type = 'forward',airport_destination,airport_depart)),UpperCase(strHTML)) >3 then
                        begin
                          Str := Copy(strHTML,1,pos(UpperCase(if_str(flight_type = 'forward',airport_destination,airport_depart)),UpperCase(strHTML))-4);
                          Str := Trim(Str);
                          flight_no := flight_no +','+Trim(Str);
                        end;
                      end;
                    end;
                  end;
                end;


                // Get price
                price_for_infant := 0;
                price := 0;
                strHTML := (DocElementTRTyped.cells.item(1, 1) as HTMLTableCell).innerHTML;
                // Parse text
                begin
                  // adult
                  if pos('<BR>',UpperCase(strHTML)) >0 then
                  begin
                    Str := Copy(strHTML,1,pos('<BR>',UpperCase(strHTML))-1);
                    Delete(strHTML,1,pos('<BR>',UpperCase(strHTML))-1+Length('<BR>'));
                  end
                  else
                  begin
                    Str := strHTML;
                    strHTML := '';
                  end;
                  While (pos('>',UpperCase(Str)) >0)
                    and (pos('<',UpperCase(Str)) >0) do
                  begin
                    Delete(Str,pos('<',UpperCase(Str)),pos('>',UpperCase(Str))-pos('<',UpperCase(Str))+1);
                  end;
                  Str := StringReplace(Str, #13, '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, #10, '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'ˆ', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'Precio', '0', [rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ' ', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ',', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, '.', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                  if not TryStrToFloat(Str, price) then
                    price := 0;
                end;
                if strHTML <> '' then
                begin
                  // infants
                  Str := strHTML;
                  While (pos('>',UpperCase(Str)) >0)
                    and (pos('<',UpperCase(Str)) >0) do
                  begin
                    Delete(Str,pos('<',UpperCase(Str)),pos('>',UpperCase(Str))-pos('<',UpperCase(Str))+1);
                  end;
                  Str := StringReplace(Str, #13, '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, #10, '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'ˆ', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ' ', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ',', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, '.', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                  if pos('BEB',UpperCase(Str)) >0 then
                    Str := Copy(Str,1,pos('BEB',UpperCase(Str))-1);
                  Str := StringReplace(Str, '(', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, ')', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'Beb', '',[rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'Precio', '0', [rfReplaceAll, rfIgnoreCase]);
                  Str := StringReplace(Str, 'Baby', '',[rfReplaceAll, rfIgnoreCase]);
                  if not TryStrToFloat(Str, price_for_infant) then
                    price_for_infant := 0;
                end;

                price := price*(adults+children)+price_for_infant*infants;
                if price <> 0 then
                begin
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

