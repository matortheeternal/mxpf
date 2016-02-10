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
  jvtMaxLevel, jvtTestsFailed, jvtTestsPassed, jvtSpecsFailed, jvtSpecsPassed: Integer;
  jvtInitialized: boolean;
  jvtLog, jvtFailures, jvtStack, jvtStackTrace: TStringList;

  
//=========================================================================
// LOG MESSAGES
//=========================================================================
procedure jvtLogMessage(msg: string);
begin
  jvtLog.Add(msg);
  if jvtEchoLog then AddMessage(msg);
end;

procedure jvtLogTest(msg: string);
var
  tab: string;
begin
  tab := StringOfChar(' ', jvtTabSize * jvtStack.Count);
  jvtLogMessage(tab + msg);
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

  
//=========================================================================
// GENERAL
//=========================================================================
procedure jvtInitialize;
begin
  jvtInitialized := true;
  jvtMaxLevel := 1;
  jvtTestsFailed := 0;
  jvtTestsPassed := 0;
  jvtSpecsPassed := 0;
  jvtSpecsFailed := 0;
  jvtLog := TStringList.Create;
  jvtStack := TStringList.Create;
  jvtFailures := TStringList.Create;
  jvtStackTrace := TStringList.Create;
  jvtLogMessage('JVT initialized at '+TimeToStr(Now));
  jvtLogMessage(' ');
end;

procedure jvtPush(var sl: TStringList; s: string);
begin
  sl.Add(s);
end;

procedure jvtPop(var sl: TStringList);
begin
  sl.Delete(Pred(sl.Count));
end;

function jvtGetStackTrace: string;
var
  i: integer;
begin
  for i := 0 to Pred(jvtStack.Count) do begin
    if Result <> '' then
      Result := Format('%s > %s', [Result, jvtStack[i]])
    else
      Result := jvtStack[i];
  end;
end;

function jvtHasTrace(t: string): boolean;
var
  i: integer;
begin
  for i := 0 to Pred(jvtStackTrace.Count) do begin
    if Pos(t, jvtStackTrace[i]) = 1 then begin
      Result := true;
      break;
    end;
  end;
end;

procedure jvtFinalize;
begin
  // log finalization
  jvtLogMessage(' ');
  jvtLogMessage('JVT finalized at '+TimeToStr(Now));

  // print/save messages
  if jvtPrintLog then jvtPrintLogMessages;
  if jvtSaveLog then jvtSaveLogMessages;
  
  // reset variables
  jvtInitialized := false;
  jvtTestsFailed := 0;
  jvtTestsPassed := 0;
  jvtMaxLevel := 0;

  // free memory used by lists
  jvtFailures.Free;
  jvtStack.Free;
  jvtStackTrace.Free;
  jvtLog.Free;
end;


//=========================================================================
// TESTING
//=========================================================================
procedure Describe(name: string);
begin
  jvtLogTest(name);
  jvtPush(jvtStack, name);
end;

procedure Pass;
var
  index: Integer;
begin
  index := jvtFailures.IndexOf(IntToStr(jvtStack.Count));
  if index > -1 then begin
    jvtFailures.Delete(index);
    raise Exception.Create(''));
  end;
  
  if jvtMaxLevel >= jvtStack.Count then begin
    jvtLogTest(jvtPassed);
    jvtLogMessage(' ');
  end;
  Inc(jvtTestsPassed);
  jvtPop(jvtStack);
end;

procedure Fail(x: Exception);
var
  trace, fail: string;
begin
  fail := jvtFailed+' '+x.Message;
  jvtLogTest(fail);
  if jvtMaxLevel >= jvtStack.Count then
    jvtLogMessage(' ');
    
  Inc(jvtTestsFailed);
  trace := jvtGetStackTrace();
  if not jvtHasTrace(trace) then
    jvtStackTrace.Add(Format('%s >> %s', [trace, fail]));
  jvtPop(jvtStack);
  jvtFailures.Add(IntToStr(jvtStack.Count));
end;

procedure Expect(expectation: boolean; test: string);
begin
  jvtLogTest(test);
  if not expectation then begin
    Inc(jvtSpecsFailed);
    raise Exception.Create(test);
  end;
  Inc(jvtSpecsPassed);
end;

procedure ExpectEqual(v1, v2: Variant; test: string);
const
  varInteger = 3;
  varDouble = 5;
  varShortInt = 16;
  varString =  256; { Pascal string }
  varUString = 258; { Unicode string }
  { SEE http://stackoverflow.com/questions/24731098/ for more }
var
  vt: Integer;
begin
  jvtLogTest(test);
  if v1 <> v2 then begin
    Inc(jvtSpecsFailed);
    vt := VarType(v1);
    case vt of
      varInteger: raise Exception.Create(Format('Expected "%d", found "%d"', [v2, v1]));
      varShortInt: raise Exception.Create(Format('Expected "%d", found "%d"', [Integer(v2), Integer(v1)]));
      varDouble: raise Exception.Create(Format('Expected "%0.4f", found "%0.4f"', [v2, v1]));
      varString, varUString: raise Exception.Create(Format('Expected "%s", found "%s"', [v2, v1]));
      else raise Exception.Create(test + ', type ' + IntToStr(vt));
    end;
  end;
  Inc(jvtSpecsPassed);
end;


//=========================================================================
// REPORTING
//=========================================================================
procedure jvtPrintReport;
var
  totalTests, totalSpecs, i: Integer;
begin
  if not jvtInitialized then
    raise Exception.Create('JVT Error: You need to call jvtInitialize before calling jvtPrintReport');
    
  jvtLogMessage(' ');
  jvtLogMessage('JVT Report:');
  totalTests := jvtTestsPassed + jvtTestsFailed;
  totalSpecs := jvtSpecsPassed + jvtSpecsFailed;
  jvtLogMessage(Format('%d tests, %d passed, %d failed.', [totalTests, jvtTestsPassed, jvtTestsFailed]));
  jvtLogMessage(Format('%d specs, %d passed, %d failed.', [totalSpecs, jvtSpecsPassed, jvtSpecsFailed]));
  if jvtStackTrace.Count > 0 then begin
    jvtLogMessage(' ');
    jvtLogMessage('Stack trace:');
    for i := 0 to Pred(jvtStackTrace.Count) do
      jvtLogMessage(jvtStackTrace[i]);
  end;
end;

end.