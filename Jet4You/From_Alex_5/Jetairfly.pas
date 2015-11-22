unit Jetairfly;
interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetJetairfly(
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

procedure GetJetairfly(
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

  i,j,k,table_index,row_index : integer;
  strHTML,strRow : String;
  htmlRow : IHTMLTableRow;
  DocSelect      : IHTMLElementCollection;
  DocSelectTable : IHTMLElementCollection;
  DocElement     : IHtmlElement;
  DocElementTable: IHTMLTable;
  DocElementRow  : IHTMLTableRow;
  Doc            : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str, via : string;
  depart_date_dt,
  arrival_date_dt : TDateTime;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  dwDateConvertDay,dwDateConvertMonth,dwDateConvertYear : word;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  JetairflyStartURL: string;
  ini : tinifile;
  iniPath:string;
  IsSuccess : boolean;
  total_price_base, total_price_taxes, dbl : double;

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
    IniPath:=extractfiledir(Application.ExeName)+'\data\Jetairfly.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    JetairflyStartURL  := ini.ReadString('main','JetairflyStartURL', 'nil');
    ini.free;
    if JetairflyStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter JetairflyStartURL in Jetairfly.ini');
      exit; //please change the code according to your rules
    end;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    mainPageTime := 0;
    totalPriceTime := 0;
    loc_date_depart := date_depart-1;
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart+1;

      //forward
      EncodedDataString :=
        'Program=inetticket_new&'+
        'User=1&'+
        'Agent=&'+
        'Reference=&'+
        'Language=E&'+
        'Taal=3&'+
        'Key_out=&'+
        'Key_ret=&'+
        'meal_out=&'+
        'meal_ret=&'+
        'comfort_service_out=&'+
        'comfort_service_ret=&'+
        'Reversed=&'+
        'Subroutine=N&'+
        'Insurance=&'+
        'f020=20&'+
        'f010=&'+
        'Origin=&'+
        'SSR_code1=&'+
        'SSR_aantal1=&'+
        'SSR_code2=&'+
        'SSR_aantal2=&'+
        'SSR_code3=&'+
        'SSR_aantal3=&'+
        'huurwagens=&'+
        'TA_login_link=&'+
        'sw_jetnet=N&'+
        'ipaddress=95.134.77.218&'+
        'jafLngCode=3&'+
        'ow_type='+if_str(returnflight,'R','O')+'&'+
        'oVan='+airport_depart+'&'+
        'oDest='+airport_destination+'&'+
        'oDag='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
        'oMaand_Jaar='+DateTimeToStringRet('mm',loc_date_depart)+'_'+
                       DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
        'rDag='+DateTimeToStringRet('dd',loc_date_return)+'&'+
        'rMaand_Jaar='+DateTimeToStringRet('mm',loc_date_return)+'_'+
                       DateTimeToStringRet('yyyy',loc_date_return)+'&'+
        'Pax='+IntToStr(adults)+'&'+
        'Child='+IntToStr(children)+'&'+
        'Infant='+IntToStr(infants)
        ;
//
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
      paramWebBrowser.Navigate(JetairflyStartURL, EmptyParam, EmptyParam, PostData, Headers);
        // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      mainPageTime := mainPageTime+(GetTickCount-ticks);

      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);


        DocSelectTable := (Doc.all.tags('TABLE')as IHTMLElementCollection);
        for table_index := 0 to DocSelectTable.length - 1 do
        begin
          DocElementTable := DocSelectTable.Item(table_index,EmptyParam) as IHTMLTable;
          if (Pos('TXT_DEFAULT', UpperCase((DocElementTable as IHTMLElement).className))>0) and
             (DocElementTable.width = 320 ) and
             ((DocElementTable as IHTMLElement).id = '') then
          begin
            // Get flight direction
            strHTML := (DocElementTable as IHTMLElement).innerHTML;

            if pos('TITELBOEKING',UpperCase(strHTML)) >0 then
              Delete(strHTML,1,pos('TITELBOEKING',UpperCase(strHTML)));
            if pos('<',UpperCase(strHTML)) >0 then
              strHTML := Copy(strHTML,1,pos('<',UpperCase(strHTML)));

            if pos('OUT',UpperCase(strHTML)) >0 then
              flight_type := 'forward';
            if returnflight then
              if pos('RETURN',UpperCase(strHTML)) >0 then
                flight_type := 'reverse';

            // Check depart/return dates 
            IsSuccess := false;
            if flexible then
            begin
              if flight_type = 'forward' then
                IsSuccess := (loc_date_depart >= date_depart)
                         and (loc_date_depart <= date_return);
              if flight_type = 'reverse' then
                IsSuccess := (loc_date_return >= date_depart)
                         and (loc_date_return <= date_return);
            end
            else
            begin
              if flight_type = 'forward' then
                IsSuccess := (loc_date_depart = date_depart)
                          or (loc_date_depart = date_return);
              if flight_type = 'reverse' then
                IsSuccess := (loc_date_return = date_depart)
                          or (loc_date_return = date_return);
            end;

            if IsSuccess then
            begin
//              flight_no := '';
              for row_index := 0 to DocElementTable.rows.length - 4 do
              begin
                DocElementRow := DocElementTable.rows.item(row_index,EmptyParam) as IHTMLTableRow;
                if (pos('RADIO',UpperCase((DocElementRow as IHTMLElement).innerHTML)) >0)
                and(pos('INPUT',UpperCase((DocElementRow as IHTMLElement).innerHTML)) >0) then
                begin

                  // Date
                  strHTML := (DocElementRow.cells.item(2,EmptyParam) as IHTMLElement).innerHTML;
                  if pos(',',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos(',',UpperCase(strHTML)));
                  strHTML := StringReplace(strHTML, '&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := Trim(strHTML);
                  if Copy(strHTML,Length(strHTML)-1,2)=DateTimeToStringRet('yy',loc_date_depart) then
                    strHTML := Copy(strHTML,1,Length(strHTML)-2)+DateTimeToStringRet('yyyy',loc_date_depart);
                  depart_date := strHTML;
                  arrival_date := strHTML;
                  // Time Depart
                  strHTML := (DocElementRow.cells.item(3,EmptyParam) as IHTMLElement).innerHTML;
                  if pos('D:',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('D:',UpperCase(strHTML))+1);
                  strHTML := Trim(strHTML);
                  depart_time := strHTML;
                  // Time Arrival
                  strHTML := (DocElementRow.cells.item(4,EmptyParam) as IHTMLElement).innerHTML;
                  if pos('A:',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('A:',UpperCase(strHTML))+1);
                  strHTML := Trim(strHTML);
                  arrival_time := strHTML;

                  // Next Row ...
                  DocElementRow := DocElementTable.rows.item(row_index+1,EmptyParam) as IHTMLTableRow;
                  strHTML := Trim((DocElementRow.cells.item(2,EmptyParam) as IHTMLElement).innerHTML);
                  While (pos('>',UpperCase(strHTML)) >0)
                    and (pos('<',UpperCase(strHTML)) >0) do
                  begin
                    Delete(strHTML,pos('<',UpperCase(strHTML)),pos('>',UpperCase(strHTML))-pos('<',UpperCase(strHTML))+1);
                  end;
                  // Searc three upper letters
                  while (strHTML[1]=' ')or
                        (Copy(strHTML,1,3) <> UpperCase(Copy(strHTML,1,3))) do
                    Delete(strHTML,1,1);
                  strHTML := StringReplace(strHTML, '*', '',[rfReplaceAll, rfIgnoreCase]);
                  flight_no := Trim(strHTML);

                  // Next Row ...
                  DocElementRow := DocElementTable.rows.item(row_index+2,EmptyParam) as IHTMLTableRow;
                  // Price
                  strHTML := (DocElementRow.cells.item(1,EmptyParam) as IHTMLElement).innerHTML;
                  strHTML := StringReplace(strHTML, ',', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '.', DecimalSeparator,[rfReplaceAll, rfIgnoreCase]);

                  While (pos('>',UpperCase(strHTML)) >0)
                    and (pos('<',UpperCase(strHTML)) >0) do
                  begin
                    Delete(strHTML,pos('<',UpperCase(strHTML)),pos('>',UpperCase(strHTML))-pos('<',UpperCase(strHTML))+1);
                  end;
                  strHTML := StringReplace(strHTML, 'Euro', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '(', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, ')', '',[rfReplaceAll, rfIgnoreCase]);
                  if pos('BASE',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('BASE',UpperCase(strHTML))+3);

                  total_price_base := 0;
                  total_price_taxes := 0;
                  if pos('+',strHTML) >0 then
                  begin
                    Str := Trim(Copy(strHTML,1,pos('+',UpperCase(strHTML))-1));

                    if not TryStrToFloat(str, total_price_base) then
                      total_price_base := 0;
                    Delete(strHTML,1,pos('+',UpperCase(strHTML)));
                  end;
                  if pos('TAXES',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('TAXES',UpperCase(strHTML))+4);
                  Str := Trim(strHTML);
                  if not TryStrToFloat(str, total_price_taxes) then
                    total_price_taxes := 0;

                  // Next Row ...
                  DocElementRow := DocElementTable.rows.item(row_index+3,EmptyParam) as IHTMLTableRow;
                  // Via
                  strHTML := (DocElementRow.cells.item(2,EmptyParam) as IHTMLElement).innerHTML;
                  While (pos('>',UpperCase(strHTML)) >0)
                    and (pos('<',UpperCase(strHTML)) >0) do
                  begin
                    Delete(strHTML,pos('<',UpperCase(strHTML)),pos('>',UpperCase(strHTML))-pos('<',UpperCase(strHTML))+1);
                  end;
                  strHTML := StringReplace(strHTML, '*', '',[rfReplaceAll, rfIgnoreCase]);
                  strHTML := StringReplace(strHTML, '&nbsp;', '',[rfReplaceAll, rfIgnoreCase]);
                  if pos('WITH STOPOVER AT',UpperCase(strHTML)) >0 then
                    Delete(strHTML,1,pos('WITH STOPOVER AT',UpperCase(strHTML))+Length('WITH STOPOVER AT')-1);
                  via := Trim(strHTML);

                  // -- Changed 2010.09.12
                  paramOutData.add(
                    //flight_type+'|'+
                    depart_date+'|'+
                    depart_time+'|'+
                    arrival_date+'|'+
                    arrival_time+'|'+
                    flight_no+'|'+
                    FloatToStr(total_price_base*(adults+children)+ total_price_taxes*(adults+children+infants))+'|'+
                    via+'|'+
                    flight_type
                    );
                  // -- Changed 2010.09.12
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
      begin
        if loc_date_depart = date_depart-1 then
          loc_date_depart := date_depart
         else
        if loc_date_depart = date_return-1 then
          loc_date_depart := date_return
         else
        if loc_date_depart = date_depart then
          loc_date_depart := date_return-1;
      end;
    end;

    // -- Changed 2010.09.12
    paramOutData.Sort;
    for I := 0 to paramOutData.Count - 1 do
    begin
      str := paramOutData[i];
      if copy(str, Length(str)-Length('reverse')+1,Length('reverse'))='reverse' then
        str := 'reverse|'+copy(str, 1,Length(str)-Length('reverse')-2);
      if copy(str, Length(str)-Length('forward')+1,Length('forward'))='forward' then
        str := 'forward|'+copy(str, 1,Length(str)-Length('forward')-2);
      paramOutData[i] := str;
    end;
    // -- Changed 2010.09.12

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
