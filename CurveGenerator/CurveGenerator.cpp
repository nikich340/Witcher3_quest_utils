#include <bits/stdc++.h>
#include <dirent.h>
#include <windows.h>
#include <yaml-cpp/yaml.h>

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

struct vec3 {
	double x, y, z;

	vec3(const vec3& a) {
		x = a.x;
		y = a.y;
		z = a.z;
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
};
double sq(double d) {
    double ret = d * d;
    return ret;
}
double dist(const vec3& rhs, const vec3& lhs) {
    double diff = sq(rhs.x - lhs.x) + sq(rhs.y - lhs.y) + sq(rhs.z - lhs.z);
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
namespace YAML {
template<>
struct convert<vec3> {
  /*static Node encode(const vec3& rhs) {
    Node node;
    node.push_back(rhs.x);
    node.push_back(rhs.y);
    node.push_back(rhs.z);
    return node;
  }*/

  static bool decode(const Node& node, vec3& rhs) {
    if (!node.IsSequence() || node.size() != 3) {
      return false;
    }

    rhs.x = node[0].as<double>();
    rhs.y = node[1].as<double>();
    rhs.z = node[2].as<double>();
    return true;
  }
};
}

using namespace std;

const int rveTypeL = 3, rveTypeR = 3;
const float scaleX = 1.0, scaleY = 1.0, scaleZ = 1.0;
YAML::Node root;
vector<vec3> poss, rots;
string tmp;
int step = 0;

string ps() {
    string ret = "";
    upn(i, 1, step) {
        ret += "  ";
    }
    return ret;
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
void showInfoLabel() {
    setConsoleColor(2);
    setConsoleColor(7);
}
void showError(string err) {
    setConsoleColor(4);
    cout << err << el;
    setConsoleColor(7);
    system("pause");
}
void coutColor(string s, int type, int next = 7) {
    setConsoleColor(type);
    cout << s;
    setConsoleColor(next);
}
string fixedStr(string s, int width) {
    while (s.length() < width)
        s.pb(' ');
    s = s.substr(0, width);
    return s;
}
string fixedStr(double d, int width) {
    string s = to_string(d);
    return fixedStr(s, width);
}
void debugNode(YAML::Node& node) {
    switch (node.Type()) {
        case YAML::NodeType::Null: cout << "Null\n"; break;
        case YAML::NodeType::Scalar: cout << "Scalar\n"; break;
        case YAML::NodeType::Sequence: cout << "Sequence\n"; break;
        case YAML::NodeType::Map: cout << "Map\n"; break;
        case YAML::NodeType::Undefined: cout << "Undefined\n"; break;
    }
}
int to_int(string s) {
    int pos = 0;
    int ret = 0;
    int cnt = 0;
    bool positive = true;
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    if (s[pos] == '-') {
        positive = false;
        ++pos;
    }
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt;
        if (cnt > 9)
            return - INT_MAX;
        ret = ret * 10 + (s[pos] - '0');
        ++pos;
    }
    if (!cnt)
        return - INT_MAX;
    return (positive ? ret : -ret);
}
double to_double(string s) {
    int pos = 0;
    double retPREF = 0;
    double retSUFF = 0;
    int cnt = 0;
    int cnt2 = 0;
    bool positive = true;
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    if (s[pos] == '-') {
        positive = false;
        ++pos;
    }
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt;
        retPREF = retPREF * 10.0 + (double)(s[pos] - '0');
        ++pos;
    }
    if (s[pos] == '.') {
        ++pos;
    } else {
        if (!cnt)
            return -999;
        else
            return (positive ? retPREF : -retPREF);
    }
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt2;
        retSUFF = retSUFF * 10.0 + (double)(s[pos] - '0');
        ++pos;
    }
    if (!cnt && !cnt2)
        return -999;

