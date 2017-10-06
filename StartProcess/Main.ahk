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
#include %A_ScriptDir%\..\SharedLibrary\ArrayExtensions.ahk
; HasVal(haystack, needle)

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

SplitPath, profile, , , , ProfileNameWithoutExtension

Global Columns :=["Description","Process","Run on start","Confirm","Hotkey"]

Global GuiTabs := Object() ; Array with GuiTabs

Global profileArray := Object() ; Array contains already resolved profiles -> purpose is to prevent endless loop

Global CheckForHotkeys := new CheckHotkey()

ResolveProfile(profile)

LogToTray("AHK StartProcess", "Settings loaded", "info")

OpenGuiHotkey = %2%

if (OpenGuiHotkey = "")
    OpenGuiHotkey := "#w"

Hotkey(OpenGuiHotkey , "OpenGui", ProfileNameWithoutExtension)    

logStartParameters = profile : %profile%, OpenGuiHotkey : %OpenGuiHotkey%

LogToFile("StartParameters",logStartParameters , "info")

PrintCurrentProfilesToFile()

CheckForHotkeys.Clear()

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
        
        SplitPath, A_LoopReadLine, , , , ProfileNameWithoutExtension

        MyTab := new GuiTab(ProfileNameWithoutExtension, Columns,ResolveSettings(A_LoopReadLine))

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
        
    if (not currentHotkey ="")
        try{

            if CheckForHotkeys.CanAddHotkey(currentHotkey, processToRun){

                Hotkey(currentHotkey , "RunProcess" , confirm , processToRun, description)
            }
            else{

                firstProcess := CheckForHotkeys.ResolveHotkey(currentHotkey)

                secondProcess := processToRun

                message := % firstProcess . " and " . secondProcess . " wannt to register the same hotkey: " . currentHotkey . ". Hotkey for " . secondProcess . " will be disabled. Please check your libraries and fix this issue."
                
                LogToMsg("Hotkey registration issue", message, "error")

                LogToFile("Hotkey registration issue", message, "error")
            }
        }
        catch e{

            msg := % "An exception was thrown!`nSpecifically: " . e.line . " - " . e.message

            LogToMsg("Error"," Cant create hotkey for : " . a_row, "error")

            LogToFile("Error"," Cant create hotkey for : " . a_row . ". " . msg, "error")
        }

    Args[5] := ReplaceHotkey(currentHotkey)

    return Args
}

; changes '!#t' to 'Alt + Win + t'
ReplaceHotkey(a_hotkey){ 

    StringReplace, a_hotkey, a_hotkey,^,Ctrl +%A_Space%

    StringReplace, a_hotkey, a_hotkey,!,Alt +%A_Space%

    StringReplace, a_hotkey, a_hotkey,+,Shift +%A_Space%

    StringReplace, a_hotkey, a_hotkey,#,Win +%A_Space%

    return a_hotkey
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
    catch e{
	
		msg := % "An exception was thrown!`nSpecifically: " . e.line . " - " . e.message
		
        LogToMsg("Error", "AppLuncher Cant run : " . a_process, "error")

        LogToFile("Error","AppLuncher Cant run : " . a_process . ". " . msg, "error")
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


; Check and prevent multiple usages of same hotkey
; 2 Processes cant use same hotkey !
class CheckHotkey{

    hotkeys := {}
    processes := {}

    CanAddHotkey(a_hotkey, a_process){

        if (HasVal(this.hotkeys, a_hotkey) = 0){

            this.hotkeys.Insert(a_hotkey)

            this.processes.Insert(a_process)

            return true
        }
        else
        {
            return false
        }
    }

    ResolveHotkey(a_hotkey){

        index := HasVal(this.hotkeys, a_hotkey)
        
        return this.processes[index]
    }

    ; Dispose Arrays
    Clear(){
        this.hotkeys := ""
        this.processes := ""
    }
}