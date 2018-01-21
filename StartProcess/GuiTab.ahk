; this class holds data which will be used in GUI
class GuiTab{
    TabName :=""
    Columns :=""
    Rows :=""
    LibraryPath := ""

    __New(a_name, a_columns, a_rows, a_libraryPath){
        this.TabName := a_name
        this.Columns := a_columns
        this.Rows := a_rows
        this.LibraryPath := a_libraryPath
    }

    OpenLibrary(){

        path := "notepad " . this.LibraryPath 

        description := "Open library path: " . this.LibraryPath 

        RunProcess(false, path, description)
    }

    SwapProcess(a_oldProcess, a_newProcess){
      
        TempFile := % A_WorkingDir . "\temp.txt"

        Loop, read, % this.LibraryPath
        {
            if a_oldProcess.CompareString(A_LoopReadLine){

                FileAppend, % a_newProcess.ExportToString() , %TempFile%

            } else {
                FileAppend, % A_LoopReadLine, %TempFile%
            }
            Fileappend, `n, %TempFile%
        }

        FileCopy, % TempFile , % this.LibraryPath, 1

        FileDelete, % TempFile

        ; update also reference in Hotkey.ahk !
    }

    DeleteProcess(a_process){

        TempFile := % A_WorkingDir . "\temp.txt"

        Loop, read, % this.LibraryPath
        {
            if a_process.CompareString(A_LoopReadLine){

            } else {
                FileAppend, % A_LoopReadLine, %TempFile%
                Fileappend, `n, %TempFile%
            }
        }

        FileCopy, % TempFile , % this.LibraryPath, 1

        FileDelete, % TempFile

        loop % this.Rows.MaxIndex() {

            if this.Rows[A_Index].Compare(a_process)
                this.Rows.Remove(A_Index)
        }

        ; Remove also reference in Hotkey.ahk !
    }

    AddProcess(a_process){
        Rows.Insert(a_process)

        Fileappend, % "`n" . a_process.ExportToString(), % this.LibraryPath

        ; Hotkey(a_process.rawHotkey, "RunProcess", a_process.confirm, a_process.processPath, a_process.description)
    }
}