unit UserScript;

uses 'lib\jvTest';

procedure TestBooleans;
begin
  Describe('True');
  try
    Expect(true, 'Should pass');
    Pass;
  except on x: Exception do
    Fail(x);
  end;
  
  Describe('False');
  try
    Expect(false, 'Should not pass');
    Pass;
  except on x: Exception do
    Fail(x);
  end;
end;

procedure TestIntegers;
begin
  Describe('Equality');
  try
    Expect(0 = 0, 'Zero should equal zero');
    Expect(1 = 1, 'One should equal one');
    Expect(2 = 2, 'Two should equal two');
    Pass;
  except on x: Exception do 
    Fail(x);
  end;
  
  Describe('Greater than');
  try
    Expect(4 > 2, 'Four should be greater than two');
    Expect(100 > -1, '100 should be greater than -1');
    Expect(99999 > 0, '99999 should be greater than 0');
    Pass;
  except on x: Exception do
    Fail(x);
  end;
  
  Describe('Less than');
  try
    Expect(1 < 3, 'One should be less than three');
    Expect(-3 < 1, '-3 should be less than 1');
    Expect(9 < 10, '9 should be less than 10');
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
  Describe('Booleans');
  try
    TestBooleans;
    Pass;
  except on x: Exception do
    Fail(x);
  end;
  
  Describe('Integer Comparison');
  try
    TestIntegers;
    Pass;
  except on x: Exception do
    Fail(x);
  end;
  
  Describe('ExpectEqual');
  try
    ExpectEqual('Test', 'Test', 'Equal strings');
    ExpectEqual(1, 1, 'Equal integers');
    ExpectEqual(1.23, 1.23, 'Equal floats');
    Pass;
  except on x: Exception do
    Fail(x);
  end;
  
  // finalize jvt
  jvtFinalize;
end;

end.