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

string actorPath;
string tmpEn, tmpRu;
fs::path workDir, enPath, ruPath, outPath;
string res;
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
void combine() {
    ifstream en(enPath.u8string());
    ifstream ru(ruPath.u8string());
    ofstream out(outPath.u8string());
    out.clear();

    while (!en.eof()) {
        getline(en, tmpEn);
        if (!ru.eof())
            getline(ru, tmpRu);
        else
            tmpRu = "eof";
        if (tmpEn.size() < 3)
            continue;
        out << tmpEn << el << tmpRu << el << el;
    }

    out.close();
}

int main()
{
    workDir = fs::current_path();
    cout << "actor file: ";
    cin >> actorPath;
    //string actorPath = "grlt.lines.csv";
    enPath = workDir / "_EN" / actorPath;
    ruPath = workDir / "_RU" / actorPath;
    outPath = workDir / "_MERGE" / actorPath;

    if (!fs::exists(enPath) || !fs::exists(ruPath)) {
        cout << enPath.u8string() << " or " << ruPath.u8string() << " NOT FOUND!\n";
        system("pause");
        return 0;
    }

    combine();

    system("pause");
    return 0;
}
