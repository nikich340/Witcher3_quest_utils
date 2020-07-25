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
#define eps 0.000000001
#define mod 1000000007
#define mp make_pair
#define NF string::npos

using namespace std;
int N, print_cnt = 0;
string name, templatee;
vector<string> tags;
double stepDist;
double curDist, totalDist = 0.0;
string s, tmp;
std::stringstream ss;
ofstream out;

struct vec3 {
	double x, y, z;

	vec3(const vec3& a) {
		x = a.x;
		y = a.y;
		z = a.z;
	}
	vec3(double xx, double yy, double zz) {
		x = xx;
		y = yy;
		z = zz;
	}
	vec3() {
		x = 0.0;
		y = 0.0;
		z = 0.0;
	}
	vec3& operator=(vec3 const& rhs) {
        if (this != &rhs) {
            x = rhs.x;
            y = rhs.y;
            z = rhs.z;
        }
        return *this;
    }
    vec3& operator+=(vec3 const& rhs) {
        x += rhs.x;
        y += rhs.y;
        z += rhs.z;
        return *this;
    }
    vec3& operator-=(vec3 const& rhs) {
        x -= rhs.x;
        y -= rhs.y;
        z -= rhs.z;
        return *this;
    }
    friend ostream& operator<<(ostream& os, const vec3& v);
};
double sq(double d) {
    double ret = d * d;
    return ret;
}
double dist(const vec3& rhs, const vec3& lhs) {
    double diff = sq(rhs.x - lhs.x) + sq(rhs.y - lhs.y) + sq(rhs.z - lhs.z);
    return sqrt(diff);
}
double distXY(const vec3& rhs, const vec3& lhs) {
    double diff = sq(rhs.x - lhs.x) + sq(rhs.y - lhs.y);
    return sqrt(diff);
}
bool operator==(const vec3& rhs, const vec3& lhs) {
    return (std::abs(rhs.x - lhs.x) < eps) && (std::abs(rhs.y - lhs.y) < eps) && (std::abs(rhs.z - lhs.z) < eps);
}
vec3 operator+(const vec3 lhs, const vec3 rhs) {
    vec3 tmp(lhs);
    tmp += rhs;
    return tmp;
}
vec3 operator-(const vec3 lhs, const vec3 rhs) {
    vec3 tmp(lhs);
    tmp -= rhs;
    return tmp;
}
bool operator!=(vec3 const& lhs, vec3 const& rhs) {
  return !(lhs == rhs);
}
istream& operator>>(istream& is, vec3& v) {
    is >> v.x >> v.y >> v.z;
    return is;
}
ostream& operator<<(ostream& os, const vec3& v)
{
    os << "[ " << v.x << ", " << v.y << ", " << v.z << " ]";
    //os << "[ " << v.x << ", " << v.z << ", " << v.y << " ]";
    return os;
}

vector<vec3> poss;
vector<vec3> rots;
void loadTracks() {
    ifstream in("tracks.txt");
    while (!in.eof()) {
        getline(in, tmp);
        if (tmp.find("nikich340_hack") != NF) {
            ss.clear();

            vec3 pos, rot;
            ss << tmp;
            ss >> tmp >> pos >> rot;
            swap(rot.y, rot.z);
            //cout << poss.size() << ": " << pos << rot << el;
            poss.pb(pos);
            rots.pb(rot);
        }
    }
}
string fillZeros(int a, int cnt) {
    string s = to_string(a);
    while (s.length() < cnt) {
        s = "0" + s;
    }
    return s;
}
void print(int idx) {
    ++print_cnt;
    out << "      " << name << fillZeros(print_cnt, 3) << ":\n";
    out << "        template: \"" << templatee << "\"\n";
    out << "        tags: [ ";
    upn(j, 0, (int) tags.size() - 1) {
        if (j > 0)
            out << ", ";
        out << "\"" << tags[j] << "\"";
    }
    out << " ]\n";
    out << "        pos: " << poss[idx] << el;
    out << "        rot: " << rots[idx] << el << el;
}
int main()
{
    out.open("result_layer.yml");
    out.clear();
    out.precision(5);
    out << std::fixed;
    loadTracks();
    N = (int)poss.size();

    stepDist = 1.0;
    name = "orianna_footprints_gen_";
    //templatee = "W3MonsterClue:quests\\\\part_2\\\\quest_files\\\\q206_berserkers\\\\clues\\\\q206_arnvalds_horse_track.w2ent";
    templatee = "W3MonsterClue:dlc\\\\bob\\\\data\\\\quests\\\\main_quests\\\\quest_files\\\\q703_all_for_one\\\\entities\\\\q703_clue_dirt_footprints.w2ent";
    tags.pb("ntr_orianna_footprints_to_house");

    print(0);
    upn(i, 1, N - 2) {
        curDist = distXY(poss[i], poss[i + 1]);
        totalDist += curDist;
        if (totalDist >= stepDist) {
            print(i + 1);
            totalDist = 0.0;
        }
    }
    //cout << "totalDist: " << totalDist << el;
    cout << "Wrote " << print_cnt << " tracks\n";
    cout << "Done!\n";
    out.close();
    system("pause");
    return 0;
}
