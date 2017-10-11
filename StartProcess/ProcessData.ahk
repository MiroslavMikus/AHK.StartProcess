class ProcessData{

    description :=""
    processPath :=""
    startEvent:=""
    exitEvent:=""
    confirm:=""
    rawHotkey:=""
    textHotkey:=""

    __New(a_des, a_process, a_start, a_exit, a_confirm, a_rawHotkey){
        this.description := a_des
        this.processPath := a_process
        this.startEvent := a_start
        this.exitEvent := a_exit
        this.confirm := a_confirm
        this.SetHotkey(a_rawHotkey)
    }

    SetHotkey(a_hotkey){
        this.rawHotkey := a_hotkey
        this.textHotkey := this.ReplaceHotkey(a_hotkey)
    }

    ; changes '!#t' to 'Alt + Win + t'
    ReplaceHotkey(a_hotkey){ 

        result := ""

        loop, Parse, a_hotkey
        {
            char = %A_LoopField%

            if (char = "^")
                result .= "Ctrl + "
            else if (char = "!")
                result .= "Alt + "
            else if (char = "+")
                result .= "Shift + "
            else if (char = "#")
                result .= "Win + "
            else 
                result .= char
        }

        return result
    }

    ExportToString(){
        return this.description . ";" . this.processPath . ";" . BoolToString(this.startEvent) . ";" . BoolToString(this.exitEvent) . ";" . BoolToString(this.confirm) . ";" . this.rawHotkey
    }

    Compare(a_processData){
        return (a_processData.description = this.description) && (a_processData.processPath = this processPath)
    }

    CompareString(a_dataString){
        Args := StrSplit(a_dataString,";")

        description := Args[1]

        processToRun := Args[2]
        
        return (description = this.description) && (processToRun = this.processPath) 
    }
}