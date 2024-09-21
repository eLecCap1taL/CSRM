# 设置控制台编码为UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 启用日志
$VerbosePreference = "Continue"

# 导入必要的程序并初始化窗口
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class KeyboardHelper {
        [DllImport("user32.dll")]
        public static extern short GetKeyState(int nVirtKey);
    }
"@

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

# 调用按键库
. .\key.ps1

# 全局变量
$script:isBinding = $false
$script:currentBindingButton = $null

# 按键绑定控件UI参数
$script:bindingControlHeight = 28
$script:bindingControlWidth = 110
$script:bindingControlHorizontalSpacing = 5
$script:bindingControlVerticalSpacing = 5

# 初始设置控件UI参数
$script:settingControlHeight = 50
$script:settingControlWidth = 150
$script:settingControlHorizontalSpacing = 5
$script:settingControlVerticalSpacing = 5

function Get-CfgKeyFromPSKey {
    param (
        [string]$psKey
    )
    $displayName = $global:PSKeyToDisplayName[$psKey]
    if ($displayName) {
        return Get-CfgKeyFromDisplayName -displayName $displayName
    }
    return $psKey.ToLower()
}

function Get-DisplayNameFromCfgKey {
    param (
        [string]$cfgKey
    )
    $displayName = $global:DisplayNameToCfgKey.GetEnumerator() | Where-Object { $_.Value -eq $cfgKey } | Select-Object -ExpandProperty Key -First 1
    if ($displayName) {
        return $displayName
    }
    return $cfgKey.ToUpper()
}

function Get-DisplayNameFromKeyCode {
    param (
        [System.Windows.Forms.Keys]$keyCode
    )
    
    switch ($keyCode) {
        ([System.Windows.Forms.Keys]::ShiftKey) { 
            $leftState = [KeyboardHelper]::GetKeyState(0xA0) # VK_LSHIFT
            if (($leftState -band 0x8000) -ne 0) {
                return "Left Shift"
            }
            else {
                return "Right Shift"
            }
        }
        ([System.Windows.Forms.Keys]::ControlKey) { 
            $leftState = [KeyboardHelper]::GetKeyState(0xA2) # VK_LCONTROL
            if (($leftState -band 0x8000) -ne 0) {
                return "Left Ctrl"
            }
            else {
                return "Right Ctrl"
            }
        }
        ([System.Windows.Forms.Keys]::Menu) { 
            $leftState = [KeyboardHelper]::GetKeyState(0xA4) # VK_LMENU
            if (($leftState -band 0x8000) -ne 0) {
                return "Left Alt"
            }
            else {
                return "Right Alt"
            }
        }
        default { return Get-DisplayNameFromPSKey -keyCode $keyCode }
    }
}

# 自动获取灵敏度
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
        }
        else {
            Write-Verbose "No match found for $param"
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
        Write-Verbose "Processing file: $($file.FullName)"
        $fileContent = Get-Content -Path $file.FullName -Encoding UTF8 -Raw
        $results = Extract-Parameters -fileContent $fileContent -parameters $parameters
        if ($results.Count -gt 0) {
            $allResults += [pscustomobject]$results
        }
    }
    return $allResults
}

$parameters = @("m_pitch", "m_yaw", "sensitivity", "name")
$vcfgFiles = @()

try {
    $csgoPath = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 730" -Name "InstallLocation"
}
catch {
    $csgoPath = $null
}

if ($csgoPath -and (Test-Path "$csgoPath\cs2.exe")) {
    $cfgPath = Join-Path -Path $csgoPath -ChildPath "csgo\cfg"
    $vcfgFiles = Get-ChildItem -Path $cfgPath -Filter "cs2_user_convars_0_slot0.vcfg" -ErrorAction SilentlyContinue
}

if (-not $vcfgFiles) {
    $steamPath = Get-WmiObject Win32_Process -Filter "name='steam.exe'" | Select-Object -ExpandProperty ExecutablePath
    if ($steamPath) {
        $steamDir = Split-Path -Path $steamPath -Parent
        $userdataPath = Join-Path -Path $steamDir -ChildPath "userdata"
        $vcfgFiles = Get-ChildItem -Path $userdataPath -Recurse -Filter "cs2_user_convars_0_slot0.vcfg" -ErrorAction SilentlyContinue
    }
}

