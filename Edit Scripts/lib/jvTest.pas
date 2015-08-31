{
  xEdit Testing Framework
  by matortheeternal
  
  This is a simple testing framework for executing tests
  in the jvInterpreter in xEdit. 
}

unit jvTest;

const
  { USER CONSTANTS }
  jvtPrintLog = true;
  jvtSaveLog = true;
  jvtEchoLog = false;
  
  { DEVELOPER CONSTANTS }
  jvtVersion = '0.1.0';
  jvtTabSize = 4;
  jvtPassed = '[PASSED]';
  jvtFailed = '[FAILED]';

var
  jvtLevel, jvtMaxLevel: Integer;
  jvtInitialized: boolean;
  jvtLog, jvtFailures: TStringList;
  
procedure jvtLogMessage(msg: string);
begin
  jvtLog.Add(msg);
  if jvtEchoLog then AddMessage(msg);
end;

procedure jvtLogTest(msg: string);
var
  tab: string;
begin
  tab := StringOfChar(' ', jvtTabSize * jvtLevel);
  jvtLog.Add(tab + msg);
end;

procedure jvtSaveLogMessages;
var
  filename: string;
begin
  // exit if no debug messages to save
  if (jvtLog.Count = 0) then exit;
  
  // save to mxpf logs folder in scripts path
  filename := ScriptsPath + 'logs\jvt\jvt-'+FormatDateTime('mmddyy_hhnnss', Now)+'.txt';
  AddMessage('JVT Log saved to '+filename);
  ForceDirectories(ExtractFilePath(filename));
  jvtLog.SaveToFile(filename);
end;

procedure jvtPrintLogMessages;
begin
  if (jvtLog.Count = 0) then exit;
  AddMessage(jvtLog.Text);
end;
  
procedure jvtInitialize;
begin
  jvtInitialized := true;
  jvtMaxLevel := 1;
  jvtLog := TStringList.Create;
  jvtFailures := TStringList.Create;
  jvtLogMessage('JVT initialized at '+TimeToStr(Now));
  jvtLogMessage(' ');
end;

procedure jvtFinalize;
begin
  // log finalization
  jvtLogMessage(' ');
  jvtLogMessage('JVT finalized at '+TimeToStr(Now));

  // print/save messages
  if jvtPrintLog then jvtPrintLogMessages;
  if jvtSaveLog then jvtSaveLogMessages;
  
  // reset boolean variables
  jvtInitialized := false;

  // free memory used by lists
  jvtFailures.Free;
  jvtLog.Free;
end;

procedure Describe(name: string);
begin
  jvtLogTest(name);
  Inc(jvtLevel);
end;

procedure Pass;
var
  index: Integer;
begin
  index := jvtFailures.IndexOf(IntToStr(jvtLevel));
  if index > -1 then begin
    jvtFailures.Delete(index);
    raise Exception.Create(''));
  end;
  
  if jvtMaxLevel >= jvtLevel then begin
    jvtLogTest(jvtPassed);
    jvtLogMessage(' ');
  end;
  Dec(jvtLevel);
end;

procedure Fail(x: Exception);
begin
  jvtLogTest(jvtFailed+' '+x.Message);
  if jvtMaxLevel >= jvtLevel then
    jvtLogMessage(' ');
    
  Dec(jvtLevel);
  jvtFailures.Add(IntToStr(jvtLevel));
end;

procedure Expect(expectation: boolean; test: string);
begin
  jvtLogTest(test);
  if not expectation then
    raise Exception.Create(test);
end;

procedure ExpectEqual(v1, v2: Variant; test: string);
const
  varInteger = 3;
  varDouble = 5;
  varString =  256;
  varUString = 258;
var
  vt: Integer;
begin
  jvtLogTest(test);
  if v1 <> v2 then begin
    vt := VarType(v1);
    case vt of
      varInteger: raise Exception.Create(Format('Expected "%d", found "%d"', [v2, v1]));
      varDouble: raise Exception.Create(Format('Expected "%0.4f", found "%0.4f"', [v2, v1]));
      varString, varUString: raise Exception.Create(Format('Expected "%s", found "%s"', [v2, v1]));
      else raise Exception.Create(test + ', type ' + IntToStr(vt));
    end;
  end;
end;

end.