; User should be aslo able to run scripts with double-click -> so in this case its not possible to use SharedLibrary\DynamicGui.ahk 

global GuiTitle := ""
global MyTabs :=""
global MyPosition :=""
global CurrentTab :=""
    
InfoGui(a_Title, a_Position, a_GuiTabs){

    GuiTitle := a_Title

    MyTabs := a_GuiTabs

    MyPosition := a_Position
    
    CalculateSizePosition()

    ; if is there already gui open - this will close it first (only in same thread)
    Gui, Destroy 
    
    gosub,CreateGui1
}


CreateGui1:
Hotkey, esc, Close1, on
global Tabnumber:=1

Gui, Add, Button, gClose1 x960 y560 w120 h30 , &Close Gui
; Gui, Add, Button, gCloseScript x825 y560 w120 h30 , Close Script
; Gui, Add, Button, gRestartScript x690 y560 w120 h30 , Restart Script

; Add Link
Gui, Add, Link, y566 x15 , Created by <a href="www.github.com/miroslavmikus">Miroslav Mikus</a> with <a href="www.autohotkey.com">Auto Hot Key</a>

allTabs := ""

; Create Tab names -> Tab1|Tab2...
Loop % MyTabs.MaxIndex(){

    allTabs := allTabs . "|" . MyTabs[A_Index].TabName
}

StringTrimLeft, allTabs, allTabs, 1

; Add Tabs
Gui, Add, Tab, gtabchange vTabnumber AltSubmit x0 y0 w1100 h450, % allTabs

; Add Menu
Menu, ScriptMenu, Add, &Restart, RestartScript
Menu, ScriptMenu, Add, &Shutdown, CloseScript
Menu, ScriptMenu, Add, &Close GUI, Close1
Menu, ScriptMenu, Add
Menu, ScriptMenu, Add, Open &Log, OpenLog
Menu, MyMenuBar, Add, &Script, :ScriptMenu


Menu, ProfileMenu, Add, Open current profile in notepad, OpenProfile
Menu, ProfileMenu, Add, Create new profile, CreateProfile
Menu, MyMenuBar, Add, &Profile, :ProfileMenu

Menu, LibraryMenu, Add, Open Library in notepad, OpenLibrary
Menu, ScriptMenu, Add
Menu, LibraryMenu, Add, Add new Process, OpenLibrary
Menu, MyMenuBar, Add, &Library, :LibraryMenu

Gui, Menu, MyMenuBar

; Fill Tabs with list view and its content
Loop % MyTabs.MaxIndex(){

    Header := CreateHeader(MyTabs[A_Index].Columns)

    Gui, Tab, % A_Index

    ListSettings := "-Multi  x0 y20 w1100 h530 gListViewEvents vProcessTab" . A_Index

    Gui, Add, ListView, % ListSettings, % Header

    AddRow(MyTabs[A_Index].Rows)

    ; Set column width based on content - for all columns
    LV_ModifyCol() 
    ; Set fix column width
    LV_ModifyCol(3, 60)
    LV_ModifyCol(4, 60)
    LV_ModifyCol(5, 60)
}

gui, show, % MyPosition, % GuiTitle
gosub,tabchange

RETURN
;--------------------------------------- Buttons
Close1:
    Hotkey, esc, Close1 ,delete
    Gui, Destroy
return

CloseScript:
    exitapp
return

RestartScript:
    Run, %A_ScriptFullPath% %profile% %OpenGuiHotkey%
return

OpenLibrary:
    MyTabs[Tabnumber].OpenLibrary()
return

OpenProfile:
    path := "notepad " . profile 

    description := "Open profile path: " . profile 

    RunProcess(false, path, description)
return

OpenLog:
    path := "notepad ahkLog.txt"

    description := "Open log: ahkLog.txt"

    RunProcess(false, path, description)
return

CreateProfile:
    FileSelectFile, SelectedFile, S8, %A_ScriptDir%, Create new profile, Text Documents (*.txt; *.csv)

    if SelectedFile =
        MsgBox, The user didn't select anything.
    else
        MsgBox, The user selected the following:`n%SelectedFile%

return
;---------------------------------------
tabchange:
    GuiControlGet, Tabnumber
Return
;---------------------------------------

ListViewEvents:
    if A_GuiEvent = DoubleClick
    {
        gui, listview, ProcessTab%Tabnumber%

        LV_GetText(Description, A_EventInfo, 1)

        LV_GetText(ProcessToRun, A_EventInfo, 2)

        LV_GetText(NeedConfirm, A_EventInfo, 4)

        RunProcess(StringToBool(NeedConfirm), ProcessToRun, Description)
    }
    ; double right click
    if A_GuiEvent = R
    {
        gui, listview, ProcessTab%Tabnumber%       

        currentTab:= MyTabs[Tabnumber].Rows

        LV_GetText(Description, A_EventInfo, 1)

        LV_GetText(ProcessToRun, A_EventInfo, 2)

        for index, element in currentTab
        {
            if (element.description = Description) && (element.processPath = ProcessToRun)
                EditProcess(element, index)
        }
    }
RETURN

CalculateSizePosition(){
    Size := "w1100 h600"
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

AddRow(a_rows){
    Loop % a_rows.MaxIndex()
        LV_Add("" , a_rows[A_Index].description , a_rows[A_Index].processPath, BoolToString(a_rows[A_Index].startEvent), BoolToString(a_rows[A_Index].exitEvent), BoolToString(a_rows[A_Index].confirm), a_rows[A_Index].textHotkey)
}