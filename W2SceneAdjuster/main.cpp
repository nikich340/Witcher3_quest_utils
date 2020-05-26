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
  static Node encode(const vec3& rhs) {
    Node node;
    node.push_back(rhs.x);
    node.push_back(rhs.y);
    node.push_back(rhs.z);
    return node;
  }

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

struct camData {
    vec3 pos;
    double fov;
    double blurNear, blurFar;
    double focusNear, focusFar;
    double intensity;
};
struct entityData {
    double timing;
    std::string name;
    vec3 pos;
};

using namespace std;

string tmp, workPath;
vector<string> sceneNames, sectionNames, shotNames;
set<string> cameraNames;
map< string, vector< pair<double, vec3> > > entityPositions;
map< string, pair<double, vec3> > entityPositionLast;
map< double, vector<entityData> > entityPositionsByDist;
vector< pair< float, string > > shotCameras;
camData currentShotCamera;

int sceneNum, sectionNum, shotNum;
YAML::Node shot, root, cameras, storyboard;

void debugNode(YAML::Node& node) {
    switch (node.Type()) {
        case YAML::NodeType::Null: cout << "Null\n"; break;
        case YAML::NodeType::Scalar: cout << "Scalar\n"; break;
        case YAML::NodeType::Sequence: cout << "Sequence\n"; break;
        case YAML::NodeType::Map: cout << "Map\n"; break;
        case YAML::NodeType::Undefined: cout << "Undefined\n"; break;
    }
}
string getPath() {
    char buffer[1024];
    GetModuleFileName( NULL, buffer, 1024 );
    string ret = string(buffer);
    int pos = ret.find_last_of("\\/");
    if (pos == string::npos)
        pos = ret.length() - 1;
    return ret.substr(0, pos);
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
bool loadSceneYml(string fileName) {
	root = YAML::LoadFile(workPath + "/" + fileName);
	if (root["repository"]["cameras"]) {
        cameras = root["repository"]["cameras"];
        for(YAML::const_iterator it = cameras.begin();it != cameras.end(); ++it) {
            //cout << "CamName: [" << it->first.as<string>() << "]\n";
            cameraNames.insert(it->first.as<string>());
        }
    } else {
    	cout << "\tNo cameras in repository found!\n";
    	return false;
    }
    if (root["storyboard"]) {
        storyboard = root["storyboard"];
        for(YAML::const_iterator it = storyboard.begin();it != storyboard.end(); ++it) {
            tmp = it->first.as<string>();
            if (tmp.find("section_") != string::npos) {
                sectionNames.pb(it->first.as<string>());
            }
        }
    } else {
    	cout << "\tNo storyboard found!\n";
    	return false;
    }
    return true;
}
void loadSceneNames() {
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir(workPath.c_str())) != NULL) {
        while ((ent = readdir (dir)) != NULL) {
            tmp = string(ent->d_name);
            if (tmp.find(".yml") != string::npos) {
                sceneNames.pb(tmp);
            }
        }
        closedir(dir);
    } else {
        cout << "ERROR OPENING DIR! Check path: " + workPath + "\n";
        return;
    }
}
bool loadShotNames() {
    if (storyboard[sectionNames[sectionNum - 1]]) {
        for(YAML::const_iterator it = storyboard[sectionNames[sectionNum - 1]].begin();it != storyboard[sectionNames[sectionNum - 1]].end(); ++it) {
            cout << "!shotName: [" << it->first.as<string>() << "]\n";
            shotNames.pb(it->first.as<string>());
        }
    } else {
        cout << "ERROR GETTINGS SHOTS FROM SECTION [" << sectionNames[sectionNum - 1] << "]!\n";
        return false;
    }
    return true;
}
void chooseSection() {
    system("cls");
    cout << "Choose section: \n";
    cout << "\t-1. Save and Back\n";
    cout << "\t0. Auto (one by one)\n";
    upn(i, 0, (int)sectionNames.size() - 1) {
        cout << "\t" << i + 1 << ". " << sectionNames[i] << el;
    }
    sectionNum = -2;
    while (sectionNum < -1 || sectionNum > (int)sectionNames.size()) {
        getline(cin, tmp);
        sectionNum = to_int(tmp);
    }
}
void chooseShot() {
    system("cls");
    cout << "Choose shot: \n";
    cout << "\t-1. Save and Back\n";
    cout << "\t0. Auto (one by one)\n";
    upn(i, 0, (int)shotNames.size() - 1) {
        cout << "\t" << i + 1 << ". " << shotNames[i] << el;
    }
    shotNum = -2;
    while (shotNum < -1 || shotNum > (int)shotNames.size()) {
        getline(cin, tmp);
        shotNum = to_int(tmp);
    }
}
void loadShotData() {
    shot = storyboard[ sectionNames[sectionNum - 1] ][ shotNames[shotNum - 1] ];

    upn(i, 0, (int) shot.size() - 1) {
        YAML::Node tempNode = shot[i];
        for(YAML::const_iterator it = tempNode.begin();it != tempNode.end(); ++it) {
            tmp = it->first.as<string>();
            if (tmp.find("cam") != string::npos) {
                YAML::Node tempCamSeq = it->second;
                if (!tempCamSeq.IsSequence() || tempCamSeq.size() < 2) {
                    cout << "WRONG (or advanced..) CAMERA DEFINITION found! Skipped\n";
                } else {
                    tmp = tempCamSeq[1].as<string>();
                    if (cameraNames.find(tmp) == cameraNames.end()) {
                        cout << "Camera [" << tmp << "] NOT FOUND IN REPOSITORY! Skipped\n";
                    } else {
                        shotCameras.pb({tempCamSeq[0].as<double>(), tmp});
                    }
                }
            }
            if (tmp.find("actor.placement") != string::npos || tmp.find("prop.placement") != string::npos) {
                YAML::Node tempPlacementSeq = it->second;
                if (!tempPlacementSeq.IsSequence() || tempPlacementSeq.size() < 4) {
                    cout << "WRONG (or advanced..) PLACEMENT DEFINITION found! Skipped\n";
                } else {
                    double timing = tempPlacementSeq[0].as<double>();
                    string entity = tempPlacementSeq[1].as<string>();
                    vec3 pos = tempPlacementSeq[2].as<vec3>();
                    if (timing < 0.0 || timing > 1.0) {
                        cout << "WRONG TIMING (<0.0 or >1.0) PLACEMENT DEFINITION found! Skipped\n";
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
}
bool loadCameraData(string camName) {
    if (!cameras[camName]) {
        cout << "ERROR! No camera " << camName << " in repository!\n";
        return false;
    }
    camData tempData;
    tempData.fov = cameras[camName]["fov"].as<double>();
    tempData.pos = cameras[camName]["transform"]["pos"].as<vec3>();
    if (cameras[camName]["dof"]["blur"]) {
        tempData.blurNear = cameras[camName]["dof"]["blur"][0].as<double>();
        tempData.blurFar = cameras[camName]["dof"]["blur"][1].as<double>();
    } else {
        tempData.blurNear = -1.0;
        tempData.blurFar = -1.0;
    }
    if (cameras[camName]["dof"]["focus"]) {
        tempData.focusNear = cameras[camName]["dof"]["focus"][0].as<double>();
        tempData.focusFar = cameras[camName]["dof"]["focus"][1].as<double>();
    } else {
        tempData.focusNear = -1.0;
        tempData.focusFar = -1.0;
    }
    if (cameras[camName]["dof"]["intensity"]) {
        tempData.intensity = cameras[camName]["dof"]["intensity"].as<double>();
    } else {
        tempData.intensity = 0.0;
    }
    currentShotCamera = tempData;
    return true;
}
void manageShotDOF() {
    shot.reset();
    shotCameras.clear();
    entityPositions.clear();

    loadShotData();
    sort(shotCameras.begin(), shotCameras.end());

    upn(i, 0, (int) shotCameras.size() - 1) {
        system("cls");
        cout << "Adjust DOF for camera: [" << shotCameras[i].X << ", " << shotCameras[i].Y << "] ?\n";
        cout << "\t0. Skip\n";
        cout << "\t1. Adjust\n";
        int selectNum = -2;
        while (selectNum < 0 || selectNum > 1) {
            cout << "\tYour choice (0 - 1): ";
            getline(cin, tmp);
            selectNum = to_int(tmp);
        }
        if (!selectNum)
            continue;
        entityPositionsByDist.clear();
        if (!loadCameraData(shotCameras[i].Y)) {
            system("pause");
            continue;
        }
        cout << "<Info for current camera>\n    fov: " << currentShotCamera.fov << "\n";
        cout << "    pos: [" << currentShotCamera.pos.x << ", " << currentShotCamera.pos.y << ", " << currentShotCamera.pos.z << "]\n";
        cout << "    dof:\n        blur: [" << currentShotCamera.blurNear << ", " << currentShotCamera.blurFar << "]\n";
        cout << "        focus: [" << currentShotCamera.focusNear << ", " << currentShotCamera.focusFar << "]\n";
        cout << "        intensity: " << currentShotCamera.intensity << "\n";

        cout << "<Entity distances from current camera>\n(for all current shot placement, "
                "or if there is no any for some entity - for last placement from previous shots, they have timing -3.333)\n";
        for (auto it = entityPositions.begin(); it != entityPositions.end(); ++it) {
            upn(j, 0, (int) it->Y.size() - 1) {
                double dd = dist(currentShotCamera.pos, it->Y[j].Y);
                entityData tempData;
                tempData.name = it->X;
                tempData.timing = it->Y[j].X;
                tempData.pos = it->Y[j].Y;
                entityPositionsByDist[dd].pb( tempData );
            }
        }
        for (auto it = entityPositionLast.begin(); it != entityPositionLast.end(); ++it) {
            if (entityPositions.count(it->X) < 1) {
                double dd = dist(currentShotCamera.pos, it->Y.Y);
                entityData tempData;
                tempData.name = it->X;
                tempData.timing = - 3.333;
                tempData.pos = it->Y.Y;
                entityPositionsByDist[dd].pb( tempData );
            }
        }

        int maxEntIdx = 0;
        vector<double> distByIdx;
        for (auto it = entityPositionsByDist.begin(); it != entityPositionsByDist.end(); ++it) {
            upn(j, 0, (int) it->Y.size() - 1) {
                ++maxEntIdx;
                distByIdx.pb(it->X);
                cout << fixed << "\t" << maxEntIdx << ". Distance from cam: " << it->X << ", timing: " << it->Y[j].timing << ", name: " << it->Y[j].name << "\n";
            }
        }
        system("pause");
    }
    system("pause");
}
void manageShots() {
    shotNames.clear();
    if (!loadShotNames()) {
        return;
    }
    while (1) {
        chooseShot();
        if (shotNum == -1)
            break;
        if (!shotNum) {
            upn(i, 1, (int)shotNames.size()) {
                shotNum = i;
                manageShotDOF();
            }
        }
        manageShotDOF();
    }
}
int main()
{
    cout.precision(5);
    workPath = getPath();
    loadSceneNames();
    while (1) {
        system("cls");
    	cout << "Choose scene: \n";
        upn(i, 0, (int)sceneNames.size() - 1) {
            cout << "\t" << i + 1 << ". " << sceneNames[i] << el;
        }
        sceneNum = -2;
        while (sceneNum < 1 || sceneNum > (int)sceneNames.size()) {
        	getline(cin, tmp);
        	sceneNum = to_int(tmp);
        }
        cout << "\tLoading " << sceneNames[sceneNum - 1] << "...\n";
        if (loadSceneYml(sceneNames[sceneNum - 1])) {
            while (1) {
                chooseSection();
                if (sectionNum == -1)
                    break;
                if (!sectionNum) {
                    upn(i, 1, (int)sectionNames.size()) {
                        sectionNum = i;
                        manageShots();
                    }
                }
                manageShots();
            }
        } else {
        	cout << "\tLoad rejected!\n";
        }
    }
    return 0;
}
