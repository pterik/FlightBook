unit Jet4You;
interface

uses
  SysUtils, Classes, Httpapp, MSHTML, ActiveX, OleCtrls, SHDocVw, embeddedwb,
  {$IFNDEF VER130}Variants,{$ENDIF} INIFiles, windows, unit1, messages;

//  {$Define DBG}

type
  TMyEmbeddedWB = class(TEmbeddedWB)
  public
    function MessageHandler(hwnd: THandle;
      lpstrText: POLESTR; lpstrCaption: POLESTR; dwType: longint; lpstrHelpFile: POLESTR;
      dwHelpContext: longint; var plResult: LRESULT): HRESULT;
end;

procedure GetJet4You(
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
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
function TryStrToFloat(str : string; out Value: Double) : Boolean;
function YearOf(const AValue: TDateTime): Word;
function MonthOf(const AValue: TDateTime): Word;

implementation

uses Forms, Controls, Dialogs;



procedure GetJet4You(
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
  i,j,k,a_index,div_index,div2_index,td_index : integer;
  strHTML        : String;
  Doc              : IHTMLDocument2;
  DocSelect        : IHTMLElementCollection;
  DocElement       : IHtmlElement;
  DocElementDivInfo  : IHTMLElement;
  DocElementDivPrice : IHTMLElement;
  DocElementDivInfo2 : IHTMLElement;
  DocElementDivPrice2: IHTMLElement;
  DocElementDivInfoSpec  : boolean;
  DocElementDivPriceSpec : boolean;
  DocElementDivInfo2Spec : boolean;
  DocElementDivPrice2Spec: boolean;
  flight_type,
  flight_no,
  depart_date,
  depart_time,
  arrival_date,
  arrival_time,
  str,
  via,
  price : string;
//  price_infant: double;
//  price_sum,price_numeric : double;
  DateConvertDay,DateConvertMonth,DateConvertYear : integer;
  depart_date_dt,arrival_date_dt : TDateTime;
  ParamWebBrowser: TMyEmbeddedWB;
  DownloadOptions : TDownloadControlOptions;
  currency_code,
  default_flight_suffix,
  Jet4YouStartURL: string;
  Jet4YouSearchURL: string;
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
  ShortMonthNames[10]:= 'Oct';
  ShortMonthNames[11]:= 'Nov';
  ShortMonthNames[12]:= 'Dec';

  ParamWebBrowser := TMyEmbeddedWB.Create(Application.mainForm);
  try
// Don`t forget to insert   uses Forms;  above
    TWinControl(ParamWebBrowser).Name:= 'ParamWebBrowser'+IntToStr(Application.mainform.ComponentCount);
    TWinControl(ParamWebBrowser).Parent:= Application.mainForm;
    ParamWebBrowser.Height := 600;
    ParamWebBrowser.Visible := false;
    //ParamWebBrowser.Visible := true;
    ParamWebBrowser.Align := alTop;
    ParamWebBrowser.Silent := true;
    ParamWebBrowser.OnShowMessage := ParamWebBrowser.MessageHandler;
    ParamWebBrowser.Update;
    DownloadOptions := ParamWebBrowser.DownloadOptions;
    //Exclude(DownloadOptions, DLCTL_DLIMAGES);
    ParamWebBrowser.DownloadOptions := DownloadOptions;
    Application.ProcessMessages;
    IniPath:=extractfiledir(Application.ExeName)+'\data\Jet4You.ini';
    // change the verification accordint to your rules
    if not FileExists(IniPath) then
    begin
      MessageDlg('Unable to proceed, can`t find file'#13#10+'"'+IniPath+'"',mtError,[mbOK],0);
      Halt(0);
    end;
    //May change 4 lines according to your rules
    ini := TIniFile.Create(IniPath);
    Jet4YouStartURL  := ini.ReadString('main','Jet4YouStartURL', 'nil');
    Jet4YouSearchURL := ini.ReadString('main','Jet4YouSearchURL', 'nil');
    default_flight_suffix  := ini.ReadString('main','DefaultFlightSuffix', '');
    ini.free;
    if Jet4YouStartURL='nil' then
    begin
      ShowMessage('Please chech the value of parameter Jet4YouSLOWStartURL in Jet4You.ini');
      exit; //please change the code according to your rules
    end;

   {$IFNDEF DBG}
    ParamWebBrowser.Height := 1;
    ParamWebBrowser.Visible := false;
   {$ENDIF}
   
    Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

    loc_date_depart := date_depart-1;
    while loc_date_depart <= date_return do
    begin
      loc_date_return := loc_date_depart+1;

      //forward
      EncodedDataString :=
'__EVENTTARGET=AvailabilityCompactSearchInputViewType$LinkButtonNewSearch&'+
'__EVENTARGUMENT=&'+
//'AvailabilityCompactSearchInputViewType$RadioButtonMarketStructure='+if_str(returnflight,'RoundTrip','OneWay')+'&'+
'AvailabilityCompactSearchInputViewType$RadioButtonMarketStructure=RoundTrip&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketOrigin1='+airport_depart+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketDestination1='+airport_destination+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketOrigin2=none&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketDestination2=none&'+
//'AvailabilityCompactSearchInputViewType$DropDownListMarketOrigin2='+airport_destination+'&'+
//'AvailabilityCompactSearchInputViewType$DropDownListMarketDestination2='+airport_depart+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketDay1='+DateTimeToStringRet('dd',loc_date_depart)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketMonth1='+DateTimeToStringRet('yyyy',loc_date_depart)+'-'+
                                                                   DateTimeToStringRet('mm',loc_date_depart)+'&'+
'ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDateRange1=4|4&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketDay2='+DateTimeToStringRet('dd',loc_date_return)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListMarketMonth2='+DateTimeToStringRet('yyyy',loc_date_return)+'-'+
                                                                   DateTimeToStringRet('mm',loc_date_return)+'&'+
'ControlGroupSearchView$AvailabilitySearchInputSearchView$DropDownListMarketDateRange2=4|4&'+
'S2AvailabilityCompactSearchInputViewType$DropDownListPassengerType_ADT='+IntToStr(adults)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListPassengerType_ADT='+IntToStr(adults)+'&'+
'S2AvailabilityCompactSearchInputViewType$DropDownListPassengerType_CHD='+IntToStr(children)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListPassengerType_CHD='+IntToStr(children)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListPassengerType_ADTM=0&'+
'AvailabilityCompactSearchInputViewType$DropDownListPassengerType_CHDM=0&'+
'S2AvailabilityCompactSearchInputViewType$DropDownListPassengerType_INFANT='+IntToStr(infants)+'&'+
'AvailabilityCompactSearchInputViewType$DropDownListPassengerType_INFANT='+IntToStr(infants)+'&'+
'ControlGroupSelectView$AvailabilityInputSelectView$market1	W~WJFUR~REGF~~None|8J~ 587~ ~~BLQ~01/23/2011~CMN~01/24/2011&'+
'ControlGroupSelectView$AvailabilityInputSelectView$market2	V~VJFUR~REGF~~None|8J~ 586~ ~~CMN~01/24/2011~BLQ~01/25/2011&'+
'AvailabilityCompactSearchInputViewType$paymentMethod=normalBooking';

      // The PostData OleVariant needs to be an array of bytes
      // as large as the string (minus the 0 terminator)
      PostData := VarArrayCreate([0, length(EncodedDataString)-1], varByte);

      // Now, move the Ordinal value of the character into the PostData array
      for i := 1 to length(EncodedDataString) do
        PostData[i-1] := ord(EncodedDataString[i]);

      Headers := 'Content-type: application/x-www-form-urlencoded'#10#13;

      {$IFDEF DBG}Form1.Caption:='Navigate about:blank';Form1.Refresh;{$ENDIF}

      // Naviagate to blank page
//      paramWebBrowser.Navigate('about:blank');
//      repeat
//      Application.ProcessMessages;
//      Sleep(10);
//      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;
      // Naviagate to source page
      {$IFDEF DBG}Form1.Caption:='Navigate Jet4You';Form1.Refresh;{$ENDIF}
      paramWebBrowser.Navigate(Jet4YouStartURL, EmptyParam, EmptyParam, PostData, Headers);
      // Wait while page is loading...
      repeat
//        if paramWebBrowser.Document <> nil then
//        begin
//          paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
////          paramWebBrowser.OnDocumentComplete
////          DocSelect := (Doc.all.tags('OBJECT')as IHTMLElementCollection);
////          for div_index := 0 to DocSelect.length - 1 do
////          begin
////            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
////            if (Pos('NOFLIGHTS', UpperCase(DocElement.id))>0) then
////              DocElement.outerHTML := '';
////          end;
//          Doc.close;
//        end;
      Application.ProcessMessages;
      Sleep(10);
      until paramWebBrowser.ReadyState >= READYSTATE_COMPLETE;

      {$IFDEF DBG}Form1.Caption:='Navigate Compleate';Form1.Refresh;{$ENDIF}
      //Form1.Caption := Form1.Caption + '+;';

      if paramWebBrowser.Document <> nil then
      begin

        // Whait price info...
        repeat
          IsSuccess := false;
          DocElementDivInfoSpec  := false;
          DocElementDivPriceSpec := false;
          DocElementDivInfo2Spec := false;
          DocElementDivPrice2Spec:= false;

          sleep(10);
          Application.ProcessMessages;
          paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);
          DocSelect := (Doc.all.tags('DIV')as IHTMLElementCollection);
          // Searching flight info div
          for div_index := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            Str := DateTimeToStringRet('d',loc_date_depart)+'/'+
                    DateTimeToStringRet('m',loc_date_depart)+'/'+
                    DateTimeToStringRet('yyyy',loc_date_depart);
            if (Pos('ROW_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT1', UpperCase(DocElement.id))>0) then
            if (Pos(Str, UpperCase(DocElement.innerHTML))>0) then
            begin
              DocElementDivInfo := DocElement;
              DocElementDivInfoSpec := true;
              // forward
              Str := UpperCase(DocElement.id);
              Delete(Str,1,Length('ROW_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT1'));
              for div2_index := 0 to DocSelect.length - 1 do
              begin
                DocElement := DocSelect.Item(div2_index,EmptyParam) as IHTMLElement;
                if (Pos('PRICEDETAILS_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT1'+Str, UpperCase(DocElement.id))>0) then
                begin
                  if (Pos('LOADING_DETAILS_EN.GIF', UpperCase(DocElement.innerHTML))<=0) then
                  begin
                    DocElementDivPrice := DocElement;
                    DocElementDivPriceSpec := true;
                  end;
                  break;
                end;
              end;
            end;
            // return
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            Str := DateTimeToStringRet('d',loc_date_return)+'/'+
                    DateTimeToStringRet('m',loc_date_return)+'/'+
                    DateTimeToStringRet('yyyy',loc_date_return);
            if returnflight then
            if (Pos('ROW_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT2', UpperCase(DocElement.id))>0) then
            if (Pos(Str, UpperCase(DocElement.innerHTML))>0) then
            begin
              DocElementDivInfo2 := DocElement;
              DocElementDivInfo2Spec := true;
              Str := UpperCase(DocElement.id);
              Delete(Str,1,Length('ROW_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT2'));
              for div2_index := 0 to DocSelect.length - 1 do
              begin
                DocElement := DocSelect.Item(div2_index,EmptyParam) as IHTMLElement;
                if (Pos('PRICEDETAILS_CONTROLGROUPSELECTVIEW_AVAILABILITYINPUTSELECTVIEW_RADIOBUTTONMKT2'+Str, UpperCase(DocElement.id))>0) then
                begin
                  if (Pos('LOADING_DETAILS_EN.GIF', UpperCase(DocElement.innerHTML))<=0) then
                  begin
                    DocElementDivPrice2 := DocElement;
                    DocElementDivPrice2Spec := true;
                  end;
                  break;
                end;
              end;
            end;
          end;
          Doc.Close;
        until
          ((not DocElementDivInfoSpec)or(DocElementDivPriceSpec))
          and
          ((not DocElementDivInfo2Spec)or(DocElementDivPrice2Spec));

      {$IFDEF DBG}Form1.Caption:='Found Price Div';Form1.Refresh;{$ENDIF}

        // check date
        if flexible then
          if (loc_date_depart<date_depart) or (loc_date_depart>date_return) then
            DocElementDivInfoSpec := false;
        if not flexible then
          if (loc_date_depart<>date_depart) and (loc_date_depart<>date_return) then
            DocElementDivInfoSpec := false;
        if flexible then
          if (loc_date_return<date_depart) or (loc_date_return>date_return) then
            DocElementDivInfo2Spec := false;
        if not flexible then
          if (loc_date_return<>date_depart) and (loc_date_return<>date_return) then
            DocElementDivInfo2Spec := false;

        // Get Data
        paramWebBrowser.Document.QueryInterface(IHTMLDocument2, Doc);

        // forward
        if DocElementDivInfoSpec then
        begin
          DocSelect := ((DocElementDivInfo.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
          // -
          depart_date := '';
          depart_time := '';
          arrival_date := '';
          arrival_time := '';
          flight_no := '';
          price := '';
          via := '';
          // -
          for div_index := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            if pos('SELECTDATE', UpperCase(DocElement.className))>0 then
            begin
              depart_date := DocElement.innerHTML;          
              arrival_date:= DocElement.innerHTML;
            end;
            if pos('SELECTTIME', UpperCase(DocElement.className))>0 then
            begin
              strHTML := DocElement.innerHTML;
              if Pos('-',strHTML) >0 then
              begin
                depart_time := Trim(Copy(strHTML,1,Pos('-',strHTML)-1));
                Delete(strHTML,1,Pos('-',strHTML));
              end;
              arrival_time := Trim(strHTML);
            end;
            if pos('SELECTFLIGHTNUMBER', UpperCase(DocElement.className))>0 then
            begin
              flight_no := DocElement.innerHTML;
              flight_no := StringReplace(flight_no,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
            end;
            if pos('SELECTFLIGHTNUMBER', UpperCase(DocElement.className))>0 then
            begin
              flight_no := DocElement.innerHTML;
              flight_no := StringReplace(flight_no,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
            end;

          end;

          // -
          DocSelect := ((DocElementDivPrice.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
          for div_index := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            if pos('FORMROW', UpperCase(DocElement.className))>0 then
            if pos('TOTAL', UpperCase(DocElement.innerHTML))>0 then
            begin
              strHTML := DocElement.innerHTML;
              if Pos('<STRONG>', UpperCase(strHTML)) > 0 then
                Delete(strHTML, 1, Pos('<STRONG>', strHTML));
              if Pos('>', strHTML) > 0 then
                Delete(strHTML, 1, Pos('>', strHTML));
              if Pos('</DIV>', UpperCase(strHTML)) > 0 then
                strHTML := copy(strHTML, 1, Pos('</DIV>', UpperCase(strHTML)));
              strHTML := StringReplace(strHTML,'strong', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'/', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'<', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'>', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
              price := Trim(strHTML);
            end;
          end;

          {$IFDEF DBG}Form1.Caption:='forward';Form1.Refresh;{$ENDIF}
          paramOutData.add(
                FloatToStr(loc_date_depart)+'forward'+depart_time+'|'+  // sort field
                'forward|'+
                depart_date+'|'+
                depart_time+'|'+
                arrival_date+'|'+
                arrival_time+'|'+
                flight_no+'|'+
                price+'|'+//FloatToStr(price)+'|'+
                via
                );
        end;

        // return
        if DocElementDivInfo2Spec then
        begin
          DocSelect := ((DocElementDivInfo2.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
          // -
          depart_date := '';
          depart_time := '';
          arrival_date := '';
          arrival_time := '';
          flight_no := '';
          price := '';
          via := '';
          // -
          // -
          for div_index := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            if pos('SELECTDATE', UpperCase(DocElement.className))>0 then
            begin
              depart_date := DocElement.innerHTML;
              arrival_date:= DocElement.innerHTML;
            end;
            if pos('SELECTTIME', UpperCase(DocElement.className))>0 then
            begin
              strHTML := DocElement.innerHTML;
              if Pos('-',strHTML) >0 then
              begin
                depart_time := Trim(Copy(strHTML,1,Pos('-',strHTML)-1));
                Delete(strHTML,1,Pos('-',strHTML));
              end;
              arrival_time := Trim(strHTML);
            end;
            if pos('SELECTFLIGHTNUMBER', UpperCase(DocElement.className))>0 then
            begin
              flight_no := DocElement.innerHTML;
              flight_no := StringReplace(flight_no,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
            end;
            if pos('SELECTFLIGHTNUMBER', UpperCase(DocElement.className))>0 then
            begin
              flight_no := DocElement.innerHTML;
              flight_no := StringReplace(flight_no,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
            end;

          end;

          // -
          DocSelect := ((DocElementDivPrice2.all as IHTMLElementCollection).tags('DIV')as IHTMLElementCollection);
          for div_index := 0 to DocSelect.length - 1 do
          begin
            DocElement := DocSelect.Item(div_index,EmptyParam) as IHTMLElement;
            if pos('FORMROW', UpperCase(DocElement.className))>0 then
            if pos('TOTAL', UpperCase(DocElement.innerHTML))>0 then
            begin
              strHTML := DocElement.innerHTML;
              if Pos('<STRONG>', UpperCase(strHTML)) > 0 then
                Delete(strHTML, 1, Pos('<STRONG>', strHTML));
              if Pos('>', strHTML) > 0 then
                Delete(strHTML, 1, Pos('>', strHTML));
              if Pos('</DIV>', UpperCase(strHTML)) > 0 then
                strHTML := copy(strHTML, 1, Pos('</DIV>', UpperCase(strHTML)));
              strHTML := StringReplace(strHTML,'strong', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'/', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'<', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'>', ' ',[rfReplaceAll, rfIgnoreCase]);
              strHTML := StringReplace(strHTML,'&nbsp;', ' ',[rfReplaceAll, rfIgnoreCase]);
              price := Trim(strHTML);
            end;
          end;
          // -
          {$IFDEF DBG}Form1.Caption:='reverse';Form1.Refresh;{$ENDIF}
          paramOutData.add(
                FloatToStr(loc_date_return)+'reverse'+depart_time+'|'+  // sort field
                'reverse|'+
                depart_date+'|'+
                depart_time+'|'+
                arrival_date+'|'+
                arrival_time+'|'+
                flight_no+'|'+
                price+'|'+//FloatToStr(price)+'|'+
                via
                );
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
        if loc_date_depart = date_depart then
          loc_date_depart := date_return-1
         else
        if loc_date_depart = date_return-1 then
          loc_date_depart := date_return;
      end;
      
    end;

  finally
    //paramOutData.savetofile('d:\My Dropbox\BookFlights\temp\qwe.txt');
    ParamWebBrowser.Free;
  end;
end;

function DateTimeToStringRet(paramFormat: String; paramDate: TDateTime) : string;
begin
  DateTimeToString(Result, paramFormat, paramDate);
end;
function if_str(Expression: Boolean; TrueValue: string;FalseValue: string) : string;
begin
  if Expression then
    Result := TrueValue
   else
    Result := FalseValue;
end;
function TryStrToInt(str : string; out Value: Integer) : Boolean;
var
  i : integer;
begin
  Value := 0;
  for i := 1 to length(str) do
    if not(str[i] in ['0','1','2','3','4','5','6','7','8','9','.',',',' ','-','+']) then
    begin
      Result := False;
      exit
    end;
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
    if str <> '' then
      Value := StrToFloat(str);
    result := true;
  except
    result := false;
  end;
end;
function YearOf(const AValue: TDateTime): Word;
var
  LMonth, LDay: Word;
begin
  DecodeDate(AValue, Result, LMonth, LDay);
end;
function MonthOf(const AValue: TDateTime): Word;
var
  LYear, LDay: Word;
begin
  DecodeDate(AValue, LYear, Result, LDay);
end;

{ TMyEmbeddedWB }

function TMyEmbeddedWB.MessageHandler(hwnd: THandle; lpstrText,
  lpstrCaption: POLESTR; dwType: Integer; lpstrHelpFile: POLESTR;
  dwHelpContext: Integer; var plResult: LRESULT): HRESULT;
begin
  Result:=S_OK; //Don't show the messagebox
end;

end.


