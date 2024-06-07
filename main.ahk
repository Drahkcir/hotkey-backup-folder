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
global INI_FILENAME := ".\config.ini"

global Application_Name
global BackupSaveFolder
global SaveFolder
global LastSave

/*
  ======================================Initialization===================================================
*/

ReadIni(){
  
  ; path where the saves will be kept (default will be the ./Saves where the script is located )
  backup_folder := IniRead(INI_FILENAME, "Default", "save_directory" , "") 
  if not backup_folder{
    backup_folder := Format("{1}\{2}", A_ScriptDir , "Saves\")
  }

  save_folder := IniRead(INI_FILENAME, "Default", "save_folder_full_path", "")
  if not save_folder {  
    MsgBox("save_folder_full_path is not set in the ini file" "`n" "unable to locate the folder to save")*
    ExitApp(-1)
  }

  ;global variable will be updated
  global Application_Name := application_name
  global BackupSaveFolder := backup_folder
  global SaveFolder := save_folder
  global LastSave := Format("{1}\LastSave", BackupSaveFolder)

  ;feedbock initialisationr to check that everything is right
  ToolTipMsg( Format("BackupSaveFolder : {1}`n`nSaveFolder : {2}", BackupSaveFolder, SaveFolder), 0, 0, 5000)
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
  }
  return True 
}

/*
  handling of the case where the dir don't exist and avoid a exception being thrown
*/
DeleteDir(dirPath){
  if  InStr( FileExist(dirPath), "D"){
    DirDelete(dirPath,1)
    sleep(1000)
  }else{
    ToolTipMsg(format("The following directory did not exist no deletion was performed : `n{1}",dirPath),0,0,5000)
    sleep 5000
  }
}

/*
  perform a backup of the gamesaves folder
*/ 

  ; creating the folder name for dated backup
  DatedSave := Format("{1}Save_{2}", BackupSaveFolder, A_NOW)

  DeleteDir(LastSave)
  
  ; create the dated copy and the lastsave folder  (nice to have backup) and need to override.
  DirCopy(SaveFolder, LastSave,0)
  DirCopy(SaveFolder,DatedSave,0)
    
  ToolTipMsg( Format("Save performed : {}", DatedSave) , 0, 0, 5000)
}

/*
  perform a restore of the save_folder from the last save that was done
*/
ImportLastSave(){

  ; remove the save currently used
  DeleteDir(SaveFolder)

  ; recreating from the backup de files to the saves game folder
  DirCopy(LastSave,SaveFolder,1)

  ToolTipMsg( Format("restore performed.") , 0, 0, 5000)
}

/*
  Perform a restore of the save_folder from the selected save that the user selected
*/
ImportSaveDir(){
    
  ; ask the player which folder to restore
  selectedBackup := DirSelect(BackupSaveFolder)
  if selectedBackup {
    DeleteDir(SaveFolder)
    ; recreating from the backup de files to the saves game folder
    DirCopy(selectedBackup,SaveFolder,1)
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

;F6 to Reload the script.
F6::{
    Reload
    Return
}

;F4 to exit the AutoHotkey script. 
F4::{
    ExitApp
}