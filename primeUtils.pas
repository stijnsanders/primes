unit primeUtils;

interface

type
  baseint=UInt64;//cardinal
const
  primes_filename='primes_i64';//'primes_i32';
  baseintsize=SizeOf(baseint);

function IntToStrX(x:baseint):string;
function StrToIntX(x:string):baseint;
function isqrt(x:baseint):baseint;

implementation

uses SysUtils;

function IntToStrX(x:baseint):string;
begin
  Result:='';
  repeat
    Result:=char($30 or (x mod 10))+Result;
    x:=x div 10;
  until x=0;
end;

function StrToIntX(x:string):baseint;
var
  i:integer;
  y:baseint;
begin
  Result:=0;
  for i:=1 to Length(x) do if x[i] in ['0'..'9'] then
   begin
    y:=Result;
    Result:=Result*10+(byte(x[i]) and $F);
	if Result<y then raise Exception.Create('Integer too big for 64 bit');
   end;
    //else raise?
  //TODO: check past usable bits
end;

function isqrt(x:baseint):baseint;
var
  p,q:baseint;
begin
  //get highest power of four
  p:=0;
  q:=4;
  while (q<>0) and (q<=x) do
   begin
    p:=q;
    q:=q shl 2;
   end;
  //
  q:=0;
  while p<>0 do
   begin
    if x>=p+q then
     begin
      dec(x,p);
      dec(x,q);
      q:=(q shr 1)+p;
     end
    else
      q:=q shr 1;
    p:=p shr 2;
   end;
  Result:=q;
end;


end.
