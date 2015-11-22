unit Ryanair;
interface
uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw,
  INIFiles, windows, unit1;

//webBrowser was removed from parameters, it creates internaly
// paramStartURL,paramGetTotalSumURL were removed from parameters, it creates internaly
function GetRyanAir(
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer) : TStringList;
function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;

const
  constIsDemoMode = false;

implementation

uses Forms, Controls, Dialogs;

function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;

function GetRyanAir(
            returnflight : boolean;
            flexible: boolean;
            airport_depart: string;
            date_depart: TDateTime;
            airport_destination: string;
            date_return: TDateTime;
            adults: integer;
            children: integer;
            infants: integer) : TStringList;
var
  EncodedDataString: string;
  PostData: OleVariant;
  Headers: OleVariant;
  loc_date_depart: TDateTime;
  loc_date_return: TDateTime;

  i,j,k : integer;
  strHTML,strRow : String;
  htmlRow : IHTMLTableRow;
  DocSelect   : IHTMLElementCollection;
  DocElement  : IHtmlElement;
  ItemElement : IHtmlElement;
  Doc         : IHTMLDocument2;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  total_price : string;
  frame_dispatch: IDispatch;
  frame_win: IHTMLWindow2;
  frame_doc: IHTMLDocument2;
  IsError : boolean;
  ticks, mainPageTime, totalPriceTime : cardinal;
  ParamWebBrowser: TWebBrowser;
  paramOutData: TStringList;
  RyanAirStartURL,RyanAirGetTotalSumURL : string;
  ini : tinifile;
  iniPath:string;
begin
  try
// Don`t forget to insert   uses Forms;  above
    ParamWebBrowser := TWebBrowser.Create(Application.mainForm);
    TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser';
    TWinControl(ParamWebBrowser).Parent:= Application.mainForm;
    ParamWebBrowser.Height := 400;
    ParamWebBrowser.Visible := true;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := true;
    ParamWebBrowser.Update;
    paramOutData:=TStringList.Create;
    Application.ProcessMessages;
    IniPath:=extractfiledir(Application.ExeName)+'\data\ryanair.ini';
    ini := TIniFile.Create(IniPath);
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    RyanairStartURL  := ini.ReadString('main','RyanairStartURL', 'nil');
    if RyanairStartURL='nil' then
    begin
    ShowMessage('Please chech the value of parameter RyanairStartURL in RyanAir.ini');
    exit; //please change the code according to your rules
    end;
    //May change 4 lines according to your rules
    RyanAirGetTotalSumURL := ini.ReadString('main','RyanairGetTotalSumURL', 'nil');
    if RyanAirGetTotalSumURL='nil' then
    begin
    ShowMessage('Please chech the value of parameter RyanairGetTotalSumURL in RyanAir.ini');
    exit; //please change the code according to your rules
    end;

    ini.free;

    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;

    mainPageTime := 0;
    totalPriceTime := 0;
    loc_date_depart := date_depart;
    while loc_date_depart <= date_return do
    begin
      if flexible then
        loc_date_return := loc_date_depart
       else
        loc_date_return := date_return;

//        SetProgress(
//              Round(50*(loc_date_depart-date_depart)/(date_return-date_depart)),
//              mainPageTime div 1000,
//              totalPriceTime div 1000
//              );

      EncodedDataString :=
        'travel_type=on&'+
        'SearchBy=columenView&'+
        'sector1_o='+HTTPEncode('a'+airport_depart)+'&'+
        'sector1_d='+HTTPEncode(airport_destination)+'&'+
        'sector_1_d='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
        'sector_1_m='+DateTimeToStringRet('mmyyyy',loc_date_depart)+'&'+
        'sector_2_d='+DateTimeToStringRet('dd',loc_date_return)+'&'+
        'sector_2_m='+DateTimeToStringRet('mmyyyy',loc_date_return)+'&'+
        'ADULT='+IntToStr(adults)+'&'+
        'CHILD='+IntToStr(children)+'&'+
        'INFANT='+IntToStr(infants)+'&'+
        'mode=1&'+
        'pT='+IntToStr(adults)+'ADULT&'+
        'oP=&'+
        'rP=&'+
        'nom=2&'+
        'date1='+DateTimeToStringRet('ddmmyyyy',loc_date_depart)+'&'+
        'date2='+DateTimeToStringRet('ddmmyyyy',loc_date_return)+'&'+
        'm1='+DateTimeToStringRet('ddmmyyyy',loc_date_depart)+'a'+airport_depart+airport_destination+'&'+
        'm2='+DateTimeToStringRet('ddmmyyyy',loc_date_return)+airport_destination+'a'+airport_depart+'&'+
        'm1DP=0&'+
        'm1DO=0&'+
        'm2DP=0&'+
        'm2DO=0&'+
        'pM=0&'+
        'tc=1&'+
        'language=&'+
        'culture=ie&'+
        'module=SB&'+
        'page=SELECT&'+
        'BalearicUserAnswer=NO&'+
        'acceptTerms=yes' ;

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
      paramWebBrowser.Navigate(RyanAirStartURL, EmptyParam, EmptyParam, PostData, Headers);
        // Wait while page is loading...
      repeat
      Application.HandleMessage;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      mainPageTime := mainPageTime+(GetTickCount-ticks);

      if paramWebBrowser.Document <> nil then
      begin
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
        DocSelect := Doc.all.tags('TR') as IHTMLElementCollection;

        for i := 0 to DocSelect.length-1 do
        begin
          try
            //htmlRow := ((DocElement as IHTMLTable).Rows.item(EmptyParam,k) as IHTMLTableRow);
            htmlRow := DocSelect.Item(i,EmptyParam) as IHTMLTableRow;

            if htmlRow.cells.length = 8 then
            begin
              strHTML := (htmlRow as IHtmlElement).id;

              flight_type :='';
              if Length(strHTML) >0 then
                if strHTML[1] = '1' then
                  flight_type := 'forward'
                 else
                  flight_type := 'reverse';

              // click
