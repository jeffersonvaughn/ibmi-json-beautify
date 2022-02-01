*free       
       //--------------------------------------------------------------------------------------------
       // core-i Solutions 
       // www.jeffersonvaughn.com
       // __________________
       //
       // This software is only to be used for demo / learning purposes.
       // It is NOT intended to be used in a live environment.
       //
       // THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
       // INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
       // PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR THE AUTHOR'S EMPLOYER BE
       // LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
       // (INCLUDING, BUT NOT LIMITED TO, LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION),
       // HOWEVER CAUSED (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
       // SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
       //
       //--------------------------------------------------------------------------------------------
       //                                                                      
       // Program ID   : jsonpretty.sqlrpgle                                          
       // Program Desc : given a filename, update file with pretty version of json string                  
       //
       // Author       : Jay Vaughn
       // Date         : 2022/02/01
       //  
       // Narrative:  user passes in...
       //            - indent char(1) - number of spaces to indent (0=continuous string)
       //            - stream filename
       //
       // NOTE: this program expects the pyton script to reside in...
       //       /jvaughn/source/jsonpretty/jsonpretty.py
       //       if the location changes, please update the g_pythonScript variable value.
       //--------------------------------------------------------------------------------------------
       ctl-opt option (*srcstmt : *nodebugio : *nounref);
       ctl-opt debug (*input);
       ctl-opt dftactgrp (*no);
       

       //-----------------------------------------------------------------------
       // SQL Default Options                                                   
       //-----------------------------------------------------------------------
       exec sql
         set option
         commit = *none,
         closqlcsr = *endmod,
         datfmt    = *iso;

       //-----------------------------------------------------------------------
       // Program interface                                                
       //-----------------------------------------------------------------------
       dcl-pi jsonPretty;
         p_indent        char(1)              const;
         p_fileName      char(50)             const;
         o_msgId         char(7);
         o_msgText       char(80);
       end-pi;

       //-----------------------------------------------------------------------
       // global variables                                               
       //-----------------------------------------------------------------------
       dcl-s g_command          char(1000);
       dcl-s g_pathToPython     char(10);
       dcl-s g_pythonScript     char(50);

       dcl-pr run     ExtPgm('QCMDEXC');
        CmdStr  Char(3000) Options(*VarSize);
        CmdLen  Packed(15:5) Const;
        CmdDbcs Char(2) Const Options(*Nopass);
       end-pr;

       //=======================================================================
       // mainline
       //=======================================================================

       *inlr = *on;

       setUp();
       executePythonScript();
       updateFile();

       return;

       //--------------------------------------------------------------------------
       // procedure
       //--------------------------------------------------------------------------
       dcl-proc setUp;
         dcl-pi *n;
         end-pi;

         g_pathToPython = 'python3';
         g_pythonScript = '/jvaughn/source/jsonpretty/jsonpretty.py';

         g_command = 'OVRDBF FILE(STDOUT) TOFILE(QTEMP/QSTDOUT) ' +
                            'OVRSCOPE(*JOB) '                     +
                            'OPNSCOPE(*JOB)';
         exec sql call qsys2.qcmdexc(:g_command);

         g_command ='CLRPFM QTEMP/QSTDOUT';
         exec sql call qsys2.qcmdexc(:g_command);

         return;

        end-proc;

       //--------------------------------------------------------------------------
       // procedure
       //-------------------------------------------------------------------------
       dcl-proc executePythonScript;
         dcl-pi *n;
         end-pi;

         g_command = 'Qsh Cmd('                                     +
                              ''''                                  +
                                  %trim(g_pathToPython) + ' '       +
                                  %trim(g_pythonScript) + ' '       +
                                  %trim(p_indent)       + ' '       +
                                  %trim(p_fileName)                 +
                             ''''                                   +
                           ')';

         callp run(g_command:%Size(g_command));

         return;

        end-proc;

       //--------------------------------------------------------------------------
       // procedure
       //--------------------------------------------------------------------------
       dcl-proc updateFile;
         dcl-pi *n;
         end-pi;

         g_command ='DLTF QTEMP/PRETTY';
         exec sql call qsys2.qcmdexc(:g_command);

         g_command = 'CRTPF FILE(QTEMP/PRETTY) RCDLEN(240)';
         exec sql call qsys2.qcmdexc(:g_command);

         exec sql
           insert into qtemp.pretty
           (select srcdta
            from qtemp.qstdout);

         g_command = 'CPYTOSTMF FROMMBR('                                  +
                                        ''''                               +
                                        '/qsys.lib/qtemp.lib/pretty.file/' +
                                        'pretty.mbr'                       +
                                        ''''                               +
                                       ')  '                               +                                       
                               'TOSTMF('                                   +
                                       ''''                                +
                                           %trim(p_fileName)               +
                                       ''''                                +
                                     ') '                                  +
                               'STMFOPT(*REPLACE)';    
         exec sql call qsys2.qcmdexc(:g_command);       

         if sqlcode <> 0;
           o_msgId = 'CPF9898';
           o_msgText = 'Error updating stream file with pretty json.';
         endif;

         g_command ='DLTOVR FILE(STDOUT) LVL(*JOB)';
         exec sql call qsys2.qcmdexc(:g_command);

         return;

        end-proc;
