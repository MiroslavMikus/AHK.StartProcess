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
    Dispose(){
        this.hotkeys := ""
        this.processes := ""
    }
}