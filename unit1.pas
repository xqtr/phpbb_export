unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, mysql55conn, mssqlconn, sqldb, db, FileUtil, Forms,
  Controls, Graphics, Dialogs, DBGrids, StdCtrls, ComCtrls, Menus, DateUtils,
  regexpr;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Datasource1: TDatasource;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MySQL55Connection1: TMySQL55Connection;
    PopupMenu1: TPopupMenu;
    SQLQuery: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    TreeView1: TTreeView;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    function FindChildbyid(Item: TTreeView;Value: String): TTreenode;
    procedure log(t:string);
    procedure TreeView1Click(Sender: TObject);
    procedure query(sql:string);
    procedure querylog(field:string);
    procedure showposts(topic_id:string);
    function filtertitle(str:string):string;
    function filterpost(str,reg,replace: string): string;
  private
    { private declarations }
  public
    { public declarations }
  end;

type
  PDataRec = ^TDataRec; { RecordPointer }
  TDataRec = record { Record for Node-Data }
    topic_id: string;
    forum_id:string;
    parent: string;
    name: string;
    topic:boolean;
    { To be extended }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function Tform1.FindChildbyid(Item: TTreeView;Value: String): TTreenode;
var
    Node: TTreeNode;
    s:string;
begin
  Result := nil;
  if item.Items.Count = 0 then Exit;
  Node := item.Items[0];
  while Node <> nil do
  begin
    if node.data<>nil then begin
    s:= pdatarec(node.Data)^.forum_id;
    if s = Value then
    begin
      Result := Node;
      exit;
    end;

    end;
    Node := Node.GetNext;
end;
end;

procedure TForm1.log(t: string);
begin
  memo1.Lines.add(t);
end;

procedure TForm1.TreeView1Click(Sender: TObject);
begin
  if treeview1.Selected<>nil then begin
     if pdatarec(treeview1.selected.data)^.topic=false then begin
       query('select topic_id,forum_id,topic_title from forum_topics where forum_id='+pdatarec(treeview1.selected.data)^.forum_id);
       memo1.lines.clear;
       querylog('topic_title');
     end else begin
       query('SELECT post_id,forum_users.username,forum_users.user_id,forum_posts.post_postcount,forum_posts.post_time,forum_posts.poster_id,forum_posts.poster_ip,forum_posts.post_subject,forum_posts.post_text,topic_id FROM forum_posts LEFT JOIN forum_users ON forum_users.user_id = forum_posts.poster_id where topic_id='+pdatarec(treeview1.selected.data)^.topic_id+' ORDER BY forum_posts.post_time');
       memo1.lines.clear;
       showposts(pdatarec(treeview1.selected.data)^.topic_id);
     end;
  end;
end;

procedure TForm1.query(sql: string);
begin
  sqlquery.close;
  sqlquery.SQL.Text := sql;
  sqlQuery.Open;
end;

procedure TForm1.querylog(field:string);
begin
  sqlquery.First;
  while not sqlquery.Eof do
  begin
    log(sqlquery.FieldByName(field).asstring);
    sqlquery.Next;
  end;

end;

procedure TForm1.showposts(topic_id: string);
var
 t:integer;
 s:string;
begin
  sqlquery.First;
    while not sqlquery.Eof do
    begin
      t:=sqlquery.FieldByName('post_time').asinteger;
      s:=FormatDateTime('hh:nn DD-MM-YYYY',UnixToDateTime(t));
      memo1.lines.add(stringofchar('=',79));
      memo1.lines.add('# '+sqlquery.FieldByName('post_id').asstring+'   '+sqlquery.FieldByName('post_subject').asstring);
      memo1.lines.add('Ημ/νια: '+s);
      memo1.lines.add('Χρηστης: '+sqlquery.FieldByName('username').asstring);
      memo1.lines.add(stringofchar('=',79));
      memo1.lines.add('');
      s:=sqlquery.FieldByName('post_text').asstring;
      memo1.lines.add(s);
      memo1.lines.add(stringofchar('=',79));
      memo1.lines.add('');
      memo1.lines.add('');
      sqlquery.Next;
    end;
