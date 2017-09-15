'Must run with cscript.exe
Set fso = CreateObject("Scripting.FileSystemObject")
Set stdin  = fso.GetStandardStream(0)
Set stdout = fso.GetStandardStream(1)
Set stderr  = fso.GetStandardStream(2)
Set objWsh = WScript.CreateObject ("WScript.Shell")
Const ForReading = 1, ForWriting = 2, ForAppending = 8

'Declare arguments
dim objArgs, sBaseFile, strText, strNewText

'Read file
strText = stdin.ReadAll

'Find end log and add to it the length of the end log string
strEndPos = InStr(strText,"--$EndLog:")
'Get the start position of the log
strStartPos = InStr(strText,"--$Log:") + Len("--$Log:") - 1

'If we didn't find the EndLog tag, just return the basic file. If we find end log, remove the log.
if strEndPos > 0 then
	strEndPos = Len(strText) - strEndPos - Len("--$Log:") - 3
	strStringStart = Left(strText, strStartPos)
	strStringEnd = Right(strText, strEndPos)
	strNewText = strStringStart & strStringEnd 
	'Write the result
	stdout.Write strNewText
else
	'No changes to file
	stdout.Write strText
end if