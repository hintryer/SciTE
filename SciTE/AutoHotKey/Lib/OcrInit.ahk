#SingleInstance Force
#Include <RapidOcr\RapidOcr>

global ocr := RapidOcr()
global ocrParam := RapidOcr.OcrParam({ doAngle: false })

CropScreen(x1, y1, x2, y2)
{
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

    ; 获取屏幕 DC
    screenDc := DllCall("GetDC", "ptr", 0)
    srcDc := DllCall("CreateCompatibleDC", "ptr", screenDc)

    ; 创建兼容位图
    srcBmp := DllCall("CreateCompatibleBitmap", "ptr", screenDc, "int", width, "int", height)
    DllCall("SelectObject", "ptr", srcDc, "ptr", srcBmp)

    ; 复制屏幕内容
    DllCall("BitBlt", "ptr", srcDc, "int", 0, "int", 0, "int", width, "int", height, "ptr", screenDc, "int", x1, "int",
        y1, "uint", 0x00CC0020)

    ; 创建 DIB Section
    bmpInfo := Buffer(40, 0)
    NumPut("uint", bmpInfo.Size, "int", width, "int", height, "short", 1, "short", 32, bmpInfo)
    hMemDc := DllCall("CreateCompatibleDC", "ptr", srcDc)
    hBmp := DllCall("CreateDIBSection", "ptr", hMemDc, "ptr", bmpInfo, "uint", 0, "ptr*", &pData := 0, "ptr", 0, "uint",
        0)
    DllCall("SelectObject", "ptr", hMemDc, "ptr", hBmp)

    ; 复制位图
    DllCall("BitBlt", "ptr", hMemDc, "int", 0, "int", 0, "int", width, "int", height, "ptr", srcDc, "int", 0, "int", 0,
        "uint", 0x00CC0020)

    ; 获取 BitmapData
    bitmap := Buffer(32, 0)
    DllCall("GetObjectW", "ptr", hBmp, "int", bitmap.Size, "ptr", bitmap)
    pData := NumGet(bitmap, 24, "ptr")
    stride := NumGet(bitmap, 12, "uint")
    pixelBytes := NumGet(bitmap, 18, "ushort")

    ; 创建 BitmapData Buffer
    bitmapData := Buffer(24 + stride * height)
    loop height
        DllCall("RtlCopyMemory", "ptr", bitmapData.Ptr + (A_Index - 1) * stride + 24, "ptr", pData + (height - A_Index) *
        stride, "uptr", stride)

    NumPut("ptr", bitmapData.Ptr + 24, "uint", stride, "int", width, "int", height, "int", 4, bitmapData)

    ; 创建结果对象
    res := {
        X: x1,
        Y: y1,
        Width: width,
        Height: height,
        HBitmap: { Ptr: hBmp, __Delete: (this) => DllCall("DeleteObject", "ptr", this) },
        BitmapData: bitmapData,
    }

    ; 清理资源
    DllCall("DeleteObject", "ptr", srcBmp)
    DllCall("DeleteDC", "ptr", srcDc)
    DllCall("DeleteDC", "ptr", hMemDc)
    DllCall("ReleaseDC", "ptr", 0, "ptr", screenDc)

    return res
}

OCRRand(x1, y1, x2, y2)
{
    global ocr, ocrParam
    try
    {
        if bmpData := CropScreen(x1, y1, x2, y2)
        {
            return ocr.ocr_from_bitmapdata(bmpData.BitmapData, ocrParam)
        }
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