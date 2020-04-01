#include <iostream>
#include <fstream>
#include <string>
#include <vector>

#define ll long long
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
#define sfio() freopen("input.txt", "r", stdin); freopen("output.txt", "w", stdout);
#define PI acos(-1.0)
#define eps 0.0000001
#define mod 1000000007
#define mp make_pair

using namespace std;
string fpath, entpath, entname;
string s;
vector<string> res;
bool start = false;
int cnt = 4;

bool isOk(char c) {
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || (c == '_') || (c == ';') || (c == ' '));
}
int main(int argc, char** argv) {
    if (argc < 2 || argc > 3) {
        cout << "\tusage: dumpEffects.exe [path to .w2ent] [optionally: path to .w2ent in game]\n\tExample: dumpEffects.exe triss.w2ent quests/main_npcs\n";
        return 0;
    }
    if (argc > 2) {
        entpath = string(argv[2]);
        upn(i, 0, entpath.length() - 1) {
            if (entpath[i] == '\\') {
                entpath[i] = '/';
            }
        }
        if (entpath.back() != '/')
            entpath.pb('/');
    }
    fpath = string(argv[1]);

    ifstream in(fpath.c_str(), ifstream::in);
    ofstream out("cookedEffects.ws", ofstream::out);

    if (!in.is_open()) {
        cout << "\tERROR! " << fpath << " can not be opened (use absolute or relative path from CURRENT directory)\n";
        return 0;
    }

    dn(i, fpath.length() - 1, 0) {
        if (fpath[i] == '\\' || fpath[i] == '/') {
            break;
        } else {
            entname = fpath[i] + entname;
        }
    }

    out << "/*\n";
    while(!in.eof()) {
        char ch = in.get();
        if (isOk(ch)) {
            s += ch;
        } else if (!s.empty()) {
            if (!start) {
                if (s == "cookedEffects")
                    start = true;
            } else {
                if (s == "cookedEffectsVersion") {
                    break;
                } else {
                    if (cnt)
                        --cnt;
                    else if (s != "buffer" && s != "SharedDataBuffer") {
                        res.pb(s);
                        out << s << "\n";
                    }
                }
            }
            s = "";
        }
    }
    out << "*/\n";
    out << "\nquest function modPlayAllEffects() {\n"
    "\tvar cookedEffects : array<CName>;\n"
    "\tvar  effectsCount : int;\n"
    "\tvar             i : int;\n"
    "\tvar currentEffect : int;\n"
    "\tvar           ent : CEntity;\n"
    "\tvar           pos : Vector;\n"
    "\tvar      template : CEntityTemplate;\n"
    "\t\n"
    "\ttemplate = (CEntityTemplate)LoadResource(\"" << entpath << entname << "\", true);\n"
    "\teffectsCount = " << to_string(res.size()) << ";\n"
    "\tFactsAdd(\"playAllEffectsCount\", 1);\n"
    "\t\n"
    "\t/* DUMPED EFFECTS */\n";
    for (auto t : res) {
        out << "\tcookedEffects.PushBack('" << t << "');\n";
    }
    out << "\n\tcurrentEffect = FactsQuerySum(\"playAllEffectsCount\") - 1;\n"
    "\tif (currentEffect >= effectsCount) {\n"
    "\t\tFactsAdd(\"playAllEffectsStop\", 1);\n"
    "\t\tFactsRemove(\"playAllEffectsCount\");\n"
    "\t\treturn;\n"
    "\t}\n"
    "\tif (currentEffect < 1) {\n"
    "\t\tpos = thePlayer.GetWorldPosition() + VecRingRand(1.f,2.f);\n"
    "\t\tent = (CEntity)theGame.CreateEntity(template, pos);\n"
    "\t\tent.AddTag('playAllEffectsNPC');\n"
    "\t} else {\n"
    "\t\tent = (CEntity)theGame.GetEntityByTag('playAllEffectsNPC');\n"
    "\t}\n"
    "\n"
    "\tent.StopAllEffects();\n"
    "\tif (ent.HasEffect(cookedEffects[currentEffect])) {\n"
    "\t\ttheGame.GetGuiManager().ShowNotification(\"Play effect: [\" + currentEffect + \"] \" + cookedEffects[currentEffect]);\n"
    "\t\tLogQuest(\"<<PlayAllEffects>>> play effect: [\" + currentEffect + \"] \" + cookedEffects[currentEffect]);\n"
    "\t\tent.PlayEffect(cookedEffects[currentEffect]);\n"
    "\t} else {\n"
    "\t\ttheGame.GetGuiManager().ShowNotification(\"Unsupported effect: [\" + currentEffect + \"] \" + cookedEffects[currentEffect]);\n"
    "\t\tLogQuest(\"<<PlayAllEffects>>> unsupported effect: [\" + currentEffect + \"] \" + cookedEffects[currentEffect]);\n"
    "\t}\n"
    "}";
    out.close();
}
