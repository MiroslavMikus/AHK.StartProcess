class HandleExit{

    runOnExit := Object()

    AddProcess(a_process){
        this.runOnExit.Insert(a_process)
    }

    ExitingScript(){

        Loop % this.runOnExit.MaxIndex()
        {

            description := this.runOnExit[A_Index][1]

            processToRun := this.runOnExit[A_Index][2]

            confirm := StringToBool(this.runOnExit[A_Index][5])

            RunProcess(confirm , processToRun, description)
        }
    }
}