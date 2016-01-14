unit UserScript;

uses 'lib\mxpf', 'lib\jvTest';


{******************************************************************************}
{ TEST GENERAL 
  Tests general MXPF functions:
    - InitializeMXPF
    - DefaultOptionsMXPF
    - FinalizeMXPF
}
{******************************************************************************}

procedure TestGeneral;
begin
  Describe('General');
  try
    Describe('InitializeMXPF');
    try
      InitializeMXPF;
      Expect(mxInitialized, 'Should set mxInitialized to true');
      Expect(Assigned(mxDebugMessages), 'Should create mxDebugMessages');
      Expect(Assigned(mxFailureMessages), 'Should create mxFailureMessages');
      Expect(Assigned(mxMasters), 'Should create mxMasters');
      Expect(Assigned(mxFiles), 'Should create mxFiles');
      Expect(Assigned(mxRecords), 'Should create mxRecords');
      Expect(Assigned(mxPatchRecords), 'Should create mxPatchRecords');
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('DefaultOptionsMXPF');
    try
      DefaultOptionsMXPF;
      Expect(mxLoadMasterRecords, 'Should set mxLoadMasterRecords to true');
      Expect(mxSkipPatchedRecords, 'Should set mxSkipPatchedRecords to true');
      Expect(mxLoadWinningOverrides, 'Should set mxLoadWinningOverrides to true');
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('FinalizeMXPF');
    try
      FinalizeMXPF;
      Expect(not mxInitialized, 'Should set mxInitialized to false');
      Expect(not mxLoadCalled, 'Should set mxLoadCalled to false');
      Expect(not mxCopyCalled, 'Should set mxCopyCalled to false');
      Expect(not mxLoadMasterRecords, 'Should set mxLoadMasterRecords to false');
      Expect(not mxLoadOverrideRecords, 'Should set mxLoadOverrideRecords to false');
      Expect(not mxLoadWinningOverrides, 'Should set mxLoadWinningOverrides to false');
      ExpectEqual(mxFileMode, 0, 'Should set mxFileMode to 0');
      ExpectEqual(mxRecordsCopied, 0, 'Should set mxRecordsCopied to 0');
      Expect(not Assigned(mxPatchFile), 'Should set mxPatchFile to nil');
      Expect(not Assigned(mxDebugMessages), 'Should free mxDebugMessages');
      Expect(not Assigned(mxFailureMessages), 'Should free mxFailureMessages');
      Expect(not Assigned(mxFiles), 'Should free mxFiles');
      Expect(not Assigned(mxMasters), 'Should free mxMasters');
      Expect(not Assigned(mxRecords), 'Should free mxRecords');
      Expect(not Assigned(mxPatchRecords), 'Should free mxPatchRecords');
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ TEST LOGGING 
  Tests logging MXPF functions:
    - DebugMessage
    - DebugList
    - FailureMessage
}
{******************************************************************************}

procedure TestLogging;
var
  sl: TStringList;
begin
  Describe('Logging');
  try
    Describe('DebugMessage');
    try
      InitializeMXPF;
      ExpectEqual(mxDebugMessages.Count, 2, 'Should have 2 messages after InitializeMXPF has been called');
      DebugMessage('Test Message');
      ExpectEqual(mxDebugMessages[2], 'Test Message', 'Messages should be stored correctly');
      FinalizeMXPF;
      Pass;
    except 
      on x: Exception do begin
        if mxInitialized then FinalizeMXPF;
        Fail(x);
      end;
    end;
    
    // create stringlist for DebugList
    sl := TStringList.Create;
    sl.Add('Apple');
    sl.Add('Orange');
    
    Describe('DebugList');
    try
      // Test with no prefix
      Describe('No prefix');
      try
        InitializeMXPF;
        DebugList(sl, '');
        ExpectEqual(mxDebugMessages[2], 'Apple', 'First message should match');
        ExpectEqual(mxDebugMessages[3], 'Orange', 'Second message should match');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with prefix
      Describe('With prefix');
      try
        InitializeMXPF;
        DebugList(sl, 'TEST: ');
        ExpectEqual(mxDebugMessages[2], 'TEST: Apple', 'First message should match');
        ExpectEqual(mxDebugMessages[3], 'TEST: Orange', 'Second message should match');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    // free stringlist
    sl.Free;
    
    Describe('FailureMessage');
    try
      InitializeMXPF;
      ExpectEqual(mxFailureMessages.Count, 0, 'Should have 0 messages after InitializeMXPF has been called');
      FailureMessage('Example Failure');
      ExpectEqual(mxFailureMessages[0], 'Example Failure', 'Messages should be stored correctly');
      FinalizeMXPF;
      Pass;
    except 
      on x: Exception do begin
        if mxInitialized then FinalizeMXPF;
        Fail(x);
      end;
    end;
    
    // All tests passed
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ TEST PATCH FILE SELECTION 
  Tests Patch File Selection MXPF functions:
    - PatchFileByAuthor
    - PatchFileByName
}
{******************************************************************************}

