#Requires AutoHotkey v2.0
#Include <print>
#Include "%A_LineFile%\..\Lib2\ImagePut.ahk"
#Include "%A_LineFile%\..\Lib2\NonNull.ahk"
#Include "%A_LineFile%\..\Lib2\cJson.ahk"

/*
author:    telppa（空）
version:   2025.09.08
*/
class RapidOCR
{
    ; v2 类构造函数，无需 return this（自动返回实例）
    __New(Configs := "")
    {
        ; 简中、繁中、英、日、韩共5种文字的默认对应模型文件
        models := Map()  ; v2 用 Map 替代 v1 关联数组

        ; v2 Map 赋值语法：Set(键, 值)
        models.Set("zh_hans", Map(
        "cls", "ch_ppocr_mobile_v2.0_cls_infer.onnx",
        "det", "ch_PP-OCRv4_det_infer.onnx",
        "rec", "ch_PP-OCRv4_rec_infer.onnx",
        "keys", "dict_chinese.txt"
        ))

        models.Set("zh_hant", Map(
        "cls", "ch_ppocr_mobile_v2.0_cls_infer.onnx",
        "det", "ch_PP-OCRv4_det_infer.onnx",
        "rec", "chinese_cht_PP-OCRv3_rec_infer.onnx",
        "keys", "dict_chinese_cht.txt"
        ))

        models.Set("en", Map(
        "cls", "ch_ppocr_mobile_v2.0_cls_infer.onnx",
        "det", "en_PP-OCRv3_det_infer.onnx",
        "rec", "en_PP-OCRv4_rec_infer.onnx",
        "keys", "dict_en.txt"
        ))

        models.Set("ja", Map(
        "cls", "ch_ppocr_mobile_v2.0_cls_infer.onnx",
        "det", "Multilingual_PP-OCRv3_det_infer.onnx",
        "rec", "japan_PP-OCRv4_rec_infer.onnx",
        "keys", "dict_japan.txt"
        ))

        models.Set("ko", Map(
        "cls", "ch_ppocr_mobile_v2.0_cls_infer.onnx",
        "det", "Multilingual_PP-OCRv3_det_infer.onnx",
        "rec", "korean_PP-OCRv4_rec_infer.onnx",
        "keys", "dict_korean.txt"
        ))

        ; v2 读取对象属性：优先用 . 访问，兼容 Configs 为 Map/对象
        model := NonNull_Ret(IsObject(Configs) ? Configs.model : "", "zh_hans")
        get_all_info := NonNull_Ret(IsObject(Configs) ? Configs.get_all_info : "", 0)
        visualize := NonNull_Ret(IsObject(Configs) ? Configs.visualize : "", 0)

        ; 可通过下面4个参数覆盖5种文字的默认对应模型文件
        cls := NonNull_Ret(IsObject(Configs) ? Configs.cls : "", models.Get(model).Get("cls"))
        det := NonNull_Ret(IsObject(Configs) ? Configs.det : "", models.Get(model).Get("det"))
        rec := NonNull_Ret(IsObject(Configs) ? Configs.rec : "", models.Get(model).Get("rec"))
        keys := NonNull_Ret(IsObject(Configs) ? Configs.keys : "", models.Get(model).Get("keys"))

        num_threads := NonNull_Ret(IsObject(Configs) ? Configs.num_threads : "", 4, 1, 16)
        padding := NonNull_Ret(IsObject(Configs) ? Configs.padding : "", 50)
        max_side_len := NonNull_Ret(IsObject(Configs) ? Configs.max_side_len : "", 1024)
        box_thresh := NonNull_Ret(IsObject(Configs) ? Configs.box_thresh : "", 0.3, 0, 1)
        box_score_thresh := NonNull_Ret(IsObject(Configs) ? Configs.box_score_thresh : "", 0.5, 0, 1)
        unclip_ratio := NonNull_Ret(IsObject(Configs) ? Configs.unclip_ratio : "", 1.6)
        do_angle := NonNull_Ret(IsObject(Configs) ? Configs.do_angle : "", 1)
        most_angle := NonNull_Ret(IsObject(Configs) ? Configs.most_angle : "", 1)

        box_thresh :=Format("{:.1f}", box_thresh)
        unclip_ratio :=Format("{:.1f}", unclip_ratio)
        template := 'RapidOCR-json.exe --models="models" --ensureAscii=1'
        template := template . " --cls=" . Chr(34) . cls . Chr(34)
        template := template . " --det=" . Chr(34) . det . Chr(34)
        template := template . " --rec=" . Chr(34) . rec . Chr(34)
        template := template . " --keys=" . Chr(34) . keys . Chr(34)
        template := template . " --numThread=" . Chr(34) . num_threads . Chr(34)
        template := template . " --padding=" . Chr(34) . padding . Chr(34)
        template := template . " --maxSideLen=" . Chr(34) . max_side_len . Chr(34)
        template := template . " --boxThresh=" . Chr(34) . box_thresh . Chr(34)
        template := template . " --boxScoreThresh=" . Chr(34) . box_score_thresh . Chr(34)
        template := template . " --unClipRatio=" . Chr(34) . unclip_ratio . Chr(34)
        template := template . " --doAngle=" . Chr(34) . do_angle . Chr(34)
        template := template . " --mostAngle=" . Chr(34) . most_angle . Chr(34)

        FileAppend(template . "`n", "命令行模板测试结果2.txt")

        ; 设置工作目录，否则无法启动 RapidOCR-json.exe
        ; v2 路径拼接优化：用 PathJoin 更可靠（或手动拼接，注意转义）
        exe_dir := A_LineFile "\..\exe"
        ; 标准化路径，避免相对路径歧义
        exe_dir := StrReplace(exe_dir, "/", "\")
        prev_workingdir := A_WorkingDir

        SetWorkingDir(exe_dir)  ; v2 函数调用格式，移除 %
        ; 检查4个模型文件是否存在，不存在则无法启动
        if (!FileExist("models\" . cls))
        {
            MsgBox("cls model " . Chr(34) . cls . Chr(34) . " not found.", "错误", 0x40010)
            ExitApp()
        }
        if (!FileExist("models\" . det))
        {
            MsgBox("det model " . Chr(34) . det . Chr(34) . " not found.", "错误", 0x40010)
            ExitApp()
        }
        if (!FileExist("models\" . rec))
        {
            MsgBox("rec model " . Chr(34) . rec . Chr(34) . " not found.", "错误", 0x40010)
            ExitApp()
        }
        if (!FileExist("models\" . keys))
        {
            MsgBox("keys model " . Chr(34) . keys . Chr(34) . " not found.", "错误", 0x40010)
            ExitApp()
        }
        ; debug 用
        ; Run("cmd.exe /k " template)

        ; 隐藏控制台
        ; https://www.reddit.com/r/AutoHotkey/comments/phhkcq/yet_another_how_do_i_sendreceive_from_cmd_window/
        Run(A_ComSpec, , "Hide", &cmdPid)  ; v2 Run 函数，传参格式调整
        DetectHiddenWindows(true)  ; v2 布尔值用 true/false
        WinWait("ahk_pid" cmdPid)
        DllCall("AttachConsole", "UInt", cmdPid)
        ProcessClose(cmdPid)  ; v2 ProcessClose 函数，移除 %

        ; 启动 RapidOCR-json.exe
        ; https://learn.microsoft.com/en-us/previous-versions/windows/internet-explorer/ie-developer/windows-scripting/ateytk4a(v=vs.84)
        shell := ""
        shell := ComObject("WScript.Shell")
        exec := shell.Exec(template)
        DllCall("FreeConsole")
        SetWorkingDir(prev_workingdir)  ; 还原工作目录

        ; 等待程序运行
        while (exec.Status)
        {
            Sleep(100)

            ; 启动超过10秒则报错
            if (A_Index >= 100)
            {
                MsgBox("Failed to run " . Chr(34) . "RapidOCR-json.exe" . Chr(34) . ".", "错误", 0x40010)
                ExitApp()
            }
        }
        ; 跳过第一行 读取第二行
        exec.StdOut.ReadLine()
        line := exec.StdOut.ReadLine()
        if (line = "OCR init completed.")
        {
            ; v2 类成员赋值：直接用 this.xxx
            this.get_all_info := get_all_info
            this.visualize := visualize
            this.exec := exec
            ; v2 构造函数无需手动 return this
        }
        else
        {
            MsgBox("Failed to init RapidOCR.`n`nError:" line, "错误", 0x40010)
            ExitApp()
        }
    }
    ; v2 类析构函数
    __Delete()
    {
        try this.exec.Terminate()
    }
    ocr(image)
    {
        try
        {
            ; 不能在此预先缩放图像，否则返回坐标时会与用户传入的原图对不上
            ; v2 对象创建：用 Map 替代 v1 关联数组
            obj := Map("image_base64", ImagePutBase64(image, "png"))
            this.exec.StdIn.WriteLine(json.dump(obj))

            ; 这里会耗时 200 ms 左右
            ret := json.load(this.exec.StdOut.ReadLine())

            if (ret.Get("code") == 100 || ret.Get("code") == 101)
            {
                ; 里面有3组数据，分别为 box score text
                if (this.get_all_info)
                    return ret.data
                else
                {
                    text := ""  ; v2 需先声明变量
                    ; v2 for 循环语法：for 键, 值 in 集合
                    for Key, Value in ret.Get("data")
                    {
                        text .= Value.Get("text") "`n"
                    }
                    return text
                }
            }
            else
                throw ValueError("RapidOCR 执行失败：" )
        }
    }
}

