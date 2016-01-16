{
  Mator's xEdit Patching Framework
  by matortheeternal
}

unit mxpf;

uses 'lib\mteFunctions';

const
  { USER CONSTANTS - FEEL FREE TO CHANGE }
  // debug constants
  mxDebug = true;
  mxDebugVerbose = false;
  
  // logging constants
  mxSaveDebug = true;
  mxSaveFailures = true;
  mxPrintDebug = false;
  mxPrintFailures = true;
  mxEchoDebug = false;
  mxEchoFailures = false;
  
  { DEVELOPER CONSTANTS - DON'T CHANGE }
  // version constant
  mxVersion = '0.2.0';
  
  // mode constants
  mxExclusionMode = 1;
  mxInclusionMode = 2;
  
  // comma separated list of bethesda skyrim files
  mxBethesdaSkyrimFiles = 'Skyrim.esm'#44'Update.esm'#44'Dawnguard.esm'#44'HearthFires.esm'#44
  'Dragonborn.esm'#44
  'Skyrim.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat';
  
  // comma separated list of hardcoded dat files
  mxHardcodedDatFiles = 
  'Skyrim.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#44
  'Fallout3.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#44
  'Oblivion.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat'#44
  'FalloutNV.Hardcoded.keep.this.with.the.exe.and.otherwise.ignore.it.I.really.mean.it.dat';

var
  mxFiles, mxMasters, mxDebugMessages, mxFailureMessages: TStringList;
  mxRecords, mxPatchRecords: TList;
  mxFileMode, mxRecordsCopied, mxRecordsFound, mxMasterRecords, 
  mxOverrideRecords: Integer;
  mxInitialized, mxLoadCalled, mxCopyCalled, mxLoadMasterRecords, 
  mxLoadOverrideRecords, mxLoadWinningOverrides, mxMastersAdded,
  mxSkipPatchedRecords, mxDisallowNewFile, mxDisallowSaving, 
  mxDisallowPrinting: boolean;
  mxPatchFile: IInterface;

//=========================================================================
// DEBUG MESSAGES
//=========================================================================
procedure DebugMessage(s: string);
begin
  mxDebugMessages.Add(s);
  if mxEchoDebug then AddMessage(s);
end;

procedure DebugList(var sl: TStringList; pre: string);
var
  i: integer;
begin
  for i := 0 to Pred(sl.Count) do
    DebugMessage(pre + sl[i]);
end;

procedure SaveDebugMessages;
var
  filename: string;
begin
  // exit if no debug messages to save
  if (mxDebugMessages.Count = 0) then exit;
  // exit if saving is disallowed
  if mxDisallowSaving then exit;
  
  // save to mxpf logs folder in scripts path
  filename := ScriptsPath + 'logs\mxpf\mxpf-debug-'+FileDateTimeStr(Now)+'.txt';
  AddMessage('MXPF Debug Log saved to '+filename);
  ForceDirectories(ExtractFilePath(filename));
  mxDebugMessages.SaveToFile(filename);
end;

procedure PrintDebugMessages;
begin
  // exit if no debug messages to print
  if (mxDebugMessages.Count = 0) then exit;
  // exit if printing is disallowed
  if mxDisallowPrinting then exit;
  
  // else print to xEdit's log
  AddMessage(mxDebugMessages.Text);
end;

//=========================================================================
// FAILURE MESSAGES
//=========================================================================
procedure FailureMessage(s: string);
begin
  mxFailureMessages.Add(s);
  if mxEchoFailures then AddMessage(s);
end;

procedure SaveFailureMessages;
var
  filename: string;
begin
  // exit if no failure messages to save
  if (mxFailureMessages.Count = 0) then exit;
  // exit if saving is disallowed
  if mxDisallowSaving then exit;
  
  // save to mxpf logs folder in scripts path
  filename := ScriptsPath + 'logs\mxpf\mxpf-failures-'+FileDateTimeStr(Now)+'.txt';
  AddMessage('MXPF Failures Log saved to '+filename);
  ForceDirectories(ExtractFilePath(filename));
  mxFailureMessages.SaveToFile(filename);
end;

procedure PrintFailureMessages;
begin
  // exit if no failure messages to print
  if (mxFailureMessages.Count = 0) then exit;
  // exit if printing is disallowed
  if mxDisallowPrinting then exit;
  
  // else print to xEdit's log
  AddMessage(mxFailureMessages.Text);
end;
  
//=========================================================================
// GENERAL
//=========================================================================
procedure InitializeMXPF;
begin
  mxInitialized := true;
  mxDebugMessages := TStringList.Create;
  mxFailureMessages := TStringList.Create;
  mxMasters := TStringList.Create;
  mxMasters.Sorted := true;
  mxMasters.Duplicates := dupIgnore;
  mxFiles := TStringList.Create;
  mxRecords := TList.Create;
  mxPatchRecords := TList.Create;
  if mxDebug then begin
    DebugMessage('MXPF Initialized at '+TimeStr(Now));
    DebugMessage(' ');
  end;
end;

procedure DefaultOptionsMXPF;
begin
  mxLoadMasterRecords := true;
  mxSkipPatchedRecords := true;
  mxLoadWinningOverrides := true;
end;

procedure FinalizeMXPF;
begin
  // clean masters on mxPatchFile if it exists
  if Assigned(mxPatchFile) then
    CleanMasters(mxPatchFile);

  // log finalization
  if mxDebug then begin
    DebugMessage(' ');
    DebugMessage('MXPF Finalized at '+TimeStr(Now));
  end;
  // print/save messages
  if mxPrintDebug then PrintDebugMessages;
  if mxPrintFailures then PrintFailureMessages;
  if mxSaveDebug then SaveDebugMessages;
  if mxSaveFailures then SaveFailureMessages;
  
  // reset variables
  mxInitialized := false;
  mxLoadCalled := false;
  mxCopyCalled := false;
  mxLoadMasterRecords := false;
  mxLoadOverrideRecords := false;
  mxLoadWinningOverrides := false;
  mxFileMode := 0;
  mxRecordsCopied := 0;
  mxPatchFile := nil;
  
  // free memory allocated for lists
  FreeAndNil(mxDebugMessages);
  FreeAndNil(mxFailureMessages);
  FreeAndNil(mxFiles);
  FreeAndNil(mxMasters);
  FreeAndNil(mxRecords);
  FreeAndNil(mxPatchRecords);
end;


//=========================================================================
// PATCH FILE SELECTION 
//=========================================================================
procedure PatchFileByAuthor(author: string);
var
  madeNewFile: boolean;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling PatchFileByAuthor');
  
  // select existing file or create new one
  madeNewFile := false;
  mxPatchFile := FileByAuthor(author);
  if not (Assigned(mxPatchFile) or mxDisallowNewFile) then begin
    mxPatchFile := AddNewFile;
    SetAuthor(mxPatchFile, author);
    madeNewFile := true;
  end;
  
  // print debug messages
  if mxDebug then begin
    if madeNewFile then 
      DebugMessage(Format('MXPF: Made new file %s, with author %s', [GetFileName(mxPatchFile), GetAuthor(mxPatchFile)]))
    else
      DebugMessage(Format('MXPF: Using patch file %s', [GetFileName(mxPatchFile)]));
    DebugMessage(' ');
  end;
end;

procedure PatchFileByName(filename: string);
var
  madeNewFile: boolean;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling PatchFileByName');
  
  // select existing file or create new one
  madeNewFile := false;
  mxPatchFile := FileByName(filename);
  if not (Assigned(mxPatchFile) or mxDisallowNewFile) then begin
    ShowMessage('Enter "'+ChangeFileExt(filename, '')+'" for the patch filename in the next window.'); 
    mxPatchFile := AddNewFile;
    madeNewFile := true;
  end;
  
  // if user entered invalid filename, tell them
  if not SameText(GetFileName(mxPatchFile), filename) then
    ShowMessage('You entered an incorrect filename.  The script will not recognize this file as the patch in the future.');
    
  // print debug messages
  if mxDebug then begin
    if madeNewFile then 
      DebugMessage(Format('MXPF: Made new file %s', [GetFileName(mxPatchFile)]))
    else
      DebugMessage(Format('MXPF: Using patch file %s', [GetFileName(mxPatchFile)]));
    DebugMessage(' ');
  end;
end;

//=========================================================================
// FILE EXCLUSIONS / INCLUSIONS
//=========================================================================
procedure SetExclusions(s: string);
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling SetExclusions');
  
  // set files to string
  mxFileMode := mxExclusionMode;
  mxFiles.CommaText := s;
  
  // print debug messages if in debug mode
  if mxDebug then begin
    DebugMessage('MXPF: Set exclusions to:');
    DebugList(mxFiles, '  ');
    DebugMessage(' ');
  end;
end;

procedure SetInclusions(s: string);
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then 
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling SetInclusions');
  
  // set files to string
  mxFileMode := mxInclusionMode;
  mxFiles.CommaText := s;
  
  // print debug messages if in debug mode
  if mxDebug then begin
    DebugMessage('MXPF: Set inclusions to:');
    DebugList(mxFiles, '  ');
    DebugMessage(' ');
  end;
end;

//=========================================================================
// RECORD PROCESSING
//=========================================================================
procedure LoadRecords(sig: string);
var
  start: TDateTime;
  i, j, n: Integer;
  f, g, rec: IInterface;
  filename: string;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling LoadRecords');
  
  // set boolean so we know the user called this function
  mxLoadCalled := true;
  // track time so we know how long the load takes
  start := Now;
  // set mxMastersAdded to false because they may change
  mxMastersAdded := false;
  
  // loop through files
  DebugMessage('MXPF: Loading records matching signature '+sig);
  for i := 0 to Pred(FileCount) do begin
    f := FileByIndex(i);
    filename := GetFileName(f);
    
    // skip patch file
    if Assigned(mxPatchFile) then begin
      if filename = GetFileName(mxPatchFile) then begin
        if mxDebug then DebugMessage('  Skipping patch file '+filename);
        break;
      end;
    end;

    // handle file mode
    if mxFileMode = mxExclusionMode then begin
      // skip files if in exclusion mode
      if mxFiles.IndexOf(filename) > -1 then begin
        if mxDebug then DebugMessage('  Skipping excluded file '+filename);
        continue;
      end;
    end
    else if mxFileMode = mxInclusionMode then begin
      // include files if in inclusion mode
      if mxFiles.IndexOf(filename) = -1 then begin
        if mxDebug then DebugMessage('  Skipping file '+filename);
        continue;
      end;
    end;
      
    // get group
    DebugMessage('  Processing file '+filename);
    g := GroupBySignature(f, sig);
    
    // skip if group not found
    if not Assigned(g) then begin
      if mxDebug then DebugMessage('    Group '+sig+' not found.');
      continue;
    end;
    
    // add masters
    AddMastersToList(f, mxMasters);
    
    mxRecordsFound := 0;
    mxMasterRecords := 0;
    mxOverrideRecords := 0;
    // loop through records in group
    for j := 0 to Pred(ElementCount(g)) do begin
      rec := ElementByIndex(g, j);
      
      // if restricted to master records only, skip if not master record
      if mxLoadMasterRecords and not IsMaster(rec) then begin
        if mxDebug and mxDebugVerbose then DebugMessage('   Skipping override record '+Name(rec));
        Inc(mxOverrideRecords);
        continue;
      end;
      
      // if restricted to override records only, skip if not override record
      if mxLoadOverrideRecords and IsMaster(rec) then begin
        if mxDebug and mxDebugVerbose then DebugMessage('   Skipping master record '+Name(rec));
        Inc(mxMasterRecords);
        continue;
      end;
      
      // if loading winning override records, get winning override
      if mxLoadWinningOverrides then begin
        try
          rec := WinningOverrideBefore(rec, mxPatchFile);
          if mxDebug and mxDebugVerbose then DebugMessage(Format('   Using override from %s', 
            [GetFileName(GetFile(rec))]));
        except
          on x: Exception do begin
            DebugMessage('   Exception getting winning override for '+Name(rec));
            continue;
          end;
        end;
      end;
      
      // add record to list
      if mxDebug and mxDebugVerbose then DebugMessage('     Found record '+Name(rec));
      mxRecords.Add(TObject(rec));
      Inc(mxRecordsFound);
    end;
    
    // print number of records we added to the list
    if mxDebug and not mxDebugVerbose then begin
      DebugMessage(Format('    Found %d records', [mxRecordsFound]));
      if mxLoadMasterRecords then 
        DebugMessage(Format('    Skipped %d override records', [mxOverrideRecords]));   
      if mxLoadOverrideRecords then 
        DebugMessage(Format('    Skipped %d master records', [mxMasterRecords]));
    end;
  end;
  
  // print final debug messages
  if mxDebug then begin
    if mxRecords.Count > 0 then
      DebugMessage(Format('MXPF: Loaded %d records in %0.2fs', [mxRecords.Count, Now - start]))
    else
      DebugMessage('MXPF: Couldn''t find any records matching signature '+sig);
    DebugMessage(' ');
  end;
end;

procedure LoadChildRecords(sig, groupSig: string);
var
  start: TDateTime;
  i, j: Integer;
  f, g, rec: IInterface;
  filename: string;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitializeMXPF before calling LoadChildRecords');
  
  // set boolean so we know the user called this function
  mxLoadCalled := true;
  // track time so we know how long the load takes
  start := Now;
  // set mxMastersAdded to false because they may change
  mxMastersAdded := false;
  // set mxRecordsFound to 0 so it is not nil
  mxRecordsFound := 0;
  
  // loop through files
  DebugMessage('MXPF: Loading records matching signature '+sig);
  for i := 0 to Pred(FileCount) do begin
    f := FileByIndex(i);
    filename := GetFileName(f);
    
    // skip patch file
    if filename = GetFileName(mxPatchFile) then begin
      if mxDebug then DebugMessage('  Skipping patch file '+filename);
      break;
    end;
    
    // handle file mode
    if mxFileMode = mxExclusionMode then begin
      // skip files if in exclusion mode
      if mxFiles.IndexOf(filename) > -1 then begin
        if mxDebug then DebugMessage('  Skipping excluded file '+filename);
        continue;
      end;
    end
    else if mxFileMode = mxInclusionMode then begin
      // include files if in inclusion mode
      if mxFiles.IndexOf(filename) = -1 then begin
        if mxDebug then DebugMessage('  Skipping file '+filename);
        continue;
      end;
    end;
      
    // get group
    DebugMessage('  Processing file '+filename);
    g := GroupBySignature(f, groupSig);
    
    // skip if group not found
    if not Assigned(g) then begin
      if mxDebug then DebugMessage('    Group '+groupSig+' not found.');
      continue;
    end;
    
    // add masters
    AddMastersToList(f, mxMasters);
    
    // load records with wbGetSiblingRecords
    wbGetSiblingRecords(g, sig, false, mxRecords);
    mxOverrideRecords := 0;
    mxMasterRecords := 0;
    mxRecordsFound := mxRecords.Count - mxRecordsFound;
    
    // filter records
    if (mxLoadMasterRecords or mxLoadOverrideRecords or mxLoadWinningOverrides) then begin
      for j := Pred(mxRecords.Count) downto 0 do begin
        rec := ObjectToElement(mxRecords[j]);
        
        // if restricted to master records only, remove if not master record
        if mxLoadMasterRecords and not IsMaster(rec) then begin
          if mxDebug and mxDebugVerbose then DebugMessage('    Removing override record '+Name(rec));
          mxRecords.Delete(j);
          Inc(mxOverrideRecords);
          continue;
        end;
        
        // if restricted to override records only, skip if not override record
        if mxLoadOverrideRecords and IsMaster(rec) then begin
          if mxDebug and mxDebugVerbose then DebugMessage('    Removing master record '+Name(rec));
          mxRecords.Delete(j);
          Inc(mxMasterRecords);
          continue;
        end;
        
        // if loading winning override records, get winning override
        if mxLoadWinningOverrides then try
          if mxDebug and mxDebugVerbose then DebugMessage('    Loading winning override from '+GetFileName(GetFile(rec)));
          mxRecords[j] := wObj;
        except
          on x: Exception do begin
            DebugMessage('    Exception getting winning override for '+Name(rec));
            mxRecords.Delete(j);
            continue;
          end;
        end;
      end;
    end;
    
    // print number of records we added to the list
    if mxDebug and not mxDebugVerbose then begin
      DebugMessage(Format('    Found %d records', [mxRecordsFound]));
      if mxLoadMasterRecords then 
        DebugMessage(Format('    Removed %d override records', [mxOverrideRecords]));
      if mxLoadWinningOverrides then 
        DebugMessage(Format('    Removed %d master records', [mxMasterRecords]));
    end;
  end;
  
  // print final debug messages
  if mxDebug then begin
    if mxRecords.Count > 0 then
      DebugMessage(Format('MXPF: Loaded %d records in %0.2fs', [mxRecords.Count, Now - start]))
    else
      DebugMessage('MXPF: Couldn''t find any records matching signature '+sig);
    DebugMessage(' ');
  end;
end;

function MaxRecordIndex: Integer;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling MaxRecordIndex');
  
  // return value if checks pass
  Result := mxRecords.Count - 1;
  if mxDebugVerbose then DebugMessage(Format('MXPF: MaxRecordIndex returned %d', [Result]));
end;

function GetRecord(i: integer): IInterface;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling LoadRecords');
  // if user hasn't loaded records, raise exception
  if not mxLoadCalled then
    raise Exception.Create('MXPF Error: You need to call LoadRecords before you can access records using GetRecord');
  // if no records available, raise exception
  if mxRecords.Count = 0 then
    raise Exception.Create('MXPF Error: Can''t call GetRecord, no records available');
  // if index is out of bounds, raise an exception
  if (i < 0) or (i > MaxRecordIndex) then
    raise Exception.Create('MXPF Error: GetRecord index out of bounds');
  
  // if all checks pass, return record at user specified index
  Result := ObjectToElement(mxRecords[i]);
  if mxDebug then DebugMessage(Format('MXPF: GetRecord at index %d returned %s', [i, Name(Result)]));
end;

procedure RemoveRecord(i: integer);
var
  n: string;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling RemoveRecord');
  // if user hasn't loaded records, raise exception
  if not mxLoadCalled then
    raise Exception.Create('MXPF Error: You need to call LoadRecords before you can remove records using RemoveRecord');
  // if no records available, raise exception
  if mxRecords.Count = 0 then
    raise Exception.Create('MXPF Error: Can''t call RemoveRecord, no records available');
  // if index is out of bounds, raise an exception
  if (i < 0) or (i > MaxRecordIndex) then
    raise Exception.Create('MXPF Error: RemoveRecord index out of bounds');
  
  // if all checks pass, remove record at user specified index
  n := Name(ObjectToElement(mxRecords[i]));
  mxRecords.Delete(i);
  if mxDebug then DebugMessage(Format('MXPF: Removed record at index %d, %s', [i, n]));
end;

//=========================================================================
// RECORD PATCHING
//=========================================================================
procedure AddMastersToPatch;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling AddMastersToPatch');
  // if user hasn't loaded records, raise exception
  if not mxLoadCalled then
    raise Exception.Create('MXPF Error: You need to call LoadRecords before you can call AddMastersToPatch');
  // if user hasn't assigned a patch file, raise exception
  if not Assigned(mxPatchFile) then
    raise Exception.Create('MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling AddMastersToPatch');
  
  // add masters to mxPatchFile
  AddMastersToFile(mxPatchFile, mxMasters, true);
  mxMastersAdded := true;
  if mxDebug then begin
    DebugMessage('MXPF: Added masters to patch file.');
    DebugList(mxMasters, '  ');
    DebugMessage(' ');
  end;
end;

function CopyRecordToPatch(i: integer): IInterface;
var
  rec: IInterface;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling CopyRecordToPatch');
  // if user hasn't loaded records, raise exception
  if not mxLoadCalled then
    raise Exception.Create('MXPF Error: You need to call LoadRecords before you can copy records using CopyRecordToPatch');
  // if user hasn't assigned a patch file, raise exception
  if not Assigned(mxPatchFile) then
    raise Exception.Create('MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling CopyRecordToPatch');
  // if no records available, raise exception
  if mxRecords.Count = 0 then
    raise Exception.Create('MXPF Error: Can''t call CopyRecordToPatch, no records available');
  // if index is out of bounds, raise an exception
  if (i < 0) or (i > MaxRecordIndex) then
    raise Exception.Create('MXPF Error: CopyRecordToPatch index out of bounds');
  
  // if all checks pass, try copying record
  rec := ObjectToElement(mxRecords[i]);
    
  // exit if record already exists in patch
  if mxSkipPatchedRecords and OverrideExistsIn(rec, mxPatchFile) then begin
    DebugMessage(Format('Skipping record %s, already in patch!', [Name(rec)]));
    exit;
  end;
  
  // set boolean so we know the user called this function
  mxCopyCalled := true;
  
  // add masters to patch file if we haven't already
  if not mxMastersAdded then AddMastersToPatch;
  
  // copy record to patch
  try
    Result := wbCopyElementToFile(rec, mxPatchFile, false, true);
    mxPatchRecords.Add(TObject(Result));
    if mxDebug then DebugMessage(Format('Copied record %s to patch file', [Name(Result)]));
  except on x: Exception do
    FailureMessage(Format('Failed to copy record %s, Exception: %s', [Name(rec), x.Message]));
  end;
end;

procedure CopyRecordsToPatch;
var
  i: integer;
  start: TDateTime;
  rec, patchRec: IInterface;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling CopyRecordsToPatch');
  // if user hasn't loaded records, raise exception
  if not mxLoadCalled then
    raise Exception.Create('MXPF Error: You need to call LoadRecords before you can copy records using CopyRecordsToPatch');
  // if user hasn't assigned a patch file, raise exception
  if not Assigned(mxPatchFile) then
    raise Exception.Create('MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling CopyRecordsToPatch');
  // if no records available, raise exception
  if mxRecords.Count = 0 then
    raise Exception.Create('MXPF Error: Can''t call CopyRecordsToPatch, no records available');
  
  // set boolean so we know the user called this function
  mxCopyCalled := true;
  // track time so we know how long the load takes
  start := Now;
  
  // add masters to patch file if we haven't already
  if not mxMastersAdded then AddMastersToPatch;
  
  // log message
  DebugMessage('MXPF: Copying records to patch '+GetFileName(mxPatchfile));
  
  // if all checks pass, loop through records list
  for i := 0 to Pred(mxRecords.Count) do begin
    rec := ObjectToElement(mxRecords[i]);
    if mxLoadWinningOverrides then 
      rec := WinningOverrideBefore(rec, mxPatchFile);
    
    // winningOverrideBefore failed
    if not Assigned(rec) then begin
      FailureMessage(Format('Failed to copy record %s, WinningOverrideBefore failure', [Name(rec)]));
      continue;
    end;
    
    // record already in patch
    if mxSkipPatchedRecords and OverrideExistsIn(rec, mxPatchFile) then begin
      DebugMessage(Format('  Skipping record %s, already in patch!', [Name(rec)]));
      continue;
    end;
    
    // try copying the record
    try
      patchRec := wbCopyElementToFile(rec, mxPatchFile, false, true);
      if not Assigned(patchRec) then
        raise Exception.Create('patchRec not assigned');
      mxPatchRecords.Add(TObject(patchRec));
      if mxDebug then DebugMessage(Format('  Copied record %s to patch file', [Name(patchRec)]));
    except on x: Exception do
      FailureMessage(Format('Failed to copy record %s, Exception: %s', [Name(rec), x.Message]));
    end;
  end;
  
  // print final debug messages
  if mxDebug then begin
     if mxPatchRecords.Count > 0 then
      DebugMessage(Format('MXPF: Copied %d records in %0.2fs', [mxPatchRecords.Count, Now - start]))
    else
      DebugMessage('MXPF: No records copied.');
    DebugMessage(' ');
  end;
end;

function MaxPatchRecordIndex: Integer;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling MaxPatchRecordIndex');
  
  // return value if checks pass
  Result := mxPatchRecords.Count - 1;
  if mxDebug then DebugMessage(Format('MXPF: MaxPatchRecordIndex returned %d', [Result]));
end;

function GetPatchRecord(i: Integer): IInterface;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling GetPatchRecord');
  // if user hasn't loaded records, raise exception
  if not mxCopyCalled then
    raise Exception.Create('MXPF Error: You need to call CopyRecordsToPatch or CopyRecordToPatch before you can access records using GetPatchRecord');
  // if index is out of bounds, raise an exception
  if (i < 0) or (i > MaxPatchRecordIndex) then
    raise Exception.Create('MXPF Error: GetPatchRecord index out of bounds');
  
  // if all checks pass, return record at user specified index
  Result := ObjectToElement(mxPatchRecords[i]);
  if mxDebug then DebugMessage(Format('MXPF: GetPatchRecord at index %d returned %s', [i, Name(Result)]));
end;

//=========================================================================
// REPORTING
//=========================================================================
procedure PrintMXPFReport;
var
  success, failure, total: Integer;
begin
  // if user hasn't initialized MXPF, raise exception
  if not mxInitialized then
    raise Exception.Create('MXPF Error: You need to call InitialzeMXPF before calling PrintMXPFReport');
  
  // print report
  AddMessage(' ');
  AddMessage('MXPF Record Copying Report:');
  success := mxPatchRecords.Count;
  failure := mxFailureMessages.Count;
  total := success + failure;
  AddMessage(Format('%d copy operations, %d successful, %d failed.', [total, success, failure]));
  AddMessage(' ');
end;

end.