    while (retSUFF >= 1.0)
        retSUFF /= 10.0;
    retPREF = retPREF + retSUFF;
    return (positive ? retPREF : -retPREF);
}
pair<int, int> to_pairInt(string s) {
    int pos = 0;
    int ret = 0;
    int cnt = 0;
    bool positive = true;
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    if (s[pos] == '-') {
        positive = false;
        ++pos;
    }
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt;
        if (cnt > 9)
            return {-INT_MAX, INT_MAX};
        ret = ret * 10 + (s[pos] - '0');
        ++pos;
    }
    if (!cnt)
        return {-INT_MAX, INT_MAX};

    if (!positive)
        ret = -ret;

    int ret2 = 0;
    int cnt2 = 0;
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    if (s[pos] == '-') {
        ++pos;
    } else {
        return {ret, ret};
    }
    while (pos < s.length() && isspace(s[pos]))
        ++pos;
    while (pos < s.length() && isdigit(s[pos])) {
        ++cnt2;
        if (cnt > 9) {
            ret2 = ret;
            break;
        }
        ret2 = ret2 * 10 + (s[pos] - '0');
        ++pos;
    }

    if (!cnt2)
        ret2 = ret;

    return {ret, ret2};
}
/*bool loadSceneYml() {
	root = YAML::LoadFile(workPath + "/" + fileName);
	if (root["repository"]["cameras"]) {
        cameras = root["repository"]["cameras"];
        for(YAML::const_iterator it = cameras.begin();it != cameras.end(); ++it) {
            //cout << "CamName: [" << it->first.as<string>() << "]\n";
            cameraNames.insert(it->first.as<string>());
        }
    } else {
    	showError("No cameras in repository found!");
    	return false;
    }
    if (root["storyboard"]) {
        storyboard = root["storyboard"];
        for(YAML::const_iterator it = storyboard.begin();it != storyboard.end(); ++it) {
            tmp = it->first.as<string>();
            if (tmp.find("section_") != NF) {
                sectionNames.pb(it->first.as<string>());
            }
        }
    } else {
    	showError("No storyboard found!");
    	return false;
    }
    return true;
}
*/
/*void loadShotData() {
    labelShot = shotNames[shotNum - 1];
    shot = storyboard[ sectionNames[sectionNum - 1] ][ shotNames[shotNum - 1] ];

    upn(i, 0, (int) shot.size() - 1) {
        YAML::Node tempNode = shot[i];
        for(YAML::const_iterator it = tempNode.begin();it != tempNode.end(); ++it) {
            tmp = it->first.as<string>();
            if (tmp.find("cam") != NF) {
                YAML::Node tempCamSeq = it->second;
                if (!tempCamSeq.IsSequence() || tempCamSeq.size() < 2) {
                    showError("WRONG (or advanced..) CAMERA DEFINITION found! Skipped");
                } else {
                    tmp = tempCamSeq[1].as<string>();
                    if (cameraNames.find(tmp) == cameraNames.end()) {
                        showError("Camera [" + tmp + "] NOT FOUND IN REPOSITORY! Skipped");
                    } else {
                        shotCameras.pb({tempCamSeq[0].as<double>(), tmp});
                    }
                }
            }
            if (tmp.find("actor.placement") != NF || tmp.find("prop.placement") != NF) {
                YAML::Node tempPlacementSeq = it->second;
                if (!tempPlacementSeq.IsSequence() || tempPlacementSeq.size() < 4) {
                    showError("WRONG (or advanced..) PLACEMENT DEFINITION found! Skipped");
                } else {
                    double timing = tempPlacementSeq[0].as<double>();
                    string entity = tempPlacementSeq[1].as<string>();
                    vec3 pos = tempPlacementSeq[2].as<vec3>();
                    if (timing < 0.0 || timing > 1.0) {
                        showError("WRONG TIMING (<0.0 or >1.0) PLACEMENT DEFINITION found! Skipped");
                        continue;
                    }
                    entityPositions[entity].pb({timing, pos});
                    if (entityPositionLast.count(entity) < 1 || timing > entityPositionLast[entity].X) {
                        entityPositionLast[entity] = {timing, pos};
                    }
                }
            }
        }
    }
}*/
void loadPoints() {
    root = YAML::LoadFile("points.yml");
    for(YAML::const_iterator it = root.begin();it != root.end(); ++it) {
        tmp = it->first.as<string>();
        if (root[tmp]["pos"]) {
            vec3 vecTmp = root[tmp]["pos"].as<vec3>();
            coutColor("Loaded pos for point " + tmp + "!\n", 6);
            poss.pb(vecTmp);
            if (root[tmp]["rot"]) {
                vec3 vecTmp = root[tmp]["rot"].as<vec3>();
                coutColor("Loaded rot for point " + tmp + "!\n", 6);
                rots.pb(vecTmp);
            } else {
                rots.pb(vec3());
            }
        } else {
            showError("Missing pos for " + tmp + ", skipped!\n");
        }
    }
}
void printCurve() {
    ofstream out("curve.yml");
    out.precision(3);
    out << "curve:\n";
    ++step;
    out << fixed << ps() << "\".type\": SMultiCurve\n";
    out << ps() << "type: ECurveType_EngineTransform\n";
    out << ps() << "showFlags: SHOW_AnimatedProperties\n";
    out << ps() << "enableAutomaticTimeByDistanceRecalculation: true\n";
    out << ps() << "curves:\n";
    ++step;
    /* X */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << poss[i].x << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* Y */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << poss[i].y << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* Z */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << poss[i].z << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* pitch */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << rots[i].x << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* yaw */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << rots[i].y << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* roll */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << rots[i].z << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* scaleX */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << scaleX << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* scaleY */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << scaleY << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }

    /* scaleZ */
    {
        out << ps() << "- \".type\": SCurveData\n";
        ++step;
        out << ps() << "Curve Values:\n";
        ++step;
        upn(i, 0, (int) poss.size() - 1) {
            out << ps() << "- \".type\": SCurveDataEntry\n";
            ++step;
            out << ps() << "me: " << (i * 1.0) / (double) (poss.size() - 1) << el;
            out << ps() << "ntrolPoint: [ -0.1, 0.0, 0.1, 0.0 ]\n";
            out << ps() << "lue: " << scaleZ << el;
            out << ps() << "rveTypeL: " << rveTypeL << el;
            out << ps() << "rveTypeL: " << rveTypeR << el;
            --step;
        }
        --step;
        out << ps() << "value type: CVT_Float\n";
        out << ps() << "type: CT_Smooth\n";
        out << ps() << "is looped: false\n";
        --step;
    }
    --step;
    out << ps() << "initialParentTransform:\n";
    ++step;
    out << ps() << "pos: [ 0.0, 0.0, 0.0 ]\n";
    --step;
    out << ps() << "hasInitialParentTransform: false\n";

    out << el;
    out.close();
    coutColor("Done!\n", 2);
}
int main()
{
    loadPoints();
    printCurve();
    system("pause");
    return 0;
}