if (-not $vcfgFiles) {
    $csgolauncherPath = Get-WmiObject Win32_Process -Filter "name='csgolauncher.exe'" | Select-Object -ExpandProperty ExecutablePath
    if ($csgolauncherPath) {
        $cfgPath = $csgolauncherPath -replace "csgolauncher.exe", "steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg"
        $vcfgFiles = Get-ChildItem -Path $cfgPath -Filter "cs2_user_convars_0_slot0.vcfg" -ErrorAction SilentlyContinue
    }
}

$userData = @()
if ($vcfgFiles) {
    $userData = Process-Files -files $vcfgFiles -parameters $parameters
}

if (-not $userData) {
    Write-Verbose "无法获取cfg 文件夹路径，请确保 Steam 正在运行。"
    Read-Host "按回车键继续"
    exit
}

# 读取保存的输入值和按键绑定
$savedData = $null
if (Test-Path 'config') {
    Write-Verbose "Attempting to read config file"
    try {
        $configContent = Get-Content 'config' -Raw
        $savedData = $configContent | ConvertFrom-Json
        if ($savedData) {
            Write-Verbose "Config file read successfully"
            if ($savedData.bindings) {
                Write-Verbose "Found $($savedData.bindings.Count) bindings in config file"
            }
            else {
                Write-Verbose "No bindings found in config file"
            }
        }
        else {
            Write-Verbose "Config file is empty or invalid"
        }
    }
    catch {
        Write-Verbose "Error parsing config file: $_"
        Write-Verbose "Config file content:"
        Write-Verbose $configContent
        

        try {
            $manualParsedData = $configContent -replace '}\s*{', '},{'
            $savedData = $manualParsedData | ConvertFrom-Json
            Write-Verbose "Manual parsing successful"
        }
        catch {
            Write-Verbose "Manual parsing failed: $_"
        }
    }
}
else {
    Write-Verbose "Config file not found"
}

# 初始化灵敏度
$sensitivity = $savedData.sensitivity.sensitivity
$yaw = $savedData.sensitivity.yaw
$pitch = $savedData.sensitivity.pitch


# 创建主窗口
$form = New-Object System.Windows.Forms.Form
$form.Text = 'CFG安装'
$form.MinimumSize = New-Object System.Drawing.Size(1000, 800)
$form.StartPosition = 'CenterScreen'
$form.KeyPreview = $true
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink

# 布局
$tableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$tableLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayoutPanel.ColumnCount = 2
$tableLayoutPanel.RowCount = 5
$tableLayoutPanel.ColumnStyles.Clear()
$tableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)))
$tableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)))

$tableLayoutPanel.RowStyles.Clear()
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 0))) # 标题行
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 30))) # 用户数据网格
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 80))) # 输入控件组
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 70))) # 按键绑定和设置
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Absolute, 50))) # 确认按钮

# 创建选择菜单
$form.Controls.Add($tableLayoutPanel)
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
$tableLayoutPanel.Controls.Add($userDataGrid, 0, 1)
$tableLayoutPanel.SetColumnSpan($userDataGrid, 2)

# 调整样式
$userDataGrid.RowHeadersVisible = $false
$userDataGrid.AlternatingRowsDefaultCellStyle.BackColor = [System.Drawing.Color]::LightGray
$userDataGrid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::LightBlue
$userDataGrid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::Black

# 添加列，设置宽度比例
$userDataGrid.Columns.Add("name", "Name")
$userDataGrid.Columns.Add("sensitivity", "Sensitivity")
$userDataGrid.Columns.Add("m_yaw", "Yaw")
$userDataGrid.Columns.Add("m_pitch", "Pitch")
$userDataGrid.Columns["name"].FillWeight = 40
$userDataGrid.Columns["sensitivity"].FillWeight = 20
$userDataGrid.Columns["m_yaw"].FillWeight = 20
$userDataGrid.Columns["m_pitch"].FillWeight = 20

# 填充数据
foreach ($user in $userData) {
    $userDataGrid.Rows.Add($user.name, $user.sensitivity, $user.m_yaw, $user.m_pitch)
}

# 创建输入控件
$inputGroup = New-Object System.Windows.Forms.GroupBox
$inputGroup.Text = "数值"
$inputGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
$inputGroup.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$inputGroup.Font = New-Object System.Drawing.Font("Arial", 10)
$tableLayoutPanel.Controls.Add($inputGroup, 0, 2)
$tableLayoutPanel.SetColumnSpan($inputGroup, 2)

$inputLayout = New-Object System.Windows.Forms.TableLayoutPanel
$inputLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$inputLayout.ColumnCount = 3
$inputLayout.RowCount = 2
for ($i = 0; $i -lt 3; $i++) {
    $inputLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 33.33)))
}
$inputLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$inputLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$inputGroup.Controls.Add($inputLayout)

