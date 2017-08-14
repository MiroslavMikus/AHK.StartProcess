#SingleInstance force

#include %A_ScriptDir%\..\SharedLibrary\Hotkey.ahk
;  Hotkey(hk, fun, arg*)
#include %A_ScriptDir%\..\SharedLibrary\TypeOperations.ahk
;  BoolToString(a_Bool)
;  StringToBool(a_string)
#include %A_ScriptDir%\..\SharedLibrary\SimpleLog.ahk
;  LogToTray(a_title, a_message, a_class, a_timeout := 5)
;  LogToMsg(a_title, a_message, a_class, a_timeout := 0)
;  LogToFile(a_title, a_message, a_class, a_FileName := ahkLog.txt)

profile = %1%

if not FileExist(profile){
    LogToFile("Exit", profile . " is missing. Script will be closed", "error")
    LogToMsg("Exit", profile . " is missing. Script will be closed", "error")    
    exitapp
}

Global Columns :=["Description","Process","Run on start","Confirm","Hotkey"]

Global GuiTabs := Object() ; Array with GuiTabs

Loop, read, %profile%
{
    if not Exist(A_LoopReadLine)
        continue

    MyTab := new GuiTab(A_LoopReadLine,Columns,ResolveSettings(A_LoopReadLine))

    GuiTabs.Insert(MyTab)
}

LogToTray("Hotkey_Process", "Settings loaded", "info")

return

#include %A_ScriptDir%\ProcessGui.ahk

#Numpad0:: ; todo change this
    InfoGui("Process Starter","", GuiTabs)
return

ResolveSettings(a_row){
    
    MyRows := Object()

    Loop, read, % a_row
    {
        MyRows.Insert(ResolveData(A_LoopReadLine))
    }

    return MyRows
}


ResolveData(a_row){
    Args := StrSplit(a_row,";")

    description := Args[1]
    processToRun := Args[2]
    runOnStart := StringToBool(Args[3])
    confirm := StringToBool(Args[4])
    currentHotkey := Args[5]

    if runOnStart
        RunProcess(confirm , processToRun)
    try{
        Hotkey(currentHotkey , "RunProcess" , confirm , processToRun)
    }
    catch{
        if (not currentHotkey = ""){
            LogToMsg("Error"," Cant create hotkey for : " . a_row, "error")
            LogToFile("Error"," Cant create hotkey for : " . a_row, "error")
        }
    }
    return Args
}

RunProcess(a_confirm, a_path){
    if a_confirm {
        MsgBox,4, AppLuncher, % "Do you really want to run: `n" . a_path . "`n ?"
        IfMsgBox No 
        {
            return
        }
    }

    try{
        StringReplace, a_process, a_path, {#}, %A_ScriptDir%
        run, %a_process%
        LogToFile("Info","Run process : " . a_process ,"Info")
    }
    catch{
        LogToMsg("Error", "AppLuncher Cant run : " . a_process, "error")
        LogToFile("Error","AppLuncher Cant run : " . a_process, "error")
    }
}

Exist(a_path){
    if not FileExist(a_path)
    {
        LogToMsg("Error", "Cannot open or access " . a_path, "error")
        return false
    }
    return true
}