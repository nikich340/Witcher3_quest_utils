#include <bits/stdc++.h>
#include <dirent.h>
#include <windows.h>

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
#define eps 0.0000001
#define mod 1000000007
#define mp make_pair

using namespace std;
class doubleStream {
    public:
        doubleStream() : fileStream("dialogsConstructorLog.txt") {}; // check if opening file succeeded!!
        // for regular output of variables and stuff
        template<typename T> doubleStream& operator<<(const T& data) {
            std::cout << data;
            fileStream << data;
            return *this;
        }
        typedef std::ostream& (*stream_function)(std::ostream&);
        doubleStream& operator<<(stream_function func) {
            func(std::cout);
            func(fileStream);
            return *this;
        }
    private:
        std::ofstream fileStream;
};
doubleStream dout;

bool firstTime = true;
int curType = 0;
int limit = 10;
bool reset = true;
bool idFillZero = true;
/* 0 - default,
   1 - loaded (at least 1) csv and ready to find
   2 - loaded dir and choose csv
*/
string workPath, tmp;
vector<pair<string, string>> CSVs;
vector<pair<string, string>> DIRs;
vector<string> loadedCsv;
map<ll, string> mapLines;
const char startSmall = 'a';
const char startBig = 'A';

bool isalp(char x) {
    return isalpha(x) || (x == '\'');
}
int getCode(char x) {
    if (x == '\'')
        return 27;
    return (x - 'a');
}
string fillWithZeros(ll id) {
    string ret = to_string(id);
    if (idFillZero) {
        int zeroCnt = 10 - ret.length();
        ret = string(zeroCnt, '0') + ret;
    }
    return ret;
}
int to_int(string s) {
    int pos = 0;
    int ret = 0;
    int cnt = 0;
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt;
        ret = ret * 10 + (s[pos] - '0');
        ++pos;
    }
    if (!cnt)
        return - INT_MAX;
    return ret;
}
string normalizePhrase(string phrase) {
    string newPhrase = "";
    bool was = false;
    upn(i, 0, phrase.length() - 1) {
        if (!isalp(phrase[i])) {
            phrase[i] = ' ';
        } else {
            phrase[i] = tolower(phrase[i]);
        }
    }
    upn(i, 0, phrase.length() - 1) {
        if (phrase[i] == ' ') {
            if (!was) {
                newPhrase.pb(' ');
            }
            was = true;
        } else {
            was = false;
            newPhrase.pb(phrase[i]);
        }
    }
    if (!newPhrase.empty() && newPhrase[newPhrase.length() - 1] != ' ')
        newPhrase.pb(' ');
    return newPhrase;
}
void setConsoleColor(int type) {
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), type);
    // you can loop k higher to see more color choices
    /*for(int k = 1; k < 255; k++)    {
    // pick the colorattribute k you want
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), k);
        cout << k << " have a nice day!\n";
    }*/
}
void coutColor(string s, int type, int next = 7) {
    setConsoleColor(type);
    cout << s;
    setConsoleColor(next);
}
void doutColor(string s, int type, int next = 7) {
    setConsoleColor(type);
    dout << s;
    setConsoleColor(next);
}
void coutLines(vector<ll>& id, int limit, string highlight, int type, int next = 7) {
    doutColor("\t\tPrint " + to_string(min(limit, (int) id.size())) + " of " + to_string(id.size()) + " suitable dialogs\n", 11);
    for (auto it : id) {
        --limit;
        if (limit < 0) {
            break;
        }
        string get = mapLines[it] + "\n";
        //cout << "get: " << get;
        int pos = normalizePhrase(get).find(highlight);
        while (pos < get.length() - highlight.length() && tolower(get[pos]) != highlight[0]) {
            ++pos;
        }
        if (highlight.length() > 1) {
            while (pos + 1 < get.length() - highlight.length() && tolower(get[pos + 1]) != highlight[1]) {
                ++pos;
            }
        }

        if (pos != string::npos) {
            dout << "\t\t" << fillWithZeros(it) << "|" << get.substr(0, pos);
            doutColor(get.substr(pos, highlight.length()), type);
            pos += highlight.length();
            dout << get.substr(pos, get.length() - pos);
        }
    }
}
string cutSpaces(string s) {
    if (s.length() > 1 && s[s.length() - 1] == ' ')
        s = s.substr(0, s.length() - 1);

    if (s.length() > 1 && s[0] == ' ')
        s = s.substr(1, s.length() - 1);
    return s;
}

