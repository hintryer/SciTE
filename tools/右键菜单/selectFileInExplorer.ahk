; 脚本：OpenSciTEFolder_Alt.ahk
#NoEnv
#SingleInstance Force

; --- 核心代码 ---
SciTE_Class := "SciTEWindow"

; 获取 SciTE 窗口的标题
WinGetTitle, SciTE_Title, ahk_class %SciTE_Class%

; 检查是否找到窗口
if ErrorLevel
{
    MsgBox, 0x10, 错误, 未找到 SciTE 窗口！
    ExitApp
}

FullPath := RegExReplace(SciTE_Title, "\s-\sSciTE.*", "")
; 从完整路径中提取目录路径
SplitPath, FullPath, , OutDir

; 打开该目录
Run, %OutDir%

ExitApp

ExitApp