$controls = @(
    @{Label = "Sensitivity:"; Name = "sensitivity" },
    @{Label = "m_yaw:"; Name = "yaw" },
    @{Label = "m_pitch:"; Name = "pitch" }
)

$textBoxes = @{}

for ($i = 0; $i -lt 3; $i++) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $controls[$i].Label
    $label.Anchor = [System.Windows.Forms.AnchorStyles]::Left
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $inputLayout.Controls.Add($label, $i, 0)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $textBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $inputLayout.Controls.Add($textBox, $i, 1)
    $textBoxes[$controls[$i].Name] = $textBox
}

# 创建按键绑定控件
$bindingGroup = New-Object System.Windows.Forms.GroupBox
$bindingGroup.Text = "按键绑定"
$bindingGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayoutPanel.Controls.Add($bindingGroup, 0, 3)

$bindingLayout = New-Object System.Windows.Forms.TableLayoutPanel
$bindingLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$bindingLayout.ColumnCount = 3
$bindingLayout.RowCount = 0
for ($i = 0; $i -lt 3; $i++) {
    $bindingLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 33.33)))
}
$bindingLayout.AutoScroll = $true
$bindingGroup.Controls.Add($bindingLayout)
Write-Verbose "Binding layout created and added to form"
$script:bindingButtons = [ordered]@{}

# 动态按键绑定控件
function Add-BindingControl {
    param (
        [string]$label,
        [string]$command,
        [string]$defaultCfgKey,
        [string[]]$ban_key
    )
    Write-Verbose "Adding binding control: Label=$label, Command=$command, DefaultCfgKey=$defaultCfgKey"
    $rowIndex = [Math]::Floor($bindingLayout.Controls.Count / 3)
    $columnIndex = $bindingLayout.Controls.Count % 3
    
    if ($columnIndex -eq 0) {
        $bindingLayout.RowCount++
        $bindingLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
    }

    $bindingPanel = New-Object System.Windows.Forms.Panel
    $bindingPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $bindingPanel.Margin = New-Object System.Windows.Forms.Padding($script:bindingControlHorizontalSpacing, $script:bindingControlVerticalSpacing, $script:bindingControlHorizontalSpacing, $script:bindingControlVerticalSpacing)
    $bindingLayout.Controls.Add($bindingPanel, $columnIndex, $rowIndex)

    $bindingLabel = New-Object System.Windows.Forms.Label
    $bindingLabel.Text = $label
    $bindingLabel.AutoSize = $true
    $bindingLabel.Location = New-Object System.Drawing.Point(0, 0)
    $bindingPanel.Controls.Add($bindingLabel)

    $bindingButton = New-Object System.Windows.Forms.Button
    $bindingButton.Text = Get-DisplayNameFromCfgKey -cfgKey $defaultCfgKey
    $bindingButton.Location = New-Object System.Drawing.Point(0, 20)
    $bindingButton.Size = New-Object System.Drawing.Size($script:bindingControlWidth, $script:bindingControlHeight)
    $bindingPanel.Controls.Add($bindingButton)

    $bindingButton.Add_Click({
            $script:isBinding = $true
            $script:currentBindingButton = $this
            $this.Text = "按下按键..."
        })

    $script:bindingButtons[$command] = @{
        Label        = $label
        Button       = $bindingButton
        CfgKey       = (Get-CfgKeyFromDisplayName -displayName (Get-DisplayNameFromCfgKey -cfgKey $defaultCfgKey))
        Command      = $command
        LastValidKey = (Get-CfgKeyFromDisplayName -displayName (Get-DisplayNameFromCfgKey -cfgKey $defaultCfgKey))
        BanKey       = $ban_key | ForEach-Object { Get-CfgKeyFromDisplayName -displayName (Get-DisplayNameFromCfgKey -cfgKey $_) }
    }

    Write-Verbose "Added binding control: Label=$label, Command=$command, DefaultCfgKey=$defaultCfgKey"
}

# 从 config 文件中读取并添加按键绑定
if ($savedData -and $savedData.bindings) {
    Write-Verbose "Adding binding controls from saved data"
    foreach ($binding in $savedData.bindings) {
        try {
            $command = $binding.nd
            $cfgKey = $binding.key
            $ban_key = if ($binding.PSObject.Properties.Name -contains "ban_key") { $binding.ban_key } else { @() }
            Write-Verbose "Adding binding: Label=$($binding.label), Command=$command, CfgKey=$cfgKey, BanKey=$($ban_key -join ',')"
            Add-BindingControl -label $binding.label -command $command -defaultCfgKey $cfgKey -ban_key $ban_key
        }
        catch {
            Write-Verbose "Error adding binding control: $_"
        }
    }
}
else {
    Write-Verbose "No saved bindings found or bindings data is invalid, no controls added"
}

