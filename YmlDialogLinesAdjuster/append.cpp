#include <bits/stdc++.h>
#include <windows.h>
#include <experimental/filesystem>

#define ll long long int
#define ld long double
#define X first
#define Y second
#define upn(x, init, n) for (int x = init; x <= n; ++x)
#define upiter(x, container) for (auto x = container.begin(); x != container.end(); ++x)
#define dn(x, init, n) for(int x = init; x >= n; --x)
#define diter(x, container) for (auto x = container.rbegin(); x != container.rend(); ++x)
#define pb push_back
#define pii pair<ll, ll>
#define el '\n'
#define sfio() freopen("input.txt", "r", stdin); freopen("output.txt", "w", stcout);
#define PI acos(-1.0)
#define eps 0.000000001
#define mod 1000000007
#define mp make_pair
#define NF string::npos

using namespace std;
namespace fs = std::experimental::filesystem;

string tmp;
fs::path workDir;
string res;
ofstream out;
/*    id      duration    str      */

void setConsoleColor(int type) {
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), type);
    // you can loop k higher to see more color choices
    /*for(int k = 1; k < 255; k++)    {
    // pick the colorattribute k you want
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), k);
        cout << k << " have a nice day!\n";
    }*/
}
void append(fs::path p) {
    ifstream csv(p.u8string());
    while (!csv.eof()) {
        getline(csv, tmp);
        int pos = 0;
        while (pos < tmp.length() && tmp[pos] == ' ') {
            tmp[pos] = '0';
            ++pos;
        }
        out << tmp << el;
    }
    csv.close();
}

int main()
{
    workDir = fs::current_path();
    cout << fs::current_path().u8string();
    out = ofstream("append_result.csv");

    for (const auto& dirEntry : fs::recursive_directory_iterator(workDir)) {
        fs::path curPath = dirEntry.path();
        if (curPath.extension() == ".csv" && curPath.filename().u8string() != "append_result") {
            cout << "append: [" << curPath.filename().u8string() << "]\n";
            append(curPath);
        }
    }
    out.close();
    system("pause");
    return 0;
}