struct branch{
    int go[28] = { 0 };
    vector<ll> IDs;
};
vector<branch> forest;

string deleteFirst(string phrase) {
    int pos = phrase.find(" ");
    if (pos == string::npos)
        return "";
    ++pos;
    return phrase.substr(pos, phrase.length() - pos);
}
void parseConfLine(string s) {
    if (s == "" || s.find("//") != string::npos) {
        //cout << "commentLine" << el;
        return;
    }
    if (s.find("limit") != string::npos) {
        limit = 0;
        int pos = 0;
        while (pos < s.length() && !isdigit(s[pos]))
            ++pos;
        while (pos < s.length() && isdigit(s[pos])) {
            limit = limit * 10 + (s[pos] - '0');
            ++pos;
        }
        return;
    }
    if (s.find(":") != string::npos) {
        workPath = s;
        if (workPath.back() != '\\' && workPath.back() != '/') {
            workPath.pb('\\');
        }
        //cout << "workPath: [" << workPath << "]" << el;
        return;
    }
    if (s.find(".csv") != string::npos) {
        int pos = s.find(".csv");
        pos += 4;
        string csvPath = s.substr(0, pos);
        //cout << "csvPath: [" << csvPath << "]" << el;
        while (s[pos] == ' ')
            ++pos;
        string csvName = s.substr(pos, s.length() - pos);
        //cout << "csvName: [" << csvName << "]" << el;
        CSVs.pb({csvName, csvPath});
        return;
    }
    int pos = s.find(" ");
    string dirPath = s.substr(0, pos);
    while (s[pos] == ' ')
        ++pos;
    string dirName = s.substr(pos, s.length() - pos);
    //cout << "dirPath: [" << dirPath << "], nameDir: [" << dirName << "]\n";
    DIRs.pb({dirName, dirPath});
}

