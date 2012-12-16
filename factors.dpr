program factors;

{$APPTYPE CONSOLE}
{$SetPEFlags $20}

uses
  Windows,
  SysUtils,
  Classes,
  primeUtils in 'primeUtils.pas';

const
  primes_readblock=$10000;
var
  fn:string;
  a,b,c,d,px,lx,fx:baseint;
  tc:cardinal;
  f:TFileStream;
  p:array[0..primes_readblock-1] of baseint;
  headerdone:boolean;
begin
  if ParamCount<1 then
   begin
    writeln('factors: pass number to calculate factors from');
    exit;
   end
  else
    a:=StrToIntX(ParamStr(1));
  if ParamCount<2 then fn:=primes_filename else fn:=ParamStr(2);
  if not FileExists(fn) then
   begin
    writeln('factors: primes file not found');
    exit;
   end;
  f:=TFileStream.Create(fn,fmOpenRead or fmShareDenyNone);
  try
    tc:=GetTickCount;
    headerdone:=false;
    b:=isqrt(a);
    c:=0;
    fx:=0;
    lx:=f.Read(p[0],primes_readblock*baseintsize) div baseintsize;
    px:=0;
    while (a>1) and (c<=b) and (px<lx) do
     begin
      c:=p[px];
      d:=0;
      while (a<>0) and ((a mod c)=0) do
       begin
        inc(d);
        a:=a div c;
        b:=a;//b+isqrt(a);//?
       end;
      if d<>0 then
       begin
        if not(headerdone) then
         begin
          writeln('primeindex;factor;count');
          headerdone:=true;
         end;
        writeln(IntToStrX(fx+px)+';'+IntToStrX(c)+';'+IntToStrX(d));
       end;
      inc(px);
      if px=lx then //=primes_readblock then
       begin
        inc(fx,lx);
        lx:=f.Read(p[0],primes_readblock*baseintsize) div baseintsize;
        px:=0;
       end;
     end;
    if px=lx then
     begin
      writeln('factors: insufficient primes in file');
      exit;
     end;
    if headerdone then
      writeln('('+IntToStrX(GetTickCount-tc)+'ms)')
    else
      if a=0 then
        writeln('zero')
      else
        writeln('prime ('+IntToStrX(GetTickCount-tc)+'ms)');
  finally
    f.Free;
  end;
end.
