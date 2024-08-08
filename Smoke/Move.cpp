#include <fstream>
#include <windows.h>
int main()
{
	while(1){
		if(system("fc CFGText.txt ..\\..\\resource\\platform_schinese.txt")){
			std::ifstream  src("CFGText.txt", std::ios::binary);
		    std::ofstream  dst("..\\..\\resource\\platform_schinese.txt",   std::ios::binary);
		
		    dst << src.rdbuf();
		}
		if(system("fc CFGText.txt ..\\..\\resource\\platform_english.txt")){
			std::ifstream  src("CFGText.txt", std::ios::binary);
		    std::ofstream  dst("..\\..\\resource\\platform_english.txt",   std::ios::binary);
		
		    dst << src.rdbuf();
		}
		Sleep(500);
	}
}
