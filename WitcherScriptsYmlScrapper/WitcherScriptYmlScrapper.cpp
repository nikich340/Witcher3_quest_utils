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
ofstream logg;
ofstream yml;
int fileCnt;

struct w3class {
    string className;
    string baseclassName;
    string type;
    vector<pair<string, string>> vars;
    //vector<string> dependenciesNames;
    bool isImported;
    bool wasDumped;
    w3class(string name) {
        className = name;
        baseclassName = "none";
        isImported = false;
        wasDumped = false;
    }
    void log() {
        logg << "  Add class! name <" << className << ">, base <" << baseclassName << ">, isImported <" << isImported << ">\n";
    }
};
map<string, int> w3classIdxByName;
vector<w3class> w3classes;

fs::path workDir, vanillaDir, customDir;
string tmp, line;

bool isLetter(char a) {
    return (a >= 'a' && a <= 'z') || (a >= 'A' && a <= 'Z') || (a >= '0' && a <= '9') || (a == '<' || a == '>' || a == '_');
}
bool isKeyword(string s) {
    return (s == "private" || s == "public" || s == "protected" || s == "editable" || s == "saved" || s == "inlined" || s == "abstract" || s == "statemachine" || s == "state");
}
enum consoleColor {
    ccBLACK, ccDARKBLUE, ccDARKGREEN, ccDARKCYAN, ccDARKRED, ccDARKVIOLET, ccDARKYELLOW, ccDARKWHITE,
    ccGRAY, ccBLUE, ccGREEN, ccCYAN, ccRED, ccVIOLET, ccYELLOW, ccWHITE
};
void setConsoleColor(int type) {
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), type);
    /*for(int k = 0; k < 255; k++)    {
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), k);
        cout << k << " have a nice day!\n";
    }*/
}
void coutColor(string s, consoleColor clr, consoleColor clr2 = ccDARKWHITE) {
    setConsoleColor(clr);
    cout << s;
    setConsoleColor(clr2);
}

