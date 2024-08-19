# 导入必要的程序集并设置窗体样式
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

# 自动获取用户灵敏度数据
function Extract-Parameters {
    param (
        [string]$fileContent,
        [string[]]$parameters
    )
    $results = @{}
    foreach ($param in $parameters) {
        $regex = '"' + [regex]::Escape($param) + '"\s*"([^"]+)"'
        $match = [regex]::Match($fileContent, $regex)
        if ($match.Success) {
            $results[$param] = $match.Groups[1].Value
        } else {
            Write-Host "No match found for $param"
        }
    }
    return $results
}

function Process-Files {
    param (
        [System.IO.FileInfo[]]$files,
        [string[]]$parameters
    )
    $allResults = @()
    foreach ($file in $files) {
        Write-Host "Processing file: $($file.FullName)"
        $fileContent = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
        $results = Extract-Parameters -fileContent $fileContent -parameters $parameters
        if ($results.Count -gt 0) {
            $allResults += [pscustomobject]$results
        }
    }
    return $allResults
}

$parameters = @("name","cl_crosshair_dynamic_maxdist_splitratio","cl_crosshair_drawoutline","cl_crosshair_dynamic_splitalpha_innermod","cl_crosshair_dynamic_splitalpha_outermod","cl_crosshair_dynamic_splitdist","cl_crosshair_outlinethickness","cl_crosshair_recoil","cl_crosshair_sniper_width","cl_crosshair_t","cl_crosshairalpha","cl_crosshaircolor","cl_crosshaircolor_b","cl_crosshaircolor_g","cl_crosshaircolor_r","cl_crosshairdot","cl_crosshairgap","cl_crosshairgap_useweaponvalue","cl_crosshairsize","cl_crosshairstyle","cl_crosshairthickness","cl_crosshairusealpha","cl_fixedcrosshairgap")
$vcfgFiles = @()

try {
    $csgoPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 730" -Name "InstallLocation"
} catch {
    $csgoPath = $null
}

    $steamPath = Get-WmiObject Win32_Process -Filter "name='steam.exe'" | Select-Object -ExpandProperty ExecutablePath
    if ($steamPath) {
        $steamDir = Split-Path -Path $steamPath -Parent
        $userdataPath = Join-Path -Path $steamDir -ChildPath "userdata"
        $vcfgFiles = Get-ChildItem -Path $userdataPath -Recurse -Filter "cs2_user_convars_0_slot0.vcfg" 
        Write-Host $userdataPath
    }

# if (-not $vcfgFiles) {
#     if ($csgoPath -and (Test-Path "$csgoPath\cs2.exe")) {
#         $cfgPath = Join-Path -Path $csgoPath -ChildPath "csgo\cfg"
#         $vcfgFiles = Get-ChildItem -Path $cfgPath -Filter "cs2_user_convars_0_slot0.vcfg" -ErrorAction SilentlyContinue
#     }
# }

# if (-not $vcfgFiles) {
#     $csgolauncherPath = Get-WmiObject Win32_Process -Filter "name='csgolauncher.exe'" | Select-Object -ExpandProperty ExecutablePath
#     if ($csgolauncherPath) {
#         $cfgPath = $csgolauncherPath -replace "csgolauncher.exe", "steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
#         $vcfgFiles = Get-ChildItem -Path $cfgPath -Filter "cs2_user_convars_0_slot0.vcfg" -ErrorAction SilentlyContinue
#     }
# }

$userData = @()
if ($vcfgFiles) {
    $userData = Process-Files -files $vcfgFiles -parameters $parameters
}

if (-not $userData) {
    Write-Host "无法获取 cfg 文件夹路径，请确保 Steam 正在运行。"
    Read-Host "按回车键继续"
    exit
}

# 创建主窗体
$form = New-Object System.Windows.Forms.Form
$form.Text = '玩家准心数据获取 (Thanks @无聊)'
$form.Size = New-Object System.Drawing.Size(600,400)
$form.MinimumSize = New-Object System.Drawing.Size(600,400)
$form.StartPosition = 'CenterScreen'

# 创建布局
$tableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$tableLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayoutPanel.ColumnCount = 1
$tableLayoutPanel.RowCount = 2
# $tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 60)))
# $tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 25)))
# $tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 15)))
$form.Controls.Add($tableLayoutPanel)

