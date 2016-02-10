{
  MXPF - Save Female NPCs
  by matortheeternal
  
  Sample MXPF script which saves a list of female NPCs
  from a user-selected list of a files to a text document
  in the same directory as TES5Edit.exe.
}

unit UserScript;

uses 'lib\mxpf';

function Initialize: Integer;
var
  i: integer;
  sFiles: String;
  sl: TStringList;
  rec: IInterface;
begin
  // get file selection from user
  if not MultiFileSelectString('Select the files you want to load Female NPCs from', sFiles) then
    exit; // if user cancels, exit
  
  // use MXPF to load NPC_ records from the user's file selection
  InitializeMXPF;
  DefaultOptionsMXPF;
  SetInclusions(sFiles);
  LoadRecords('NPC_');
  
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