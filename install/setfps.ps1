$directory = "./Preference.cfg" # 文件路径，没做错误处理，相信主包

# Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# 创建ui 获取输入内容
$form = New-Object System.Windows.Forms.Form
$form.Text = "请输入你的CS2最高帧率(如不锁帧输入0即可)"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.MinimizeBox = $false

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10, 20)
$label.Size = New-Object System.Drawing.Size(400, 20)
$label.Text = "请输入你的CS2帧率设置(如不锁帧输入0即可)："

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10, 50)
$textBox.Size = New-Object System.Drawing.Size(300, 20)

$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(100, 90)
$button.Size = New-Object System.Drawing.Size(75, 23)
$button.Text = "确定"
$button.Add_Click({
        $form.Close()
    })

$form.Controls.Add($label)
$form.Controls.Add($textBox)
$form.Controls.Add($button)

$form.Topmost = $true
$form.Add_Shown({ $textBox.Select() })
$result = $form.ShowDialog()

# 防呆
if ([int]::TryParse($textBox.Text, [ref]$null)) {
    $fps = [int]$textBox.Text
    if ($fps -lt 64 -and $fps -gt 0) {
        [System.Windows.Forms.MessageBox]::Show("输入无效，请输入0或输入64到9999之间的数值。", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit 1
    }
    if ($fps -lt 0 -or $fps -gt 9999) {
        [System.Windows.Forms.MessageBox]::Show("输入无效，请输入0或输入64到9999之间的数值。", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit 1
    }
}
else {
    [System.Windows.Forms.MessageBox]::Show("请输入有效的数字。", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit 1
}


# 读取
$fileContent = Get-Content -Path $directory -Raw -Encoding UTF8

# 修改
$newCsrmFpsMaxCommand = "alias CSRM_fps_max fps_max $fps`n"
$csrmFpsMaxPattern = '(?m)^\s*alias\s+CSRM_fps_max\s+fps_max\s+(\d+)\s*$'
$newfileContent = $fileContent -replace $csrmFpsMaxPattern, $newCsrmFpsMaxCommand

# 写入
$utf8NoooooooooBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($directory, $newfileContent, $utf8NoooooooooBom)

# 弹窗提示
[System.Windows.Forms.MessageBox]::Show("成功。", "完成", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)