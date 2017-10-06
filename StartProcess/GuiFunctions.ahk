OpenGui(a_title){
    GuiTitle := "Profile : " . a_title
    InfoGui(GuiTitle,"", GuiTabs)
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