procedure TestPatchFileSelection;
var
  bCaughtException: boolean;
begin
  Describe('Patch File Selection');
  try
    Describe('PatchFileByAuthor');
    try
      // Test MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          PatchFileByAuthor('MXPF Tests');
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitializeMXPF before calling PatchFileByAuthor', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not Assigned(mxPatchFile), 'Should not assign mxPatchFile');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test file loaded
      Describe('File loaded');
      try
        InitializeMXPF;
        PatchFileByAuthor('MXPF Tests');
        Expect(Assigned(mxPatchFile), 'Should find the file');
        ExpectEqual(GetAuthor(mxPatchFile), 'MXPF Tests', 'Author should match');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test file not loaded
      Describe('File not loaded');
      try
        InitializeMXPF;
        PatchFileByAuthor('SomeRandomAuthor');
        Expect(true, 'Should not throw an exception');
        Expect(not Assigned(mxPatchFile), 'Should not assign mxPatchFile');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test multiple matching files
      Describe('Multiple matching files');
      try
        InitializeMXPF;
        PatchFileByAuthor('MXPF Tests');
        ExpectEqual(GetFileName(mxPatchFile), 'TestMXPF-1.esp', 'Should find first file matching author');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('PatchFileByName');
    try
      // Test MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
        PatchFileByName('TestMXPF-1.esp');
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitializeMXPF before calling PatchFileByName', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not Assigned(mxPatchFile), 'Should not assign mxPatchFile');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test file loaded
      Describe('File loaded');
      try
        InitializeMXPF;
        PatchFileByName('TestMXPF-1.esp');
        Expect(Assigned(mxPatchFile), 'Should find the file');
        ExpectEqual('TestMXPF-1.esp', GetFileName(mxPatchFile), 'Filenames should match');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test file not loaded
      Describe('File not loaded');
      try
        InitializeMXPF;
        PatchFileByAuthor('SomeRandomFilename.esp');
        Expect(true, 'Should not throw an exception');
        Expect(not Assigned(mxPatchFile), 'Should not assign mxPatchFile');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    // All tests passed?
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ TEST FILE SELECTION 
  Tests File Selection MXPF functions:
    - SetExclusions
    - SetInclusions
}
{******************************************************************************}

procedure TestFileSelection;
var
  bCaughtException: boolean;
begin
   Describe('File Selection');
  try
    Describe('SetExclusions');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          SetExclusions('TestMXPF-2.esp');
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitializeMXPF before calling SetExclusions', 'Should raise the correction exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        ExpectEqual(mxFileMode, 0, 'Should not change mxFileMode');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with MXPF initialized
      Describe('MXPF initialized');
      try
        InitializeMXPF;
        SetExclusions('TestMXPF-2.esp');
        ExpectEqual(mxFileMode, 1, 'Should set mxFileMode to 1');
        ExpectEqual(mxFiles.Text, 'TestMXPF-2.esp'#13#10, 
          'Should load the specified files into mxFiles');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('SetInclusions');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          SetInclusions('TestMXPF-1.esp,TestMXPF-2.esp');
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitializeMXPF before calling SetInclusions', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        ExpectEqual(mxFileMode, 0, 'Should not change mxFileMode');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with MXPF initialized
      Describe('MXPF initialized');
      try
        InitializeMXPF;
        SetInclusions('TestMXPF-1.esp,TestMXPF-2.esp');
        ExpectEqual(mxFileMode, 2, 'Should set mxFileMode to 2');
        ExpectEqual(mxFiles.Text, 'TestMXPF-1.esp'#13#10'TestMXPF-2.esp'#13#10, 
          'Should load the specified files into mxFiles');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ TEST RECORD PROCESSING
  Tests Record Processing MXPF functions:
    - LoadRecords
    - GetRecord
    - RemoveRecord
    - MaxRecordIndex
}
{******************************************************************************}

procedure TestRecordProcessing;
var
  bCaughtException: boolean;
  rec: IInterface;
