#include <iostream>
#include <fstream>
#include <string>
#include <set>
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
vector<string> cookedEffectsNames;
set<string> notEffectNames;
bool start = false;
int cnt = 4;

bool isOk(char c) {
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || (c == '_') || (c == ';') || (c == ' '));
}
bool isEffectName(string t) {
	bool onlyDigits = true;
	for (auto c : t) {
		if (!isdigit(c)) {
			onlyDigits = false;
			break;
		}
	}
	if (onlyDigits || notEffectNames.find(s) != notEffectNames.end()) {
		return false;
	}
	return true;
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
    if (!in.is_open()) {
        cout << "\tERROR! " << fpath << " can not be opened (use absolute or relative path from CURRENT directory)\n";
        return 0;
    }

    /*dn(i, fpath.length() - 1, 0) {
        if (fpath[i] == '\\' || fpath[i] == '/') {
            break;
        } else {
            entname = fpath[i] + entname;
        }
    }*/
    //fpath = fpath.substr(0, fpath.length() - entname.length());
    //fpath += "cookedEffects.ws";

    ofstream out("entityEffects.csv", ofstream::out | ofstream::app);

    notEffectNames.insert("SharedDataBuffer");
    notEffectNames.insert("buffer");
    notEffectNames.insert("name");
    notEffectNames.insert("array");
    notEffectNames.insert("CEntityTemplateCookedEffect");

    while(!in.eof()) {
        char ch = in.get();
        if (isOk(ch)) {
            s += ch;
        } else if (!s.empty()) {
            if (!start) {
                if (s == "cookedEffects")
                    start = true;
            } else {
            	//cout << "? [" << s << "]\n";
                if (s == "cookedEffectsVersion") {
                    break;
                } else {
                    if (isEffectName(s)) {
                        cookedEffectsNames.pb(s);
                    }
                }
            }
            s = "";
        }
    }
    if (cookedEffectsNames.empty()) {
        cout << "Finished! EMPTY effects data!\n";
        out.close();
        return 0;
    }
    out << fpath << "	";// << (int)cookedEffectsNames.size();
    for (auto eff : cookedEffectsNames) {
        out << "	effectNames.PushBack(\'" << eff << "\');\n";
    }
    out << el;
    out.close();
    cout << "Finished! Effects extracted: " << (int)cookedEffectsNames.size();
}
