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
      Expect(mxInitialized, 'mxInitialized should be true');
      Expect(Assigned(mxDebugMessages), 'mxDebugMessages should be created');
      Expect(Assigned(mxFailureMessages), 'mxFailureMessages should be created');
      Expect(Assigned(mxMasters), 'mxMasters should be created');
      Expect(Assigned(mxFiles), 'mxFiles should be created');
      Expect(Assigned(mxRecords), 'mxRecords should be created');
      Expect(Assigned(mxPatchRecords), 'mxPatchRecords should be created');
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('DefaultOptionsMXPF');
    try
      DefaultOptionsMXPF;
      Expect(mxLoadMasterRecords, 'mxLoadMasterRecords should be true');
      Expect(mxCopyWinningOverrides, 'mxCopyWinningOverrides should be true');
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('FinalizeMXPF');
    try
      FinalizeMXPF;
      Expect(not mxInitialized, 'mxInitialized should be false');
      Expect(not mxLoadCalled, 'mxLoadCalled should be false');
      Expect(not mxCopyCalled, 'mxCopyCalled should be false');
      Expect(not mxLoadMasterRecords, 'mxLoadMasterRecords should be false');
      Expect(not mxLoadOverrideRecords, 'mxLoadOverrideRecords should be false');
      Expect(not mxCopyWinningOverrides, 'mxCopyWinningOverrides should be false');
      ExpectEqual(mxFileMode, 0, 'mxFileMode should be 0');
      ExpectEqual(mxRecordsCopied, 0, 'mxRecordsCopied should be 0');
      Expect(not Assigned(mxPatchFile), 'mxPatchFile should be unassigned');
      Expect(not Assigned(mxDebugMessages), 'mxDebugMessages should be freed');
      Expect(not Assigned(mxFailureMessages), 'mxFailureMessages should be freed');
      Expect(not Assigned(mxFiles), 'mxFiles should be freed');
      Expect(not Assigned(mxMasters), 'mxMasters should be freed');
      Expect(not Assigned(mxRecords), 'mxRecords should be freed');
      Expect(not Assigned(mxPatchRecords), 'mxPatchRecords should be freed');
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
begin
  Describe('Patch File Selection');
  try
    Describe('PatchFileByAuthor');
    try
      // Test MXPF not initialized
      Describe('MXPF not initialized');
      try
        PatchFileByAuthor('MXPF Tests');
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
      
      // All tests passed.
      Pass;
    except 
      on x: Exception do Fail(x);
    end;
    
    Describe('PatchFileByName');
    try
      // Test MXPF not initialized
      Describe('MXPF not initialized');
      try
        PatchFileByName('TestMXPF-1.esp');
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
        Expect(not Assigned(mxPatchFile), 'Should not assign mxPatchFile');
        FinalizeMXPF;
        Pass;
      except 
        on x: Exception do begin
          if mxInitialized then FinalizeMXPF;
          Fail(x);
        end;
      end;
      
      // All tests passed.
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
{ TEST FILE SELECTION 
  Tests File Selection MXPF functions:
    - SetExclusions
    - SetInclusions
}
{******************************************************************************}

procedure TestFileSelection;
begin
   Describe('File Selection');
  try
    Describe('SetExclusions');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        SetExclusions('TestMXPF-2.esp');
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
      
      // All tests passed.
      Pass;
    except 
      on x: Exception do begin
        if mxInitialized then FinalizeMXPF;
        Fail(x);
      end;
    end;
    
    Describe('SetInclusions');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        SetInclusions('TestMXPF-1.esp,TestMXPF-2.esp');
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
      
      // All tests passed.
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
  Tests RecordProcessing MXPF functions:
    - LoadRecords
    - GetRecord
    - RemoveRecord
    - MaxRecordIndex
}
{******************************************************************************}

procedure TestRecordProcessing;
begin
   Describe('Record Processing');
  try
    Describe('LoadRecords');
    try
      // Test with MXPF not initialized
      Describe('MXPF not initialized');
      try
        LoadRecords('ARMO');
        Expect(true, 'Should not throw an exception');
        Pass;
      except 
        on x: Exception Fail(x);
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
      
      // All tests passed.
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
  mxHideErrorPopups := true;
  mxDisallowNewFile := true;
  mxDisallowSaving := true;
  mxDisallowPrinting := true;
  
  // perform tests
  TestGeneral;
  TestLogging;
  TestPatchFileSelection;
  TestFileSelection;
  TestRecordProcessing;
  //TestRecordPatching;
  //TestReporting;
  
  // finalize jvt
  jvtFinalize;
end;

end.