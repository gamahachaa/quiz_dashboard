@echo off
echo from sub bat PROD
set serverFolderName=quiz_dashboard_test
set BINDIR=%cd%\bin\

rem delete old JS
"C:\_mesProgs\WinSCP\WinSCP.com" ^
  /log="%cd%\WinSCP.log" /ini=nul ^
  /command ^
    "open sftp://qook:uU155cy54IGQf0M4Jek6@10.192.14.13/ -hostkey=""ssh-rsa 2048 nqlUJZBRZk4+gCB8pRNrGcXJrx13iKLTftGfrXlqvk4=""" ^
    "cd /home/qook/app/qook/%serverFolderName%/" ^
    "rm *.js" ^
    "exit"
rem add new JS	
"C:\_mesProgs\WinSCP\WinSCP.com" ^
  /log="%cd%\WinSCP.log" /ini=nul ^
  /command ^
    "open sftp://qook:uU155cy54IGQf0M4Jek6@10.192.14.13/ -hostkey=""ssh-rsa 2048 nqlUJZBRZk4+gCB8pRNrGcXJrx13iKLTftGfrXlqvk4=""" ^
    "lcd %BINDIR%\" ^
    "cd /home/qook/app/qook/%serverFolderName%/" ^
    "put -nopreservetime *.js" ^
    "exit"
	
rem delete old JS MAP	
"C:\_mesProgs\WinSCP\WinSCP.com" ^
  /log="%cd%\WinSCP.log" /ini=nul ^
  /command ^
    "open sftp://qook:uU155cy54IGQf0M4Jek6@10.192.14.13/ -hostkey=""ssh-rsa 2048 nqlUJZBRZk4+gCB8pRNrGcXJrx13iKLTftGfrXlqvk4=""" ^
    "cd /home/qook/app/qook/%serverFolderName%" ^
    "rm *.js.map" ^
    "exit"
	
rem add new JS MAP	
"C:\_mesProgs\WinSCP\WinSCP.com" ^
  /log="%cd%\WinSCP.log" /ini=nul ^
  /command ^
    "open sftp://qook:uU155cy54IGQf0M4Jek6@10.192.14.13/ -hostkey=""ssh-rsa 2048 nqlUJZBRZk4+gCB8pRNrGcXJrx13iKLTftGfrXlqvk4=""" ^
    "lcd %BINDIR%\" ^
    "cd /home/qook/app/qook/%serverFolderName%" ^
    "put -nopreservetime *.js.map" ^
    "exit"
rem ADD FONTS

rem index
"C:\_mesProgs\WinSCP\WinSCP.com" ^
  /log="%cd%\WinSCP.log" /ini=nul ^
  /command ^
    "open sftp://qook:uU155cy54IGQf0M4Jek6@10.192.14.13/ -hostkey=""ssh-rsa 2048 nqlUJZBRZk4+gCB8pRNrGcXJrx13iKLTftGfrXlqvk4=""" ^
    "lcd %BINDIR%\" ^
    "cd /home/qook/app/qook/%serverFolderName%" ^
    "put -nopreservetime index.html" ^
    "exit"