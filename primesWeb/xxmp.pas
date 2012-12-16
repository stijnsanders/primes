unit xxmp;

{
  xxm Project

This is a default xxm Project class inheriting from TXxmProject. You are free to change this one for your project.
Use LoadPage to process URL's as a requests is about to start.
(Be carefull with sending content from here though.)
It is advised to link each request to a session here, if you want session management.
(See  an example xxmSession.pas in the public folder.)
Use LoadFragment to handle calls made to Context.Include.

  $Rev: 102 $ $Date: 2010-09-15 14:42:45 +0200 (wo, 15 sep 2010) $
}

interface

uses xxm;

type
  TXxmprimes=class(TXxmProject)
  public
    function LoadPage(Context: IXxmContext; Address: WideString): IXxmFragment; override;
    function LoadFragment(Context: IXxmContext; Address, RelativeTo: WideString): IXxmFragment; override;
    procedure UnloadFragment(Fragment: IXxmFragment); override;
  end;

function XxmProjectLoad(AProjectName:WideString): IXxmProject; stdcall;

implementation

uses xxmFReg, Windows, SysUtils, Classes;

function XxmProjectLoad(AProjectName:WideString): IXxmProject;
begin
  Result:=TXxmprimes.Create(AProjectName);
end;

threadvar
  log:record
    id,d:cardinal;
    qpd,qpt:int64;
    f:TFileStream;
    x:string;
  end;

{ TXxmprimes }

function TXxmprimes.LoadPage(Context: IXxmContext; Address: WideString): IXxmFragment;
var
  i:cardinal;
begin
  inherited;
  //TODO: link session to request
  Result:=XxmFragmentRegistry.GetFragment(Self,Address,'');

  i:=GetCurrentThreadId;
  if log.id<>i then
   begin
    log.id:=i;
    log.f:=nil;
    if not QueryPerformanceFrequency(log.qpd) then log.qpd:=1000;
   end;
  if not QueryPerformanceCounter(log.qpt) then log.qpt:=GetTickCount;
  log.x:=
    FormatDateTime('hh:nn:ss.zzz',Now)+#9+
    Context.ContextString(csVerb)+#9+
    Address+#9+
    Context.ContextString(csQueryString)+#9+
    Context.ContextString(csRemoteAddress)+#9+
    Context.ContextString(csUserAgent)+#9;
end;

function TXxmprimes.LoadFragment(Context: IXxmContext; Address, RelativeTo: WideString): IXxmFragment;
begin
  Result:=XxmFragmentRegistry.GetFragment(Self,Address,RelativeTo);
end;

procedure TXxmprimes.UnloadFragment(Fragment: IXxmFragment);
var
  i:cardinal;
  s:string;
  qpt:int64;
begin
  inherited;
  //TODO: set cache TTL, decrease ref count
  //Fragment.Free;

  i:=Trunc(Now);
  if (log.f=nil) or (log.d<>i) then
   begin
    FreeAndNil(log.f);
    log.d:=i;
    SetLength(s,1024);
    SetLength(s,GetModuleFileName(HInstance,PChar(s),1024));
    i:=Length(s);
    while (i>0) and (s[i]<>PathDelim) do dec(i);
    if i>0 then dec(i);
    while (i>0) and (s[i]<>PathDelim) do dec(i);
    s:=Copy(s,1,i)+'log\'+FormatDateTime('yyyymmdd_hhnn',Now)+'_'+IntToStr(GetCurrentProcessID)+'_'+IntToStr(GetCurrentThreadID)+'.log';
    try
        log.f:=TFileStream.Create(s,fmCreate or fmShareDenyWrite);
      //TODO: header?
    except
      on EFCreateError do
       begin
          log.f:=TFileStream.Create(s,fmOpenWrite or fmShareDenyWrite);
      log.f.Position:=log.f.Size;
       end;
    end;
   end;

  if not QueryPerformanceCounter(qpt) then qpt:=GetTickCount;
  s:=log.x+IntToStr((qpt-log.qpt)*1000 div log.qpd)+'ms'#13#10;
  log.f.Write(s[1],Length(s));

end;

initialization
  IsMultiThread:=true;
end.
