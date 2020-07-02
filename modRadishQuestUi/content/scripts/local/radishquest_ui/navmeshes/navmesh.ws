// ----------------------------------------------------------------------------
struct SRadUiVertexInfo {
    var edges: array<SRadUiEdge>;
    var triangles: array<int>;
}
// ----------------------------------------------------------------------------
class CRadishNavMesh extends IRadishQuestSelectableElement {
    // ------------------------------------------------------------------------
    protected var settings: SRadishNavMeshData;
    // ------------------------------------------------------------------------
    protected var id: String;
    protected var caption: String;
    // ------------------------------------------------------------------------
    protected var placement: SRadishPlacement;
    // ------------------------------------------------------------------------
    protected var proxy: CRadUiNavMeshProxy;
    // ------------------------------------------------------------------------
    private var meshVertex: CRadishNavMeshVertex;
    private var selectedVertex: int; default selectedVertex = -1;
    private var selectedTriangleId: int; default selectedTriangleId = -1;
    private var selectedTriangle: SRadUiTriangle;
    // ------------------------------------------------------------------------
    public function init(id: String, newPlacement: SRadishPlacement) {
        // init settings before call to initProxy (in init)
        settings.vertices.Clear();
        settings.vertices.PushBack(newPlacement.pos + Vector(0.0, 0.0, 0.0));
        settings.vertices.PushBack(newPlacement.pos + Vector(1.0, 0.0, 0.0));
        settings.vertices.PushBack(newPlacement.pos + Vector(0.0, 2.0, 0.0));
        settings.vertices.PushBack(newPlacement.pos + Vector(1.0, 2.0, 0.0));

        settings.triangles.Clear();
        settings.triangles.PushBack(SRadUiTriangle(0, 1, 2));
        settings.triangles.PushBack(SRadUiTriangle(1, 3, 2));

        settings.phantomBorder.Clear();

        placement = newPlacement;

        settings.id = id;
        settings.placement = newPlacement;

        initFromData(settings);
    }
    // ------------------------------------------------------------------------
    protected function initProxy() {
        proxy = new CRadUiNavMeshProxy in this;
        proxy.init("-", placement, false);

        // not strictly a proxy but a thin wrapper which gets passed around to
        // interactive placement mode (and auto syncs with this area)
        initMeshVertex();
    }
    // ------------------------------------------------------------------------
    public function initFromData(data: SRadishNavMeshData) {
        placement = data.placement;

        initProxy();
        setSettings(data);
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        proxy.destroy();
    }
    // ------------------------------------------------------------------------
    // naming
    // ------------------------------------------------------------------------
    public function getId() : String {
        return id;
    }
    // ------------------------------------------------------------------------
    public function getCaption() : String {
        return caption;
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var mergedCaption: String;

        mergedCaption = caption + " [" + settings.triangles.Size() + "]";

        if (proxy.isVisible()) {
            return "v " + mergedCaption;
        } else {
            return ". " + mergedCaption;
        }
    }
    // ------------------------------------------------------------------------
    public function setId(newName: String) {
        this.id = RadUi_escapeAsId(newName);
        caption = StrReplaceAll(id, "_", " ");
    }
    // ------------------------------------------------------------------------
    // visibility
    // ------------------------------------------------------------------------
    public function getProxy() : IRadishBaseProxyRepresentation {
        return this.proxy;
    }
    // ------------------------------------------------------------------------
    public function toggleVisibility() {
        this.proxy.toggleVisibility();
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        proxy.show(doShow);
    }
    // ------------------------------------------------------------------------
    public function highlight(doHighlight: bool) {
        proxy.highlight(doHighlight);
    }
    // ------------------------------------------------------------------------
    public function refreshRepresentation() {
        proxy.moveTo(placement);
    }
    // ------------------------------------------------------------------------
    public function setAppearance(id: name) {
        proxy.setAppearance(id);
        updateAppearanceSetting(proxy.getAppearance());
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {
        proxy.cycleAppearance();
        updateAppearanceSetting(proxy.getAppearance());
    }
    // ------------------------------------------------------------------------
    // visualization properties
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return placement;
    }
    // ------------------------------------------------------------------------
    public function setPlacement(newPlacement: SRadishPlacement) {
        var diffPos: Vector;
        var i, s: int;

        diffPos = newPlacement.pos - placement.pos;

        settings.placement = newPlacement;
        s = settings.vertices.Size();
        for (i = 0; i < s; i += 1) {
            settings.vertices[i] += diffPos;
        }
        placement = newPlacement;

        proxy.moveTo(placement);
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        //FIXME
        var meshSize: Vector;

        meshSize = proxy.getSize();
        if (meshSize.X > 0.5f || meshSize.Y > 0.5f || meshSize.Z > 0.5f) {
            return meshSize;
        } else {
            return Vector();
        }
    }
    // ------------------------------------------------------------------------
    // settings
    // ------------------------------------------------------------------------
    public function getSettings() : SRadishNavMeshData {
        settings.id = id;
        // this has to be updated as base class contains the current placement data
        settings.placement = placement;
        return settings;
    }
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishNavMeshData) {
        settings = newSettings;
        placement = settings.placement;
        setId(settings.id);

        refreshPrecalculatedData();
        proxy.setSettings(settings, borderEdges);
    }
    // ------------------------------------------------------------------------
    protected function updateAppearanceSetting(id: name) {
        settings.appearance = id;
    }
    // ------------------------------------------------------------------------
    // precalculated data to ensure sane iteration ordering
    // ------------------------------------------------------------------------
    private var vertexInfo: array<SRadUiVertexInfo>;
    // vertex 1 -> vertex 2
    private var borderEdges: array<int>;
    private var vertexOrder: array<int>;
    // ------------------------------------------------------------------------
    private function precalculatedDataAddEdge(
        vertex1: int, vertex2: int, edges: array<SRadUiEdge>) : array<SRadUiEdge>
    {
        var foundEdge: bool;
        var e: int;

        foundEdge = false;
        for (e = 0; e < edges.Size(); e += 1) {
            if ((edges[e].a == vertex2 && edges[e].b == vertex1)
                || (edges[e].a == vertex1 && edges[e].b == vertex2)) {

                edges[e].adjacentTriangles += 1;

                return edges;
            }
        }
        edges.PushBack(SRadUiEdge(vertex1, vertex2, 1));

        return edges;
    }
    // ------------------------------------------------------------------------
    protected function refreshPrecalculatedData() {
        var vertexId, e, i, v, t, length: int;
        var currentVertex, borderEndVertex: int;

        var edges: array<SRadUiEdge>;
        var info: SRadUiVertexInfo;
        var triangle: SRadUiTriangle;
        var edge: SRadUiEdge;
        var newPhantomEdges: array<SRadUiEdge>;

        var a,b,c: int;

        vertexInfo.Clear();
        vertexOrder.Clear();
        borderEdges.Clear();

        // -- preinit array for all vertices to have a simple lut
        v = settings.vertices.Size();
        for (i = 0; i < v; i += 1) {
            vertexInfo.PushBack(SRadUiVertexInfo());
            borderEdges.PushBack(-1);
        }

        // -- first pass: assign edges and triangles to vertex lut
        t = settings.triangles.Size();
        for (i = 0; i < t; i += 1) {
            triangle = settings.triangles[i];

            vertexInfo[triangle.a].triangles.PushBack(i);
            vertexInfo[triangle.b].triangles.PushBack(i);
            vertexInfo[triangle.c].triangles.PushBack(i);

            // always attach edge to info of the smaller vertex id
            // edge 1: a -> b
            if (triangle.a < triangle.b) {
                vertexId = triangle.a;
            } else {
                vertexId = triangle.b;
            }
            vertexInfo[vertexId].edges = precalculatedDataAddEdge(
                triangle.a, triangle.b, vertexInfo[vertexId].edges);

            // edge 2: b -> c
            if (triangle.b < triangle.c) {
                vertexId = triangle.b;
            } else {
                vertexId = triangle.c;
            }
            vertexInfo[vertexId].edges = precalculatedDataAddEdge(
                triangle.b, triangle.c, vertexInfo[vertexId].edges);

            // edge 3: c -> a
            if (triangle.c < triangle.a) {
                vertexId = triangle.c;
            } else {
                vertexId = triangle.a;
            }
            vertexInfo[vertexId].edges = precalculatedDataAddEdge(
                triangle.c, triangle.a, vertexInfo[vertexId].edges);
        }

        // -- partition into border edges and inner edges
        borderEndVertex = -1;
        for (i = 0; i < v; i += 1) {
            edges = vertexInfo[i].edges;

            for (e = 0; e < edges.Size(); e += 1) {
                if (edges[e].adjacentTriangles == 1) {
                    borderEdges[edges[e].a] = edges[e].b;
                    borderEndVertex = edges[e].b;
                }
            }
        }

        // -- order vertices as connected border edge sequence
        if (borderEndVertex > -1) {
            // precaution guard for unexpected meshes: border length < vertex count
            length = 0;

            currentVertex = borderEndVertex;
            vertexOrder.PushBack(currentVertex);
            while (borderEdges[currentVertex] != borderEndVertex && length < v && currentVertex > -1) {
                currentVertex = borderEdges[currentVertex];
                vertexOrder.PushBack(currentVertex);
                length += 1;
            }
        } else {
            LogChannel('ERROR', "navmesh: failed to extract border edges!");
        }

        // TODO sort *inner* vertices by absolute coordinates (?)
        // -- add inner vertices to end
        for (i = 0; i < v; i += 1) {
            if (borderEdges[i] == -1) {
                vertexOrder.PushBack(i);
            }
        }
        // update mergeable border edges in settings as some edges may not be a border anymore
        v = settings.phantomBorder.Size();
        newPhantomEdges.Clear();
        for (i = 0; i < v; i += 1) {
            edge = settings.phantomBorder[i];

            if (borderEdges[edge.a] == edge.b || borderEdges[edge.b] == edge.a) {
                newPhantomEdges.PushBack(edge);
            }
        }
        settings.phantomBorder = newPhantomEdges;
    }
    // ------------------------------------------------------------------------
    // settings editing (text input)
    // ------------------------------------------------------------------------
    public function addUiSettings(settingsList: CRadishUiSettingsList) {
        var i, vertexId: int;

        // vertex order is already partitioned into inner and border edges
        for (i = 0; i < vertexOrder.Size(); i += 1) {
            vertexId = vertexOrder[i];

            if (borderEdges[vertexId] == -1) {
                // inner edge
                settingsList.addSetting(
                    "vi" + i,
                    "#" + (i + 1) + ": " + UiSettingVecToString(settings.vertices[vertexId]),
                    "inner vertices");
            } else {
                // border edge
                settingsList.addSetting(
                    "vb" + i,
                    "#" + (i + 1) + ": " + UiSettingVecToString(settings.vertices[vertexId]),
                    "border vertices");
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getVertexUiSettingId(vertexId: int) : String {
        var i, s: int;
        s = settings.vertices.Size();

        if (vertexId >= 0 && vertexId < s) {
            for (i = 0; i < s; i += 1) {
                if (vertexOrder[i] == vertexId) {
                    if (borderEdges[vertexId] == -1) {
                        return "vi" + i;
                    } else {
                        return "vb" + i;
                    }
                }
            }
        }
        return "-";
    }
    // ------------------------------------------------------------------------
    public function getAsUiSetting(selectedId: String) : IModUiSetting {
        var null: IModUiSetting;
        var vertexSlot: int;

        vertexSlot = extractVertexSlot(selectedId);
        if (vertexSlot >= 0) {
            return VecToUiSetting(this, settings.vertices[vertexOrder[vertexSlot]]);
        }
        return null;
    }
    // ------------------------------------------------------------------------
    public function syncSetting(id: String, settingValue: IModUiSetting) {
        var vertexSlot: int;

        vertexSlot = extractVertexSlot(id);
        if (vertexSlot >= 0) {
            settings.vertices[vertexOrder[vertexSlot]] = UiSettingToVector(settingValue);
        }
    }
    // ------------------------------------------------------------------------
    public function extractVertexSlot(id: String) : int {
        if (StrBeginsWith(id, "v")) {
            return StringToInt(StrRight(id, StrLen(id) - 2), 1);
        } else {
            return -1;
        }
    }
    // ------------------------------------------------------------------------
    public function isInnerVertexSelected() : bool {
        return borderEdges[selectedVertex] == -1;
    }
    // ------------------------------------------------------------------------
    public function isInnerVertexSlot(vertexSlot: int) : bool {
        if (vertexSlot >= 0 && vertexSlot < vertexOrder.Size()) {
            return borderEdges[vertexOrder[vertexSlot]] == -1;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    public function getFirstInnerVertexSlot() : int {
        var i, s: int;

        s = vertexOrder.Size();

        for (i = 0; i < s; i += 1) {
            if (borderEdges[vertexOrder[i]] == -1) {
                return i;
            }
        }
        return -1;
    }
    // ------------------------------------------------------------------------
    // vertex manipulation
    // ------------------------------------------------------------------------
    protected function initMeshVertex() {
        meshVertex = new CRadishNavMeshVertex in this;
        meshVertex.init(this);
        meshVertex.show(false);
    }
    // ------------------------------------------------------------------------
    public function getVertexCount() : int {
        return settings.vertices.Size();
    }
    // ------------------------------------------------------------------------
    protected function selectVertexbyId(vertexId: int) {
        var nextVertex, thirdVertex: int;
        var info: SRadUiVertexInfo;
        var i: int;
        var triangle: SRadUiTriangle;

        if (vertexId >= 0 && vertexId < settings.vertices.Size()) {
            selectedVertex = vertexId;

            info = vertexInfo[selectedVertex];

            if (borderEdges[selectedVertex] == -1) {
                // inner edge
                // select first edge
                selectedTriangleId = info.triangles[0];
                triangle = settings.triangles[selectedTriangleId];
                if (triangle.a == selectedVertex) {
                    nextVertex = triangle.b;
                    thirdVertex = triangle.c;
                } else if (triangle.b == selectedVertex) {
                    nextVertex = triangle.c;
                    thirdVertex = triangle.a;
                } else {
                    nextVertex = triangle.a;
                    thirdVertex = triangle.b;
                }
            } else {
                // prefer border triangle
                nextVertex = borderEdges[selectedVertex];

                // find triangle with edge (selectedVertex -> nextVertex) and extract
                // third vertex
                for (i = 0; i < info.triangles.Size(); i += 1) {
                    selectedTriangleId = info.triangles[i];
                    triangle = settings.triangles[selectedTriangleId];

                    // all these triangles are adjacent and thus have selectedVertex as vertex
                    // find the one which also contains nextVertex (the other border vertex)
                    if (triangle.a == nextVertex) {
                        if (triangle.b == selectedVertex) {
                            thirdVertex = triangle.c;
                        } else {
                            thirdVertex = triangle.b;
                        }
                        break;
                    } else if (triangle.b == nextVertex) {
                        if (triangle.a == selectedVertex) {
                            thirdVertex = triangle.c;
                        } else {
                            thirdVertex = triangle.a;
                        }
                        break;
                    } else if (triangle.c == nextVertex) {
                        if (triangle.a == selectedVertex) {
                            thirdVertex = triangle.b;
                        } else {
                            thirdVertex = triangle.a;
                        }
                        break;
                    }
                }
            }
            // this does NOT necessary equal the triangle definition used in settings
            // as the order is different: first is selected, followed by current edge
            selectedTriangle = SRadUiTriangle(selectedVertex, nextVertex, thirdVertex);

            meshVertex.initWithVertexData(
                settings.vertices[selectedVertex],
                settings.vertices[nextVertex],
                settings.vertices[thirdVertex]);

            proxy.preselectVertexEntities(selectedVertex);

            meshVertex.show(true);
        } else {
            // just hide the vertex
            meshVertex.show(false);
            selectedTriangleId = -1;
            selectedVertex = -1;
        }
    }
    // ------------------------------------------------------------------------
    public function selectVertexBySlot(vertexSlot: int) {
        if (vertexSlot >= 0 && vertexSlot < vertexOrder.Size()) {
            selectVertexbyId(vertexOrder[vertexSlot]);
        } else {
            selectVertexbyId(-1);
        }
    }
    // ------------------------------------------------------------------------
    public function selectVertexByType(innerVertex: bool) : int {
        var i, s: int;
        if (innerVertex) {
            for (i = 0; i < vertexOrder.Size(); i += 1) {
                if (borderEdges[vertexOrder[i]] == -1) {
                    selectVertexbyId(vertexOrder[i]);
                    break;
                }
                // no inner verex was selected if none was found
            }
        } else {
            // first in vertexOrder should always be a border vertex
            selectVertexbyId(vertexOrder[0]);
        }
        return selectedVertex;
    }
    // ------------------------------------------------------------------------
    public function getSelectedVertex() : CRadishNavMeshVertex {
        return meshVertex;
    }
    // ------------------------------------------------------------------------
    public function syncSelectedVertexPos(newPlacement: Vector) {
        settings.vertices[selectedVertex] = newPlacement;
        proxy.syncSelectedVertexPosition(newPlacement);
    }
    // ------------------------------------------------------------------------
    // vertex management
    // ------------------------------------------------------------------------
    public function cycleEdge() {
        var nextVertex, thirdVertex: int;
        var info: SRadUiVertexInfo;
        var i, s: int;
        var triangle: SRadUiTriangle;
        // pick the next triangle
        if (selectedTriangleId > -1) {
            info = vertexInfo[selectedVertex];
            s = info.triangles.Size();
            for (i = 0; i < s; i += 1) {
                if (selectedTriangleId == info.triangles[i]) {
                    break;
                }
            }
            selectedTriangleId = info.triangles[(i + 1) % s];
            triangle = settings.triangles[selectedTriangleId];

            // pick next and third index
            if (triangle.a == selectedVertex) {
                nextVertex = triangle.b;
                thirdVertex = triangle.c;
            } else if (triangle.b == selectedVertex) {
                nextVertex = triangle.c;
                thirdVertex = triangle.a;
            } else {
                nextVertex = triangle.a;
                thirdVertex = triangle.b;
            }
            // this does NOT necessary equal the triangle definition used in settings
            // as the order is different: first is selected, followed by current edge
            selectedTriangle = SRadUiTriangle(selectedVertex, nextVertex, thirdVertex);

            meshVertex.initWithVertexData(
                settings.vertices[selectedVertex],
                settings.vertices[nextVertex],
                settings.vertices[thirdVertex]);
        }
    }
    // ------------------------------------------------------------------------
    public function toggleSelectedEdgeType() : int {
        var newType, slot: int;
        var edge: SRadUiEdge;

        if (borderEdges[selectedVertex] != -1 && borderEdges[selectedTriangle.b] != -1) {
            // is border edge
            edge = SRadUiEdge(selectedVertex, selectedTriangle.b);

            // update settings
            slot = settings.phantomBorder.FindFirst(edge);
            if (slot == -1) {
                slot = settings.phantomBorder.FindFirst(SRadUiEdge(edge.b, edge.a));
            }
            if (slot == -1) {
                // upgrade to phantom edge
                settings.phantomBorder.PushBack(edge);
                newType = 2;
            } else {
                // downgrade to normal border
                settings.phantomBorder.Erase(slot);
                newType = 1;
            }
            // update proxy
            proxy.updateEdgeType(edge, newType);

            return newType;
        }
        return -1;
    }
    // ------------------------------------------------------------------------
    private function splitTriangle(
        triangleId: int, vertexId1: int, vertexId2: int, newVertexId: int)
    {
        var triangle: SRadUiTriangle;
        var thirdVertexId: int;
        var updatedTriangle, newTriangle: SRadUiTriangle;

        triangle = settings.triangles[triangleId];

        // depending on the (base) edge direction of the triangle the updated and
        // new triangle are created differently
        if (triangle.a == vertexId1 && triangle.b == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.a, newVertexId, triangle.c);
            newTriangle = SRadUiTriangle(newVertexId, triangle.b, triangle.c);

        } else if (triangle.b == vertexId1 && triangle.c == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.b, newVertexId, triangle.a);
            newTriangle = SRadUiTriangle(newVertexId, triangle.c, triangle.a);

        } else if (triangle.c == vertexId1 && triangle.a == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.c, newVertexId, triangle.b);
            newTriangle = SRadUiTriangle(newVertexId, triangle.a, triangle.b);

        } else if (triangle.a == vertexId1 && triangle.c == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.a, triangle.b, newVertexId);
            newTriangle = SRadUiTriangle(newVertexId, triangle.b, triangle.c);

        } else if (triangle.c == vertexId1 && triangle.b == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.c, triangle.a, newVertexId);
            newTriangle = SRadUiTriangle(newVertexId, triangle.a, triangle.b);

        } else if (triangle.b == vertexId1 && triangle.a == vertexId2) {

            updatedTriangle = SRadUiTriangle(triangle.b, triangle.c, newVertexId);
            newTriangle = SRadUiTriangle(newVertexId, triangle.c, triangle.a);

        } else {
            LogChannel('ERROR', "splittriangle failed. this should not have happened!");
        }

        settings.triangles[triangleId] = updatedTriangle;
        settings.triangles.PushBack(newTriangle);
    }
    // ------------------------------------------------------------------------
    public function addVertex() : int {
        var info: SRadUiVertexInfo;
        var isBorderEdge: bool;
        var i, nextVertex, thirdVertex, newVertexId: int;
        var A, B, C, newVertex: Vector;
        var triangle, newTriangle: SRadUiTriangle;

        // adding a new vertex boils down to splitting currently selected edge.
        // there are two different cases:
        // 1. splitting border edge (easy)
        //    - requires adding one new triangle (new vertex outside the mesh!)
        //    - no modification of existing triangles/edges
        // 2. splitting inner edge (more difficult)
        //    - requires splitting both adjacent triangles
        //    -> two new triangles, two modified triangle

        if (selectedTriangleId < 0 || selectedTriangleId >= settings.triangles.Size()) {
            return -1;
        }

        // -- check if selected edge is a border or an inner edge
        nextVertex = selectedTriangle.b;

        isBorderEdge = (borderEdges[selectedVertex] == nextVertex || borderEdges[nextVertex] == selectedVertex);

        if (isBorderEdge) {
            thirdVertex = selectedTriangle.c;
            // calculate new vertex in opposite direction to third vertex of current triangle
            A = settings.vertices[selectedVertex];
            B = settings.vertices[nextVertex];
            C = settings.vertices[thirdVertex];

            newVertex = A + 0.5 * (B - A) - (C - B);

            // add new vertex and new triangle to settings
            newVertexId = settings.vertices.Size();
            newTriangle = SRadUiTriangle(selectedVertex, newVertexId, nextVertex);
            settings.vertices.PushBack(newVertex);
            settings.triangles.PushBack(newTriangle);

            // if selected edge is a phantom edge then both new edges will be phantom edges, too
            if (settings.phantomBorder.Remove(SRadUiEdge(selectedVertex, nextVertex))
                || settings.phantomBorder.Remove(SRadUiEdge(nextVertex, selectedVertex)))
            {
                settings.phantomBorder.PushBack(SRadUiEdge(selectedVertex, newVertexId));
                settings.phantomBorder.PushBack(SRadUiEdge(newVertexId, nextVertex));
            }

            // update precalculated data
            refreshPrecalculatedData();

            // update proxy
            proxy.addNewBorderTriangle(newVertex, newTriangle);

            // select new vertex
            selectVertexbyId(newVertexId);
        } else {
            // calculate new vertex (middle of the edge)
            A = settings.vertices[selectedVertex];
            B = settings.vertices[nextVertex];
            newVertex = A + 0.5 * (B - A);

            // add new vertex
            newVertexId = settings.vertices.Size();
            settings.vertices.PushBack(newVertex);

            // find both adjacent triangles
            info = vertexInfo[selectedVertex];

            for (i = 0; i < info.triangles.Size(); i += 1) {
                triangle = settings.triangles[info.triangles[i]];
                if ((info.triangles[i] == selectedTriangleId)
                    || (triangle.a == nextVertex || triangle.b == nextVertex || triangle.c == nextVertex))
                {
                    splitTriangle(info.triangles[i], selectedVertex, nextVertex, newVertexId);
                }
            }

            // update precalculated data
            refreshPrecalculatedData();

            // respawn proxy completely (keep it simple)
            proxy.setSettings(settings, borderEdges);

            // select new vertex
            selectVertexbyId(newVertexId);
        }
        return newVertexId;
    }
    // ------------------------------------------------------------------------
    public function isSelectedVertexDeletable() : bool {
        var info: SRadUiVertexInfo;
        var isBorder: bool;

        info = vertexInfo[selectedVertex];
        isBorder = borderEdges[selectedVertex] != -1;

        if (isBorder) {
            // merge only simple cases (outer vertex)
            // (deletion of vertex with two border triangles can split mesh into two parts!)
            return info.triangles.Size() == 1;
        } else {
            // only merge of inner vertices with exactly 4 *inner* edges
            // (merge never cascade beyond adjacent triangles)
            return info.triangles.Size() == 4;
        }
        return false;
    }
    // ------------------------------------------------------------------------
    private function removeVertexFromSettings(vertexId: int) {
        var triangle: SRadUiTriangle;
        var edge: SRadUiEdge;
        var v, sv, t, st, sb, b, vertexSlot: int;
        var newSettings: SRadishNavMeshData;

        sv = settings.vertices.Size();
        for (v = 0; v < sv; v += 1) {
            if (v != vertexId) {
                newSettings.vertices.PushBack(settings.vertices[v]);
            }
        }

        st = settings.triangles.Size();
        for (t = 0; t < st; t += 1) {
            triangle = settings.triangles[t];

            // valid triangle?
            if (triangle.a != -1) {
                // update vertexid if slot was after deleted vertex
                if (triangle.a > vertexId) {
                    triangle.a -= 1;
                }
                if (triangle.b > vertexId) {
                    triangle.b -= 1;
                }
                if (triangle.c > vertexId) {
                    triangle.c -= 1;
                }
                newSettings.triangles.PushBack(triangle);
            }
        }
        sb = settings.phantomBorder.Size();
        for (b = 0; b < sb; b += 1) {
            edge = settings.phantomBorder[b];

            // skip all edges with deleted vertex
            if (edge.a != vertexId && edge.b != vertexId) {
                // update vertexid if slot was after deleted vertex
                if (edge.a > vertexId) {
                    edge.a -= 1;
                }
                if (edge.b > vertexId) {
                    edge.b -= 1;
                }
                newSettings.phantomBorder.PushBack(edge);
            }
        }

        settings = newSettings;
    }
    // ------------------------------------------------------------------------
    private function extractUnknownVertex(triangle: SRadUiTriangle, v1, v2, v3: int) : int {
        if (triangle.a != v1 && triangle.a != v2 && triangle.a != v3) { return triangle.a; }
        if (triangle.b != v1 && triangle.b != v2 && triangle.b != v3) { return triangle.b; }
        if (triangle.c != v1 && triangle.c != v2 && triangle.c != v3) { return triangle.c; }
        return -1;
    }
    // ------------------------------------------------------------------------
    public function deleteVertex() : int {
        var info: SRadUiVertexInfo;
        var isBorder: bool;
        var i, vertexId, selectedVertexB, selectedVertexC, vertexX, vertexY: int;
        var t0, t1, t2, t3: int;
        var t0_containsB, t1_containsB, t2_containsB, t3_containsB: bool;
        var t0_containsC, t1_containsC, t2_containsC, t3_containsC: bool;
        var triangle0, triangle1, triangle2, triangle3: SRadUiTriangle;


        // valid default
        vertexId = 0;

        info = vertexInfo[selectedVertex];
        isBorder = borderEdges[selectedVertex] != -1;

        if (isBorder && info.triangles.Size() == 1) {
            settings.triangles[info.triangles[0]] = SRadUiTriangle(-1, -1, -1);
            removeVertexFromSettings(selectedVertex);
            vertexId = borderEdges[selectedVertex];
        }
        if (!isBorder && info.triangles.Size() == 4) {
            // find two separate pairs of adjacen triangles and merge into two *new* triangles
            //
            //  b---------y
            //  |\__   __/|
            //  |   \ /   |     selected:   a, b, c
            //  |    a    |
            //  | __/ \__ |     first new:  b, c, x
            //  |/       \|     second new: x, y, b
            //  c---------x
            //
            selectedVertexB = selectedTriangle.b;
            selectedVertexC = selectedTriangle.c;

            t0 = info.triangles[0];
            t1 = info.triangles[1];
            t2 = info.triangles[2];
            t3 = info.triangles[3];

            triangle0 = settings.triangles[t0];
            triangle1 = settings.triangles[t1];
            triangle2 = settings.triangles[t2];
            triangle3 = settings.triangles[t3];

            // mark old for removal
            settings.triangles[t0] = SRadUiTriangle(-1, -1, -1);
            settings.triangles[t1] = SRadUiTriangle(-1, -1, -1);
            settings.triangles[t2] = SRadUiTriangle(-1, -1, -1);
            settings.triangles[t3] = SRadUiTriangle(-1, -1, -1);

            t0_containsB = triangle0.a == selectedVertexB || triangle0.b == selectedVertexB || triangle0.c == selectedVertexB;
            t1_containsB = triangle1.a == selectedVertexB || triangle1.b == selectedVertexB || triangle1.c == selectedVertexB;
            t2_containsB = triangle2.a == selectedVertexB || triangle2.b == selectedVertexB || triangle2.c == selectedVertexB;
            t3_containsB = triangle3.a == selectedVertexB || triangle3.b == selectedVertexB || triangle3.c == selectedVertexB;

            t0_containsC = triangle0.a == selectedVertexC || triangle0.b == selectedVertexC || triangle0.c == selectedVertexC;
            t1_containsC = triangle1.a == selectedVertexC || triangle1.b == selectedVertexC || triangle1.c == selectedVertexC;
            t2_containsC = triangle2.a == selectedVertexC || triangle2.b == selectedVertexC || triangle2.c == selectedVertexC;
            t3_containsC = triangle3.a == selectedVertexC || triangle3.b == selectedVertexC || triangle3.c == selectedVertexC;

            if (t0_containsB && !t0_containsC) {
                // must have y
                vertexY = extractUnknownVertex(triangle0, selectedVertex, selectedVertexB, selectedVertexC);
            } else if (t0_containsC && !t0_containsB) {
                // must have x
                vertexX = extractUnknownVertex(triangle0, selectedVertex, selectedVertexB, selectedVertexC);
            }

            if (t1_containsB && !t1_containsC) {
                // must have y
                vertexY = extractUnknownVertex(triangle1, selectedVertex, selectedVertexB, selectedVertexC);
            } else if (t1_containsC && !t1_containsB) {
                // must have x
                vertexX = extractUnknownVertex(triangle1, selectedVertex, selectedVertexB, selectedVertexC);
            }

            if (t2_containsB && !t2_containsC) {
                // must have y
                vertexY = extractUnknownVertex(triangle2, selectedVertex, selectedVertexB, selectedVertexC);
            } else if (t2_containsC && !t2_containsB) {
                // must have x
                vertexX = extractUnknownVertex(triangle2, selectedVertex, selectedVertexB, selectedVertexC);
            }

            if (t3_containsB && !t3_containsC) {
                // must have y
                vertexY = extractUnknownVertex(triangle3, selectedVertex, selectedVertexB, selectedVertexC);
            } else if (t3_containsC && !t3_containsB) {
                // must have x
                vertexX = extractUnknownVertex(triangle3, selectedVertex, selectedVertexB, selectedVertexC);
            }

            settings.triangles.PushBack(SRadUiTriangle(selectedVertexB, selectedVertexC, vertexX));
            settings.triangles.PushBack(SRadUiTriangle(vertexX, vertexY, selectedVertexB));

            removeVertexFromSettings(selectedVertex);
            vertexId = 0;
        }
        if (vertexId > selectedVertex) {
            vertexId -= 1;
        }
        // update precalculated data
        refreshPrecalculatedData();
        proxy.setSettings(settings, borderEdges);

        selectVertexbyId(vertexId);
        return vertexId;
    }
    // ------------------------------------------------------------------------
    // definition creation
    // ------------------------------------------------------------------------
    public function asDefinition() : SEncValue {
        var content, triangles, edges, t, e: SEncValue;
        var triangle: SRadUiTriangle;
        var edge: SRadUiEdge;
        var i, s: int;

        // triangles:
        //  - [[0.0, 1.0, 2.0], [...], [...]]
        //  ...
        // mergeableborder:
        //  - [[0.0, 1.0, 2.0], [...]]
        //  ...

        content = encValueNewMap();
        triangles = encValueNewList();
        edges = encValueNewList();

        s = settings.triangles.Size();
        for (i = 0; i < s; i += 1) {
            triangle = settings.triangles[i];

            t = encValueNewList();
            encListPush(PosToEncValue(settings.vertices[triangle.a]), t);
            encListPush(PosToEncValue(settings.vertices[triangle.b]), t);
            encListPush(PosToEncValue(settings.vertices[triangle.c]), t);

            encListPush(t, triangles);
        }

        s = settings.phantomBorder.Size();
        for (i = 0; i < s; i += 1) {
            edge = settings.phantomBorder[i];

            e = encValueNewList();
            encListPush(PosToEncValue(settings.vertices[edge.a]), e);
            encListPush(PosToEncValue(settings.vertices[edge.b]), e);

            encListPush(e, edges);
        }

        encMapPush("triangles", triangles, content);
        encMapPush("mergeableborder", edges, content);

        return content;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
