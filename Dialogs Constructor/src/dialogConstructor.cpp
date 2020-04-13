#include <bits/stdc++.h>
#include <dirent.h>
#include <windows.h>

/* unsigned __int128 typed constant. */
#define __C_UINT128(LOW, HIGH) ((((unsigned __int128) (HIGH)) << 32) | ((unsigned __int128) (LOW)))
/* signed __int128 typed constant. */
#define __C_INT128(LOW, HIGH) (signed __int128) (__C_UINT128(LOW, HIGH))

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
#define sfio() freopen("input.txt", "r", stdin); freopen("output.txt", "w", stdout);
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
        dout << k << " have a nice day!\n";
    }*/
}
void coutColor(string s, int type, int next = 7) {
    setConsoleColor(type);
    dout << s;
    setConsoleColor(next);
}
void coutLines(vector<ll>& id, int limit, string highlight, int type, int next = 7) {
    coutColor("\t\tPrint " + to_string(min(limit, (int) id.size())) + " of " + to_string(id.size()) + " suitable dialogs\n", 11);
    for (auto it : id) {
        --limit;
        if (limit < 0) {
            break;
        }
        string get = mapLines[it] + "\n";
        //dout << "get: " << get;
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
            dout << "\t\t" << it << "|" << get.substr(0, pos);
            coutColor(get.substr(pos, highlight.length()), type);
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
        //dout << "commentLine" << el;
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
        //dout << "workPath: [" << workPath << "]" << el;
        return;
    }
    if (s.find(".csv") != string::npos) {
        int pos = s.find(".csv");
        pos += 4;
        string csvPath = s.substr(0, pos);
        //dout << "csvPath: [" << csvPath << "]" << el;
        while (s[pos] == ' ')
            ++pos;
        string csvName = s.substr(pos, s.length() - pos);
        //dout << "csvName: [" << csvName << "]" << el;
        CSVs.pb({csvName, csvPath});
        return;
    }
    int pos = s.find(" ");
    string dirPath = s.substr(0, pos);
    while (s[pos] == ' ')
        ++pos;
    string dirName = s.substr(pos, s.length() - pos);
    //dout << "dirPath: [" << dirPath << "], nameDir: [" << dirName << "]\n";
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
    //dout << "findForest: [" << phrase << "]\n";

    upn(i, 0, phrase.length() - 1) {
        //dout << "PREV! " << prev << " cur: [" << phrase.substr(start, i - start) << "], prev:[" << phrase.substr(start, prev - start) << "]\n";
        if (phrase[i] == ' ') {
            if (!forest[jump].IDs.empty()) {
                foundPrev = forest[jump].IDs;
                prev = i;
            } else {
                jump = 0;
                if (!foundPrev.empty()) {
                    string curPhrase = cutSpaces(phrase.substr(start, prev - start));
                    coutColor("\t[" + curPhrase + "]\n", 10);
                    coutLines(foundPrev, limit, curPhrase, 47);
                    foundPrev.clear();
                    start = prev;
                    i = prev;
                } else {
                    string curPhrase = cutSpaces(phrase.substr(start, i - start));
                    coutColor("\t[" + curPhrase  + "]\n", 4);
                    coutColor("\t\tNot found :(\n", 79);
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
                coutColor("\t[" + curPhrase + "]\n", 10);
                coutLines(foundPrev, limit, curPhrase, 47);
                foundPrev.clear();
                start = prev;
                i = prev;
            } else {
                while (phrase[i] != ' ')
                    ++i;
                string curPhrase = cutSpaces(phrase.substr(start, i - start));
                coutColor("\t[" + curPhrase + "]\n", 4);
                coutColor("\t\tNot found :(\n", 79);
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
        coutColor("\t[" + curPhrase + "]\n", 10);
        coutLines(foundPrev, limit, curPhrase, 47);
        foundPrev.clear();
    } else {
        string curPhrase = cutSpaces(phrase.substr(start, (phrase.length() - 1)- start));
        coutColor("\t" + curPhrase + "\n", 4);
        coutColor("\t\tNot found :(\n", 79);
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
    //dout << "[" << id << "]" << phrase << el;

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
        dout << "\tLoading " << csvName << " wait a second..." << el;
        loadedCsv.pb(csvName);
    }
    ifstream csvIn(csvPath);
    if (!csvIn.is_open()) {
        dout << "\tERROR! Fail to open " << csvPath << ", check path!\n";
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
    dout << "\tLoaded DIR: " << dirName << el;
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
        dout << "ERROR OPENING DIR! Possibly it does not exits? Check path: " << dirPath << "\n";
        return;
    }
    if (dirName == "REMAINING ACTORS") {
        dout << "\tLoading REMAINING ACTORS .csv, wait a second..." << el;
        for (auto csv : dirFiles) {
            string csvPath = dirPath + "\\" + csv;
            loadCsv(csvPath, csv, false);
        }
        loadedCsv.pb("*.csv (REMAINING ACTORS DIALOGS)");
        return;
    }

    int idx = 1;
    for (auto csv : dirFiles) {
        dout << "\t" << idx << " [" << csv << "]\n";
        ++idx;
    }
    int userIdx = idx;
    int maxIdx = idx - 1;
    while (userIdx < 1 || userIdx > maxIdx) {
        dout << "Print number of your choice (1 - " << maxIdx << "): ";
        cin >> userIdx;
    }
    string csvPath = dirPath + "\\" + dirFiles[userIdx - 1];
    loadCsv(csvPath, dirFiles[userIdx - 1]);
}

int main(int argc, char** argv) {
    ifstream conf("dialogConstructor.conf");
    if (!conf.is_open()) {
        dout << "\tError opening dialogConstructor.conf!\n";
        return -1;
    } else {
        while (!conf.eof()) {
            getline(conf, tmp);
            parseConfLine(tmp);
            /*if (conf.eof())
                break;*/
        }
    }
    cout << "+++++ Dialog Constructor v1.0 (@nikich340) +++++\n";
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
        if (loadedCsv.empty()) coutColor("[]", 11);
        for (auto it : loadedCsv) {
            coutColor("[" + it + "] ", 11);
        }
        dout << "---\n";

        for (auto csv : CSVs) {
            dout << "\t" << idx << ": choose " << csv.Y << " [" << csv.X << "]\n";
            ++idx;
        }
        for (auto dir : DIRs) {
            dout << "\t" << idx << ": choose " << dir.Y << " [" << dir.X << "]\n";
            ++idx;
        }
        int userIdx = idx;
        int maxIdx = idx - 1;
        while (userIdx < 1 || userIdx > maxIdx) {
            dout << "\nPrint number of your choice (1 - " << maxIdx << "): ";
            getline(cin, tmp);
            for (auto x : tmp) {
                if (!isdigit(x))
                    break;
            }
            userIdx = 0;
            for (auto x : tmp) {
                userIdx = userIdx * 10 + (x - '0');
            }
        }
        if (userIdx <= CSVs.size()) {
            --userIdx;
            loadCsv(workPath + CSVs[userIdx].Y, CSVs[userIdx].X);
        } else {
            userIdx -= CSVs.size() + 1;
            loadDir(DIRs[userIdx].X, DIRs[userIdx].Y);
        }
        while (true) {
            tmp = "";
            dout << "Your dialog line: ";
            setConsoleColor(6);
            getline(cin, tmp);

            system("cls");
            coutColor("...Print \"!back\" (save loaded) or \"!reset\" to load another actor dialogs...\n", 8);
            dout << "---Loaded dialogs: ";
            if (loadedCsv.empty()) coutColor("[]", 11);
            for (auto it : loadedCsv) {
                coutColor("[" + it + "] ", 11);
            }
            dout << "---\n";

            coutColor("  " + tmp + "\n", 6);
            if (tmp == "")
                continue;
            else if (tmp == "!reset") {
                reset = true;
                break;
            } else if (tmp == "!back") {
                reset = false;
                break;
            } else {
                findForest(tmp);
            }
        }
    }
}
