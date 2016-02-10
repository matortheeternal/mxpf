{
  MXPF - Save Female NPCs - Quick
  by matortheeternal
  
  Sample script for MXPF which is the same as the Save
  Female NPCs script, but makes use of the MXPF macros
  MultiFileSelectString and QuickLoad.
}

unit UserScript;

uses 'lib\mxpf';

function Initialize: Integer;
var
  sl: TStringList;
  sFiles: String;
  i: integer;
  rec: IInterface;
begin
  // get file selection from user
  if not MultiFileSelectString('Select the files you want to load Female NPCs from', sFiles) then 
    exit; // if user cancels, exit
  
  // set up MXPF and load NPC_ records from files the user selected
  QuickLoad(sFiles, 'NPC_', true);
  
  // initialize stringlist which will hold a list of female NPCs we find
  sl := TStringList.Create;
    
  // add names of female NPCs to the stringlist
  for i := 0 to MaxRecordIndex do begin
    rec := GetRecord(i);
    if geev(rec, 'ACBS/Flags/Female') = '1' then
      sl.Add(Name(rec));
  end;
  
  // clean up
  FinalizeMXPF;
  sl.SaveToFile('Female NPCs.txt');
  sl.Free;
end;

end.