# 创建初始设置控件
$settingsGroup = New-Object System.Windows.Forms.GroupBox
$settingsGroup.Text = "初始设置"
$settingsGroup.Dock = [System.Windows.Forms.DockStyle]::Fill
$tableLayoutPanel.Controls.Add($settingsGroup, 1, 3)

$settingsLayout = New-Object System.Windows.Forms.TableLayoutPanel
$settingsLayout.Dock = [System.Windows.Forms.DockStyle]::Fill
$settingsLayout.ColumnCount = 1
$settingsLayout.RowCount = 3
for ($i = 0; $i -lt 3; $i++) {
    $settingsLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 33.33)))
}
$settingsLayout.AutoScroll = $true
$settingsGroup.Controls.Add($settingsLayout)

$bindingGroup.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$settingsGroup.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right

$bindingLayout.Padding = New-Object System.Windows.Forms.Padding(10)
$settingsLayout.Padding = New-Object System.Windows.Forms.Padding(10)

# 初始化初始设置控件字典
$script:settingsControls = @{}

# 动态初始设置控件
function Add-SettingControl {
    param (
        [string]$name,
        [string[]]$options,
        [string]$selectedOption
    )
    $controlCount = $settingsLayout.Controls.Count
    $columnIndex = [Math]::Floor($controlCount / 3)
    $rowIndex = $controlCount % 3
    
    if ($rowIndex -eq 0 -and $controlCount -gt 0) {
        $settingsLayout.ColumnCount++
        $settingsLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
    }

    $settingPanel = New-Object System.Windows.Forms.Panel
    $settingPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $settingPanel.Margin = New-Object System.Windows.Forms.Padding($script:settingControlHorizontalSpacing, $script:settingControlVerticalSpacing, $script:settingControlHorizontalSpacing, $script:settingControlVerticalSpacing)
    $settingsLayout.Controls.Add($settingPanel, $columnIndex, $rowIndex)

    $settingLabel = New-Object System.Windows.Forms.Label
    $settingLabel.Text = $name
    $settingLabel.AutoSize = $true
    $settingLabel.Location = New-Object System.Drawing.Point(0, 0)
    $settingPanel.Controls.Add($settingLabel)

    $settingComboBox = New-Object System.Windows.Forms.ComboBox
    $settingComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $settingComboBox.Location = New-Object System.Drawing.Point(0, 20)
    $settingComboBox.Size = New-Object System.Drawing.Size($script:settingControlWidth, $script:settingControlHeight)
    $settingPanel.Controls.Add($settingComboBox)

    foreach ($option in $options) {
        $settingComboBox.Items.Add($option)
    }

    if ($selectedOption -and $settingComboBox.Items.Contains($selectedOption)) {
        $settingComboBox.SelectedItem = $selectedOption
    }
    elseif ($settingComboBox.Items.Count -gt 0) {
        $settingComboBox.SelectedIndex = 0
    }

    $script:settingsControls[$name] = $settingComboBox
}

# 从 config 文件中读取并添加初始设置
if ($savedData -and $savedData.settings) {
    Write-Verbose "Adding setting controls from saved data"
    foreach ($setting in $savedData.settings) {
        try {
            Add-SettingControl -name $setting.name -options $setting.options -selectedOption $setting.selectedOption
        }
        catch {
            Write-Verbose "Error adding setting control: $_"
        }
    }
}
else {
    Write-Verbose "No saved settings found or settings data is invalid, no controls added"
}

# 确认按钮
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = 'OK'
$okButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$okButton.Margin = New-Object System.Windows.Forms.Padding(10)
$tableLayoutPanel.Controls.Add($okButton, 0, 4)
$tableLayoutPanel.SetColumnSpan($okButton, 2)


# 创建自动添加启动项的复选框
$autoexecCheckBox = New-Object System.Windows.Forms.CheckBox
$autoexecCheckBox.Text = "帮我在autoexec中添加启动项(建议勾选)"
$autoexecCheckBox.Checked = $true
$autoexecCheckBox.Anchor = [System.Windows.Forms.AnchorStyles]::Right
$autoexecCheckBox.AutoSize = $true
$autoexecCheckBox.Margin = New-Object System.Windows.Forms.Padding(0, 0, 10, 5)
$tableLayoutPanel.Controls.Add($autoexecCheckBox, 1, 5)

