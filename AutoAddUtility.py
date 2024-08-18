import os
import re
import sys


# 获取自定义程序生成的语句
def read_last_line(file_path):
    try:
        with open(file_path, 'r') as file:
            lines = file.readlines()
            return lines[-1].strip() if lines else None
    except Exception as e:
        print(f"获取自定义道具文件内的注册指令时发生错误：{e}，请检查{file_path}文件内容")


# 解析道具名称
def get_utility_names(last_line):
    parts = last_line.split()
    if parts[0] == "alias" and len(parts) > 1:
        utility_english_name = parts[1]
        print(f'道具英文名是: {utility_english_name}')
        utility_chinese_name = input("请输入该道具的中文名（用于显示在轮盘上）：")
        print(f'道具中文名是: {utility_chinese_name}')
        return utility_english_name, utility_chinese_name
    return None, None


# 在文件中追加内容
def write_to_file_append(file_path, string_to_append):
    try:
        with open(file_path, 'a', encoding='utf-8') as file:
            file.write('\n' + string_to_append)
            print(f"成功在文件 {file_path} 中写入 {string_to_append}")
            print("=========该次文件写入已完成=========")
    except Exception as e:
        print(f"写入字符串时出现错误：{e}")


# 统计文件中包含目标文本的行数
def count_lines_with_text(file_path, target_text):
    with open(file_path, 'r', encoding='utf-8') as file:
        return sum(1 for line in file if target_text in line)


