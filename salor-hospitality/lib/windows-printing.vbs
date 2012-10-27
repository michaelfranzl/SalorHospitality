Set objFSO = CreateObject("Scripting.FileSystemObject")



Const ForReading = 1
Const ForWriting = 2





a = 5
While a < 10
    Wscript.Sleep 1000
    Wscript.Echo a
    If objFSO.FileExists("1.salor") Then
Wscript.Echo a
Set objFileA = objFSO.OpenTextFile("1.salor", ForReading)
Set objFileB = objFSO.OpenTextFile("1.salor2", ForWriting, True)

Do Until objFileA.AtEndOfStream
    strLine = objFileA.ReadLine
    objFileB.WriteLine strLine
    Wscript.Echo strLine
Loop

objFileA.Close
objFileB.Close


        Set objFile = objFSO.GetFile("1.salor2")
        objFile.Copy "\\127.0.0.1\salor"
        objFile.Delete

        Set objFile = objFSO.GetFile("1.salor")
        objFile.Delete
    End If
Wend