> Note : To clone also all submodules use :
> _git clone **--recursive** https://github.com/MiroslavMikus/AHK.StartProcess.git_

## Introduction:

This is my very old AHK experiment. I wanted to create some lightweight app where I can manage my most used Macros / Scripts and Processes.
Follower of this small app will be (hopefully soon released) [Macro Manager](https://github.com/MiroslavMikus/MacroManager)

## Initial Setup

Setup consist of **Profiles** and **Libraries**. 

### Profiles

One profile is simple text file which contains Paths to **Libraries**. 

Example:

```
data\PowerShell.csv
data\Numpad.csv
```
> Note: Path starts from folder where is script executed.

Default profile is *Settings.csv*. But you can also pass your own by command parameter like:

```
Main.ahk "CustomProfile.ahk"
```

> Note: Profile name cant contain spaces like "Custom Profile.ahk"

###  Libraries

Is simple CSV file with *;* separator. This file contains:
 - Processes
   - Text field
   - Contain process with parameters
   - Quoted if necessary
 - Description
   - Text field
   - Field to remember what should this process or script do
 - Run on Start
   - Boolean
   - Indicates if this script should be run on start of *StartProcess* app
 - Confirm run
   - Boolean
   - Throws message box if is this process invoked. Prevent run by accident.
 - Hotkey definition 
   - Text field
   - Definitions for Hotkey triggers in [AHK](https://www.autohotkey.com/docs/commands/Send.htm) format
   - Example:

| Keyboard combination | AHK Definition |
|----------------------|----------------|
| Shift                | +              |
| Alt                  | !              |
| Ctrl                 | ^              |
| Win                  | #              |
| F1-F12               | F1-F12         |
| Numpad0-9            | Numapd0-9      |

Therefore:

| Keyboard combination | AHK Definition |
|----------------------|----------------|
| Ctrl + Shift + G     | ^+G            |
| Alt +F5              | !F5            |
| Ctrl+Alt+O           | ^!O            |
| Win + Numpad 0       | #Numpad0       |
| Win + Alt + F5       | #!F5           |

#### So and then Example for one Library will be:

| Description       | Process                     | Run on start | Confirm | Hotkey   |
|-------------------|-----------------------------|--------------|---------|----------|
| Settings          | notepad {#}\data\Numpad.csv | false        | false   | !K       |
| Open CMD          | CMD                         | false        | false   | ^Numpad1 |
| Open Powershell   | Powershell                  | false        | false   | ^Numpad2 |
| Open Google in IE | iexplore.exe www.google.com | false        | false   | ^Numpad3 |
| Open Task Manager | taskmgr                     | false        | false   | ^Numpad7 |
|                   |                             |              |         |          |

And the file looks like:
```
Settings;notepad {#}\data\Numpad.csv;false;false!K
Open CMD;CMD;false;false;^Numpad1
Open Powershell;Powershell;false;false;^Numpad2
Open Google in IE;iexplore.exe www.google.com;false;false;^Numpad3
Open Task Manager;taskmgr;false;false;^Numpad7
```

> Note: that placeholder **{#}** in Process column. All Processes are defined with absolut defined path (Or Path variable in system). To make this App portable and without changing the system Path variable I created **{#}** placeholder which will be replaced with the Path where the app is runnig. You have just to place your scripts and libraries to one soubfolder of folder where is this app placed.