program check1;

uses
  SysUtils, Classes;

{$APPTYPE CONSOLE}

const
  dSize=$10000;
  fSize=dSize*SizeOf(integer);
var
  f1,f2:TFileStream;
  d1,d2:array[0..dSize] of integer;
  i,x,c,l1,l2:integer;
begin
  f1:=TFileStream.Create(ParamStr(1),fmOpenRead);
  f2:=TFileStream.Create(ParamStr(2),fmOpenRead);
  x:=0;
  l1:=f1.Read(d1[0],fSize);
  l2:=f2.Read(d2[0],fSize);
  while (l1=fSize) and (l2=fSize) do
   begin
    c:=0;
    for i:=0 to dSize-1 do if d1[i]=d2[i] then inc(c);
    if c<>dSize then writeln(Format('%.8x: %.2f%%',[x,c*100.0/dSize]));
    inc(x,fSize);
    l1:=f1.Read(d1[0],fSize);
    l2:=f2.Read(d2[0],fSize);
   end;
  writeln(Format('%.8x done',[x]));
end.