# 创建用户数据网格
$userDataGrid = New-Object System.Windows.Forms.DataGridView
$userDataGrid.Dock = [System.Windows.Forms.DockStyle]::Fill
$userDataGrid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill
$userDataGrid.ColumnHeadersHeightSizeMode = [System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode]::AutoSize
$userDataGrid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$userDataGrid.MultiSelect = $false
$userDataGrid.AllowUserToAddRows = $false
$userDataGrid.AllowUserToDeleteRows = $false
$userDataGrid.ReadOnly = $true
$userDataGrid.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$tableLayoutPanel.Controls.Add($userDataGrid, 0, 0)

# 添加列并设置宽度比例
$userDataGrid.Columns.Add("name", "Name")
# $userDataGrid.Columns.Add("sensitivity", "Sensitivity")
# $userDataGrid.Columns.Add("m_yaw", "Yaw")
# $userDataGrid.Columns.Add("m_pitch", "Pitch")
$userDataGrid.Columns["name"].FillWeight = 40
# $userDataGrid.Columns["sensitivity"].FillWeight = 20
# $userDataGrid.Columns["m_yaw"].FillWeight = 20
# $userDataGrid.Columns["m_pitch"].FillWeight = 20

# 填充数据
foreach ($user in $userData) {
    $userDataGrid.Rows.Add($user.name)
}

# 创建输入控件组
# $inputGroup = New-Object System.Windows.Forms.GroupBox
# $inputGroup.Text = "数值"
# $inputGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
# $tableLayoutPanel.Controls.Add($inputGroup, 0, 1)

# $inputLayout = New-Object System.Windows.Forms.TableLayoutPanel
# $inputLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
# $inputLayout.ColumnCount = 6
# $inputLayout.RowCount = 1
# for ($i = 0; $i -lt 6; $i++) {
#     $inputLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 16.66)))
# }
# $inputGroup.Controls.Add($inputLayout)

# 创建输入控件
# $controls = @(
#     @{Label="Sensitivity:"; Name="sensitivity"},
#     @{Label="m_yaw:"; Name="yaw"},
#     @{Label="m_pitch:"; Name="pitch"}
# )


# $textBoxes = @{}

# for ($i = 0; $i -lt 3; $i++) {
#     $label = New-Object System.Windows.Forms.Label
#     $label.Text = $controls[$i].Label
#     $label.Anchor = [System.Windows.Forms.AnchorStyles]::Right
#     $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
#     $inputLayout.Controls.Add($label, $i * 2, 0)

#     $textBox = New-Object System.Windows.Forms.TextBox
#     $textBox.Dock = [System.Windows.Forms.DockStyle]::Fill
#     $textBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
#     $inputLayout.Controls.Add($textBox, $i * 2 + 1, 0)
#     $textBoxes[$controls[$i].Name] = $textBox
# }

# 创建按钮
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = '先选择对应的 CS 用户名, 再点击按钮一键导入准心数据'
$okButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$okButton.Margin = New-Object System.Windows.Forms.Padding(10)
$tableLayoutPanel.Controls.Add($okButton, 0, 1)

# 添加工具提示
# $toolTip = New-Object System.Windows.Forms.ToolTip
# $toolTip.SetToolTip($textBoxes["sensitivity"], "Enter your in-game sensitivity")
# $toolTip.SetToolTip($textBoxes["yaw"], "Enter your m_yaw value")
# $toolTip.SetToolTip($textBoxes["pitch"], "Enter your m_pitch value")

# 事件处理
$Global:fuser = ""
$userDataGrid.Add_SelectionChanged({
    if ($userDataGrid.SelectedRows.Count -gt 0) {
        $selectedRow = $userDataGrid.SelectedRows[0]
        # Write-host $Global:fuser
        $Global:fuser=$userData[$userDataGrid.SelectedRows.Index]
        $sc = "当前选择玩家: "
        Write-host $sc $Global:fuser.name
        # $textBoxes["sensitivity"].Text = $selectedRow.Cells["sensitivity"].Value
        # $textBoxes["yaw"].Text = $selectedRow.Cells["m_yaw"].Value
        # $textBoxes["pitch"].Text = $selectedRow.Cells["m_pitch"].Value
    }
})