# 创建教程链接
$tutorialLink = New-Object System.Windows.Forms.LinkLabel
$tutorialLink.Text = "我是萌新，点击查看教程"
$tutorialLink.LinkColor = [System.Drawing.Color]::Blue
$tutorialLink.AutoSize = $true
$tutorialLink.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Bottom
$tutorialLink.Margin = New-Object System.Windows.Forms.Padding(10, 0, 0, 5)
$tableLayoutPanel.Controls.Add($tutorialLink, 0, 5)

# 调整TableLayoutPanel的行数和列样式
$tableLayoutPanel.RowCount = 6
$tableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
$tableLayoutPanel.ColumnStyles[1] = New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 50)

# 教程链接点击触发
$tutorialLink.Add_Click({
        $tutorialPath = Join-Path -Path $PSScriptRoot -ChildPath "软件教程.txt"
        if (Test-Path $tutorialPath) {
            Start-Process notepad.exe -ArgumentList $tutorialPath
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("未找到教程文件。", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })


# 添加提示
<# $toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.SetToolTip($textBoxes["sensitivity"], "Enter your in-game sensitivity")
$toolTip.SetToolTip($textBoxes["yaw"], "Enter your m_yaw value")
$toolTip.SetToolTip($textBoxes["pitch"], "Enter your m_pitch value") #>

# 事件处理
$userDataGrid.Add_SelectionChanged({
        if ($userDataGrid.SelectedRows.Count -gt 0) {
            $selectedRow = $userDataGrid.SelectedRows[0]
            $textBoxes["sensitivity"].Text = $selectedRow.Cells["sensitivity"].Value
            $textBoxes["yaw"].Text = $selectedRow.Cells["m_yaw"].Value
            $textBoxes["pitch"].Text = $selectedRow.Cells["m_pitch"].Value
        }
    })

$restrictInput = {
    param($sender, $event)
    if (-not ($event.KeyChar -match '\d') -and $event.KeyChar -ne '.' -and $event.KeyChar -ne [char][System.Windows.Forms.Keys]::Back) {
        $event.Handled = $true
    }
    elseif ($event.KeyChar -eq '.' -and $sender.Text.Contains('.')) {
        $event.Handled = $true
    }
}

$textBoxes["sensitivity"].Add_KeyPress($restrictInput)
$textBoxes["yaw"].Add_KeyPress($restrictInput)
$textBoxes["pitch"].Add_KeyPress($restrictInput)

# 按钮触发
$okButton.Add_Click({
        Write-Verbose "OK button clicked"
        if ($textBoxes["sensitivity"].Text -eq "" -or $textBoxes["yaw"].Text -eq "" -or $textBoxes["pitch"].Text -eq "") {
            [System.Windows.Forms.MessageBox]::Show("请填写所有数值", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $sensitivity = $textBoxes["sensitivity"].Text
        $yaw = $textBoxes["yaw"].Text
        $pitch = $textBoxes["pitch"].Text

        $configFile = "Preference.cfg"
        Write-Verbose "Updating Preference.cfg"
        if (-not (Test-Path $configFile)) {
            [System.Windows.Forms.MessageBox]::Show("配置文件不存在！", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }

        $content = Get-Content $configFile -Encoding UTF8 -Raw
    
        # 更新灵敏度
        $sensitivityPattern = '(alias StopGrenade "sensitivity )[\d.]+;(m_yaw )[\d.]+;(m_pitch )[\d.]+"'
        $sensitivityReplacement = "`${1}$sensitivity;`${2}$yaw;`${3}$pitch`""
        $content = $content -replace $sensitivityPattern, $sensitivityReplacement

        # 处理按键绑定
        $inputValues = @{
            sensitivity = @{
                sensitivity = $sensitivity
                yaw         = $yaw
                pitch       = $pitch
            }
            bindings    = @()
            settings    = @()
        }

        Write-Verbose "Current binding buttons:"
        $script:bindingButtons.GetEnumerator() | ForEach-Object {
            Write-Verbose ("Key: {0}, Label: {1}, CfgKey: {2}, Command: {3}" -f $_.Key, $_.Value.Label, $_.Value.CfgKey, $_.Value.Command)
        }

        Write-Verbose "Processing bindings"
        if ($savedData -and $savedData.bindings) {
            foreach ($originalBinding in $savedData.bindings) {
                $label = $originalBinding.label
                $matchingButton = $script:bindingButtons.GetEnumerator() | Where-Object { $_.Value.Label -eq $label } | Select-Object -First 1
                if ($matchingButton) {
                    $data = $matchingButton.Value
                    Write-Verbose "Processing binding: Label=$($data.Label), Original CfgKey=$($originalBinding.key), New CfgKey=$($data.CfgKey)"
            
                    if ([string]::IsNullOrEmpty($data.CfgKey)) {
                        Write-Verbose "Warning: New CfgKey is null or empty for $($data.Label). Skipping this binding."
                        continue
                    }

                    $newBinding = @{
                        label = $data.Label
                        key   = $data.CfgKey
                        nd    = $originalBinding.nd -replace [regex]::Escape($originalBinding.key), $data.CfgKey
                    }

                    if ($originalBinding.PSObject.Properties.Name -contains "ban_key") {
                        $newBinding.ban_key = $originalBinding.ban_key | ForEach-Object { 
                            Get-CfgKeyFromDisplayName -displayName (Get-DisplayNameFromCfgKey -cfgKey $_)
                        }
                    }

                    $inputValues.bindings += $newBinding

            
                    # 更新内容
                    $oldCommands = $originalBinding.nd -split '\r?\n'
                    $newCommands = $newBinding.nd -split '\r?\n'

                    for ($i = 0; $i -lt $oldCommands.Count; $i++) {
                        $oldCommand = $oldCommands[$i].Trim()
                        $newCommand = $newCommands[$i].Trim()
                
                        if ($oldCommand -and $newCommand -and -not $oldCommand.StartsWith("//")) {
                            $pattern = "(?m)^(?!//)\s*" + [regex]::Escape($oldCommand) + "\s*$"
                            Write-Verbose "Replacing pattern: $pattern"
                            Write-Verbose "With new command: $newCommand"
                            $content = $content -replace $pattern, $newCommand
                            Write-Verbose "Replacement attempt completed"
                        }
                    }
            
                    Write-Verbose "Updated binding: Label=$($data.Label), CfgKey=$($data.CfgKey), Commands=$($newCommands -join ' | ')"
                }
                else {
                    Write-Verbose "No matching button found for label: $label. Keeping original binding."
                    $inputValues.bindings += $originalBinding
                }
            }
        }


        # 处理设置
        Write-Verbose "Processing settings"
        foreach ($settingName in $script:settingsControls.Keys) {
            $comboBox = $script:settingsControls[$settingName]
            $savedSetting = $savedData.settings | Where-Object { $_.name -eq $settingName }
            if ($savedSetting) {
                $oldOptionIndex = $savedSetting.options.IndexOf($savedSetting.selectedOption)
                $newOptionIndex = $savedSetting.options.IndexOf($comboBox.SelectedItem)
        
                if ($oldOptionIndex -ge 0 -and $newOptionIndex -ge 0) {
                    $oldOption = $savedSetting.cfg_options[$oldOptionIndex]
                    $newOption = $savedSetting.cfg_options[$newOptionIndex]
            
                    Write-Verbose "Processing setting: $settingName"
                    Write-Verbose "Old option: $oldOption"
                    Write-Verbose "New option: $newOption"

                    $pattern = "(?m)^(?!//)\s*" + [regex]::Escape($oldOption) + "\s*$"
                    $newContent = $content -replace $pattern, $newOption
                    if ($newContent -ne $content) {
                        $content = $newContent
                        Write-Verbose "Setting updated successfully"
                    }
                    else {
                        Write-Verbose "Failed to update setting. Pattern not found or no changes made."
                    }
            
                    $savedSetting.selectedOption = $comboBox.SelectedItem
                    $inputValues.settings += $savedSetting
                }
                else {
                    Write-Verbose "Warning: Invalid option index for setting $settingName. Old: $oldOptionIndex, New: $newOptionIndex"
                }
            }
            else {
                Write-Verbose "Warning: No saved setting found for $settingName"
            }
        }

        Write-Verbose "Content before writing to file:"
        Write-Verbose $content

        # debug 输出写入内容
        Write-Verbose "Content before writing to file:"
        Write-Verbose ($content | Out-String)

        # 写入
        # Set-Content $configFile -Value $content -Encoding UTF8 -ErrorAction Stop
        # Write-Verbose "Config file updated successfully"
        # 尝试使用新写入方法，并且尝试不影响原先的错误系统（可能出现bug）
        try {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($configFile, $content, $utf8NoBom)
            Write-Verbose "Config file updated successfully"
        }
        catch {
            Write-Verbose "Error updating config file: $_"
            [System.Windows.Forms.MessageBox]::Show("更新配置文件时发生错误: $_", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }


        Write-Verbose "Saving input values to config file"
        $inputValuesJson = $inputValues | ConvertTo-Json -Depth 3
        Write-Verbose "Input values JSON:"
        Write-Verbose $inputValuesJson

        # Set-Content "config" -Value $inputValuesJson -Encoding UTF8 -ErrorAction Stop
        # Write-Verbose "Config saved successfully"
        # 尝试使用新写入方法，并且尝试不影响原先的错误系统（可能出现bug）
        try {
            $utf8NooBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText("config", $inputValuesJson, $utf8NooBom)
            Write-Verbose "Config saved successfully"
        }
        catch {
            Write-Verbose "Error saving config file: $_"
            [System.Windows.Forms.MessageBox]::Show("保存配置文件时发生错误: $_", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }



        $feedbackMessage = ""

        # 自动添加启动项
        if ($autoexecCheckBox.Checked) {
            $csgoConfigPath = Split-Path $PSScriptRoot -Parent
            $autoexecPath = Join-Path -Path $csgoConfigPath -ChildPath "autoexec.cfg"
            Write-Verbose "Autoexec path: $autoexecPath"

            # 检查文件，如果没有autoexec.cfg，创建一个
            if (Test-Path $autoexecPath) {
                if ((Get-Item $autoexecPath).IsReadOnly) {
                    Write-Verbose "autoexec.cfg is read-only"
                    $feedbackMessage += "autoexec.cfg 是只读文件，无法修改。`n"
                    return
                }
            }
            else {
                try {
                    New-Item -Path $autoexecPath -ItemType File -Force | Out-Null
                    Write-Verbose "Created new autoexec.cfg file"
                    $feedbackMessage += "已创建新的 autoexec.cfg 文件。`n"
                }
                catch {
                    Write-Verbose "Error creating autoexec.cfg: $_"
                    $feedbackMessage += "无法创建 autoexec.cfg 文件。错误: $_`n"
                    return
                }
            }

            # 读取
            try {
                $content = [System.IO.File]::ReadAllText($autoexecPath)
                Write-Verbose "Current content of autoexec.cfg:"
                Write-Verbose $content
            }
            catch {
                Write-Verbose "Error reading autoexec.cfg: $_"
                $feedbackMessage += "无法读取 autoexec.cfg 文件。错误: $_`n"
                return
            }

            # 检查有无exec CSRM/Main
            if ($content -notmatch "exec CSRM/Main") {
                try {
                    # 尝试添加
                    $newContent = if ($content) {
                        if ($content.TrimEnd().EndsWith("`n")) {
                            $content.TrimEnd() + "exec CSRM/Main`n"
                        }
                        else {
                            $content.TrimEnd() + "`nexec CSRM/Main`n"
                        }
                    }
                    else {
                        "exec CSRM/Main`n"
                    }

                    # 写入添加
                    # 尝试使用新写入方法，并且尝试不影响原先的错误系统（可能出现bug）
                    # [System.IO.File]::WriteAllText($autoexecPath, $newContent)
                    $utf8NoooBom = New-Object System.Text.UTF8Encoding $false
                    [System.IO.File]::WriteAllText($autoexecPath, $newContent, $utf8NoooBom)
                    # 莫名的bug，刷新一下
                    [System.IO.File]::SetLastWriteTime($autoexecPath, 
                        [DateTime]::Now) 
                    Write-Verbose "Added 'exec CSRM/Main' to autoexec.cfg"
                    $feedbackMessage += "已尝试将 'exec CSRM/Main' 添加到 autoexec.cfg 中。`n"
                }
                catch {
                    Write-Verbose "Error updating autoexec.cfg: $_"
                    $feedbackMessage += "无法更新 autoexec.cfg 文件。错误: $_`n"
                    return
                }
            }
            else {
                Write-Verbose "'exec CSRM/Main' already exists in autoexec.cfg"
                $feedbackMessage += "autoexec.cfg 中已存在 'exec CSRM/Main'，无需添加。`n"
            }

        
            # 验证
            <# try {
                Start-Sleep -Seconds 1
                $verificationContent = [System.IO.File]::ReadAllText($autoexecPath)
                Write-Verbose "Verification content:"
                Write-Verbose $verificationContent
                if ($verificationContent -match "exec CSRM/Main") {
                    Write-Verbose "Verification successful: 'exec CSRM/Main' found in autoexec.cfg"
                    $feedbackMessage += "验证成功：'exec CSRM/Main' 已在 autoexec.cfg 中找到。`n"
                }
                else {
                    Write-Verbose "Verification failed: 'exec CSRM/Main' not found in autoexec.cfg"
                    $feedbackMessage += "验证失败：未能在 autoexec.cfg 中找到 'exec CSRM/Main'。`n"
                }
            }
            catch {
                Write-Verbose "Error verifying autoexec.cfg: $_"
                $feedbackMessage += "无法验证 autoexec.cfg 文件。错误: $_`n"
            } #>

            # 最终检查
            try {
                $finalContent = [System.IO.File]::ReadAllText($autoexecPath)
                Write-Verbose "Final content of autoexec.cfg:"
                Write-Verbose $finalContent
            }
            catch {
                Write-Verbose "Error reading final content of autoexec.cfg: $_"
                $feedbackMessage += "无法读取 autoexec.cfg 的最终内容。错误: $_`n"
            }
        }

        Write-Verbose "Saving config file"
        $inputValues | ConvertTo-Json -Depth 3 | Set-Content "config" -Encoding UTF8

        Write-Verbose "Processing resource.zip"
        try {
            $currentDirectory = Get-Location
            $sourceFile = Join-Path -Path $currentDirectory -ChildPath "resource.zip"
            if (-Not (Test-Path -Path $sourceFile)) {
                throw "当前目录下未找到 resource.zip 文件"
            }

            $process = Get-Process -Name "完美世界竞技平台" -ErrorAction Stop
            $processPath = ($process | Select-Object -First 1).Path
            $directory = Split-Path $processPath -Parent

            $targetFile = Join-Path -Path $directory -ChildPath "plugin\resource\resource.zip"
            $targetDirectory = Split-Path $targetFile -Parent
            if (-Not (Test-Path -Path $targetDirectory)) {
                New-Item -Path $targetDirectory -ItemType Directory -Force
            }

            Copy-Item -Path $sourceFile -Destination $targetFile -Force
            if (-Not (Test-Path -Path $targetFile)) {
                throw "文件复制失败: $targetFile"
            }

            $zipFilePath2 = ".\resource.zip"
            $destinationFolder2 = "..\..\resource"
            if (-not (Test-Path $destinationFolder2)) {
                New-Item -Path $destinationFolder2 -ItemType Directory
            }

            Expand-Archive -Path $zipFilePath2 -DestinationPath $destinationFolder2 -Force

            Write-Verbose "Installation completed"
            # 最终提示
            $finalMessage = "安装完成，请自行前往游戏测试。`n`n"
            if ($feedbackMessage) {
                $finalMessage += "附属：`n$feedbackMessage"
            }

            $result = [System.Windows.Forms.MessageBox]::Show($finalMessage, "安装完成", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                $form.Close()
            }
        }
        catch {
            Write-Verbose "Error occurred: $_"
            [System.Windows.Forms.MessageBox]::Show("发生错误: $_", "错误", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

# 按键检查
$form.Add_KeyDown({
        param($sender, $e)
        if ($script:isBinding) {
            $keyCode = $e.KeyCode
            $displayName = Get-DisplayNameFromKeyCode -keyCode $keyCode
            $cfgKey = Get-CfgKeyFromDisplayName -displayName $displayName
        
            foreach ($pair in $script:bindingButtons.GetEnumerator()) {
                if ($pair.Value.Button -eq $script:currentBindingButton) {
                    $isBanned = $false
                
                    if ($pair.Value.BanKey -and $pair.Value.BanKey -contains $cfgKey) {
                        $isBanned = $true
                    }
                
                    if ($isBanned) {
                        [System.Windows.Forms.MessageBox]::Show("此功能禁止绑定此按键", "警告", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
                        $script:currentBindingButton.Text = Get-DisplayNameFromCfgKey -cfgKey $pair.Value.LastValidKey
                    }
                    else {
                        $pair.Value.CfgKey = $cfgKey
                        $pair.Value.LastValidKey = $cfgKey
                        $script:currentBindingButton.Text = $displayName
                    }
                    break
                }
            }
        
            $script:isBinding = $false
            $script:currentBindingButton = $null
            $e.Handled = $true
            $e.SuppressKeyPress = $true
        }
    })

# 隐藏命令窗口
$consolePtr = [Win32]::GetConsoleWindow()
[Win32]::ShowWindow($consolePtr, 0) 

# 显示窗体
Write-Verbose "Displaying form"
$form.ShowDialog()
exit

# 关不掉？我不信
<# $form.Add_FormClosed({
     [System.Windows.Forms.Application]::Exit()
     [System.Environment]::Exit(0)
})
信了 #>