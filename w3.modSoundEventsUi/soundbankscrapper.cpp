#include <bits/stdc++.h>

#define ll long long
#define ld long double
#define X first
#define Y second
#define upn(x, init, n) for (int x = init; x <= n; ++x)
#define upiter(x, container) for (auto x = container.begin(); x != container.end(); ++x)
#define dn(x, init, n) for(int x = init; x >= n; --x)
#define diter(x, container) for (auto x = container.rbegin(); x != container.rend(); ++x)
#define pb push_back
#define pii pair<int, int>
#define el '\n'
#define sfio() freopen("input.txt", "r", stdin); freopen("output.txt", "w", stdout);
#define print(x, l, r) upn(i, l, r) cout << "x[" << i << "] = " << x[i] << ", "
#define PI acos(-1.0)
#define eps 0.0000001
#define mod 1000000007
#define mod2 1000000033
#define NF string::npos

using namespace std;
struct soundBank {
    string bankName, category;
    vector<string> eventNames;
    void clear() {
        category = "";
        bankName = "";
        eventNames.clear();
    }
};

ifstream in;
ofstream out;
string line;
vector<soundBank> banks;
map<string, vector<int>> idxByCategory;
soundBank curBank;

string strAfter(string s, string sub) {
    int pos = s.find(sub);
    if (pos == NF)
        return s;
    else
        return s.substr(pos + sub.length(), s.length() - (pos + sub.length()));
}
string strBefore(string s, string sub) {
    int pos = s.find(sub);
    if (pos == NF)
        return s;
    else
        return s.substr(0, pos);
}
bool strStartWith(string s, string start) {
    if (start.length() > s.length())
        return false;
    return s.substr(0, start.length()) == start;
}
string strBetween(string before, string s, string after) {
    return strBefore(strAfter(s, before), after);
}
string getCategory(string bnkName) {
    if ( strStartWith(bnkName, "monster") ) {
        return "monsters";
    } else if ( strStartWith(bnkName, "amb") ) {
        return "ambient";
    } else if ( strStartWith(bnkName, "cs") || strStartWith(bnkName, "vs") || strStartWith(bnkName, "vo") ) {
        return "cutscenes";
    } else if ( strStartWith(bnkName, "animal") ) {
        return "animals";
    } else if ( strStartWith(bnkName, "qu") || strStartWith(bnkName, "mq") || strStartWith(bnkName, "mh") || strStartWith(bnkName, "sq") ) {
        return "quests";
    } else if ( strStartWith(bnkName, "music") ) {
        return "music";
    } else if ( strStartWith(bnkName, "sign") ) {
        return "signs";
    } else if ( strStartWith(bnkName, "fx") || strStartWith(bnkName, "magic") || strStartWith(bnkName, "physics") ) {
        return "fx";
    } else if ( strStartWith(bnkName, "work") || strStartWith(bnkName, "grunt") ) {
        return "work";
    } else if ( strStartWith(bnkName, "gui") ) {
        return "gui";
    } else {
        return "uncategorized";
    }
}
void writeCsv() {
    out.open("sound_events_list.csv");
    out.clear();
    ofstream out2("dbg.txt"); out2.clear();

    out << "col0;Cat1;Cat2;Cat3;id;caption\n";
    for (auto it : idxByCategory) {
        for (auto i : it.Y) {
            out2 << banks[i].bankName << " [" << banks[i].eventNames.size() << "]" << "<" << banks[i].category << ">\n";
            upn(j, 0, (int)banks[i].eventNames.size() - 1) {
                out << ";" << banks[i].category << ";" << banks[i].bankName << ";;" << banks[i].bankName << ":" << banks[i].eventNames[j] << ";" << banks[i].eventNames[j] << el;
            }
        }
    }
    /*upn(i, 0, (int)banks.size() - 1) {
        out2 << banks[i].bankName << " [" << banks[i].eventNames.size() << "]" << "<" << banks[i].category << ">\n";
        upn(j, 0, (int)banks[i].eventNames.size() - 1) {
            out << ";" << banks[i].category << ";" << banks[i].bankName << ";;" << banks[i].bankName << ":" << banks[i].eventNames[j] << ";" << banks[i].eventNames[j] << el;
        }
    }*/
    out.close();
}
int main() {
    in.open("soundbanksinfo.xml");
    bool waitEvents = false;
    bool waitBankName = false;

    while (!in.eof()) {
        getline(in, line);
        if (line.find("<SoundBank ") != NF) {
            if (!curBank.eventNames.empty()) {
                curBank.category = getCategory(curBank.bankName);
                banks.pb(curBank);
                idxByCategory[curBank.category].pb((int)banks.size() - 1);
            }
            curBank.clear();
            waitBankName = true;
            waitEvents = false;
        } else if (waitBankName && line.find(".bnk") != NF) {
            curBank.bankName = strBetween("<Path>", line, "</Path>");
            //cout << "bankName: [" << curBank.bankName << "]\n";
            waitBankName = false;
            waitEvents = true;
        } else if (waitEvents && line.find("<Event ") != NF) {
            curBank.eventNames.pb(strBetween("\" Name=\"", line, "\" />"));
            //cout << "    eventName: [" << curBank.eventNames.back() << "]\n";
        }
    }
    if (!curBank.eventNames.empty()) {
        curBank.category = getCategory(curBank.bankName);
        banks.pb(curBank);
        idxByCategory[curBank.category].pb((int)banks.size() - 1);
    }
    cout << banks.size() << el;

    writeCsv();
}
