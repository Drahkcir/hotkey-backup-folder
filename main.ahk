#Requires AutoHotkey v2.0
#SingleInstance Force

#WinActivateForce
SetTitleMatchMode 2
SetControlDelay 0
SetWinDelay -1
SetKeyDelay -1
SetMouseDelay -1

/*
  ======================================Constants Declaration===================================================
*/
global APPLICATION_NAME := "Ghost Recon® Wildlands"
global INI_FILENAME := ".\variable.ini"


global BackupSaveFolder
global LastSave


/*
  ======================================Initialization===================================================
*/

ReadIni(){
  
  ; path where the saves will be kept (default will be the ./Saves where the script is located )
  save_folder := IniRead(INI_FILENAME, "Default", "SaveDirectory" , "") 
  if not save_folder{
    save_folder := Format("{1}\{2}", A_ScriptDir , "Save\")
  }
  
  ; ubisoft id of the user (needed to get to the save games of right user)
  ubisoft_id := IniRead(INI_FILENAME, "Default", "Ubisoft_id")
  
  ; optionnal configuration options
  ubisoft_savegame_path := IniRead(INI_FILENAME, "Default", "Ubisoft_savegame_path","Ubisoft\Ubisoft Game Launcher\savegames\")
  ubisoft_path := IniRead(INI_FILENAME, "Default", "Ubisoft_path",Format("{1}\", EnvGet("ProgramFiles(x86)")))
  ubisoft_id := IniRead(INI_FILENAME, "Default", "Ubisoft_id")

  ;global variable will be updated
  global BackupSaveFolder := save_folder
  global GameSaveFolder := Format("{1}{2}{3}\1771\", ubisoft_path,ubisoft_savegame_path,ubisoft_id)
  global LastSave := Format("{1}\LastSave", BackupSaveFolder)

  ;feedbock initialisationr to check that everything is right
  ToolTipMsg( Format("BackupSaveFolder : {1}`n`nGameSaveFolder : {2}", BackupSaveFolder, GameSaveFolder), 0, 0, 5000)
}

ReadIni()


/*
  ======================================Function declarations===================================================
*/

ToolTipMsg(msg,x,y,duration){
  ToolTip( msg, x, y )
  SetTimer () => ToolTip(), -duration  
}


/*
  checking that the application is currently running.
*/
check_app_window(){
  if not WinExist(APPLICATION_NAME){
      ;MsgBox APPLICATION_NAME  " not running"      
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

  ; recreating from the backup de files to the saves game folder
  DirCopy(LastSave,GameSaveFolder,1)

  ToolTipMsg( Format("restore performed.") , 0, 0, 5000)
}

; Perform  a backup of the gamesaves folder from the selected save that the user selected
ImportSaveDir(){
    
  ; ask the player which folder to restore
  selectedBackup := DirSelect(BackupSaveFolder)
  if selectedBackup {
    DeleteDir(GameSaveFolder)
    ; recreating from the backup de files to the saves game folder
    DirCopy(selectedBackup,GameSaveFolder,1)
    ToolTipMsg(Format("restore of {1} performed.", selectedBackup) , 0, 0, 5000)
  }
  
}

/*
  ======================================Events Handling/Main execution===================================================
*/

Numpad8::{
  ; check the application is fonctionning to avoid doing save when the app is no longer running  
  result := check_app_window()
  SaveGhostMode()
  if not result {
    MsgBox( APPLICATION_NAME " is not running" "`n" "Save performed. Quitting the AutoHotKey script ")
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
F6::{
    Reload
    Return
}

;F4 to quit the AutoHotkey. 
F4::{
    ExitApp
}