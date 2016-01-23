{
  MXPF - Reweight Keys
  by matortheeternal
  
  Sample MXPF Script, sets Key record weights to 0.05.
  
  This script makes use of the QuickPatch macro, which allows 
  it to work in 3 lines of code.
}

unit UserScript;

uses 'lib\mxpf';

function Initialize: Integer;
var
  i: integer;
begin
  QuickPatch('MXPF - Reweight Keys', mxHardcodedDatFiles, 'KEYM');
  for i := MaxPatchRecordIndex downto 0 do 
    seev(GetPatchRecord(i), 'DATA\Weight', '0.05');
  FinalizeMXPF;
end;

end.
