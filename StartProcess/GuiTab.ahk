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

            }else{

                FileAppend, % A_LoopReadLine, %TempFile%
            }
            Fileappend, `n, %TempFile%
        }

        FileCopy, % TempFile , % this.LibraryPath, 1
        FileDelete, % TempFile
    }
}