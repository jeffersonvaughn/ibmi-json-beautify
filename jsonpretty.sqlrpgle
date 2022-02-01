**free
ctl-opt option (*srcstmt : *nodebugio : *nounref);
ctl-opt debug (*input);
ctl-opt dftactgrp (*no);

exec sql
  set option
  commit = *none,
  closqlcsr = *endmod,
  datfmt    = *iso;

dcl-pi jsonPretty;
  p_jsonIn        char(32000)             const;
  o_jsonOut       char(32000);
end-pi;

dcl-s g_command          char(1000);
dcl-s g_pathToPython     char(10);
dcl-s g_pythonScript     char(25);

dcl-pr run     ExtPgm('QCMDEXC');
       CmdStr  Char(3000) Options(*VarSize);
       CmdLen  Packed(15:5) Const;
       CmdDbcs Char(2) Const Options(*Nopass);
end-pr;

//--------------------------------------------------------

setUp();
executePythonScript();
getJsonPretty();

*inlr = *on;
return;

//--------------------------------------------------------
// setUp subprocedure
//--------------------------------------------------------

dcl-proc setUp;

g_pathToPython = 'python3';
g_pythonScript = '/home/jvaughn/jsonpretty.py';

g_command = 'OVRDBF FILE(STDOUT) TOFILE(QTEMP/QSTDOUT) ' +
                   'OVRSCOPE(*JOB) '                     +
                   'OPNSCOPE(*JOB)';
exec sql call qsys2.qcmdexc(:g_command);

g_command ='CLRPFM QTEMP/QSTDOUT';
exec sql call qsys2.qcmdexc(:g_command);

end-proc setUp;

//--------------------------------------------------------
// executePythonScript subprocedure
//--------------------------------------------------------

dcl-proc executePythonScript;

g_command = 'Qsh Cmd('                                     +
                     ''''                                  +
                         %trim(g_pathToPython) + ' '       +
                         %trim(g_pythonScript) + ' '       +
                         %trim(p_jsonIn)                     +
                     ''''                                  +
                       ')';

callp run(g_command:%Size(g_command));

end-proc executePythonScript;

//--------------------------------------------------------
// getJsonPretty       subprocedure
//--------------------------------------------------------

dcl-proc getJsonPretty;

exec sql
  select srcdta
    into :o_jsonPretty
  from qtemp.qstdout
  fetch first 1 row only;

g_command ='DLTOVR FILE(STDOUT) LVL(*JOB)';
exec sql call qsys2.qcmdexc(:g_command);

end-proc;