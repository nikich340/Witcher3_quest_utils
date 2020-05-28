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

string tmp, workPath, fileName;
string labelScene, labelSection, labelShot, labelCamera, labelLastOP;
vector<string> sceneNames, sectionNames, shotNames;
set<string> cameraNames;
map<string, bool> isCameraChanged;
map< string, vector< pair<double, vec3> > > entityPositions;
map< string, pair<double, vec3> > entityPositionLast;
map< double, vector<entityData> > entityPositionsByDist;
vector< pair< float, string > > shotCameras;
camData currentShotCamera;

int sceneNum, sectionNum, shotNum;
YAML::Node shot, root, cameras, storyboard;


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
    if (labelScene != "-")
        cout << labelScene << el;
    if (labelSection != "-")
        cout << "    " << labelSection << el;
    if (labelShot != "-")
        cout << "        " << labelShot << el;
    if (labelCamera != "-")
        cout << "            " << labelCamera << el;
    if (labelCamera != "-" && labelLastOP != "-")
        cout << "    Last change: " << labelLastOP << el;
    cout << el;
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
string getPath() {
    char buffer[1024];
    GetModuleFileName( NULL, buffer, 1024 );
    string ret = string(buffer);
    int pos = ret.find_last_of("\\/");
    if (pos == NF)
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
bool loadSceneYml() {
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
void loadSceneNames() {
    DIR *dir;
    struct dirent *ent;
    if ((dir = opendir(workPath.c_str())) != NULL) {
        while ((ent = readdir (dir)) != NULL) {
            tmp = string(ent->d_name);
            if (tmp.find(".yml") != NF || tmp.find(".yaml") != NF) {
                sceneNames.pb(tmp);
            }
        }
        closedir(dir);
    } else {
        showError("ERROR OPENING DIR! Check path: " + workPath);
        return;
    }
}
bool loadShotNames() {
    labelSection = sectionNames[sectionNum - 1];
    if (storyboard[sectionNames[sectionNum - 1]]) {
        for(YAML::const_iterator it = storyboard[sectionNames[sectionNum - 1]].begin();it != storyboard[sectionNames[sectionNum - 1]].end(); ++it) {
            shotNames.pb(it->first.as<string>());
        }
    } else {
        showError("ERROR GETTINGS SHOTS FROM SECTION [" + sectionNames[sectionNum - 1] + "]!");
        return false;
    }
    return true;
}
void chooseSection() {
    system("cls");
    showInfoLabel();
    cout << "Choose section: \n";
    setConsoleColor(14);
    cout << "    -1. Auto (one by one)\n";
    cout << "    0. Back to scenes\n";
    upn(i, 0, (int)sectionNames.size() - 1) {
        cout << "    " << i + 1 << ". " << sectionNames[i] << el;
    }
    sectionNum = -2;
    setConsoleColor(6);
    while (sectionNum < -1 || sectionNum > (int)sectionNames.size()) {
        cout << "\nYour choice (-1 - " << sectionNames.size() << "): ";
        getline(cin, tmp);
        sectionNum = to_int(tmp);
    }
    setConsoleColor(7);
}
void chooseShot() {
    system("cls");
    showInfoLabel();
    cout << "Shot selection:\n";
    setConsoleColor(11);
    cout << "   -1. Auto (one by one)\n";
    cout << "    0. Back to sections\n";
    upn(i, 0, (int)shotNames.size() - 1) {
        cout << "    " << i + 1 << ". " << shotNames[i] << el;
    }
    shotNum = -2;
    setConsoleColor(6);
    while (shotNum < -1 || shotNum > (int)shotNames.size()) {
        cout << "\nYour choice (-1 - " << shotNames.size() << "): ";
        getline(cin, tmp);
        shotNum = to_int(tmp);
    }
    setConsoleColor(7);
}
void loadShotData() {
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
}
bool loadCameraData(string camName) {
    if (!cameras[camName]) {
        showError("ERROR! No camera " + camName + " in repository!");
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
void saveSceneYml() {
    ifstream inScene(workPath + "/" + fileName);
    ofstream outScene(workPath + "/DOF_" + fileName);
    bool inRepository = false;
    string curCamera = "-";

    while (!inScene.eof()) {
        getline(inScene, tmp);
        if (curCamera != "-" && isCameraChanged[curCamera]) {
            if (tmp.find("cam_") != NF) {
                curCamera = "-";
            } else if (tmp.find("dof:") != NF) {
                outScene << tmp << el;
                outScene << "        blur: " << cameras[curCamera]["dof"]["blur"] << el;
                outScene << "        focus: " << cameras[curCamera]["dof"]["focus"] << el;
                outScene << "        intensity: " << cameras[curCamera]["dof"]["intensity"] << el;
                continue;
            } else if (tmp.find("focus:") != NF ||
                       tmp.find("blur:") != NF ||
                       tmp.find("intensity:") != NF) {
                continue;
            }
        } else if (tmp.find("repository:") != NF) {
            inRepository = true;
        } else if (tmp.find("production:") != NF ||
                   tmp.find("storyboard:") != NF ||
                   tmp.find("dialogscript:") != NF) {
            inRepository = false;
        }
        if (inRepository) {
            for (auto it : cameraNames) {
                if (tmp.find(it) != NF) {
                    curCamera = it;
                    break;
                }
            }
        }

        outScene << tmp << el;
    }
}
void saveCameraData(string camName) {
    cameras[camName]["dof"]["intensity"] = currentShotCamera.intensity;
    cameras[camName]["dof"]["focus"][0] = currentShotCamera.focusNear;
    cameras[camName]["dof"]["focus"][1] = currentShotCamera.focusFar;
    cameras[camName]["dof"]["blur"][0] = currentShotCamera.blurNear;
    cameras[camName]["dof"]["blur"][1] = currentShotCamera.blurFar;
    saveSceneYml();
}
void manageShotDOF() {
    shot.reset();
    shotCameras.clear();
    entityPositions.clear();

    loadShotData();
    if (shotCameras.empty()) {
        showError("No cameras in shot! Nothing to adjust. Skipped");
        return;
    }
    sort(shotCameras.begin(), shotCameras.end());
    bool backk = false;

    upn(i, 0, (int) shotCameras.size() - 1) {
        system("cls");
        labelCamera = "[" + to_string(shotCameras[i].X) + ", " + shotCameras[i].Y + "]";
        labelLastOP = "-";
        if (isCameraChanged[shotCameras[i].Y]) {
            setConsoleColor(10);
            cout << "Adjust DOF for camera: " << labelCamera << " ?\n";
            cout << "   Warning: camera was already changed before (probably in another shot)\n";
            cout << "    n(0). Skip\n";
            cout << "    y(1). Adjust\n";
            tmp = "-";
            setConsoleColor(6);
            while (tmp.find("y") == NF && tmp.find("n") == NF) {
                cout << "\nYour choice (y, n, 0, 1): ";
                getline(cin, tmp);
                if (to_int(tmp) == 0)
                    tmp = "n";
                if (to_int(tmp) == 1)
                    tmp = "y";
            }
            setConsoleColor(7);
            if (tmp.find("y") == NF)
                continue;
        }

        entityPositionsByDist.clear();
        if (!loadCameraData(shotCameras[i].Y)) {
            continue;
        }
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
                tempData.timing = - 1.0;
                tempData.pos = it->Y.Y;
                entityPositionsByDist[dd].pb( tempData );
            }
        }

        while (1) {
            system("cls");
            showInfoLabel();
            setConsoleColor(12);
            cout << "<Info for current camera>\n    <was changed in this session>: " << (isCameraChanged[shotCameras[i].Y] ? "Yes" : "No") << el;
            cout << "    fov: " << currentShotCamera.fov << "\n";
            cout << "    pos: [" << currentShotCamera.pos.x << ", " << currentShotCamera.pos.y << ", " << currentShotCamera.pos.z << "]\n";
            cout << "    dof:\n        blur: [" << currentShotCamera.blurNear << ", " << currentShotCamera.blurFar << "]\n";
            cout << "        focus: [" << currentShotCamera.focusNear << ", " << currentShotCamera.focusFar << "]\n";
            cout << "        intensity: " << currentShotCamera.intensity << "\n\n";

            setConsoleColor(13);
            cout << "<Entity distances from current camera>\n(for all current shot placement, "
                    "or if there is no any for some entity - for last placement from previous shots, without timing)\n\n";

            setConsoleColor(9);
            cout << "       -4. Adjust DOF blur for current focus\n";
            cout << "       -3. Set DOF intensity\n";
            cout << "       -2. Set blur distances manually\n";
            cout << "       -1. Set focus distances manually\n";
            cout << "        0. Save + next camera\n";
            cout << "     save. Save current camera settings\n";
            cout << "     next. Next camera in shot\n";
            cout << "     back. Back to shots\n";
            setConsoleColor(3);

            int maxEntIdx = 0;
            vector<double> distByIdx;

            for (auto it = entityPositionsByDist.begin(); it != entityPositionsByDist.end(); ++it) {
                upn(j, 0, (int) it->Y.size() - 1) {
                    ++maxEntIdx;
                    distByIdx.pb(it->X);
                    cout << fixed << "        " << maxEntIdx << ". Distance from cam: " << fixedStr(it->X, 12);
                    if (it->Y[j].timing > -eps) {
                        cout << ", timing: " << fixedStr(it->Y[j].timing, 5);
                    } else {
                        cout << "               ";
                    }
                    cout << ", name: " << it->Y[j].name << "\n";
                }
            }

            pair<int, int> entNum ={ -10, -10 };
            setConsoleColor(6);
            while (entNum.X < -5 || entNum.Y > maxEntIdx || (entNum.X > entNum.Y)) {
                cout << "\nYour choice (pair num1 - num2 or single -4, -3, -2, -1, 0, save, next, back): ";
                getline(cin, tmp);
                if (tmp.find("save") != NF || tmp.find("next") != NF || tmp.find("back") != NF) {
                    break;
                }
                entNum = to_pairInt(tmp);
            }
            if (tmp.find("save") != NF) {
                saveCameraData(shotCameras[i].Y);
                labelLastOP = "Saved!";
                continue;
            } else if (tmp.find("next") != NF) {
                break;
            } else if (tmp.find("back") != NF) {
                backk = true;
                break;
            }  else if (entNum.X == -4) {
                if (currentShotCamera.focusNear < 2.0) {
                    currentShotCamera.blurNear = currentShotCamera.focusNear + 0.5;
                } else {
                    currentShotCamera.blurNear = currentShotCamera.focusNear - 1.0;
                }
                currentShotCamera.blurFar = currentShotCamera.focusFar + 2.0;
                isCameraChanged[shotCameras[i].Y] = true;
                labelLastOP = "set DOF blur to [" + to_string(currentShotCamera.blurNear) + ", " + to_string(currentShotCamera.blurFar) + "]";
            } else if (entNum.X == -3) {
                double customIntensity = -1.0;
                while (customIntensity < 0.0 || customIntensity > 1.0) {
                    cout << "\tInput dof intensity (float in range [0.0 - 1.0]): ";
                    getline(cin, tmp);
                    customIntensity = to_double(tmp);
                }
                currentShotCamera.intensity = customIntensity;
                isCameraChanged[shotCameras[i].Y] = true;
                labelLastOP = "set DOF intensity to " + to_string(customIntensity);
            } else if (entNum.X == -2) {
                double customBlurNear = -1.0, customBlurFar = -1.0;

                while (customBlurNear < 0.0) {
                    cout << "\tInput near blur distance (float in range [0.0 - ...]): ";
                    getline(cin, tmp);
                    customBlurNear = to_double(tmp);
                }
                while (customBlurFar < customBlurNear) {
                    cout << "\tInput far focus distance (float in range [" << customBlurNear << " - ...]): ";
                    getline(cin, tmp);
                    customBlurFar = to_double(tmp);
                }
                currentShotCamera.blurNear = customBlurNear;
                currentShotCamera.blurFar = customBlurFar;
                isCameraChanged[shotCameras[i].Y] = true;
                labelLastOP = "set DOF blur to [" + to_string(customBlurNear) + ", " + to_string(customBlurFar) + "]";
            } else if (entNum.X == -1) {
                double customFocusNear = -1.0, customFocusFar = -1.0;

                while (customFocusNear < 0.0) {
                    cout << "\tInput near focus distance (float in range [0.0 - ...]): ";
                    getline(cin, tmp);
                    customFocusNear = to_double(tmp);
                }
                while (customFocusFar < customFocusNear) {
                    cout << "\tInput far focus distance (float in range [" << customFocusNear << " - ...]): ";
                    getline(cin, tmp);
                    customFocusFar = to_double(tmp);
                }
                currentShotCamera.focusNear = customFocusNear;
                currentShotCamera.focusFar = customFocusFar;
                isCameraChanged[shotCameras[i].Y] = true;
                labelLastOP = "set DOF focus to [" + to_string(customFocusNear) + ", " + to_string(customFocusFar) + "]";
            } else if (!entNum.X) {
                saveCameraData(shotCameras[i].Y);
                break;
            } else {
                currentShotCamera.focusNear = distByIdx[entNum.X - 1] - 0.5;
                currentShotCamera.focusFar = distByIdx[entNum.Y - 1] + 0.5;

                /* still use rmemr's hack, no way to find "aperture" or "hyperfocal" dist for
                virtual game camera */
                if (currentShotCamera.focusNear < 2.0) {
                    currentShotCamera.blurNear = currentShotCamera.focusNear + 0.5;
                } else {
                    currentShotCamera.blurNear = currentShotCamera.focusNear - 1.0;
                }
                currentShotCamera.blurFar = currentShotCamera.focusFar + 2.0;
                isCameraChanged[shotCameras[i].Y] = true;
                labelLastOP = "set DOF focus to [" + to_string(currentShotCamera.focusNear) + ", " + to_string(currentShotCamera.focusFar) + "]";
            }
        }
        if (backk)
            break;
    }
    labelCamera = "-";
    labelLastOP = "-";
	labelShot = "-";
}
void manageShots() {
    shotNames.clear();
    if (!loadShotNames()) {
        return;
    }
    while (1) {
        chooseShot();
        if (shotNum == 0)
            break;
        if (shotNum == -1) {
            upn(i, 1, (int)shotNames.size()) {
                shotNum = i;
                manageShotDOF();
            }
            continue;
        }
        manageShotDOF();
    }
    labelSection = "-";
}
int main()
{
    cout.precision(5);
    labelCamera = labelLastOP = labelScene = labelSection = labelShot = "-";
    workPath = getPath();
    loadSceneNames();
    while (1) {
        system("cls");
    	cout << "Scene selection: \n";
    	cout << "    0. Quit\n";
        upn(i, 0, (int)sceneNames.size() - 1) {
            cout << "    " << i + 1 << ". " << sceneNames[i] << el;
        }
        sceneNum = -2;
        setConsoleColor(6);
        while (sceneNum < 0 || sceneNum > (int)sceneNames.size()) {
            cout << "Your choice (1 - " << sceneNames.size() << "): ";
        	getline(cin, tmp);
        	sceneNum = to_int(tmp);
        }
        if (!sceneNum)
            return 0;
        setConsoleColor(7);
        labelScene = sceneNames[sceneNum - 1];
        cout << "    Loading " << labelScene << "...\n";
        fileName = labelScene;
        if (loadSceneYml()) {
            while (1) {
                chooseSection();
                if (sectionNum == 0)
                    break;
                if (sectionNum == -1) {
                    upn(i, 1, (int)sectionNames.size()) {
                        sectionNum = i;
                        manageShots();
                    }
                    continue;
                }
                manageShots();
            }
        }
    }
    return 0;
}
