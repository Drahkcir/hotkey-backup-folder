#Requires AutoHotkey v2.0
#SingleInstance Force

#WinActivateForce
SetTitleMatchMode 2
SetControlDelay 0
SetWinDelay -1
SetKeyDelay -1
SetMouseDelay -1

/*
  ======================================Constants===================================================
*/

global APPLICATION_NAME := "Ghost Recon® Wildlands"

; the backups will be in a sub directory(named saves) of the location of the script
global BackupSaveFolder := Format("{1}\Saves\", A_ScriptDir)
global LastSave := Format("{1}LastSave", BackupSaveFolder)



/*
  ======================================Function declarations===================================================
*/



FindDirectories(){
  ; find the save game folder
  ; global GameSaveFolder := "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames\9a2dd866-f617-484b-a24c-19aa5c956280\1771\"
  global ubisoft_id := "9a2dd866-f617-484b-a24c-19aa5c956280" ;hardcoded for debuging purpose

  ;ubisoft folder
  global ubisoft_folder := Format("{1}Ubisoft\Ubisoft Game Launcher\savegames\",EnvGet("ProgramFiles(x86)")) ;
  
  Loop Files ubisoft_folder, "D" {
    Msgbox("A_LoopFileName : " A_LoopFileName)
  }

  global GameSaveFolder := Format("{1}\Ubisoft\Ubisoft Game Launcher\savegames\{2}\1771\",EnvGet("ProgramFiles(x86)"), ubisoft_id)

  ToolTip( Format("Saved performed : {1}`n`nGameSaveFolder : {2}", BackupSaveFolder,GameSaveFolder) , 0, 0)
  SetTimer () => ToolTip(), -5000

  ;FileExist
  global LastSave := Format("{1}LastSave", BackupSaveFolder)

}


ToolTipMsg(msg,x,y,duration){
  ToolTip( msg, x, y )
  SetTimer () => ToolTip(), -duration  
}


/*
  checking that the application is currently running.
*/
check_app_window(){
  if not WinExist(APPLICATION_NAME){
      MsgBox APPLICATION_NAME  " not running"      
      return False
  }
  WinActivate
  return True 
}

; handling of the case where the dir don't exist and avoid a exception being thrown
DeleteDir(dirPath){
  if  InStr( FileExist(dirPath), "D"){
    DirDelete(dirPath,1)
    sleep(1000)
  }else{
    ToolTipMsg(format("The following directory did not exist no deletion was performed : `n{1}",dirPath),0,0,5000)
    sleep 5000
  }
}


; perform a backup of the gamesaves folder
SaveGhostMode(){

  ; creating the folder name for dated backup
  DatedSave := Format("{1}Save_{2}", BackupSaveFolder, A_NOW)

  DeleteDir(LastSave)
  
  ; create the dated copy and the last save folder  (nice to have backup) and need to override.
  DirCopy(GameSaveFolder, LastSave,0)
  DirCopy(GameSaveFolder,DatedSave,0)
    
  ToolTipMsg( Format("Save performed : {}", DatedSave) , 0, 0, 5000)
  
}

; perform a backup of the gamesaves folder from the last save that was done
ImportLastSave(){

  ; remove the save currently used
  DeleteDir(GameSaveFolder)
  
  ; ask the player which folder to restore
  selectedBackup := DirSelect(BackupSaveFolder)

  ; recreating from the backup de files to the saves game folder
  DirCopy(LastSave,GameSaveFolder,1)

  ToolTipMsg( Format("restore performed.") , 0, 0, 5000)
}



; Perform  a backup of the gamesaves folder from the selected save that the user selected
ImportSaveDir(){
    
  DeleteDir(GameSaveFolder)

  ; ask the player which folder to restore
  selectedBackup := DirSelect(BackupSaveFolder)

  ; recreating from the backup de files to the saves game folder
  DirCopy(selectedBackup,GameSaveFolder,1)

  ToolTipMsg( Format("restore  of {1} performed.", selectedBackup) , 0, 0, 5000)

}

/*
  ======================================Events Handling/Main execution===================================================
*/
FindDirectories()


Numpad8::{
  ; check the application is fonctionning to avoid doing save when the app is no longer running  
  result := check_app_window()
  SaveGhostMode()
  if not result {
    MsgBox("Save performed. Quitting the AutoHotKey script as the application is not runinng.")
    ExitApp
  }
}

Numpad7::{
  ImportLastSave()
}

Numpad9::{
  ImportSaveDir()
}

;F5 to Reload the script.
F5::{
    Reload
    Return
}

;F4 to quit the AutoHotkey. 
F4::{
    ExitApp
}