void findForest(string phrase) {
    int jump = 0;
    int start = 0;
    int prev = 0;
    vector<ll> foundPrev;

    phrase = normalizePhrase(phrase);
    if (phrase.find_last_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ") == string::npos) {
        coutColor("\tYour text must contain at least 1 literal ([a - z], [A - Z])!\n", 12);
        return;
    }
    //cout << "findForest: [" << phrase << "]\n";

    upn(i, 0, phrase.length() - 1) {
        //cout << "PREV! " << prev << " cur: [" << phrase.substr(start, i - start) << "], prev:[" << phrase.substr(start, prev - start) << "]\n";
        if (phrase[i] == ' ') {
            if (!forest[jump].IDs.empty()) {
                foundPrev = forest[jump].IDs;
                prev = i;
            } else {
                jump = 0;
                if (!foundPrev.empty()) {
                    string curPhrase = cutSpaces(phrase.substr(start, prev - start));
                    doutColor("\t[" + curPhrase + "]\n", 10);
                    coutLines(foundPrev, limit, curPhrase, 47);
                    foundPrev.clear();
                    start = prev;
                    i = prev;
                } else {
                    string curPhrase = cutSpaces(phrase.substr(start, i - start));
                    doutColor("\t[" + curPhrase  + "]\n", 4);
                    doutColor("\t\tNot found :(\n", 79);
                    start = i;
                    prev = i;
                }
            }
            continue;
        }

        int code = getCode(phrase[i]);
        if (!forest[jump].go[code]) {
            jump = 0;
            if (!foundPrev.empty()) {
                string curPhrase = cutSpaces(phrase.substr(start, prev - start));
                doutColor("\t[" + curPhrase + "]\n", 10);
                coutLines(foundPrev, limit, curPhrase, 47);
                foundPrev.clear();
                start = prev;
                i = prev;
            } else {
                while (phrase[i] != ' ')
                    ++i;
                string curPhrase = cutSpaces(phrase.substr(start, i - start));
                doutColor("\t[" + curPhrase + "]\n", 4);
                doutColor("\t\tNot found :(\n", 79);
                start = i;
                prev = i;
            }
        } else {
            jump = forest[jump].go[code];
        }
    }

    if (start == prev)
        return;
    if (!foundPrev.empty()) {
        string curPhrase = cutSpaces(phrase.substr(start, prev - start));
        doutColor("\t[" + curPhrase + "]\n", 10);
        coutLines(foundPrev, limit, curPhrase, 47);
        foundPrev.clear();
    } else {
        string curPhrase = cutSpaces(phrase.substr(start, (phrase.length() - 1)- start));
        doutColor("\t" + curPhrase + "\n", 4);
        doutColor("\t\tNot found :(\n", 79);
    }
}
void addForest(string phrase, ll id) {
    //charCnt += phrase.length();
    int jump = 0;
    upn(i, 0, phrase.length() - 1) {
        if (phrase[i] == ' ') {
            forest[jump].IDs.pb(id);
            continue;
        }
        //int code = (phrase[i] > 'z' ? (phrase[i] - 'A') : (phrase[i] - 'a'));
        int code = getCode(phrase[i]);
        if (!forest[jump].go[code]) {
            branch newB;
            forest.pb(newB);
            forest[jump].go[code] = forest.size() - 1;
        }
        jump = forest[jump].go[code];
    }
    if (phrase.back() != ' ')
        forest[jump].IDs.pb(id);
}
void addPhrase(string phrase, ll id) {
    //cout << "[" << id << "]" << phrase << el;

    // wrap some strange '...' csv symbols
    upn(i, 0, phrase.length() - 3) {
        if (phrase[i] == -30 && phrase[i + 1] == -128 && phrase[i + 2] == -90) {
            phrase[i] = phrase[i + 1] = phrase[i + 2] = '.';
            i += 2;
        }
    }
    mapLines.insert({id, phrase});
    string newPhrase = normalizePhrase(phrase);

    while (!newPhrase.empty()) {
        addForest(newPhrase, id);

        newPhrase = deleteFirst(newPhrase);
    }
}
void loadCsv(string csvPath, string csvName, bool notify = true) {
    if (notify) {
        cout << "\tLoading " << csvName << " wait a second..." << el;
        loadedCsv.pb(csvName);
    }
    ifstream csvIn(csvPath);
    if (!csvIn.is_open()) {
        cout << "\tERROR! Fail to open " << csvPath << ", check path!\n";
        return;
    }
    string curLine;

    while (!csvIn.eof()) {
        getline(csvIn, curLine);
        if (curLine.find("||") == string::npos)
            continue;
        int pos = 0;
        while (curLine[pos] == ' ')
            ++pos;
        ll id = 0;
        while (isdigit(curLine[pos])) {
            id = id * 10 + (curLine[pos] - '0');
            ++pos;
        }
        pos = curLine.find("||") + 2;
        string phrase = curLine.substr(pos, curLine.length() - pos);

        addPhrase(phrase, id);
    }
    return;
}
void loadDir(string dirName, string dirPath) {
    dirPath = workPath + dirPath;
    cout << "\tLoaded DIR: " << dirName << el;
    DIR *dir;
    struct dirent *ent;
    vector<string> dirFiles;
    if ((dir = opendir (dirPath.c_str())) != NULL) {
        ent = readdir (dir);
        ent = readdir (dir);
        while ((ent = readdir (dir)) != NULL) {
            dirFiles.pb( string(ent->d_name) );
        }
        closedir(dir);
    } else {
        cout << "ERROR OPENING DIR! Possibly it does not exits? Check path: " << dirPath << "\n";
        return;
    }
    if (dirName == "REMAINING ACTORS") {
        cout << "\t1: Load all actors\n\t2: Choose one actor\n";
        cout << "\tPrint number of your choice (1 - 2): ";
        int userIdx = 0;
        while (userIdx < 1 || userIdx > 2) {
            getline(cin, tmp);
            userIdx = to_int(tmp);
        }
        if (userIdx == 1) {
            cout << "\tLoading REMAINING ACTORS .csv, wait a second..." << el;
            for (auto csv : dirFiles) {
                string csvPath = dirPath + "\\" + csv;
                loadCsv(csvPath, csv, false);
            }
            loadedCsv.pb("*.csv (REMAINING ACTORS DIALOGS)");
            return;
        }
    }

    int idx = 1;
    for (auto csv : dirFiles) {
        cout << "\t" << idx << " [" << csv << "]\n";
        ++idx;
    }
    int userIdx = idx;
    int maxIdx = idx - 1;
    while (userIdx < 1 || userIdx > maxIdx) {
        cout << "Print number of your choice (1 - " << maxIdx << "): ";
        cin >> userIdx;
    }
    string csvPath = dirPath + "\\" + dirFiles[userIdx - 1];
    loadCsv(csvPath, dirFiles[userIdx - 1]);
}

