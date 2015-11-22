unit Corendon;
interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
procedure GetCorendon(
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

procedure GetCorendon(
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
  DocSelectTable : IHTMLElementCollection;
  DocTable    : IHTMLTable;
  DocSelectTablePrice : IHTMLElementCollection;
  DocTablePrice    : IHTMLTable;
  DocElement  : IHtmlElement;
  ItemElement : IHtmlElement;
  RadioButtonElement  : IHTMLInputElement;
  RadioButtonElementFirst  : IHTMLInputElement;
  Doc         : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  total_price,
  via : string;
  depart_date_dt, arrival_date_dt : TDateTime;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  dwDateConvertDay,dwDateConvertMonth,dwDateConvertYear : word;
  frame_dispatch: IDispatch;
  frame_win: IHTMLWindow2;
  frame_doc: IHTMLDocument2;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  CorendonStartURL: string;
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
    IniPath:=extractfiledir(Application.ExeName)+'\data\Corendon.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    CorendonStartURL  := ini.ReadString('main','CorendonStartURL', 'nil');
    ini.free;
    if CorendonStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter CorendonStartURL in Corendon.ini');
      exit; //please change the code according to your rules
    end;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    mainPageTime := 0;
    totalPriceTime := 0;
    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
    begin
      //loc_date_return := loc_date_depart;

      DecodeDate(loc_date_depart,dwDateConvertYear,dwDateConvertMonth,dwDateConvertDay);
      loc_date_return := EncodeDate(dwDateConvertYear,dwDateConvertMonth,1);

      //forward
      EncodedDataString :=
        'FromFlightDate='+DateTimeToStringRet('dd',loc_date_depart)+'/'+
                          DateTimeToStringRet('m',loc_date_depart)+'/'+
                          DateTimeToStringRet('yyyy',loc_date_depart)+'&'+
        'ReturnFlightDate='+DateTimeToStringRet('dd',loc_date_return)+'/'+
                            DateTimeToStringRet('m',loc_date_return)+'/'+
                            DateTimeToStringRet('yyyy',loc_date_return)+'&'+
        'FromAirportCode='+airport_depart+'&'+
        'ToAirportCode='+airport_destination+'&'+
        'AdultCount='+IntToStr(adults)+'&'+
        'ChildCount='+IntToStr(children)+'&'+
        'BabyCount='+IntToStr(infants)+'&'+
        'WayType='+if_str(returnflight,'Return','OneWay');

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      ticks := GetTickCount;
      // Naviagate to blank page
      paramWebBrowser.Navigate('about:blank');
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      paramWebBrowser.Navigate(CorendonStartURL+EncodedDataString, EmptyParam, EmptyParam);
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

        for table_index := 0 to DocSelectTable.length-1 do
        begin
          DocTable := DocSelectTable.Item(table_index,EmptyParam) as IHTMLTable;
          flight_type := '';
          if Pos(UpperCase('gvToGo'), UpperCase((DocTable as IHTMLElement).id))>0 then
            flight_type := 'forward';
          if Pos(UpperCase('gvReturn'), UpperCase((DocTable as IHTMLElement).id))>0 then
            flight_type := 'reverse';
          if flight_type <> '' then
          begin
            for i := 0 to DocTable.rows.length-1 do
            try
              htmlRow := DocTable.rows.Item(i,EmptyParam) as IHTMLTableRow;
              try
                if htmlRow.cells.length < 5 then
                  continue;
              except
                continue;
              end;

              strHTML := (htmlRow.cells.item(1, 1) as HTMLTableCell).innerHTML;
              // search '.' in Datum field
              if Pos('.',strHTML)>0 then
              begin
                // Datum
                if pos('(',strHTML) >0 then
                  Delete(strHTML,1,pos('',strHTML)-1);
                strHTML := Trim(strHTML);
                depart_date := strHTML;
                arrival_date := strHTML;
                arrival_date_dt := 0;
                if Length(arrival_date) >= 10 then
                  if TryStrToInt(Copy(arrival_date,1,2), DateConvertDay) then
                    if TryStrToInt(Copy(arrival_date,4,2), DateConvertMonth) then
                      if TryStrToInt(Copy(arrival_date,7,4), DateConvertYear) then
                      begin
                        arrival_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        arrival_date := DateTimeToStringRet('dd mmm yyyy',arrival_date_dt);
                      end;
                if Length(depart_date) >= 10 then
                  if TryStrToInt(Copy(depart_date,1,2), DateConvertDay) then
                    if TryStrToInt(Copy(depart_date,4,2), DateConvertMonth) then
                      if TryStrToInt(Copy(depart_date,7,4), DateConvertYear) then
                      begin
                        depart_date_dt := EncodeDate(DateConvertYear,DateConvertMonth,DateConvertDay);
                        depart_date := DateTimeToStringRet('dd mmm yyyy',depart_date_dt);
                      end;


                //Vertrekplaats/tijd
                strHTML := (htmlRow.cells.item(2, 2) as HTMLTableCell).innerHTML;
                depart_time := strHTML;
                arrival_time := strHTML;
                if pos('<',depart_time) > 0 then
                  depart_time := copy(depart_time,1,pos('<',depart_time)-1);
                if pos('>',arrival_time) > 0 then
                  Delete(arrival_time,1,pos('>',arrival_time));
                depart_time := Trim(depart_time);
                arrival_time := Trim(arrival_time);

                //Via
                strHTML := (htmlRow.cells.item(3, 3) as HTMLTableCell).innerHTML;
                via := Trim(strHTML);
                if pos('>',via) > 0 then
                  Delete(via,1,pos('>',via));
                if pos('<',via) > 0 then
                  via := copy(via,1,pos('<',via)-1);
                if via='-' then
                  via:='';

                //Vlucht
                strHTML := (htmlRow.cells.item(4, 4) as HTMLTableCell).innerHTML;
                flight_no := strHTML;

                //Price
                strHTML := (htmlRow.cells.item(6, 6) as HTMLTableCell).innerHTML;
                total_price := Trim(strHTML);
                if (Length(total_price)>1)
                 and (Copy(total_price,1,1)='ˆ') then
                  Delete(total_price,1,1);
                if (Length(total_price)>2)
                 and (Copy(total_price,Length(total_price)-1,2)=',-') then
                  Delete(total_price,Length(total_price)-1,2);
                total_price := Trim(total_price);

                IsSuccess := depart_date_dt=loc_date_depart;

                if TryStrToFloat(total_price,dbl) then
                begin
                  if flight_type = 'forward' then
                  begin
                    total_price := 'ˆ '+FloatToStr(
                          dbl*(adults+children)+
                          45*(adults+children)+
                          20*(infants));
                  end
                  else
                  if flight_type = 'reverse' then
                  begin
                    total_price := 'ˆ '+FloatToStr(
                          dbl*(adults+children)+
                          45*(adults+children)+
                          20*(infants));
                  end;
                end;

                //Prijs
                if IsSuccess then
                begin
                  paramOutData.add(
                      flight_type+'|'+
                      depart_date+'|'+
                      depart_time+'|'+
                      arrival_date+'|'+
                      arrival_time+'|'+
                      flight_no+'|'+
                      total_price+'|'+
                      via
                      );
                end;
              end;
            except
//              on E : Exception do
//              begin
//                ShowMessage('Exception class name = '+E.ClassName);
//                ShowMessage('Exception message = '+E.Message);
//              end;
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
