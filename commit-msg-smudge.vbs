'Must run with cscript.exe
Set fso = CreateObject("Scripting.FileSystemObject")
Set stdin  = fso.GetStandardStream(0)
Set stdout = fso.GetStandardStream(1)
Set stderr  = fso.GetStandardStream(2)
Set objWsh = WScript.CreateObject ("WScript.Shell")
Const ForReading = 1, ForWriting = 2, ForAppending = 8

'Declare arguments
dim objArgs, sBaseFile, strText, strNewText

Set objArgs = WScript.Arguments
num = objArgs.Count
if num < 1 then
    stderr.WriteLine "Usage: [CScript | WScript] hsdw-commit-msg-smudge.vbs infile.sql"
    WScript.Quit 1
end if

'Set the file name
'This file may not exist yet, we use this for running git pretty commands.
sBaseFile = objArgs(0)
'msgbox sBaseFile

cmd = "git log --date=format:""%Y-%m-%d %H:%M:%S"" --pretty=format:""%cd - %h - %cN - %s"" -1 -- " & sBaseFile

'msgbox "T" & sBaseFile &":" & cmd &"T"
'Get any info for this file from gitlog
'On Error Resume Next
Set oExec = objWsh.Exec (cmd)
If (Err.Number <> 0) Then
    strerr.WriteLine "Error: " & Err.Message	
Else
    'msgbox oexec.stderr.readline
    Do While oExec.Status = 0
        Do While Not oExec.StdOut.AtEndOfStream
            strLogTxt = strLogTxt & "--" & oExec.StdOut.ReadLine
        Loop
        WScript.Sleep 0
    Loop
End If

'Read all standard input to a string and insert the log when tag is found.
v_str_replace = false
Do
    strText = stdin.ReadLine()
    if v_str_replace <> true then
        strStartPos = InStr(strText,"--$Log:") 
	if strStartPos > 0 then
	        'Perform substitutions
		'stdout.writeline strText
		strStringEnd = Right(strText, len(strText) - Len("--$Log:"))
		stdout.writeline Left(strText, strStartPos + Len("--$Log:"))
		stdout.writeline "--Last commit:"
		stdout.writeline strLogTxt
	    stdout.writeline "--$EndLog:"
		if Len(strStringEnd) > 0 then
	            stdout.writeline strStringEnd
		end if
		v_str_replace = true
	else
		stdout.writeline strText
	end if
    else
        stdout.writeline strText
    end if
Loop While Not stdin.atEndOfStream