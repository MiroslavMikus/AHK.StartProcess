; because i wann with double-click start selected process -> im not able to use dynamic gui from shared library... 

global GuiTitle := ""
global MyTabs :=""
global MyPosition :=""
    
InfoGui(a_Title, a_Position, a_GuiTabs){
    GuiTitle := a_Title
    MyTabs := a_GuiTabs
    MyPosition := a_Position
    CalculateSizePosition()
    Gui, Destroy 
    ; if is some GUI there - this will close it first (only in same thread)
    gosub,CreateGui
}


CreateGui:
Hotkey, esc, Close, on
Tabnumber:=1

; Create Tabs
Gui, Add, Button, gClose x510 y360 w120 h30 , &Close Gui
Gui, Add, Button, gCloseScript x375 y360 w120 h30 , Close Script
Gui, Add, Button, gRestartScript x240 y360 w120 h30 , Restart Script

; Add Link
Gui, Add, Link, y366 x15 , Created by <a href="www.github.com/miroslavmikus">Miroslav Mikus</a> with <a href="www.autohotkey.com">Auto Hot Key</a>

allTabs := ""
Loop % MyTabs.MaxIndex(){
    allTabs := allTabs . "|" . MyTabs[A_Index].TabName
}
StringTrimLeft, allTabs, allTabs, 1
Gui, Add, Tab, gtabchange vTabnumber AltSubmit x0 y0 w650 h350, % allTabs

; Fill Tabs with grid and content
Loop % MyTabs.MaxIndex(){
    Header := CreateHeader(MyTabs[A_Index].Columns)
    Gui, Tab, % A_Index
    ListSettings := "-Multi  x0 y20 w650 h330 gListViewEvents vProcessTab" . A_Index
    Gui, Add, ListView, % ListSettings, % Header
    AddRow(MyTabs[A_Index].Rows)
    LV_ModifyCol()    
}
gui, show, % MyPosition
gosub,tabchange
RETURN

Close:
GuiClose:
    Hotkey, esc, Close ,delete
    Gui, Destroy
return
CloseScript:
    exitapp
return
RestartScript:
    ; wrappedProfile = "" . %profile% . ""
    Run, %A_ScriptFullPath% %profile% ; todo wrap profile to ""
return
;-------------------------------------------------------------------------------------
tabchange:
GuiControlGet, Tabnumber
Return
;-------------------------------------------------------------------------------------

ListViewEvents:
if A_GuiEvent = DoubleClick
{
    gui, listview, ProcessTab%Tabnumber%
    LV_GetText(ProcessToRun, A_EventInfo, 2)
    LV_GetText(NeedConfirm, A_EventInfo, 4)
    RunProcess(StringToBool(NeedConfirm), ProcessToRun)
}
RETURN



CalculateSizePosition(){
    Size := "w650 h400"
    If MyPosition = ""
        MyPosition := Size
    else
        MyPosition := MyPosition . " " . Size
}


CreateHeader(a_array){      
    allTabs := ""
    Loop % a_array.MaxIndex()
        allTabs := allTabs . "|" . a_array[A_Index]
    StringTrimLeft, allTabs, allTabs, 1
    return allTabs
}

AddRow(a_rows){ ; take one array [["",""],["",""]]
    arrayLength := a_rows[1].MaxIndex()        
    if arrayLength = 1
        Loop % a_rows.MaxIndex()
            LV_Add("" , a_rows[A_Index][1])
    else if arrayLength = 2
        Loop % a_rows.MaxIndex()
            LV_Add("" , a_rows[A_Index][1] , a_rows[A_Index][2])
    else if arrayLength = 3
        Loop % a_rows.MaxIndex()
            LV_Add("" , a_rows[A_Index][1] , a_rows[A_Index][2] , a_rows[A_Index][3])
    else if arrayLength = 4
        Loop % a_rows.MaxIndex()
            LV_Add("" , a_rows[A_Index][1] , a_rows[A_Index][2], a_rows[A_Index][3], a_rows[A_Index][4])
    else if arrayLength = 5
        Loop % a_rows.MaxIndex()
            LV_Add("" , a_rows[A_Index][1] , a_rows[A_Index][2], a_rows[A_Index][3], a_rows[A_Index][4], a_rows[A_Index][5])
}

class GuiTab{
    TabName :=""
    Columns :=""
    Rows :=""

    __New(a_name, a_columns, a_rows){
        this.TabName := a_name
        this.Columns := a_columns
        this.Rows := a_rows
    }
}