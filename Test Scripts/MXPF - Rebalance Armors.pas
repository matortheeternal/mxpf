{
  Test mxpf
}

unit UserScript;

uses mxpf, mteFunctions;

function Initialize: Integer;
var
  i: integer;
  armorRating, newArmorRating: real;
  rec: IInterface;
begin
  // set MXPF options and initialize it
  DefaultOptionsMXPF;
  InitializeMXPF;
  
  // select/create a new patch file that will be identified by its author field
  PatchFileByAuthor('TestMXPF');
  SetExclusions(mxBethesdaFiles); // excludes bethesda files from record loading
  LoadRecords('ARMO'); // loads all Armor records
  
  // you can filter the loaded records like this
  // it's important that the loop starts at MaxRecordIndex and goes down to 0
  // because we're removing records
  for i := MaxRecordIndex downto 0 do begin
    rec := GetRecord(i);
    // remove records that don't have the ArmorLight keyword
    if not HasKeyword(rec, 'ArmorLight') then
      RemoveRecord(i)
    // remove records with DNAM - Armor Rating = 0
    else if (genv(rec, 'DNAM - Armor Rating') = 0) then
      RemoveRecord(i);
  end;
  
  // then copy records to the patch file
  CopyRecordsToPatch;
  
  // and set values on them
  for i := 0 to MaxPatchRecordIndex do begin
    rec := GetPatchRecord(i);
    armorRating := StrToFloat(geev(rec, 'DNAM'));
    newArmorRating := Int(armorRating * 1.25);
    AddMessage(Format('Changed armor rating from %0.2f to %0.2f on %s', [armorRating, newArmorRating, Name(rec)]));
    seev(rec, 'DNAM', FloatToStr(newArmorRating));
  end;
  
  // call PrintMXPFReport for a report on successes and failures
  PrintMXPFReport;
  
  // always call FinalizeMXPF when done
  FinalizeMXPF;
end;

end.
