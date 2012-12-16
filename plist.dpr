program plist;

{$APPTYPE CONSOLE}

uses
  Windows,
  SysUtils,
  Classes,
  primeUtils in 'primeUtils.pas';

const
  primes_readblock=$10000;
var
  fn:string;
  a,b,c,d,ax,bx,fx:baseint;
  useindex,showmax:boolean;
  tc:cardinal;
  f:TFileStream;
  p:array[0..primes_readblock-1] of baseint;
begin
  //defaults
  useindex:=false;
  showmax:=false;
  a:=0;
  //parameters
  d:=1;
  if ParamCount<d then
   begin
    writeln('plist: pass number to list primes for');
    exit;
   end
  else
   begin
    if (ParamCount>d) and (LowerCase(ParamStr(d))='index') then
     begin
      useindex:=true;
      inc(d);
     end;
    if (LowerCase(ParamStr(d))='max') then showmax:=true else a:=StrToIntX(ParamStr(d));
   end;
  inc(d);
  if ParamCount>=d then b:=StrToIntX(ParamStr(d)) else b:=a;
  inc(d);
  if ParamCount>=d then fn:=ParamStr(d) else fn:=primes_filename;
  if not FileExists(fn) then
   begin
    writeln('plist: primes file not found');
    exit;
   end;
  f:=TFileStream.Create(fn,fmOpenRead or fmShareDenyNone);
  try
    tc:=GetTickCount;
    fx:=f.Size div baseintsize;
    writeln('primeindex;prime');
    if showmax then
     begin
      dec(fx);
      f.Position:=fx*baseintsize;
      f.Read(c,baseintsize);
      writeln(IntToStrX(fx)+';'+IntToStrX(c));
     end
    else
      if useindex then
       begin
        if a>fx then
         begin
          writeln('plist: searching past end of primes list');
          exit;
         end;
        d:=a;
        f.Position:=a*baseintsize;
        while (d<=b) and (d<fx) do
         begin
          f.Read(c,baseintsize);
          writeln(IntToStrX(d)+';'+IntToStrX(c));
          inc(d);
         end;
       end
      else
       begin
        //TODO: try minimax?
        //start with an estimated number less than the prime index
        bx:=(a div 20)+1;//TODO: invert n*ln(n)
        //search forward
        ax:=0;
        repeat
          if ax=0 then ax:=bx else
           begin
            ax:=bx;
            inc(bx,primes_readblock);
           end;
          if bx>fx then
           begin
            writeln('plist: searching past end of primes list');
            exit;
           end;
          f.Position:=bx*baseintsize;
          f.Read(c,baseintsize);
        until c>a;
        f.Position:=ax*baseintsize;
        f.Read(p[0],primes_readblock*baseintsize);
        //too far? search backward
        while (p[0]>a) and (ax<>0) do
         begin
          dec(ax,primes_readblock);
          f.Position:=ax*baseintsize;
          f.Read(p[0],primes_readblock*baseintsize);
         end;
        //forward inside of block
        d:=0;
        while (p[d]<a) and (d<primes_readblock) do inc(d);
        //now list
        while (p[d]<b) or (a=b) do
         begin
          writeln(IntToStrX(ax+d)+';'+IntToStrX(p[d]));
          inc(d);
          if d=primes_readblock then
           begin
            inc(ax,primes_readblock);
            f.Read(p[0],primes_readblock*baseintsize);
            d:=0;
           end;
          if a=b then b:=0;
         end;
        end;
    writeln('('+IntToStrX(GetTickCount-tc)+'ms)')
  finally
    f.Free;
  end;
end.
