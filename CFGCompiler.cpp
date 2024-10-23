#include <iostream>
#include <fstream>
#include <filesystem>
#include <vector>
#include <string>
#include <algorithm>

namespace fs = std::filesystem;

bool isBlacklisted(const fs::path& path, const std::vector<std::string>& blacklisted) {
    // 检查文件名和目录名
    for (const auto& black : blacklisted) {
        if (path.filename().string().find(black) != std::string::npos) {
            return true;
        }
        
        // 检查父目录的每一部分
        for (const auto& part : path) {
            if (part.string().find(black) != std::string::npos) {
                return true;
            }
        }
    }
    return false;
}

bool isWhitelisted(const fs::path& path) {
    // 仅允许 .cfg 文件
    return path.extension() == ".cfg";
}

void processFiles(const std::vector<std::string>& blacklisted, const std::string& outputFile) {
    std::ofstream result(outputFile);
    
    if (!result) {
        std::cerr << "Error opening result file: " << outputFile << std::endl;
        return;
    }

    for (const auto& entry : fs::recursive_directory_iterator(fs::current_path())) {
        if (entry.is_regular_file()) {
            if (!isBlacklisted(entry.path(), blacklisted) && isWhitelisted(entry.path())) {
                std::cout << "Reading file: " << entry.path() << std::endl; // 输出文件名提示
                
                std::ifstream file(entry.path());
                if (file) {
                    std::string line;
                    while (std::getline(file, line)) {
                        result << line << std::endl; // 输出到 CompilerResult.txt
                    }
                } else {
                    std::cerr << "Error opening file: " << entry.path() << std::endl;
                }
            }
        }
    }

    result.close();
}

int main() {
    std::ios::sync_with_stdio(false); // 优化输入输出性能
    std::cin.tie(0); // 解除 cin 和 cout 的绑定
    std::cout.tie(0); // 解除 cout 和 cin 的绑定

    // 黑名单示例：检查包含的字符串
    std::vector<std::string> blacklisted = {"Ticker","Practice","Preference","event","Radio"};
    // blacklisted.clear();
    std::string outputFile = "CompilerResult.txt";

    processFiles(blacklisted, outputFile);

    std::cout << "Processing complete. Output written to " << outputFile << std::endl;

    return 0;
}
