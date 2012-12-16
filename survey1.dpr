program survey1;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  primeUtils in 'primeUtils.pas';

const
  primes_readblock=$10000;
  interspace=2;
var
  f:TFileStream;
  a,b,c,i,l:baseint;
  p:array[0..primes_readblock-1] of baseint;
begin
  f:=TFileStream.Create(primes_filename,fmOpenRead or fmShareDenyNone);
  try
    b:=0;
    c:=0;
    repeat
      l:=f.Read(p[0],primes_readblock*baseintsize) div baseintsize;
      i:=0;
      while i<l do
       begin
        a:=b;
        b:=c;
        c:=p[i];
        inc(i);
        if (a+interspace=b) and (b+interspace=c) then
          writeln(IntToStrX(a)+' '+IntToStrX(b)+' '+IntToStrX(c));
       end;
    until l<>primes_readblock;
  finally
    f.Free;
  end;
end.