//              try
              total_price := '||'+((htmlRow.cells.item(1, 1) as HTMLTableCell).getElementsByTagName('INPUT').item(EmptyParam,0) as IHTMLInputElement).value;
//              except
//              end;

              // flight num
              strHTML := (htmlRow.cells.item(6, 6) as HTMLTableCell).innerHTML;
              Delete(strHTML, 1, pos('<b>Flight</b> ',strHTML)+13);
              Delete(strHTML, 1, pos('FR',strHTML)-1);//+ 3 was changed
              flight_no := strHTML;

              // Volwassene
              strHTML := (htmlRow.cells.item(3, 3) as HTMLTableCell).innerHTML;
              strHTML := Copy(strHTML, 1, pos('<',strHTML)-1);
              strRow := strRow + ', ' + strHTML;

              // 8 sep
              strHTML := (htmlRow.cells.item(6, 6) as HTMLTableCell).innerHTML;
              Delete(strHTML, 1, pos('&nbsp;',strHTML)+5);
              Delete(strHTML, 1, pos('</B>',strHTML)+3);
              strHTML := Copy(strHTML, 1, pos('<BR',strHTML)-1);
              depart_date := strHTML;
              arrival_date := strHTML;

              // 7:00
              strHTML := (htmlRow.cells.item(7, 7) as HTMLTableCell).innerHTML;
              strHTML := StringReplace(strHTML,'&nbsp;',' ',[rfReplaceAll, rfIgnoreCase]);
              if (Length(strHTML)>0)and(strHTML[1]=' ') then
                Delete(strHTML,1,1);
              depart_time := Copy(strHTML, 1, pos(' ',strHTML));
              Delete(strHTML, 1, pos('<BR>',strHTML)+3);
              if (Length(strHTML)>0)and(strHTML[1]=' ') then
                Delete(strHTML,1,1);
              arrival_time := Copy(strHTML, 1, pos(' ',strHTML));

              if returnflight or (flight_type = 'forward') then
                paramOutData.add(
                    flight_type+'|'+
                    depart_date+'|'+
                    depart_time+'|'+
                    arrival_date+'|'+
                    arrival_time+'|'+
                    flight_no+'|'+
                    total_price
                    );
            end;
          except
          end;
        end;
        Doc.close;
      end
       else
        paramOutData.Add('InternalError');

      // Get TotalPrice
      for I := 0 to paramOutData.Count - 1 do
        if pos('|||',paramOutData[i]) >0 then
        begin
          flight_type := paramOutData[i];
          //Delete(flight_type,1,pos('Ryanair|',paramOutData[i])+Length('Ryanair|')-1);
          flight_type := Copy(flight_type,1,pos('|',flight_type)-1);
          //Please don`t remove line below, it causes troubles with 'price' column
          Sleep(200);
          Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;
          strHTML := paramOutData[i];
          Delete(strHTML, 1, pos('|||',paramOutData[i])+Length('|||')-1);

          ticks := GetTickCount;
          paramWebBrowser.Navigate('about:blank');
          // Wait while page is loading...
          repeat
          Application.HandleMessage;
          Sleep(10);
          until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
          paramWebBrowser.Navigate(
                RyanAirGetTotalSumURL+ 'flightKeys='+strHTML+
                '&numberOfMarkets=1&keyDelimeter=%2B%2B%2B',
                EmptyParam, EmptyParam, EmptyParam, Headers);
          // Wait while page is loading...
          repeat
          Application.HandleMessage;
          Sleep(10);
          until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
          totalPriceTime := totalPriceTime+(GetTickCount-ticks);

          if paramWebBrowser.Document <> nil then
          try
            paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
            DocSelect := (doc.all.tags('TR') as IHTMLElementCollection);
          except
          end;
          strHTML := doc.body.innerHTML;

          try
          Delete(strHTML, 1, pos('Totale prijs:',strHTML));
          Delete(strHTML, 1, pos('>',strHTML));
          Delete(strHTML, 1, pos('>',strHTML));
          strHTML := StringReplace(strHTML,'<TD>',' ',[rfReplaceAll, rfIgnoreCase]);
          strHTML := StringReplace(strHTML,'</TD>','',[rfReplaceAll, rfIgnoreCase]);
          strHTML := StringReplace(strHTML,#$D#$A,'',[rfReplaceAll, rfIgnoreCase]);
          except
          end;

          Doc.close;

          total_price := Copy(strHTML, 1, pos('<',strHTML)-1);
          if total_price = '' then
          begin
            strHTML := doc.body.innerHTML;
          end;

          paramOutData[i] := copy(paramOutData[i],1,pos('|||',paramOutData[i]))+total_price;
        end;

      if flexible then
        loc_date_depart := loc_date_depart + 1
       else
        break;
    end;
     Result:= paramOutData;

  finally
  ParamWebBrowser.Free;
  end;

end;

end.