end;

function TForm1.filterTitle(str: string): string;
var
    s:string;
begin
  s:=str;
  s:=stringreplace(s,'/','-',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'#','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'@','a',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'...','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,' ... ','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'!','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'?','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'&quot;','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'''','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,':','_',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,';','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'&gt;','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'&gt','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,';','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,'&amp;','',[rfReplaceAll, rfIgnoreCase]);
  s:=stringreplace(s,',,,','',[rfReplaceAll, rfIgnoreCase]);
  result:=s;
end;

function TForm1.filterpost(str,reg,replace: string): string;
var
  RegexObj: TRegExpr;
  i:integer;
  s:string;
begin
  s:=str;
  RegexObj := TRegExpr.Create;
  RegexObj.Expression := reg;
  if RegexObj.Exec(str) then begin
    replaceRegexpr(reg,str,replace,false);
  end;
  result:=s;
  RegexObj.Free;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  parent_id, forum_id,forum_name: string;
  RootNode, DeptNode,temp: TTreeNode;
  d:integer;
  pdata:pdatarec;
begin
  sqlquery.close;
  forum_id := '0';
  Treeview1.Items.Clear;
  new(pdata);
        pdata^.forum_id:='0';
        pdata^.parent:='0';
        pdata^.topic:=false;
  RootNode := Treeview1.Items.AddObject(nil, 'Forums',pdata);
  DeptNode := nil;
  sqlquery.SQL.Text := 'SELECT forum_id,parent_id,forum_name from forum_forums order by parent_id, forum_id';
  sqlQuery.Open;
  try
    sqlquery.First;
    while not sqlquery.Eof do
    begin
      parent_id := sqlquery.FieldByName('parent_id').Asstring;
      forum_name := stringreplace(sqlquery.FieldByName('forum_name').Asstring,'/','-',[rfReplaceAll, rfIgnoreCase]);
      log(sqlquery.FieldByName('forum_name').asstring);
      if parent_id = '0' then
      begin
        new(pdata);
        pdata^.forum_id:=sqlquery.FieldByName('forum_id').AsString;
        pdata^.parent:=sqlquery.FieldByName('parent_id').AsString;
        pdata^.topic:=false;
        DeptNode := treeview1.Items.AddChildObject(rootnode,filtertitle(forum_name),pdata);
      end else begin
        temp:=findchildbyid(treeview1,sqlquery.FieldByName('parent_id').AsString);
        new(pdata);
        pdata^.forum_id:=sqlquery.FieldByName('forum_id').AsString;
        pdata^.parent:=sqlquery.FieldByName('parent_id').AsString;
        pdata^.topic:=false;
        DeptNode := treeview1.Items.AddChildObject(temp,filtertitle(forum_name),pdata);
      end;

      sqlquery.Next;
    end;
  finally

  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  topic_id, forum_id,topic_title: string;
  RootNode, DeptNode,temp: TTreeNode;
  d:integer;
  pdata:pdatarec;
begin
  sqlquery.close;
  sqlquery.SQL.Text := 'select topic_id,forum_id,topic_title from forum_topics';
  sqlQuery.Open;
  try
    sqlquery.First;
    while not sqlquery.Eof do
    begin
      topic_id:=sqlquery.FieldByName('topic_id').AsString;
      forum_id:=sqlquery.FieldByName('forum_id').AsString;
      topic_title:=sqlquery.FieldByName('topic_title').AsString;
      temp:=findchildbyid(treeview1,forum_id);
      new(pdata);
      pdata^.topic_id:=topic_id;
      pdata^.forum_id:=forum_id;
      pdata^.parent:=forum_id;
      pdata^.topic:=true;
      DeptNode := treeview1.Items.AddChildObject(temp,filtertitle(topic_title),pdata);
      sqlquery.Next;
    end;
  finally

  end;

end;

procedure TForm1.Button3Click(Sender: TObject);
var
  base:string;
  parentt,node:ttreenode;
  ps,q,q1:string;
  sl:tstringlist;
   t:integer;
  s:string;

Function GetNodePath(ANode: TTreenode; ADelimiter: String='/'): String;
begin
Result := '';
       while ANode<>nil do
       begin
          Result := ADelimiter + aNode.Text + Result;
          ANode := ANode.Parent;
       end;
if Result <> '' then Delete(Result,1,1);
end;

begin
  base:='/home/x/Various/forum_text';
  Node := TreeView1.Items[0];
  memo1.lines.clear;
  sl:=tstringlist.Create;
  while Node<>nil do
  begin
    ps:=getnodepath(node);
    log(''+base+'/'+ps);

   if node.Data<>nil then
      if pdatarec(node.data)^.topic=true then begin

            query('SELECT post_id,forum_users.username,forum_users.user_id,forum_posts.post_postcount,forum_posts.post_time,forum_posts.poster_id,forum_posts.poster_ip,forum_posts.post_subject,forum_posts.post_text,topic_id FROM forum_posts LEFT JOIN forum_users ON forum_users.user_id = forum_posts.poster_id where topic_id='+pdatarec(node.data)^.topic_id+' ORDER BY forum_posts.post_time');
           sl.clear;
			//Add a banner here, if you want
			sl.add('');


           sqlquery.First;
    while not sqlquery.Eof do
    begin

           t:=sqlquery.FieldByName('post_time').asinteger;
           s:=FormatDateTime('hh:nn DD-MM-YYYY',UnixToDateTime(t));
      sl.add('''-----------------------------------------------------------------------------''');
      sl.add(Format(' | # %6s Θεμα: %-61s ',[sqlquery.FieldByName('post_id').asstring, trim(sqlquery.FieldByName('post_subject').asstring)]));
      sl.add(Format(' : Hμ/νια: %0:16s %1:48s ',[s, ' ']));
      sl.add(Format(' '' Χρηστης: %0:-20s %1:43s ',[sqlquery.FieldByName('username').asstring, ' ']));
      sl.add('              . ---  ----  --------  -----------------------------------------''');
      sl.add('');
      s:=sqlquery.FieldByName('post_text').asstring;
      sl.add(s);
      sl.add('');
      sl.add('');

      sqlquery.Next;
    end;

	//add a footer here, if you want.
    sl.add('');
    sl.saveToFile(''+base+'/'+ps+'.txt');
           end;

       Node := Node.GetNext;
       log('.');
       application.ProcessMessages;
  end;
   sl.free;
   log('End of process... [Post Creation]');
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  base:string;
  parentt,node:ttreenode;
  ps:string;
  sl:tstringlist;
   t:integer;
  s:string;

Function GetNodePath(ANode: TTreenode; ADelimiter: String='/'): String;
begin
Result := '';
       while ANode<>nil do
       begin
          Result := ADelimiter + aNode.Text + Result;

         ANode := ANode.Parent;
       end;
if Result <> '' then Delete(Result,1,1);
end;

begin
  base:='/home/x/Various/forum_text';
  Node := TreeView1.Items[0];
  memo1.lines.clear;
  sl:=tstringlist.Create;
  while Node<>nil do
  begin
    ps:=getnodepath(node);
    log(''+base+'/'+ps);

    if directoryexists(base+'/'+getnodepath(node)) then log('[exists] '+base+'/'+getnodepath(node)) else begin
    log('[created] '+base+'/'+getnodepath(node));
    forcedirectories(base+'/'+getnodepath(node))
    end;
       Node := Node.GetNext;
  end;
   sl.free;

end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var i:integer;
begin
  for i:=0 to treeview1.Items.Count-1 do begin
    if assigned(treeview1.Items[i].Data) then
    Finalize(PDataRec(treeview1.Items[i].Data)^);
  end;
end;

end.