$restrictInput = {
    param($sender, $event)
    if (-not ($event.KeyChar -match '\d') -and $event.KeyChar -ne '.' -and $event.KeyChar -ne [char][System.Windows.Forms.Keys]::Back) {
        $event.Handled = $true
    } elseif ($event.KeyChar -eq '.' -and $sender.Text.Contains('.')) {
        $event.Handled = $true
    }
}
# $textBoxes["sensitivity"].Add_KeyPress($restrictInput)
# $textBoxes["yaw"].Add_KeyPress($restrictInput)
# $textBoxes["pitch"].Add_KeyPress($restrictInput)



# 确认按钮点击事件1
$okButton.Add_Click({
    # if ($textBoxes["sensitivity"].Text -eq "" -or $textBoxes["yaw"].Text -eq "" -or $textBoxes["pitch"].Text -eq "") {
    #     [System.Windows.Forms.MessageBox]::Show("请填写所有数值", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    # } else {
    # Write-Host $Global:fuser
        $user=$Global:fuser
        Write-Host $user
        $sc = "最终选择玩家: "
        Write-host $sc $user.name
        $1=$user.cl_crosshair_dynamic_maxdist_splitratio
        $2=$user.cl_crosshair_drawoutline
        $3=$user.cl_crosshair_dynamic_splitalpha_innermod
        $4=$user.cl_crosshair_dynamic_splitalpha_outermod
        $5=$user.cl_crosshair_dynamic_splitdist
        $6=$user.cl_crosshair_outlinethickness
        $7=$user.cl_crosshair_recoil
        $8=$user.cl_crosshair_sniper_width
        $9=$user.cl_crosshair_t
        $10=$user.cl_crosshairalpha
        $11=$user.cl_crosshaircolor
        $12=$user.cl_crosshaircolor_b
        $13=$user.cl_crosshaircolor_g
        $14=$user.cl_crosshaircolor_r
        $15=$user.cl_crosshairdot
        $16=$user.cl_crosshairgap
        $17=$user.cl_crosshairgap_useweaponvalue
        $18=$user.cl_crosshairsize
        $19=$user.cl_crosshairstyle
        $20=$user.cl_crosshairthickness
        $21=$user.cl_crosshairusealpha
        $22=$user.cl_fixedcrosshairgap
        $drawoutline = $user.cl_crosshair_drawoutline
        $hh = "\n"
        $content1 = "alias SetPCR1 `"cl_crosshair_dynamic_maxdist_splitratio $1;cl_crosshair_drawoutline $2;cl_crosshair_dynamic_splitalpha_innermod $3;cl_crosshair_dynamic_splitalpha_outermod $4;cl_crosshair_dynamic_splitdist $5;cl_crosshair_outlinethickness $6;`""
        $content2 = "alias SetPCR2 `"cl_crosshair_sniper_width $8;cl_crosshair_t $9;cl_crosshairalpha $10;cl_crosshaircolor $11;cl_crosshaircolor_b $12;cl_crosshaircolor_g $13;cl_crosshaircolor_r $14;cl_crosshairdot $15;`""
        $content3 = "alias SetPCR3 `"cl_crosshairgap $16;cl_crosshairgap_useweaponvalue $17;cl_crosshairsize $18;cl_crosshairstyle $19;cl_crosshairthickness $20;cl_crosshairusealpha $21;cl_fixedcrosshairgap $22;`""
        $bg = ""
        Set-Content -Path "./PlayerCrossHair.cfg" -Value $bg -Encoding UTF8
        Add-Content -Path "./PlayerCrossHair.cfg" -Value $content1 -Encoding UTF8
        Add-Content -Path "./PlayerCrossHair.cfg" -Value $content2 -Encoding UTF8
        Add-Content -Path "./PlayerCrossHair.cfg" -Value $content3 -Encoding UTF8
        $content4 = "alias RNCrossHairAlphaPL cl_crosshairalpha $10"
        Add-Content -Path "./PlayerCrossHair.cfg" -Value $content4 -Encoding UTF8

        [System.Windows.Forms.MessageBox]::Show("获取成功。", "成功", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        $form.Close()
    # }
})

# 显示窗体
$form.ShowDialog()