scrapFile(fs::path p) {
    ifstream ws(p.u8string());
    ++fileCnt;
    logg << fileCnt << ": " << p.filename().u8string() << el;
    int lineCnt = 0;

    int bracketLevel = 0;
    char prev = '0';

    string somename = "";
    vector<string> names;

    string basename = "";
    string type = "";
    bool isComment = false;
    bool isImport = false;
    bool inClass = false;
    bool waitBase = false;
    bool waitName = false;
    bool ignoreSpaces = false;

    while (!ws.eof()) {
        getline(ws, line);
        ++lineCnt;
        //if (lineCnt > 5000) break;
        upn(i, 0, (int)line.length() - 1) {
            char cur = line[i];
            if (isComment) {
                if (cur == '/') {
                    if (prev == '*') {
                        /* stop comment */
                        isComment = false;
                    }
                }
            } else {
                if (cur == '/' && prev == '/') {
                    /* comment line */
                    somename = "";
                    break;
                } else if (cur == '*' && prev == '/') {
                    /* start comment */
                    isComment = true;
                    somename = "";
                } else if (isLetter(cur)) {
                    /* letter of useful (or not) name */
                    somename.pb(cur);
                    if (somename == "array") {
                        ignoreSpaces = true;
                    }
                    if (cur == '>') {
                        ignoreSpaces = false;
                    }
                    //logg << "  line " << lineCnt << ": somename+:" << somename << el;
                } else if (cur == '{') {
                    /* level up */
                    //logg << "  line " << lineCnt << ": {!\n";
                    if (waitName && !somename.empty()) {
                        names.pb(somename);
                        somename = "";
                    }
                    if (waitBase && !somename.empty()) {
                        basename = somename;
                        somename = "";
                    }
                    if (!names.empty()) {
                        if (names.size() > 1) {
                            logg << "  line " << lineCnt << ": expected single name for type <" << basename << ">\n";
                        }
                        w3class newClass(names[0]);
                        if (!basename.empty()) {
                            newClass.baseclassName = basename;
                        }
                        newClass.isImported = isImport;
                        newClass.type = type;
                        newClass.log();
                        w3classes.pb(newClass);
                    }
                    waitName = false;
                    waitBase = false;
                    isImport = false;
                    type = "";
                    names.clear();
                    basename = "";
                    somename = "";
                    ++bracketLevel;
                } else if (cur == '}') {
                    /* level down */
                    waitName = false;
                    waitBase = false;
                    somename = "";
                    --bracketLevel;
                    if (bracketLevel == 0)
                        inClass = false;
                } else if (cur == ':') {
                    /* ready for var type */
                    if (!somename.empty() && waitName) {
                        names.pb(somename);
                        somename = "";
                    }
                    if (!names.empty()) {
                        waitBase = true;
                        waitName = false;
                    }
                } else {
                    //logg << "  line " << lineCnt << ": separator!\n";
                    /* any separator char */
                    if (cur == ' ' && ignoreSpaces) {
                        /* array< ILOVESPACES >; */
                        continue;
                    }
                    if (cur == ';') {
                        if (waitBase && !somename.empty()) {
                            basename = somename;
                            somename = "";
                        }
                        /* if it was var, pack */
                        if (inClass && bracketLevel == 1 && !basename.empty() && !names.empty()) {
                            if (!isImport) {
                                upn(ii, 0, (int)names.size() - 1) {
                                    w3classes[(int)w3classes.size() - 1].vars.pb({names[ii], basename});
                                    logg << "  line " << lineCnt << ": Add var <" << names[ii] << ">, type <" << basename << "> to last class\n";
                                }
                            }

                        }
                        names.clear();
                        basename = "";
                        isImport = false;
                        waitBase = false;
                        waitName = false;
                    } else if (somename == "import") {
                        /* import */
                        isImport = true;
                        //logg << "  line " << lineCnt << ": import!\n";
                    } else if (somename == "extends") {
                        /* for class */
                        waitBase = true;
                        waitName = false;
                        //logg << "  line " << lineCnt << ": Extends! waitbase\n";
                    } else if (somename == "enum" || somename == "struct" || somename == "class") {
                        /* start some */
                        waitName = true;
                        waitBase = false;
                        inClass = true;
                        type = somename;
                        //logg << "  line " << lineCnt << ": Class! waitname\n";
                    } else if (somename == "var") {
                        /* start var */
                        waitName = true;
                        waitBase = false;
                        type = "var";
                        //logg << "  line " << lineCnt << ": Var! waitname\n";
                    } else if (waitName && !somename.empty()) {
                        /* add name */
                        names.pb(somename);
                        somename = "";
                        //logg << "  line " << lineCnt << ": addname!\n";
                    } else if (waitBase && !somename.empty()) {
                        basename = somename;
                        somename = "";
                        waitBase = false;
                        //logg << "  line " << lineCnt << ": addbase!\n";
                    } else {
                        if (!basename.empty())
                            logg << "  line " << lineCnt << ": miss somename <" << somename << ">\n";
                    }

                    somename = "";
                }
                prev = line[i];
            }
        }
    }
    logg << "    [OK] " << lineCnt << " lines proceed\n";
}
void writeYml(int idx, string type, bool ifImported = false) {
    if (w3classes[idx].isImported && w3classes[idx].vars.empty()) {
        logg << "Skip writing imported class <" << w3classes[idx].className << ">\n";
        return;
    }
    if (w3classes[idx].type != type || w3classes[idx].isImported != ifImported) {
        return;
    }
    if (w3classes[idx].type == "enum" && w3classes[idx].isImported) { cout << "wtf?" << w3classes[idx].baseclassName << el;}
    yml << "    " << w3classes[idx].className << ":\n";
    if (!w3classes[idx].isImported) {
        yml << "      .extends: " << w3classes[idx].baseclassName << "\n";
    }
    if (!w3classes[idx].vars.empty()) {
        yml << "      .adds:\n";
        upn(j, 0, (int)w3classes[idx].vars.size() - 1) {
            yml << "        " << w3classes[idx].vars[j].X << ": " << w3classes[idx].vars[j].Y << el;
        }
    }
    yml << el;

}
int main(int argv, char** argc)
{
    logg.open("log.txt");
    yml.open("result.yml");
    workDir = fs::current_path().u8string();
    //vanillaDir = workDir / "scripts";
    vanillaDir = workDir / "allscripts.v1.31.ws";
    customDir = workDir / "myscripts";

    if (!fs::exists(vanillaDir)) {
        coutColor("\"scripts\" folder NOT FOUND!\nAborted\n", ccDARKRED);
        system("pause");
        return 0;
    }
	/*for (const auto& dirEntry : fs::recursive_directory_iterator(vanillaDir)) {
        fs::path curPath = dirEntry.path();
        if (curPath.extension() == ".ws") {
            //scrapFile(curPath);
            addFile(curPath);
            cout << "add: " << curPath.filename().u8string() << el;
        }
    }*/
    scrapFile(vanillaDir);
    /*upn(i, 0, (int)w3classes.size() - 1) {
        writeYml(i, "enum", false);
    }*/
    /*upn(i, 0, (int)w3classes.size() - 1) {
        writeYml(i, "struct", true);
    }*/
    /*upn(i, 0, (int)w3classes.size() - 1) {
        writeYml(i, "struct", false);
    }*/
    upn(i, 0, (int)w3classes.size() - 1) {
        writeYml(i, "class", 0);
    }/*
    upn(i, 0, (int)w3classes.size() - 1) {
        writeYmli, "class", true);
    }*/
    yml.close();
    return 0;
}
