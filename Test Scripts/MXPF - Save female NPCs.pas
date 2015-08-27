unit UserScript;

uses mteFunctions, mxpf;

function Initialize: Integer;
var
  i: integer;
  sl: TStringList;
begin
  // initialize stringlists
  sl := TStringList.Create;
  files := TStringList.Create;
  
  // get user file selection
  MultiFileSelect(files);
  DefaultOptionsMXPF;
  InitializeMXPF;
  SetInclusions(files.CommaText);
  LoadRecords('NPC_');
  for i := 0 to MaxRecordIndex do begin
    rec := GetRecord(i);
    if geev(rec, 'ACBS/Flags/Female') = '1' then
      sl.Add(Name(rec));
  end;
  FinalizeMXPF;
  
  // clean up
  sl.SaveToFile('Female NPCs.txt');
  files.Free;
  sl.Free;
end;

end.