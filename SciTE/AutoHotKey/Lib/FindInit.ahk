#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <FindText>
#Include <Print>

 /**
 * 封装FindText查找并点击函数
 * @param Text 待查找的文本特征串（必填）
 * @param offsetX X 轴偏移量（可选，默认 0）
 * @param offsetY Y 轴偏移量（可选，默认 0）
 * @param clickBtn 点击按钮（可选，默认 "L" 左键；可选 "R" 右键 /"M" 中键或者次数）
 * @param index 匹配项索引（第 1 个为 1，第 2 个为 2... 默认 1）
 * @returns 返回一个二级数组，;第一级是每个结果对象，第二级是结果对象的具体信息对象
 * 举例  FindTextClick(下拉选项,,,,,2) ：点击第二个下拉项
 * 举例  FindTextClick(输入框,100,0,3) ：点击输入框，X轴偏移100，三次点击
*/
FindTextClick(Text, offsetX:=0, offsetY:=0, clickBtn:="", clickType:="" , index:=1)
{
    if (ok:=FindText(&X:='wait', &Y:=-1, 0,0, 0, 0, 0.1, 0, Text))
    {
        if (ok.Length >= index)
        {
            ; 计算偏移后坐标（第N个匹配项的坐标 + 偏移量）
            clickX := ok[index].X + offsetX
            clickY := ok[index].Y + offsetY
            FindText().Click(clickX, clickY, clickBtn,clickType)
            Sleep 300
            return ok  ; 查找并点击成功
        }
    }
    return false  ; 未找到文本
}

; /* ; 点击第 1 个匹配项 */
; FindTextClick("下拉选项")

; /* ; 点击第 2 个匹配项 */
; FindTextClick("下拉选项", 0, 0, "", "", 2)

; /* ; 点击输入框并向右偏移 100 像素，左键单击 */
; FindTextClick("输入框", 100, 0)

; /* ; 点击输入框并三次左键点击 */
; FindTextClick("输入框", 0, 0, 3)

; 参数 path：文件完整路径
; 参数 removeBlank (可选)：为 true 则去除所有空白行（默认 true)
; 返回：行数组 / 读取失败返回 false
; 有非 ANSI / UTF-8 文件时，最好明确指定编码；默认按 ANSI 读取
; 举例：ReadTxtToArr("C:\path\to\file.txt") 读取文件并去除空白行
; filePath := A_Desktop "\input.txt" A_ScriptDir A_MyDocuments
;lines := ReadTxtToArr(filePath, true)
ReadTxtToArr(path, removeBlank := true)
{
    if !path
        return []

    try
    {
        content := FileRead(path)
    }
    catch
    {
        return false
    }

    if content = ""
        return []

    lines := []
    loop parse, content, "`n", "`r"
    {
        field := Trim(A_LoopField)
        if removeBlank
        {
            if Trim(field) = ""
                continue
        }
        lines.Push(field)
    }

    ; 若未请求去除空白行，保留原有行为：去掉末尾多余空行
    if (!removeBlank && lines.Length() && lines[lines.Length()] = "")
        lines.Pop()

    return lines
}

/* main()
{
    lineArr := ReadTxtToArr(A_Desktop "\123.txt")
    if (lineArr == false)
    {
        MsgBox "无法读取文件：" A_Desktop "\123.txt"
        return
    }
    for num, text in lineArr
    {
        ; 在这里写你的业务逻辑
        Sleep 200
    }
} */