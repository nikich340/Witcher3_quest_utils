// ----------------------------------------------------------------------------
// most simple vertex visualisation (no highlight, no visibility toggles,
// no appearances, etc.)
class CRadUiMeshVertexProxy extends IRadishBaseProxyRepresentation {
    // ------------------------------------------------------------------------
    protected var proxyVertex: CEntity;
    protected var proxyTriangleEdge: CEntity;
    protected var proxyGroundEdge: CEntity;

    protected var edgeWidth: float; default edgeWidth = 0.75;

    protected var appearanceVertex: CName; default appearanceVertex = 'orange';
    protected var appearanceTriangleEdge: CName; default appearanceTriangleEdge = 'yellow';
    protected var appearanceGroundEdge: CName; default appearanceGroundEdge = 'red';
    // ------------------------------------------------------------------------
    private var vertexPos: Vector;
    private var fixedVertexPos1: Vector;
    private var fixedVertexPos2: Vector;
    private var groundPos: Vector;
    // ------------------------------------------------------------------------
    public function init() {
        var template: CEntityTemplate;
        var appearance: CAppearanceComponent;

        template = (CEntityTemplate)LoadResource("dlc\modtemplates\radishquestui\base\edge.w2ent", true);

        proxyVertex = theGame.CreateEntity(template, Vector(), EulerAngles());
        proxyVertex.AddTag('RADUI');

        appearance = (CAppearanceComponent)proxyVertex.GetComponentByClassName('CAppearanceComponent');
        appearance.ApplyAppearance(appearanceVertex);

        proxyTriangleEdge = theGame.CreateEntity(template, Vector(), EulerAngles());
        proxyTriangleEdge.AddTag('RADUI');

        appearance = (CAppearanceComponent)proxyTriangleEdge.GetComponentByClassName('CAppearanceComponent');
        appearance.ApplyAppearance(appearanceTriangleEdge);

        proxyGroundEdge = theGame.CreateEntity(template, Vector(), EulerAngles());
        proxyGroundEdge.AddTag('RADUI');

        appearance = (CAppearanceComponent)proxyGroundEdge.GetComponentByClassName('CAppearanceComponent');
        appearance.ApplyAppearance(appearanceGroundEdge);
    }
    // ------------------------------------------------------------------------
    public function setVertexData(
        vertexPos: Vector, fixedVertexPos1: Vector, fixedVertexPos2: Vector)
    {
        this.vertexPos = vertexPos;
        this.fixedVertexPos1 = fixedVertexPos1;
        this.fixedVertexPos2 = fixedVertexPos2;
        this.groundPos = vertexPos;
        this.groundPos.Z -= 10.0;

        adjustVertex();
        adjustEdge(proxyTriangleEdge, vertexPos, fixedVertexPos1);
        adjustEdge(proxyGroundEdge, vertexPos, groundPos);
    }
    // ------------------------------------------------------------------------
    public function show(doShow: bool) {
        proxyVertex.SetHideInGame(!doShow);
        proxyTriangleEdge.SetHideInGame(!doShow);
        proxyGroundEdge.SetHideInGame(!doShow);
    }
    // ------------------------------------------------------------------------
    public function moveTo(placement: SRadishPlacement) {
        vertexPos = placement.pos;
        //proxyVertex.Teleport(vertexPos);
        groundPos = vertexPos;
        groundPos.Z -= 10.0;

        adjustVertex();
        adjustEdge(proxyTriangleEdge, vertexPos, fixedVertexPos1);
        adjustEdge(proxyGroundEdge, vertexPos, groundPos);
    }
    // ------------------------------------------------------------------------
    public function getPlacement() : SRadishPlacement {
        return SRadishPlacement(vertexPos);
    }
    // ------------------------------------------------------------------------
    public function getSize() : Vector {
        return Vector(0.5, 0.5, 0.5, 1.0);
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        proxyVertex.StopAllEffects();
        proxyVertex.Destroy();

        proxyTriangleEdge.StopAllEffects();
        proxyTriangleEdge.Destroy();

        proxyGroundEdge.StopAllEffects();
        proxyGroundEdge.Destroy();

        delete proxyVertex;
        delete proxyTriangleEdge;
        delete proxyGroundEdge;
    }
    // ------------------------------------------------------------------------
    private function adjustEdge(entity: CEntity, vertex1: Vector, vertex2: Vector) {
        var angles: EulerAngles;
        var meshComponent: CMeshComponent;
        var length: float;
        var diff: Vector;

        length = VecDistance(vertex1, vertex2);

        diff = vertex2 - vertex1;
        angles = EulerAngles(Rad2Deg(AcosF(diff.Z / length)), 90.0 + Rad2Deg(AtanF(diff.Y, diff.X)), 0.0);

        entity.TeleportWithRotation(vertex1, angles);
        meshComponent = (CMeshComponent)entity.GetComponentByClassName('CMeshComponent');
        meshComponent.SetScale(Vector(edgeWidth, edgeWidth, length));
    }
    // ------------------------------------------------------------------------
    private function adjustVertex() {
        var endPos: Vector;

        endPos = vertexPos + 0.5 * VecNormalize(VecCross(fixedVertexPos1 - vertexPos, fixedVertexPos2 - vertexPos));

        adjustEdge(proxyVertex, vertexPos, endPos);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
struct SRadUiTriangleScaling {
    var t1Width: float;
    var t2Width: float;
    var tHeight: float;
}
// ----------------------------------------------------------------------------
class CRadUiNavMeshProxy extends CRadishProxyRepresentation {
    // ------------------------------------------------------------------------
    public var edgeWidth: float; default edgeWidth = 0.25;
    public var borderEdgeWidth: float; default borderEdgeWidth = 0.5;
    // ------------------------------------------------------------------------
    private var vertices: array<Vector>;
    private var triangles: array<SRadUiTriangle>;
    private var edges: array<SRadUiEdge>;
    // 0: normal, 1: border, 2: phatom/mergeable border
    private var edgeTypes: array<int>;
    // ------------------------------------------------------------------------
    private var selectedVertex: int;
    private var selectedEdges: array<int>;
    private var selectedTriangles: array<int>;
    // ------------------------------------------------------------------------
    private var edgeEntities: array<CEntity>;
    // ------------------------------------------------------------------------
    // triangles have to be created from to entities
    // ------------------------------------------------------------------------
    private var triangleEntity1: array<CEntity>;
    private var triangleEntity2: array<CEntity>;

    // cache scaling because appearance change respawns entities and scales is reset
    private var trianglesScaling: array<SRadUiTriangleScaling>;
    private var edgeScaling: array<Float>;
    // ------------------------------------------------------------------------
    private var edgeTemplate: CEntityTemplate;
    private var triangleTemplate: CEntityTemplate;
    // ------------------------------------------------------------------------
    private var appearanceNames: array<CName>; default appearanceId = 'blue';
    // ------------------------------------------------------------------------
    public function init(
        templatePath: String, placement: SRadishPlacement, visibleSourceEntity: bool)
    {
        super.init("", placement, false);

        edgeTemplate = (CEntityTemplate)LoadResource("dlc\modtemplates\radishquestui\base\edge.w2ent", true);
        triangleTemplate = (CEntityTemplate)LoadResource("dlc\modtemplates\radishquestui\base\triangle.w2ent", true);

        // by definition triangles and edges have the same appearances
        GetAppearanceNames(triangleTemplate, appearanceNames);

        reset();
    }
    // ------------------------------------------------------------------------
    public function reset() {
        vertices.Clear();
        triangles.Clear();
        edges.Clear();

        edgeEntities.Clear();
        triangleEntity1.Clear();
        triangleEntity2.Clear();

        edgeScaling.Clear();
        trianglesScaling.Clear();

        edgeTypes.Clear();
    }
    // ------------------------------------------------------------------------
    // temporary array
    private var borderVertices: array<int>;
    private var phantomEdges: array<SRadUiEdge>;
    // ------------------------------------------------------------------------
    public function setSettings(newSettings: SRadishNavMeshData, borderVertices: array<int>) {
        var s, i: int;

        s = newSettings.triangles.Size();

        despawn();
        reset();
        vertices = newSettings.vertices;

        // temporary vars to be used as lookup for edge type identification while
        // building triangles
        this.phantomEdges = newSettings.phantomBorder;
        this.borderVertices = borderVertices;

        for (i = 0; i < s; i += 1) {
            addTriangle(newSettings.triangles[i]);
        }

        this.phantomEdges.Clear();
        this.borderVertices.Clear();

        spawn();
    }
    // ------------------------------------------------------------------------
    public function moveTo(newPlacement: SRadishPlacement) {
        var diffPos: Vector;
        var i, s: int;

        diffPos = newPlacement.pos - placement.pos;

        s = vertices.Size();
        for (i = 0; i < s; i += 1) {
            vertices[i] = vertices[i] + diffPos;
        }

        super.moveTo(newPlacement);

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            // this may get out of sync by rounding errors at some point
            triangleEntity1[i].Teleport(triangleEntity1[i].GetWorldPosition() + diffPos);
            triangleEntity2[i].Teleport(triangleEntity2[i].GetWorldPosition() + diffPos);
        }

        s = edges.Size();
        for (i = 0; i < s; i += 1) {
            // this may get out of sync by rounding errors at some point
            edgeEntities[i].Teleport(edgeEntities[i].GetWorldPosition() + diffPos);
        }
    }
    // ------------------------------------------------------------------------
    public function setAppearance(newAppearance: CName) {
        var meshComponent: CMeshComponent;
        var appearanceComp: CAppearanceComponent;
        var i, s: int;
        var scaling: SRadUiTriangleScaling;
        var width: float;

        appearanceId = newAppearance;

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            scaling = trianglesScaling[i];

            appearanceComp = (CAppearanceComponent)triangleEntity1[i].GetComponentByClassName('CAppearanceComponent');
            appearanceComp.ApplyAppearance(newAppearance);
            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)triangleEntity1[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(Vector(scaling.t1Width, scaling.tHeight, 1.0));

            appearanceComp = (CAppearanceComponent)triangleEntity2[i].GetComponentByClassName('CAppearanceComponent');
            appearanceComp.ApplyAppearance(newAppearance);
            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)triangleEntity2[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(Vector(scaling.t2Width, scaling.tHeight, 1.0));
        }

        s = edgeEntities.Size();
        for (i = 0; i < s; i += 1) {
            appearanceComp = (CAppearanceComponent)edgeEntities[i].GetComponentByClassName('CAppearanceComponent');
            switch (edgeTypes[i]) {
                case 1:
                    appearanceComp.ApplyAppearance('red');
                    width = borderEdgeWidth;
                    break;
                case 2:
                    appearanceComp.ApplyAppearance('green');
                    width = borderEdgeWidth;
                    break;
                default:
                    appearanceComp.ApplyAppearance(newAppearance);
                    width = edgeWidth;
            }

            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)edgeEntities[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(Vector(width, width, edgeScaling[i]));
        }
    }
    // ------------------------------------------------------------------------
    public function cycleAppearance() {
        var i: int;

        i = appearanceNames.FindFirst(appearanceId);
        if (i == -1) {
            i = 0;
        }
        setAppearance(appearanceNames[(i + 1) % appearanceNames.Size()]);
    }
    // ------------------------------------------------------------------------
    // mesh creation/modification
    // ------------------------------------------------------------------------
    public function updateEdgeType(edge: SRadUiEdge, newType: int) : int {
        var meshComponent: CMeshComponent;
        var appearanceComp: CAppearanceComponent;
        var edgeType, i: int;
        var width: float;

        i = edges.FindFirst(edge);
        if (i == -1) {
            i = edges.FindFirst(SRadUiEdge(edge.b, edge.a));
            if (i == -1) {
                LogChannel('ERROR', "navmeshProxy.updateEdgeType: failed to extract edge slot");
            }
        }
        if (i > -1) {
            edgeType = edgeTypes[i];
            // make it inner edge and update appearance
            edgeTypes[i] = newType;

            appearanceComp = (CAppearanceComponent)edgeEntities[i].GetComponentByClassName('CAppearanceComponent');
            switch (newType) {
                case 1:
                    appearanceComp.ApplyAppearance('red');
                    width = borderEdgeWidth;
                    break;
                case 2:
                    appearanceComp.ApplyAppearance('green');
                    width = borderEdgeWidth;
                    break;
                default:
                    appearanceComp.ApplyAppearance(appearanceId);
                    width = edgeWidth;
            }

            // refresh size as appearance change seems to respawn entity
            meshComponent = (CMeshComponent)edgeEntities[i].GetComponentByClassName('CMeshComponent');
            meshComponent.SetScale(Vector(width, width, edgeScaling[i]));
        }

        return edgeType;
    }
    // ------------------------------------------------------------------------
    private function findBaseEdge(newTriangle: SRadUiTriangle) : SRadUiEdge {
        // find base edge
        // newTriangle contains *new* vertexId which is always higher than the other
        // two vertexIds: this is the base edge
        if (newTriangle.a < newTriangle.b) {
            if (newTriangle.b < newTriangle.c) {
                return SRadUiEdge(newTriangle.a, newTriangle.b);
            } else {
                return SRadUiEdge(newTriangle.a, newTriangle.c);
            }
        } else if (newTriangle.a < newTriangle.c) {
            return SRadUiEdge(newTriangle.a, newTriangle.b);
        } else {
            return SRadUiEdge(newTriangle.b, newTriangle.c);
        }
    }
    // ------------------------------------------------------------------------
    public function addNewBorderTriangle(newVertex: Vector, newTriangle: SRadUiTriangle) {
        var newTriangleSlot, newEdgeSlot: int;
        var proxyEdge1, proxyEdge2: CEntity;
        var eScaling: float;
        var tScaling: SRadUiTriangleScaling;
        var edgeType: int;
        var baseEdge: SRadUiEdge;

        //TODO check new triangle?
        vertices.PushBack(newVertex);
        addTriangle(newTriangle);

        newTriangleSlot = triangles.Size() - 1;
        // cache scaling since array is not expanded to this slot
        tScaling = updateTriangle(triangles[newTriangleSlot], newTriangleSlot);
        trianglesScaling[newTriangleSlot] = tScaling;

        // new border triangle means two new edges were added, too
        newEdgeSlot = edges.Size() - 2;

        eScaling = updateEdge(edges[newEdgeSlot], newEdgeSlot);
        edgeScaling[newEdgeSlot] = eScaling;
        eScaling = updateEdge(edges[newEdgeSlot + 1], newEdgeSlot + 1);
        edgeScaling[newEdgeSlot + 1] = eScaling;

        // new edges are same type as base edge was
        baseEdge = findBaseEdge(newTriangle);
        // "old" border edge is now inner edge
        edgeType = updateEdgeType(baseEdge, 0);
        // update new edges
        updateEdgeType(edges[newEdgeSlot], edgeType);
        updateEdgeType(edges[newEdgeSlot + 1], edgeType);
    }
    // ------------------------------------------------------------------------
    private function addTriangle(triangle: SRadUiTriangle) {
        triangles.PushBack(triangle);

        addEdge(SRadUiEdge(triangle.a, triangle.b));
        addEdge(SRadUiEdge(triangle.b, triangle.c));
        addEdge(SRadUiEdge(triangle.c, triangle.a));
    }
    // ------------------------------------------------------------------------
    private function addEdge(edge: SRadUiEdge) {
        var flipped: SRadUiEdge;

        flipped = SRadUiEdge(edge.b, edge.a);

        if (!edges.Contains(edge) && !edges.Contains(flipped)) {
            edges.PushBack(edge);

            if (borderVertices[edge.a] == edge.b || borderVertices[edge.b] == edge.a) {
                // border edge
                // check if it's also marked as mergeable edge
                if (phantomEdges.Contains(edge) || phantomEdges.Contains(flipped)) {
                    // "phantom" border
                    edgeTypes.PushBack(2);
                } else {
                    //  "hard" border
                    edgeTypes.PushBack(1);
                }
            } else {
                // inner edge
                edgeTypes.PushBack(0);
            }
        }
    }
    // ------------------------------------------------------------------------
    private function addNewProxyTriangle(pos: Vector, rot1: EulerAngles, rot2: EulerAngles) {
        var appearance: CAppearanceComponent;
        var entity1: CEntity;
        var entity2: CEntity;
        var scaling: SRadUiTriangleScaling;

        entity1 = theGame.CreateEntity(triangleTemplate, pos, rot1);
        entity2 = theGame.CreateEntity(triangleTemplate, pos, rot2);

        appearance = (CAppearanceComponent)entity1.GetComponentByClassName('CAppearanceComponent');
        appearance.ApplyAppearance(appearanceId);
        appearance = (CAppearanceComponent)entity2.GetComponentByClassName('CAppearanceComponent');
        appearance.ApplyAppearance(appearanceId);

        entity1.AddTag('RADUI');
        entity2.AddTag('RADUI');

        entity1.SetHideInGame(!isVisible && !isHighlighted);
        entity2.SetHideInGame(!isVisible && !isHighlighted);

        triangleEntity1.PushBack(entity1);
        triangleEntity2.PushBack(entity2);
        trianglesScaling.PushBack(SRadUiTriangleScaling(1.0, 1.0, 1.0));
    }
    // ------------------------------------------------------------------------
    private function addNewProxyEdge(pos: Vector, rot: EulerAngles, type: int) {
        var appearance: CAppearanceComponent;
        var entity: CEntity;

        entity = theGame.CreateEntity(edgeTemplate, pos, rot);
        appearance = (CAppearanceComponent)entity.GetComponentByClassName('CAppearanceComponent');
        switch (type) {
            case 1:     appearance.ApplyAppearance('red'); break;
            case 2:     appearance.ApplyAppearance('green'); break;
            default:    appearance.ApplyAppearance(appearanceId);
        }
        entity.AddTag('RADUI');

        entity.SetHideInGame(!isVisible && !isHighlighted);

        edgeEntities.PushBack(entity);
        edgeScaling.PushBack(1.0);
    }
    // ------------------------------------------------------------------------
    private function updateTriangle(triangle: SRadUiTriangle, slot: int) : SRadUiTriangleScaling {
        var proxy1, proxy2: CEntity;
        var angles1, angles2: EulerAngles;
        var meshComponent: CMeshComponent;

        var a, b, c: Vector;
        var da, db, dc: float;

        var directedUnitVec, rectCornerPoint: Vector;
        var t1Width, t2Width, tHeight: float;
        var m: Matrix;

        //        C
        //       /|^___
        //      / |    \___
        //     v  |        \__
        //    A---P----------->B
        a = vertices[triangle.b] - vertices[triangle.a];
        b = vertices[triangle.c] - vertices[triangle.b];
        c = vertices[triangle.a] - vertices[triangle.c];

        da = VecLength(a);
        db = VecLength(b);
        dc = VecLength(c);

        // use longest triangle side as split for two rectangular triangles
        if (da > db) {
            if (da > dc) {
                // longest side: a -> orthogonal projection onto a
                directedUnitVec = VecNormalize(a);
                rectCornerPoint = VecDot(-c, directedUnitVec) * directedUnitVec;

                // triangle 1: (rectCornerPoint -> C), (C -> A), (A -> rectCornerPoint)
                // triangle 2: (rectCornerPoint -> B), (B -> C), (C -> rectCornerPoint)
                t1Width = VecLength(rectCornerPoint);
                t2Width = da - t1Width;

                tHeight = VecLength(-c - rectCornerPoint);
                rectCornerPoint += vertices[triangle.a];

                m.X = rectCornerPoint - vertices[triangle.b];
                m.Y = rectCornerPoint - vertices[triangle.c];
            } else {
                // longest side: c -> orthogonal projection onto c
                directedUnitVec = VecNormalize(c);
                rectCornerPoint = VecDot(-b, directedUnitVec) * directedUnitVec;

                // triangle 1: (rectCornerPoint -> B), (B -> C), (C -> rectCornerPoint)
                // triangle 2: (rectCornerPoint -> A), (A -> B), (B -> rectCornerPoint)
                t1Width = VecLength(rectCornerPoint);
                t2Width = dc - t1Width;

                tHeight = VecLength(-b - rectCornerPoint);
                rectCornerPoint += vertices[triangle.c];

                m.X = rectCornerPoint - vertices[triangle.a];
                m.Y = rectCornerPoint - vertices[triangle.b];
            }
        } else {
            if (db > dc) {
                // longest side: b -> orthogonal projection onto b
                directedUnitVec = VecNormalize(b);
                rectCornerPoint = VecDot(-a, directedUnitVec) * directedUnitVec;

                // triangle 1: (rectCornerPoint -> A), (A -> B), (B -> rectCornerPoint)
                // triangle 2: (rectCornerPoint -> C), (C -> A), (A -> rectCornerPoint)
                t1Width = VecLength(rectCornerPoint);
                t2Width = db - t1Width;

                tHeight = VecLength(-a - rectCornerPoint);
                rectCornerPoint += vertices[triangle.b];

                m.X = rectCornerPoint - vertices[triangle.c];
                m.Y = rectCornerPoint - vertices[triangle.a];
            } else {
                // longest side: c -> orthogonal projection onto c
                directedUnitVec = VecNormalize(c);
                rectCornerPoint = VecDot(-b, directedUnitVec) * directedUnitVec;

                // triangle 1: (rectCornerPoint -> B), (B -> C), (C -> rectCornerPoint)
                // triangle 2: (rectCornerPoint -> A), (A -> B), (B -> rectCornerPoint)
                t1Width = VecLength(rectCornerPoint);
                t2Width = dc - t1Width;

                tHeight = VecLength(-b - rectCornerPoint);
                rectCornerPoint += vertices[triangle.c];

                m.X = rectCornerPoint - vertices[triangle.a];
                m.Y = rectCornerPoint - vertices[triangle.b];
            }
        }

        m.Z = VecCross(m.X, m.Y);
        m.W = Vector(0.0, 0.0, 0.0, 1.0);

        angles2 = MatrixGetRotation(m);
        angles1 = angles2;
        angles1.Roll += 180.0;

        if (slot < triangleEntity1.Size()) {
            proxy1 = triangleEntity1[slot];
            proxy2 = triangleEntity2[slot];
            proxy1.TeleportWithRotation(rectCornerPoint, angles1);
            proxy2.TeleportWithRotation(rectCornerPoint, angles2);
        } else {
            addNewProxyTriangle(rectCornerPoint, angles1, angles2);
            proxy1 = triangleEntity1[slot];
            proxy2 = triangleEntity2[slot];
        }

        meshComponent = (CMeshComponent)proxy1.GetComponentByClassName('CMeshComponent');
        meshComponent.SetScale(Vector(t1Width, tHeight, 1.0));

        meshComponent = (CMeshComponent)proxy2.GetComponentByClassName('CMeshComponent');
        meshComponent.SetScale(Vector(t2Width, tHeight, 1.0));

        return SRadUiTriangleScaling(t1Width, t2Width, tHeight);
    }
    // ------------------------------------------------------------------------
    private function updateEdge(edge: SRadUiEdge, slot: int) : float {
        var proxy: CEntity;
        var angles: EulerAngles;
        var meshComponent: CMeshComponent;
        var width, length: float;
        var diff: Vector;

        var pos1, pos2: Vector;

        pos1 = vertices[edge.a];
        pos2 = vertices[edge.b];

        length = VecDistance(pos1, pos2);

        diff = pos2 - pos1;
        angles = EulerAngles(Rad2Deg(AcosF(diff.Z / length)), 90.0 + Rad2Deg(AtanF(diff.Y, diff.X)), 0.0);

        if (slot < edgeEntities.Size()) {
            proxy = edgeEntities[slot];
            proxy.TeleportWithRotation(pos1, angles);
        } else {
            addNewProxyEdge(pos1, angles, edgeTypes[slot]);
            proxy = edgeEntities[slot];
        }
        switch (edgeTypes[slot]) {
            case 1: width = borderEdgeWidth; break;
            case 2: width = borderEdgeWidth; break;
            default: width = edgeWidth;
        }

        meshComponent = (CMeshComponent)proxy.GetComponentByClassName('CMeshComponent');
        meshComponent.SetScale(Vector(width, width, length));

        return length;
    }
    // ------------------------------------------------------------------------
    // mesh vertex adjustment
    // ------------------------------------------------------------------------
    public function preselectVertexEntities(vertexId: int) {
        var i, s: int;

        selectedVertex = vertexId;
        selectedEdges.Clear();
        selectedTriangles.Clear();

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            if (triangles[i].a == vertexId || triangles[i].b == vertexId || triangles[i].c == vertexId) {
                selectedTriangles.PushBack(i);
            }
        }

