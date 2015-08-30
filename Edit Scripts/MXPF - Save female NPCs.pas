unit UserScript;

uses 'lib\mteFunctions', 'lib\mxpf';

function Initialize: Integer;
var
  i: integer;
  sl, files: TStringList;
begin
  // initialize stringlists
  sl := TStringList.Create;
  files := TStringList.Create;
  
  // get user file selection
  MultiFileSelect(files);
  InitializeMXPF;
  DefaultOptionsMXPF;
  SetInclusions(files.CommaText);
  LoadRecords('NPC_');
  for i := 0 to MaxRecordIndex do begin
    rec := GetRecord(i);
    if geev(rec, 'ACBS/Flags/Female') = '1' then
      sl.Add(Name(rec));
  end;
  
  // clean up
  FinalizeMXPF;
  sl.SaveToFile('Female NPCs.txt');
  files.Free;
  sl.Free;
end;

end.