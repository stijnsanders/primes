program primes;

{$APPTYPE CONSOLE}
{$SetPEFlags $20}

uses
  FastMM4 in 'FastMM\FastMM4.pas',
  Windows,
  SysUtils,
  Classes,
  primeUtils in 'primeUtils.pas';

const
  primes_writeblock=$10000;
  growstep=$100; //must be smaller than primes_writeblock!
  treshold=8;
var
  fn:string;
  a,b:array of baseint;
  grow:boolean;
  c,d,dmax,dx,px,lx,fx:baseint;
  tc:cardinal;
  f:TFileStream;
  p:array[0..primes_writeblock-1] of baseint;
begin
  if ParamCount<1 then fn:=primes_filename else fn:=ParamStr(1);
  //Defaults
  fx:=0;
  px:=1;
  lx:=0;
  p[0]:=2;
  c:=3;
  //start or reprise file
  if FileExists(fn) then
   begin
    f:=TFileStream.Create(fn,fmOpenReadWrite or fmShareDenyWrite);
    fx:=((f.Size div baseintsize) div primes_writeblock)*primes_writeblock;
    if fx<>0 then
     begin
      f.Position:=(fx-1)*baseintsize;
      f.Read(c,baseintsize);
      write('p('+IntToStrX(fx)+')='+IntToStrX(c)+' : resume');
      px:=0;
      inc(c,2);
      //reprise from existing file, start with highest bx in a[bx]<isqrt(c)
      dmax:=isqrt(c);
      lx:=0;
      repeat
        f.Position:=lx*baseintsize;
        f.Read(d,baseintsize);
        if (d<dmax) then inc(lx,growstep);
      until not((lx<fx) and (d<dmax));
      writeln(' ('+IntToStrX(dmax)+') [max:'+IntToStrX(lx)+']');
      SetLength(a,lx);
      f.Position:=0;
      f.Read(a[0],lx*baseintsize);
      SetLength(b,lx);
      d:=0;
      while d<lx do
       begin
        b[d]:=c-(c mod a[d]);
        inc(d);
       end;
     end;
   end
  else
    begin
     //f:=TFileStream.Create(fn,fmCreate);
     TFileStream.Create(fn,fmCreate).Free;
     f:=TFileStream.Create(fn,fmOpenReadWrite or fmShareDenyWrite);
    end;
  grow:=lx=0;
  try
    tc:=GetTickCount;
    dx:=0;
    repeat
      //check grow flag
      if grow then
       begin
        grow:=false;
        d:=lx+growstep;
        if d=0 then raise Exception.Create('primes buffer size too large for integer type');
        writeln('new size : '+IntToStrX(d)+' ['+IntToStrX(fx+px)+','+IntToStrX(c)+']');
        SetLength(a,d);
        SetLength(b,d);
        if fx<=lx then
          Move(p[lx],a[lx],growstep*baseintsize)
        else
         begin
          f.Position:=lx*baseintsize;
          f.Read(a[lx],growstep*baseintsize);
         end;
        Move(a[lx],b[lx],growstep*baseintsize);
        lx:=d;
       end;
      //check each prime's next multiple
      d:=0;
      if (fx=0) and (px<lx) then dmax:=px else dmax:=lx;//calculate dmax lowest x in a[x]>isqrt(c) here?
      repeat
        while b[d]<c do inc(b[d],a[d]);
        if b[d]>c then inc(d);
      until (d=dmax) or (b[d]=c);
      if d=dmax then
       begin
        //prime found
        p[px]:=c;
        if (fx=0) and (px<=lx) then
         begin
          a[px]:=c;
          b[px]:=c;
         end;
        inc(px);
        //at growstep? grow and store
        if px=primes_writeblock then
         begin
          writeln('p('+IntToStrX(fx+px-1)+')='+IntToStrX(c)+' : '+IntToStrX(GetTickCount-tc)+'ms [highf:p('+IntToStrX(dx)+')='+IntToStrX(a[dx])+';max:'+IntToStrX(lx)+']');
          f.Position:=fx*baseintsize;
          f.Write(p[0],primes_writeblock*baseintsize);
          inc(fx,primes_writeblock);
          if fx=0 then raise Exception.Create('primes list length too large for integer type');
          px:=0;
          dx:=0;
          tc:=GetTickCount;
         end;
       end
      else
       begin
        if dx<d then dx:=d;
        if d>lx-treshold then grow:=true;
       end;
      //next to check: skip even numbers
      inc(c,2);
    //loop until counter rolls over
    until c<3;
  finally
    f.Free;
  end;
end.
