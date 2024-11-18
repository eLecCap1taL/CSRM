#include <fstream>
#include <vector>
#include <string>
using namespace std;
int main() {
    // 定义需要创建的文件名
    std::vector<std::string> weaponNames = {
        "AWP", "G3SG1", "AUG", "MP5", "MP7", "MP9", "P90", "AK47",
        "M249", "NOVA", "M4A1", "MAG7", "Bizon", "FAMAS", "MAC10",
        "Negev", "SG556", "SSG08", "UMP45", "XM1014", "Galilar",
        "Glock18", "Elite", "Scar20", "SawedOff", "Revolver",
        "HKP2000", "FiveSeven", "P250", "USP", "Tec9", "Deagle","unknown"
    };

    // 创建每个文件
    for (const auto& name : weaponNames) {
        std::ofstream outfile(name + ".cfg");
        ofstream fout(name+".cfg",ios::out);
        fout<<"echo [Weapon] "<<name<<endl;
        fout<<endl;
        fout<<"fastshiftReg_unknown";
        fout<<endl;
        fout<<endl;
        fout<<"alias hzSndFetch_curwp exec Horizon/src/core/sndFetch/weapon/"+name<<endl;
        if (outfile) {
            outfile.close(); // 确保文件被正确关闭
        } else {
            // 输出错误信息
        }
    }

    return 0;
}