int main(int argc, char** argv) {
    ifstream conf("dialogConstructor.conf");
    if (!conf.is_open()) {
        cout << "\tError opening dialogConstructor.conf!\n";
        return -1;
    } else {
        while (!conf.eof()) {
            getline(conf, tmp);
            parseConfLine(tmp);
            /*if (conf.eof())
                break;*/
        }
    }
    cout << "+++++ Dialog Constructor v1.1 (@nikich340) +++++\n";
    coutColor("+++ Tips: 1) search algorithm is case-insensitive and punctuation-insensitive, do not care about it\n"
            "+++       2) apostrophe was saved, so try to use abbreviations (I will -> I'll, we have -> we've and etc)\n"
            "+++       3) algorithm eagerly looking for the longest existing phrase on each iteration and always prefers few longer phrases to many short ones\n"
            "+++       4) you can use \"!back\" command to load more than one actor\n", 14);
    while (true) {
        if (reset) {
            forest.clear();
            branch root;
            forest.pb(root);
            loadedCsv.clear();
        }
        setConsoleColor(7);
        if (!firstTime)
            system("cls");
        firstTime = false;
        int idx = 1;
        dout << "\n---Loaded dialogs: ";
        if (loadedCsv.empty()) doutColor("[]", 11);
        for (auto it : loadedCsv) {
            doutColor("[" + it + "] ", 11);
        }
        dout << "---\n";

        for (auto csv : CSVs) {
            cout << "\t" << idx << ": choose " << csv.Y << " [" << csv.X << "]\n";
            ++idx;
        }
        for (auto dir : DIRs) {
            cout << "\t" << idx << ": choose " << dir.Y << " [" << dir.X << "]\n";
            ++idx;
        }
        cout << "\t\t" << idx << ": fill ID of found dialog lines with zeros (498762|Text... -> 0000498762|Text...), current: [" << (idFillZero ? "Yes" : "No") << "]\n";
        ++idx;
        cout << "\t\t" << idx << ": go to search with current set\n";
        ++idx;
        cout << "\t\t" << idx << ": quit\n";
        ++idx;

        int userIdx = idx;
        int maxIdx = idx - 1;
        while (userIdx < 1 || userIdx > maxIdx) {
            cout << "\nPrint number of your choice (1 - " << maxIdx << "): ";
            getline(cin, tmp);
            userIdx = to_int(tmp);
        }
        if (userIdx == maxIdx) {
            return 0;
        }
        if (userIdx == maxIdx - 2) {
            idFillZero = !idFillZero;
            continue;
        }
        if (userIdx <= CSVs.size()) {
            --userIdx;
            loadCsv(workPath + CSVs[userIdx].Y, CSVs[userIdx].X);
        } else if (userIdx <= CSVs.size() + DIRs.size()) {
            userIdx -= CSVs.size() + 1;
            loadDir(DIRs[userIdx].X, DIRs[userIdx].Y);
        }
        while (true) {
            tmp = "";
            cout << "Your dialog line: ";
            setConsoleColor(6);
            getline(cin, tmp);

            system("cls");
            coutColor("...Print \"!back\" (save loaded) or \"!reset\" to load another actor dialogs...\n", 8);
            cout << "---Loaded dialogs: ";
            if (loadedCsv.empty()) coutColor("[]", 11);
            for (auto it : loadedCsv) {
                coutColor("[" + it + "] ", 11);
            }
            cout << "---\n";

            if (tmp == "")
                continue;
            else if (tmp == "!reset") {
                reset = true;
                break;
            } else if (tmp == "!back") {
                reset = false;
                break;
            } else {
                doutColor("  " + tmp + "\n", 6);
                findForest(tmp);
            }
        }
    }
}
