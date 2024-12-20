import os
import shutil
import zipfile

def create_release():
    # 定义目录和文件路径
    temp_dir = './Temp'
    horizon_dir = os.path.join(temp_dir, 'Horizon')
    exclude_dirs = {'.git', '.github', '.vscode', 'Temp'}
    exclude_extensions = {'.cpp', '.exe'}
    additional_files = [
        '../Cap1taL\u6b22\u8fce\u6253\u8d4f_wechat.jpg',
        '../Cap1taL\u6b22\u8fce\u6253\u8d4f_\u652f\u4ed8\u5b9d.jpg',
        '../\u4e00\u5b9a\u5b8c\u6574\u770b\u4e00\u904d\u6559\u7a0b\uff01.txt',
        '../\u4f7f\u7528\u6559\u7a0b&\u5e38\u89c1\u95ee\u9898.pdf',
        '../\u4f7f\u7528\u6559\u7a0b&\u5e38\u89c1\u95ee\u9898.png',
    ]

    # 1. 创建临时目录
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir)
    os.makedirs(horizon_dir)

    # 2. 复制脚本所在目录的文件
    script_dir = os.path.dirname(os.path.abspath(__file__))
    for root, dirs, files in os.walk(script_dir):
        # 排除特定目录
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        # 计算相对路径
        rel_path = os.path.relpath(root, script_dir)
        dest_dir = os.path.join(horizon_dir, rel_path) if rel_path != '.' else horizon_dir

        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)

        # 复制文件
        for file in files:
            if file == os.path.basename(__file__) or file == 'gen.zip':
                continue
            if file == os.path.basename(__file__) or file == 'gen.bat':
                continue
            shutil.copy2(os.path.join(root, file), dest_dir)

    # 3. 删除指定扩展名的文件
    for root, dirs, files in os.walk(horizon_dir):
        for file in files:
            if any(file.endswith(ext) for ext in exclude_extensions):
                os.remove(os.path.join(root, file))

    # 4. 删除空文件夹
    for root, dirs, files in os.walk(horizon_dir, topdown=False):
        for dir in dirs:
            dir_path = os.path.join(root, dir)
            if not os.listdir(dir_path):
                os.rmdir(dir_path)

    # 5. 复制额外的文件到 Temp 目录
    for file in additional_files:
        dest_file = os.path.join(temp_dir, os.path.basename(file))
        shutil.copy2(file, dest_file)
    dest_file = os.path.join(temp_dir, os.path.basename('./install.exe'))
    shutil.copy2('./install.exe', dest_file)

    # 6. 打包 Temp 目录为 zip 文件
    zip_filename = 'gen.zip'
    with zipfile.ZipFile(zip_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, temp_dir)
                zipf.write(full_path, rel_path)

    # 7. 删除临时目录
    shutil.rmtree(temp_dir)

if __name__ == "__main__":
    create_release()