# 获取最后一个sm编号
def get_last_sm_number(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            matches = re.findall(r'sm(\d+)', content)
            return int(matches[-1]) if matches else 0
    except Exception as e:
        print(f"插入字符串时出现错误：{e},\n可能是地图名或分类名错误，请检查")
        return 0


# 在sm文件中插入内容
def write_to_sm(file_path, sm_id):
    insert_text = f'sm{sm_id};ClearThrow;'
    count = sm_id + 2
    C_radial_radio_tab_0_text_ID = f'cl_radial_radio_tab_0_text_{count} cmd";'
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    for i in range(len(lines)):
        if C_radial_radio_tab_0_text_ID in lines[i]:
            lines[i] = lines[i].strip() + insert_text + '\n'
            break
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(lines)
    return C_radial_radio_tab_0_text_ID.replace(' cmd";', '')


# 在资源文件中添加新的配置项
def add_text_var_to_res(file_path, new_var):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        for i in range(len(lines)):
            if '}' in lines[i].strip():
                lines.insert(i, new_var)
                break
        with open(file_path, 'w', encoding='utf-8') as file:
            file.writelines(lines)
        print("=========已完成对 platform_schinese.txt 的新增=========")
    except Exception as e:
        print(f"发生错误: {e}")


# 替换文件中的文本
def replace_text_in_file(file_path, text_var, text_id):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    for i in range(len(lines)):
        if text_id in lines[i]:
            lines[i] = f'{text_id} {text_var}\n'
            break
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(lines)
        print("=========已完成对 RadioInfo1Text 文件中变量名的替换=========")


# 删除文件的最后一行
def remove_last_line(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    if lines:
        lines = lines[:-1]
    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(lines)


# 查找下一个可用的轮盘
def find_next_available_file(directory):
    for i in range(1, 100):
        filename = os.path.join(directory, f'RadioInfo{i}Text.cfg')
        if os.path.exists(filename) and not is_file_full(filename):
            return filename
    return None


# 检查文件是否满载
def is_file_full(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            for line in file:
                if "#CFG_Noun_None" in line:
                    return False  # 发现空槽位，文件未满载
        return True  # 没有发现空槽位，文件已满载
    except Exception as e:
        print(f"检查文件是否满载时出错: {e}")
        return True  # 出错时假设文件已满载


# 替换一个空槽
def replace_empty_slot(file_path, new_content):
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()
        for i in range(len(lines)):
            if "#CFG_Noun_None" in lines[i]:
                lines[i] = re.sub(r'#CFG_Noun_None', new_content, lines[i], 1)
                break
        with open(file_path, 'w', encoding='utf-8') as file:
            file.writelines(lines)
            print(f"已在文件 {file_path} 中替换一个空槽")
    except Exception as e:
        print(f"替换文件中的空槽时出错: {e}")


def get_new_cmdfile_path(empty_slot_path):
    global number
    match = re.search(r'RadioInfo(\d+)Text\.cfg', empty_slot_path)
    if match:
        number = match.group(1)
    else:
        print("未找到文件名中存在数字")
    cmdfile_name = f"RadioInfo{number}CMD.cfg"
    print(f"新的cmd文件名：{cmdfile_name}")
    return cmdfile_name


# 主程序开始执行
def main():
    while True:
        custom_file_path = "./CustomGrenade/CustomGrenadeRegedit.cfg"
        grenade_regedit_path = "./Grenade/GrenadeRegedit.cfg"
        last_line = read_last_line(custom_file_path)
        regedit_string = last_line
        print("在开始使用自动添加道具之前请确认已使用一键添加自定义道具(半成品).exe完成道具添加！")
        print(f"检测到已存在的注册指令，内容为：{last_line}")
        confirmation_add = input("如果确定自己已经完成道具注册且上方显示注册指令正确请输入1后回车：")
        if confirmation_add != "1":
            sys.exit(0)
        utility_english_name, utility_chinese_name = get_utility_names(last_line)
        write_to_file_append(grenade_regedit_path, regedit_string)

        folder_path = './Grenade/'
        directories = [d for d in os.listdir(folder_path) if os.path.isdir(os.path.join(folder_path, d))]
        print(f"当前cfg中存在以下地图：{directories}")
        map_name = input("你要向什么地图中插入？(输入英文地图名)：")
        folder_path = os.path.join(folder_path, map_name)
        directories = [d for d in os.listdir(folder_path) if os.path.isdir(os.path.join(folder_path, d))]
        print(f"当前地图下存在以下分类: {directories}")
        class_name = input("你要向哪个分类中插入？(刚才指定的地图文件夹中的文件夹名)：")

        add_textfile_path = os.path.join(folder_path, class_name, 'RadioInfo1Text.cfg')
        add_cmdfile_path = os.path.join(folder_path, class_name, 'RadioInfo1CMD.cfg')
        resource_path = './resource/platform_schinese.txt'
        target_text = '#CFG_Noun_None'
        new_text_var = f'\t"CFG_{utility_english_name}"                    "{utility_chinese_name}"\n'
        text_var = f"#CFG_{utility_english_name}"

        vacant_slot = count_lines_with_text(add_textfile_path, target_text)
        print(f"{add_textfile_path} 中存在 {vacant_slot} 个空道具槽位")

        if vacant_slot != 0:
            try:
                print("正在执行新增道具中......")
                sm_id = get_last_sm_number(add_cmdfile_path) + 1
                add_utility_string = f'''alias sm{sm_id} "alias DoSayEchoWork echoln {utility_chinese_name};alias DoSayAllWork say {utility_chinese_name};alias DoSayTeamWork say_team {utility_chinese_name};DoOutput;alias StartSetAngle {utility_english_name};"'''
                write_to_file_append(add_cmdfile_path, add_utility_string)
                T_radial_radio_tab_0_text_ID = write_to_sm(add_cmdfile_path, sm_id)
                add_text_var_to_res(resource_path, new_text_var)
                replace_text_in_file(add_textfile_path, text_var, T_radial_radio_tab_0_text_ID)
                print(f"======道具：{utility_english_name} 添加成功！======")
            except Exception as e:
                print(f"道具添加失败，错误原因：{e}")
        else:

            # 寻找下一个可以使用的文件并替换
            next_file = find_next_available_file(os.path.join(folder_path, class_name))
            if next_file:
                print(f"发现下一个可以使用的轮盘：{next_file}")
                try:
                    replace_empty_slot(next_file, text_var)
                    print(f"在 {next_file} 中替换了空槽，完成道具添加！")
                    cmdfile_name = get_new_cmdfile_path(next_file)
                    new_cmdfile_path = './Grenade/' + map_name + '/' + class_name + '/' + cmdfile_name
                    sm_id = int(get_last_sm_number(new_cmdfile_path)) + 1
                    print(f"新的cmd文件路径：{new_cmdfile_path}")
                    add_utility_string = f'''alias sm{sm_id} "alias DoSayEchoWork echoln {utility_chinese_name};alias DoSayAllWork say {utility_chinese_name};alias DoSayTeamWork say_team {utility_chinese_name};DoOutput;alias StartSetAngle {utility_english_name};"'''
                    write_to_file_append(new_cmdfile_path, add_utility_string)
                    write_to_sm(new_cmdfile_path, sm_id)
                except Exception as e:
                    print(f"替换失败，错误原因：{e}")
            else:
                print("当前目录中无法找到任何可用轮盘，请自行手动增加轮盘数量")
        should_continue = input("道具添加完成！输入 quit 退出程序，或按 Enter 键继续添加道具：")
        if should_continue.lower() == "quit":
            break


if __name__ == "__main__":
    main()

input("程序结束，按回车键关闭...")
