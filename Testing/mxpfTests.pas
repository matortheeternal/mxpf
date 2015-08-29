unit UserScript;

uses mxpf, jvTest;

procedure TestMXPF_General;
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
    except on x: Exception do
      Fail(x);
    end;
    
    Describe('DefaultOptionsMXPF');
    try
      DefaultOptionsMXPF;
      Expect(mxLoadMasterRecords, 'mxLoadMasterRecords should be true');
      Expect(mxCopyWinningOverrides, 'mxCopyWinningOverrides should be true');
      Pass;
    except on x: Exception do
      Fail(x);
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
      Expect(mxFileMode = 0, 'mxFileMode should be 0');
      Expect(mxRecordsCopied = 0, 'mxRecordsCopied should be 0');
      Expect(not Assigned(mxDebugMessages), 'mxDebugMessages should be freed');
      Expect(not Assigned(mxFailureMessages), 'mxFailureMessages should be freed');
      Expect(not Assigned(mxFiles), 'mxFiles should be freed');
      Expect(not Assigned(mxMasters), 'mxMasters should be freed');
      Expect(not Assigned(mxRecords), 'mxRecords should be freed');
      Expect(not Assigned(mxPatchRecords), 'mxPatchRecords should be freed');
      Pass;
    except on x: Exception do
      Fail(x);
    end;
    
    Pass;
  except on x: Exception do
    Fail(x);
  end;
end;

function Initialize: Integer;
begin
  // initialize jvt
  jvtInitialize;
  
  // perform tests
  TestMXPF_General;
  //TestMXPF_PatchFileSelection;
  //TestMXPF_FileSelection;
  
  // finlaize jvt
  jvtFinalize;
end;

end.