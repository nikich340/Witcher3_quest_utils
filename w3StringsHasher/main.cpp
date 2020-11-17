#include <bits/stdc++.h>

using namespace std;
string s;
/* thanks rmemr for discovering it! */
int HashKey(string key)
{
    int hashR = 0;
    for(char c: key)
    {
        hashR *= 31;
        hashR += (int)c;
    }
    return hashR;
}
int main()
{
    while (1) {
        cin >> s;
        cout << std::hex << HashKey(s) << endl;
    }
    return 0;
}
