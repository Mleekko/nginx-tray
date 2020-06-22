
#include <TrayConstants.au3>
#include <StringConstants.au3>
#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>

Opt("TrayMenuMode", 3)
Opt("TrayOnEventMode", 1)


Const $Title = "Nginx Tray"

Global $nginxPID = ProcessExists("nginx.exe")

Global $idStart = 0
Global $idRestart = 0
Global $idStop = 0
Global $idReload = 0
Global $idSeparator = 0
Global $idExit = 0


Func StarServer()
   TraySetIcon("icon-green.ico")
   TrayTip($Title, "Nginx Server is starting...", 3)
   $nginxPID = Run('nginx.exe', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
   UpdateTray()
EndFunc

Func DoStopServer()
   RunWait('nginx.exe -s stop', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
   $nginxPID = ProcessExists("nginx.exe")
   If $nginxPID <> 0 Then
	  ProcessClose($nginxPID)
	  $nginxPID = 0
   EndIf
EndFunc

Func StopServer()
   TraySetIcon("icon-red.ico")
   TrayTip($Title, "Nginx Server is stopping...", 3)
   DoStopServer()
   UpdateTray()
EndFunc

Func RestartServer()
   TrayTip($Title, "Restarting Nginx...", 3)
   DoStopServer()
   $nginxPID = Run('nginx.exe', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
   UpdateTray()
EndFunc

Func ToggleServer()
   If $nginxPID = 0 Then
	  StarServer()
   Else
	  StopServer()
   EndIf
EndFunc

Func ReloadConfig()
   TrayTip($Title, "Reloading Nginx config...", 3, $TIP_NOSOUND)
   RunWait('nginx.exe -s reload', @ScriptDir, @SW_HIDE, $STDOUT_CHILD)
EndFunc

Func Noop()
EndFunc

Func ExitApp()
   If $nginxPID <> 0 Then
	  StopServer()
   EndIf
   Sleep(3000)
   Exit
EndFunc

Func UpdateTray()
   TrayItemDelete($idStart)
   TrayItemDelete($idRestart)
   TrayItemDelete($idStop)
   TrayItemDelete($idReload)
   TrayItemDelete($idSeparator)
   TrayItemDelete($idExit)
   InitTrayItems()
EndFunc

Func InitTrayItems()
   Local $isRunning = ($nginxPID <> 0)

   $idStart = TrayCreateItem("Start Server")
   TrayItemSetOnEvent($idStart, "StarServer")
   If $isRunning Then
	  TrayItemSetState ( $idStart, $TRAY_DISABLE )
   EndIf

   If $isRunning Then
	  $idRestart = TrayCreateItem("Restart Server")
	  TrayItemSetOnEvent($idRestart, "RestartServer")
   EndIf

   $idStop = TrayCreateItem("Stop Server")
   TrayItemSetOnEvent($idStop, "StopServer")
   If Not $isRunning Then
	  TrayItemSetState ( $idStop, $TRAY_DISABLE )
   EndIf

   If $isRunning Then
	  $idReload = TrayCreateItem("Reload Config")
	  TrayItemSetOnEvent($idReload, "ReloadConfig")
   EndIf

   $idSeparator = TrayCreateItem("")

   $idExit = TrayCreateItem("Exit")
   TrayItemSetOnEvent($idExit, "ExitApp")

   TraySetClick ( 16 ) ; Open menu on releasing RMB
   TraySetOnEvent($TRAY_EVENT_PRIMARYDOUBLE, "ToggleServer")

   If $isRunning Then
	  TraySetIcon("icon-green.ico")
   Else
	  TraySetIcon("icon-red.ico")
   EndIf

   TraySetState($TRAY_ICONSTATE_SHOW) ; Show the tray menu.
EndFunc


Func Init()
   InitTrayItems()
   If $nginxPID = 0 Then
	  StarServer()
   EndIf
EndFunc


Init()



While 1
   Sleep(5000)
   $nginxPID = ProcessExists("nginx.exe")
WEnd
