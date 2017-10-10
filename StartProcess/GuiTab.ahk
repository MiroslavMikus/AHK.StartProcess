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
}