        s = edges.Size();
        for (i = 0; i < s; i += 1) {
            if (edges[i].a == vertexId || edges[i].b == vertexId) {
                selectedEdges.PushBack(i);
            }
        }
    }
    // ------------------------------------------------------------------------
    public function syncSelectedVertexPosition(newPos: Vector) {
        var i, s, slot: int;

        vertices[selectedVertex] = newPos;

        // update only marked triangles and edges
        s = selectedTriangles.Size();
        for (i = 0; i < s; i += 1) {
            slot = selectedTriangles[i];
            trianglesScaling[slot] = updateTriangle(triangles[slot], slot);
        }

        s = selectedEdges.Size();
        for (i = 0; i < s; i += 1) {
            slot = selectedEdges[i];
            edgeScaling[slot] = updateEdge(edges[slot], slot);
        }
    }
    // ------------------------------------------------------------------------
    // spawn
    // ------------------------------------------------------------------------
    protected function spawn() {
        super.spawn();
        spawnTriangles();
        spawnEdges();
    }
    // ------------------------------------------------------------------------
    private function spawnTriangles() {
        var scaling: SRadUiTriangleScaling;
        var i, s: int;

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            // cache scaling since array is not yet expanded for this slot
            // -> it gets not updated in the array
            scaling = updateTriangle(triangles[i], i);
            trianglesScaling[i] = scaling;
        }
    }
    // ------------------------------------------------------------------------
    private function spawnEdges() {
        var scaling: float;
        var i, s: int;
        var proxy: CEntity;

        s = edges.Size();
        for (i = 0; i < s; i += 1) {
            // cache scaling since array is not yet expanded for this slot
            // -> it gets not updated in the array
            scaling = updateEdge(edges[i], i);
            edgeScaling[i] = scaling;
        }
    }
    // ------------------------------------------------------------------------
    // despawn
    // ------------------------------------------------------------------------
    protected function despawn() {
        despawnEdges();
        despawnTriangles();
    }
    // ------------------------------------------------------------------------
    private function despawnEdges() {
        var i, s: int;

        s = edgeEntities.Size();
        for (i = 0; i < s; i += 1) {
            edgeEntities[i].Destroy();
        }
    }
    // ------------------------------------------------------------------------
    public function despawnTriangles() {
        var i, s: int;

        s = triangleEntity1.Size();
        for (i = 0; i < s; i += 1) {
            triangleEntity1[i].Destroy();
            triangleEntity2[i].Destroy();
        }
    }
    // ------------------------------------------------------------------------
    public function destroy() {
        despawn();
        reset();
        super.destroy();
    }
    // ------------------------------------------------------------------------
    // dynamic show/hide
    // ------------------------------------------------------------------------
    protected function highlightProxy(doHighlight: bool) {
        var i, s : int;

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            triangleEntity1[i].SetHideInGame(!doHighlight);
            triangleEntity2[i].SetHideInGame(!doHighlight);
        }
        s = edgeEntities.Size();
        for (i = 0; i < s; i += 1) {
            edgeEntities[i].SetHideInGame(!doHighlight);
        }
        super.highlightProxy(doHighlight);
    }
    // ------------------------------------------------------------------------
    protected function showProxy(doShow: bool) {
        var i, s : int;

        s = triangles.Size();
        for (i = 0; i < s; i += 1) {
            triangleEntity1[i].SetHideInGame(!doShow);
            triangleEntity2[i].SetHideInGame(!doShow);
        }
        s = edgeEntities.Size();
        for (i = 0; i < s; i += 1) {
            edgeEntities[i].SetHideInGame(!doShow);
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
