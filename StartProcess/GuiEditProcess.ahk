; TODO Disable all hotkeys while is this dialog open
; when press ok -> check if there is the Hotkey already used

global CurrentProcessData
global OldProcessData
global RowIndex

EditProcess(a_processData, a_rowIndex){

    CurrentProcessData := a_processData

    OldProcessData := a_processData

    RowIndex := a_rowIndex

    Gui, 2:Destroy 

    gosub, CreateGui2
}


CreateGui2:

Gui 2:Add, Text, x23 y28 w73 h24 +0x200, Description :
Gui 2:Add, Edit, x150 y29 w512 h24 vdescription gChangeDescription, % CurrentProcessData.description

Gui 2:Add, Text, x23 y71 w73 h24 +0x200, Process :
Gui 2:Add, Edit, x150 y73 w512 h24 vprocessPath gChangeProcessPath, % CurrentProcessData.processPath

Gui 2:Add, CheckBox,% "vrunonstart gChangeStartEvent x23 y120 w95 h23 " . IsChecked(CurrentProcessData.startEvent), Run on Start
Gui 2:Add, CheckBox,% "vrunonexit gChangeEndEvent x150 y120 w95 h23 " . IsChecked(CurrentProcessData.exitEvent), Run on Exit
Gui 2:Add, CheckBox,% "vconfirm gChangeConfirm x272 y120 w95 h23 " . IsChecked(CurrentProcessData.confirm), Confirm


Gui 2:Add, Text, x23 y171 w73 h23 +0x200, Hotkey :

if !InStr(CurrentProcessData.rawHotkey,"#")
{
    Gui 2:Add, Hotkey, x150 y171 w512 h21 Limit1 vrawHotkey gChangeHotkey, % CurrentProcessData.rawHotkey
} else {
    Gui 2:Add, Text, x150 y171 w512 h21 +0x200, Hotkeys with Windows (#) are not supported. Please add/update them manually.
}

Gui 2:Add, Button, x474 y222 w80 h23 gSave, &OK
Gui 2:Add, Button, x578 y222 w80 h23 gClose2, &Close
Gui 2:Add, Button, x370 y222 w80 h23 gDeleteProcess, &Delete

Gui 2:Show, w680 h262, Window
Return

DeleteProcess:

    currentTab:= MyTabs[Tabnumber]

    MsgBox, % currentTab.Rows.MaxIndex()
    
    ; currentTab.DeleteProcess(OldProcessData)
     
    currentTab.RemoveProcessFromGuiTab(RowIndex)

    MsgBox, % currentTab.Rows.MaxIndex()

    ; gui, listview, ProcessTab%Tabnumber%

    ; LV_Delete(RowIndex)

    gosub, Close2
return

Close2:
    Gui, 2:Destroy
return

Save:
    currentTab:= MyTabs[Tabnumber]

    ; todo unsubscribe old hotkey
    
    currentTab.ExportToFile()


    Gui, 2:Destroy

    Gui, 1:Default

    gui, listview, ProcessTab%Tabnumber%

    LV_Modify(RowIndex, , CurrentProcessData.description,CurrentProcessData.processPath, BoolToString(CurrentProcessData.startEvent), BoolToString(CurrentProcessData.exitEvent), BoolToString(CurrentProcessData.confirm), CurrentProcessData.textHotkey)
    
return

ChangeHotkey:
    GuiControlGet, rawHotkey
    CurrentProcessData.SetHotkey(rawHotkey)
return

ChangeProcessPath:
    GuiControlGet, processPath
    CurrentProcessData.processPath := ProcessPath
return  

ChangeStartEvent:
    GuiControlGet, runonstart
    CurrentProcessData.startEvent := Runonstart
return

ChangeEndEvent:
    GuiControlGet, runonexit
    CurrentProcessData.exitEvent := Runonexit
return

ChangeConfirm:
    GuiControlGet, confirm
    CurrentProcessData.confirm := Confirm
return

ChangeDescription:
    GuiControlGet, description
    CurrentProcessData.description := Description
return

IsChecked(a_bool){
    if a_bool
        return "Checked"
}