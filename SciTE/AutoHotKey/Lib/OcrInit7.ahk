#SingleInstance Force
#Include <RapidOcr7\RapidOcr2>

global ocr := RapidOCR()

OCRRand(x1, y1, x2, y2)
{
    global ocr
    ; 规范化坐标
    if (x1 > x2)
    {
        temp := x1
        x1 := x2
        x2 := temp
    }
    if (y1 > y2)
    {
        temp := y1
        y1 := y2
        y2 := temp
    }

    width := x2 - x1
    height := y2 - y1

    if (width <= 0 || height <= 0)
    {
        MsgBox("Invalid coordinates")
        return ""
    }
    try
    {
        return ocr.OCR(x1, y1, x2, y2)
    }
    catch as e
    {
        MsgBox "识别错误：" e.Message
        return ""
    }
}
/* main()
{
    Text := OCRRand(50, 50, 500, 500)
    MsgBox "识别结果：" Text
}
main() */