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

if (profile = ""){
    if Exist("Settings.csv"){
        profile := "Settings.csv"
    }
    Else{
        exitapp
    }
}
else if not Exist(profile)
{ 
    exitapp
}

SplitPath, profile, ProfileFileName, ProfileDirectory, ProfileExtension, ProfileNameWithoutExtension

Global Columns :=["Description","Process","Run on start","Confirm","Hotkey"]

Global GuiTabs := Object() ; Array with GuiTabs

Global profileArray := Object() ; Array contains already resolved profiles -> purpose is to prevent endless loop

ResolveProfile(profile)

LogToTray("AHK StartProcess", "Settings loaded", "info")

OpenGuiHotkey = %2%

if (OpenGuiHotkey = "")
    OpenGuiHotkey := "#w"

Hotkey(OpenGuiHotkey , "OpenGui", ProfileNameWithoutExtension)    

logStartParameters = profile : %profile%, OpenGuiHotkey : %OpenGuiHotkey%

LogToFile("StartParameters",logStartParameters , "info")

PrintCurrentProfilesToFile()

SplitPath, profile, ProfileFileName, ProfileDirectory, ProfileExtension, ProfileNameWithoutExtension
return

#include %A_ScriptDir%\ProcessGui.ahk

OpenGui(a_title){
    GuiTitle := "Profile : " . a_title
    InfoGui(GuiTitle,"", GuiTabs)
}

ResolveProfile(a_profile){

    if not CanResolverofile(a_profile)
        return

    Loop, read, %a_profile%
    {
        if(InStr(A_LoopReadLine, "@") = 1){ ; if first char == @

            profilePath := StrSplit(A_LoopReadLine, "@")[2]

                ResolveProfile(profilePath)  

            continue
             
        } else {

            if not Exist(A_LoopReadLine)
                continue
        }
         
        MyTab := new GuiTab(A_LoopReadLine,Columns,ResolveSettings(A_LoopReadLine))

        GuiTabs.Insert(MyTab)
    }
}

CanResolverofile(a_profile){
    
    if not Exist(a_profile)
        return

    for index, element in profileArray
    {
        if (a_profile = element){

            errMsg := "You are trying to resolve " . a_profile . " multiple times. This profile will be skiped."

            LogToMsg("Resolving issue",errMsg ,"error")

            LogToFile("Resolving issue",errMsg ,"error")

            return false
        }
    }

    profileArray.Insert(a_profile)

    return true
}

PrintCurrentProfilesToFile(){

    Profiles := ""
    
    for index, element in profileArray
    {
        Profiles = %Profiles%, %element% 
    }

    Profiles := SubStr(Profiles,3)

    LogToFile("Effective Profiles",Profiles , "info")

    profileArray:= "" ; Dispose profiles
}

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
        RunProcess(confirm , processToRun, description)
    try{
        Hotkey(currentHotkey , "RunProcess" , confirm , processToRun, description)
    }
    catch{
        if (not currentHotkey = ""){

            LogToMsg("Error"," Cant create hotkey for : " . a_row, "error")

            LogToFile("Error"," Cant create hotkey for : " . a_row, "error")
        }
    }
    return Args
}

RunProcess(a_confirm, a_path, a_description){

    if a_confirm {

        MsgBox,4, % a_description, % "Do you really want to run: `n" . a_path . "`n ?"

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
        messge := "Cannot open or access " . a_path

        LogToMsg("Error", messge, "error")

        LogToFile("Error", messge, "error")

        return false
    }
    return true
}