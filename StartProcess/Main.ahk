#SingleInstance force

#include %A_ScriptDir%\..\SharedLibrary\Hotkey.ahk
;  Hotkey(hk, fun, arg*) : void
#include %A_ScriptDir%\..\SharedLibrary\TypeOperations.ahk
;  BoolToString(a_Bool) : string
;  StringToBool(a_string) : bool
#include %A_ScriptDir%\..\SharedLibrary\SimpleLog.ahk
;  LogToTray(a_title, a_message, a_class, a_timeout := 5) : void
;  LogToMsg(a_title, a_message, a_class, a_timeout := 0) : void
;  LogToFile(a_title, a_message, a_class, a_FileName := ahkLog.txt) : void
#include %A_ScriptDir%\..\SharedLibrary\ArrayExtensions.ahk
; HasVal(haystack, needle) : int (index)
#include CheckHotkey.ahk
; class CheckHotkey
#include GuiTab.ahk
; class GuiTab
#include GuiFunctions.ahk
; OpenGui(a_title) : void
; ReplaceHotkey(a_hotkey) : string
#include ResolveProfile.ahk
; ResolveProfile(a_profile) : Creates GuiTabs[]
; CanResolveProfile(a_profile) : bool
; PrintCurrentProfilesToFile() : void
; ResolveLibrary(a_row) : string[][]
; ResolveProcess(a_row) : string[]
#include OnExit.ahk
; class HandleExit
#include ProcessData.ahk
; class ProcessData


profile = %1%

; Check if Setting are existing
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

; --------- Globals ---------
Global Columns :=["Description","Process","OnStart","OnExit","Confirm","Hotkey"]

Global GuiTabs := Object() ; Array with GuiTabs

Global profileArray := Object() ; Array contains already resolved profiles -> purpose is to prevent endless loop

Global CheckForHotkeys := new CheckHotkey()

Global ExitHandler := new HandleExit() 
; --------- Globals ---------

ResolveProfile(profile)

LogToTray("AHK StartProcess", "Settings loaded", "info")

OpenGuiHotkey = %2%

if (OpenGuiHotkey = "")
    OpenGuiHotkey := "#w"

SplitPath, profile, , , , ProfileNameWithoutExtension

Hotkey(OpenGuiHotkey , "OpenGui", ProfileNameWithoutExtension)    

logStartParameters = profile : %profile%, OpenGuiHotkey : %OpenGuiHotkey%

LogToFile("StartParameters",logStartParameters , "info")

PrintCurrentProfilesToFile()

CheckForHotkeys.Dispose()

OnExit, ExitLabel

return

#include %A_ScriptDir%\ProcessGui.ahk
; InfoGui()
#Include GuiEditProcess.ahk
; EditProcess(a_processData) 

ExitLabel:
    ExitHandler.ExitingScript()
    exitapp
return

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
	
        if A_IsCompiled{

		    msg := % "An exception was thrown!`nSpecifically: " . e.message

        } else {

		    msg := % "An exception was thrown!`nSpecifically: " . e.line . " - " . e.message
        }
		
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
