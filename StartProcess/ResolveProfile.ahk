ResolveProfile(a_profile){

    if not CanResolveProfile(a_profile)
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

        MyTab := new GuiTab(ProfileNameWithoutExtension, Columns,ResolveLibrary(A_LoopReadLine), A_LoopReadLine)

        GuiTabs.Insert(MyTab)
    }
}

CanResolveProfile(a_profile){
    
    if not Exist(a_profile)
        return false

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

ResolveLibrary(a_row){
    
    MyRows := Object()

    Loop, read, % a_row
    {
        MyRows.Insert(ResolveProcess(A_LoopReadLine))
    }

    return MyRows
}

ResolveProcess(a_row){
    Args := StrSplit(a_row,";")

    description := Args[1]

    processToRun := Args[2]

    runOnStart := StringToBool(Args[3])

    runOnExit := StringToBool(Args[4])

    confirm := StringToBool(Args[5])

    currentHotkey := Args[6]

    data := new ProcessData(description,processToRun,runOnStart,runOnExit,confirm,currentHotkey)

    if runOnStart
        RunProcess(confirm , processToRun, description)
    
    if runOnExit{
        ExitHandler.AddProcess(Args)
    }

    if (not currentHotkey ="")
        try{

            if CheckForHotkeys.CanAddHotkey(currentHotkey, processToRun){

                ; HotkeyManager.AddHotkey(currentHotkey , "RunProcess" , confirm , processToRun, description)
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

            if A_IsCompiled{
                msg := % "An exception was thrown! Specifically: " . e.message
            } else {
                msg := % "An exception was thrown!Specifically: " . e.line . " - " . e.message
            }


            LogToMsg("Error"," Cant create hotkey for : " . a_row, "error")

            LogToFile("Error"," Cant create hotkey for : " . a_row . ". " . msg, "error")
        }

    return data
}