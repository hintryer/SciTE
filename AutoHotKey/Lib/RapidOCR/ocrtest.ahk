
; ocr a screenshot
; 根据坐标截屏并识别

#Include RapidOCR\RapidOCR2.ahk
inst := RapidOCR()

OCR(Box) {
	return inst.OCR([Box[1],Box[2],Box[3]-Box[1],Box[4]-Box[2]])
}
; ocr the clipboard
; 识别剪贴板
MsgBox % inst.ocr(ClipboardAll)
; 根据坐标截屏并识别
MsgBox OCR([78,267,957,328])
; 识别本地图片（支持 bmp, dib, rle, jpg, jpeg, jpe, jfif, gif, tif, tiff, png ）
MsgBox  inst.ocr("test\zh_hans.jpg")
; 识别所有显示器内容
MsgBox  inst.ocr(0)
; by title
; 根据窗口标题识别一个程序界面（这里用的是画图窗口）
if (A_Language = 0804)
  MsgBox % inst.ocr("无标题 - 画图")
else
  MsgBox % inst.ocr("Untitled - Paint")

; by ahk_class
; 根据窗口类名识别
MsgBox % inst.ocr("ahk_class MSPaintApp")

; by ahk_id
; 根据窗口句柄识别
; MsgBox % inst.ocr("ahk_id 0x123abc")

; by ahk_exe
; 根据进程名识别
MsgBox % inst.ocr("ahk_exe mspaint.exe")

; by ahk_pid
; 根据进程 PID 识别
; MsgBox % inst.ocr("ahk_pid 1234")