begin
   Describe('Record Processing');
  try
    Describe('LoadRecords');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          LoadRecords('ARMO');
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitializeMXPF before calling LoadRecords', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with mxPatchFile not assigned
      Describe('Patch file not assigned');
      try
        InitializeMXPF;
        LoadRecords('ARMO');
        Expect(true, 'Should not throw an exception');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with mxPatchFile assigned
      Describe('Patch file assigned');
      try
        InitializeMXPF;
        PatchFileByAuthor('MXPF Tests');
        LoadRecords('ASTP');
        ExpectEqual(mxMasters.Text, 'Skyrim.esm'#13#10, 'Should load files into mxMasters');
        ExpectEqual(mxRecords.Count, 20, 'Should load records into mxRecords');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test exclusion mode
      Describe('Exclusion mode');
      try
        InitializeMXPF;
        PatchFileByName('TestMXPF-2.esp');
        SetExclusions('TestMXPF-1.esp');
        LoadRecords('ASTP');
        ExpectEqual(mxMasters.Text, 'Skyrim.esm'#13#10, 'Should not add masters from skipped files');
        ExpectEqual(mxRecords.Count, 20, 'Should not load records from excluded files');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test inclusion mode
      Describe('Inclusion mode');
      try
        InitializeMXPF;
        PatchFileByName('TestMXPF-2.esp');
        SetInclusions('Skyrim.esm');
        LoadRecords('ASTP');
        ExpectEqual(mxMasters.Text, 'Skyrim.esm'#13#10, 'Should only add masters from included files');
        ExpectEqual(mxRecords.Count, 20, 'Should only load records from included files');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test mxLoadMasterRecords
      Describe('mxLoadMasterRecords');
      try
        InitializeMXPF;
        mxLoadMasterRecords := true;
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('ARMO');
        ExpectEqual(mxRecords.Count, 2763, 'Should only load master records');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test mxLoadOverrideRecords
      Describe('mxLoadOverrideRecords');
      try
        InitializeMXPF;
        mxLoadOverrideRecords := true;
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('ARMO');
        ExpectEqual(mxRecords.Count, 8, 'Should only load override records');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test group not found in file selection
      Describe('Empty group');
      try
        InitializeMXPF;
        SetExclusions('Skyrim.esm');
        LoadRecords('SLGM');
        ExpectEqual(mxRecords.Count, 0, 'Should load 0 records');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('MaxRecordIndex');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          MaxRecordIndex;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling MaxRecordIndex', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with MXPF initialized
      Describe('MXPF initialized');
      try
        InitializeMXPF;
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('ARMO');
        ExpectEqual(MaxRecordIndex, mxRecords.Count - 1, 'Should return mxRecords.Count - 1');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('GetRecord');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          rec := GetRecord(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling LoadRecords', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with LoadRecords not called
      Describe('LoadRecords not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          GetRecord(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call LoadRecords before you can access records using GetRecord', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with no records loaded
      Describe('No records loaded');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('SLGM');
          GetRecord(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: Can''t call GetRecord, no records available', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with an invalid index
      Describe('Invalid index');
      try
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('ARMO');
          GetRecord(-1);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: GetRecord index out of bounds', 
              'Should raise the correct exception');
          end;
        end;
        // if no exception caught, fail test
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with valid index
      Describe('Valid index');
      try
        InitializeMXPF;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('ASTP');
        Expect(Assigned(GetRecord(0)), 'Should return a record');
        ExpectEqual(Name(GetRecord(0)), 'Friend [ASTP:01000800]', 'Should return the corect record');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('RemoveRecord');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          RemoveRecord(0);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling RemoveRecord', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with LoadRecords not called
      Describe('LoadRecords not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          RemoveRecord(0);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call LoadRecords before you can remove records using RemoveRecord', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with no records loaded
      Describe('No records loaded');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('SLGM');
          RemoveRecord(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: Can''t call RemoveRecord, no records available', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with an invalid index
      Describe('Invalid index');
      try
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('ARMO');
          RemoveRecord(-1);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: RemoveRecord index out of bounds', 
              'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with valid index
      Describe('Valid index');
      try
        InitializeMXPF;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('ASTP');
        RemoveRecord(0);
        ExpectEqual(mxRecords.Count, 0, 'Should remove the record at the index');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    // All tests passed?
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ TEST RECORD PATCHING
  Tests Record Patching MXPF functions:
    - AddMastersToPatch
    - CopyRecordToPatch
    - CopyRecordsToPatch
    - MaxPatchRecordIndex
    - GetPatchRecord
}
{******************************************************************************}

procedure TestRecordPatching;
var
  bCaughtException: boolean;
  rec, g: IInterface;
  s, fn: string;
  sl: TStringList;
  count: Integer; 
begin
   Describe('Record Patching');
  try
    Describe('AddMastersToPatch');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          AddMastersToPatch;
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling AddMastersToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxMastersAdded, 'Should not set mxMastersAdded to true');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with LoadRecords not called
      Describe('LoadRecords not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          AddMastersToPatch;
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call LoadRecords before you can call AddMastersToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxMastersAdded, 'Should not set mxMastersAdded to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with mxPatchFile not assigned
      Describe('mxPatchFile not assigned');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('ARMO');
          AddMastersToPatch;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling AddMastersToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxMastersAdded, 'Should not set mxMastersAdded to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with mxPatchFile assigned
      sl := TStringList.Create;
      Describe('mxPatchFile assigned');
      try
        InitializeMXPF;
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        AddMastersToPatch;
        Expect(mxMastersAdded, 'Should set mxMastersAdded to true');
        GetMasters(mxPatchFile, sl);
        ExpectEqual(sl.Text, 'Skyrim.esm'#13#10'TestMXPF-1.esp'#13#10'TestMXPF-2.esp'#13#10, 'Should add the correct masters');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      sl.Free;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('CopyRecordToPatch');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          CopyRecordToPatch(0);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling CopyRecordToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        Pass;
      except 
        on x: Exception do Fail(x);
      end;
      
      // Test with LoadRecords not called
      Describe('LoadRecords not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          CopyRecordToPatch(0);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call LoadRecords before you can copy records using CopyRecordToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with mxPatchFile not assigned
      Describe('mxPatchFile not assigned');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          LoadRecords('ARMO');
          CopyRecordToPatch(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling CopyRecordToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with no records available
      Describe('No records available');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          PatchFileByName('TestMXPF-3.esp');
          SetExclusions('Skyrim.esm');
          LoadRecords('SLGM');
          CopyRecordToPatch(0);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: Can''t call CopyRecordToPatch, no records available', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test invalid index
      Describe('Invalid index');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          PatchFileByName('TestMXPF-3.esp');
          LoadRecords('ARMO');
          CopyRecordToPatch(-1);
        except 
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: CopyRecordToPatch index out of bounds', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test valid index
      Describe('Valid index');
      try
        InitializeMXPF;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        rec := CopyRecordToPatch(0);
        s := Name(rec);
        Remove(rec);
        Expect(mxCopyCalled, 'Should set mxCopyCalled to true');
        Expect(mxMastersAdded, 'Should set mxMastersAdded to true');
        ExpectEqual(mxPatchRecords.Count, 1, 'Should add the record to mxPatchRecords');
        ExpectEqual(s, 'ArmorIronGauntlets "Iron Gauntlets" [ARMO:00012E46]', 'Record should be present in the patch file');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test mxLoadWinningOverrides
      Describe('mxLoadWinningOverrides');
      try
        InitializeMXPF;
        mxLoadWinningOverrides := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        rec := CopyRecordToPatch(0);
        s := GetElementEditValues(rec, 'DNAM');
        Remove(rec);
        ExpectEqual(s, '15.000000', 'Should copy the winning override record');
        FinalizeMXPF;
        
        // when winning override is in a file not in the file selection
        InitializeMXPF;
        mxLoadWinningOverrides := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-2.esp');
        LoadRecords('WEAP');
        rec := CopyRecordToPatch(0);
        s := GetElementEditValues(rec, 'DATA\Damage');
        Remove(rec);
        ExpectEqual(s, '8', 'Should not copy winning override from file outside of the file selection');
        FinalizeMXPF;
        
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test mxSkipPatchedRecords
      Describe('mxSkipPatchedRecords');
      try
        InitializeMXPF;
        mxSkipPatchedRecords := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('WEAP');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        Expect(not mxMastersAdded, 'Should not set mxMastersAdded to true');
        ExpectEqual(mxPatchRecords.Count, 0, 'Should not add record to mxPatchRecords');
        Expect(not Assigned(CopyRecordToPatch(0)), 'Should not return a record');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('CopyRecordsToPatch');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          CopyRecordsToPatch;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling CopyRecordsToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        Pass;
      except
        on x: Exception do Fail(x);
      end;
      
      // Test with LoadRecords not called
      Describe('LoadRecords not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          CopyRecordsToPatch;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call LoadRecords before you can copy records using CopyRecordsToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do Fail(x);
      end;
      
      // Test with mxPatchFile not assigned
      Describe('mxPatchFile not assigned');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          LoadRecords('ARMO');
          CopyRecordsToPatch;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to assign mxPatchFile using PatchFileByAuthor or PatchFileByName before calling CopyRecordsToPatch', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with no records
      Describe('No records');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          SetExclusions('Skyrim.esm');
          PatchFileByName('TestMXPF-2.esp');
          LoadRecords('SLGM');
          CopyRecordsToPatch;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: Can''t call CopyRecordsToPatch, no records available', 'Should raise the correct exception');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Expect(not mxCopyCalled, 'Should not set mxCopyCalled to true');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with records available
      Describe('mxSkipPatchedRecords');
      try
        InitializeMXPF;
        mxSkipPatchedRecords := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        CopyRecordsToPatch;
        g := GroupBySignature(mxPatchFile, 'ARMO');
        count := ElementCount(g);
        Remove(g);
        Expect(mxCopyCalled, 'Should set mxCopyCalled to true');
        Expect(mxMastersAdded, 'Should set mxMastersAdded to true');
        ExpectEqual(mxPatchRecords.Count, 21, 'Should add the records to mxPatchRecords');
        ExpectEqual(count, 21, 'Should copy the records to the patch file');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // all tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('MaxPatchRecordIndex');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          MaxPatchRecordIndex;
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling MaxPatchRecordIndex', 'Should raise the correct exception.');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except
        on x: Exception do Fail(x);
      end;
      
      // Test with MXPF initialized
      Describe('MXPF initialized');
      try
        InitializeMXPF;
        mxSkipPatchedRecords := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        CopyRecordsToPatch;
        g := GroupBySignature(mxPatchFile, 'ARMO');
        Remove(g);
        ExpectEqual(MaxPatchRecordIndex, mxPatchRecords.Count - 1, 'Should return mxPatchRecords.Count - 1');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;
    
    Describe('GetPatchRecord');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        bCaughtException := false;
        try
          GetPatchRecord(0);
        except
          on x: Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call InitialzeMXPF before calling GetPatchRecord', 'Should raise the correct exception.');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        Pass;
      except
        on x: Exception do Fail(x);
      end;
      
      // Test with CopyRecord(s)ToPatch not called
      Describe('CopyRecord(s)ToPatch not called');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          mxSkipPatchedRecords := true;
          SetExclusions('Skyrim.esm');
          PatchFileByName('TestMXPF-3.esp');
          LoadRecords('ARMO');
          GetPatchRecord(0);
        except 
          on x : Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: You need to call CopyRecordsToPatch or CopyRecordToPatch before you can access records using GetPatchRecord', 'Should raise the correct exception.');
          end;
        end;
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with an invalid index
      Describe('Invalid index');
      try
        bCaughtException := false;
        try
          InitializeMXPF;
          mxSkipPatchedRecords := true;
          SetExclusions('Skyrim.esm');
          PatchFileByName('TestMXPF-3.esp');
          LoadRecords('ARMO');
          CopyRecordsToPatch;
          GetPatchRecord(-1);
        except 
          on x : Exception do begin
            bCaughtException := true;
            ExpectEqual(x.Message, 'MXPF Error: GetPatchRecord index out of bounds', 'Should raise the correct exception.');
          end;
        end;
        g := GroupBySignature(mxPatchFile, 'ARMO');
        Remove(g);
        Expect(bCaughtException, 'Should have raised an exception');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // Test with an invalid index
      Describe('Valid index');
      try
        InitializeMXPF;
        mxSkipPatchedRecords := true;
        SetExclusions('Skyrim.esm');
        PatchFileByName('TestMXPF-3.esp');
        LoadRecords('ARMO');
        CopyRecordsToPatch;
        rec := GetPatchRecord(0);
        s := Name(rec);
        fn := GetFileName(GetFile(rec));
        g := GroupBySignature(mxPatchFile, 'ARMO');
        Remove(g);
        ExpectEqual(s, 'ArmorIronGauntlets "Iron Gauntlets" [ARMO:00012E46]', 'Should return the correct record');
        ExpectEqual(fn, 'TestMXPF-3.esp', 'Should return record from the patch file.');
        FinalizeMXPF;
        Pass;
      except
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed?
      Pass;
    except
      on x: Exception do Fail(x);
    end;

    
    // All tests passed?
    Pass;
  except 
    on x: Exception do Fail(x);
  end;
end;


{******************************************************************************}
{ ENTRY POINTS
  Entry points for when the script is run in xEdit.
    - Initialize
}
{******************************************************************************}

function Initialize: Integer;
begin
  // initialize jvt
  jvtInitialize;
  
  // set up MXPF for testing environment
  mxDisallowNewFile := true;
  mxDisallowSaving := true;
  mxDisallowPrinting := true;
  
  // perform tests
  TestGeneral;
  TestLogging;
  TestPatchFileSelection;
  TestFileSelection;
  TestRecordProcessing;
  TestRecordPatching;
  
  // finalize jvt
  jvtPrintReport;
  jvtFinalize;
end;

end.