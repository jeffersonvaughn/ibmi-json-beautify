**free
ctl-opt option (*srcstmt : *nodebugio : *nounref);
ctl-opt debug (*input);
ctl-opt dftactgrp (*no);

exec sql
  set option
  commit = *none,
  closqlcsr = *endmod,
  datfmt    = *iso;

dcl-pi hashitr;
  p_pass          char(32)              const;
  o_hash          char(64);
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
getHashValue();

*inlr = *on;
return;

//--------------------------------------------------------
// setUp subprocedure
//--------------------------------------------------------

dcl-proc setUp;

g_pathToPython = 'python3';
g_pythonScript = '/home/jvaughn/hashit.py';

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
                         %trim(p_pass)                     +
                     ''''                                  +
                       ')';

callp run(g_command:%Size(g_command));

end-proc executePythonScript;

//--------------------------------------------------------
// getHashValue        subprocedure
//--------------------------------------------------------

dcl-proc getHashValue;

exec sql
  select srcdta
    into :o_hash
  from qtemp.qstdout
  fetch first 1 row only;

g_command ='DLTOVR FILE(STDOUT) LVL(*JOB)';
exec sql call qsys2.qcmdexc(:g_command);

end-proc;