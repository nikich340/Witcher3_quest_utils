// ----------------------------------------------------------------------------
class CEncodedRadishNavMesh extends CRadishNavMesh {
    // ------------------------------------------------------------------------
    //default readOnly = true;
    // ------------------------------------------------------------------------
    // ------------------------------------------------------------------------
    public function initFromDbgInfos(metaInfo: array<SDbgInfo>) {
        var i, s: int;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {
            // parse encoded meta information in dbgInfo
            switch (metaInfo[i].type) {
                case "id":          this.id = metaInfo[i].s; break;
                case "vertices":    this.extractVertices(metaInfo[i].v); break;
                case "triangles":   this.extractTriangles(metaInfo[i].v); break;
                case "border":      this.extractBorder(metaInfo[i].v); break;
            }
        }
        settings.id = this.id;
        initFromData(settings);
    }
    // ------------------------------------------------------------------------
    private function extractVertices(metaInfo: array<SDbgInfo>) {
        var i, s, c, cs: int;
        var center: Vector;
        var x, y, z: float;
        var vec: array<SDbgInfo>;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {

            if (metaInfo[i].type == "v") {
                vec = metaInfo[i].v;
                cs = vec.Size();

                x = 0.0;
                y = 0.0;
                z = 0.0;

                for (c = 0; c < cs; c += 1) {
                    switch (vec[c].type) {
                        case "x": x = vec[c].f; break;
                        case "y": y = vec[c].f; break;
                        case "z": z = vec[c].f; break;
                    }
                }

                settings.vertices.PushBack(Vector(x, y, z));

                center += Vector(x, y, z);
            }
        }

        center.X /= s;
        center.Y /= s;
        center.Z /= s;
        center.W = 1;

        settings.placement = SRadishPlacement(center);
    }
    // ------------------------------------------------------------------------
    private function extractTriangles(metaInfo: array<SDbgInfo>) {
        var i, s, t, ts: int;
        var a, b, c: int;
        var triangle: array<SDbgInfo>;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {

            if (metaInfo[i].type == "t") {
                triangle = metaInfo[i].v;
                ts = triangle.Size();

                a = -1;
                b = -1;
                c = -1;

                for (t = 0; t < ts; t += 1) {
                    switch (triangle[t].type) {
                        case "a": a = triangle[t].i; break;
                        case "b": b = triangle[t].i; break;
                        case "c": c = triangle[t].i; break;
                    }
                }
                settings.triangles.PushBack(SRadUiTriangle(a, b, c));
            }
        }
    }
    // ------------------------------------------------------------------------
    private function extractBorder(metaInfo: array<SDbgInfo>) {
        var i, s, e, es: int;
        var a, b: int;
        var edge: array<SDbgInfo>;

        s = metaInfo.Size();
        for (i = 0; i < s; i += 1) {

            if (metaInfo[i].type == "e") {
                edge = metaInfo[i].v;
                es = edge.Size();

                a = -1;
                b = -1;

                for (e = 0; e < es; e += 1) {
                    switch (edge[e].type) {
                        case "a": a = edge[e].i; break;
                        case "b": b = edge[e].i; break;
                    }
                }
                settings.phantomBorder.PushBack(SRadUiEdge(a, b));
            }
        }
    }
    // ------------------------------------------------------------------------
    public function getExtendedCaption() : String {
        var prefix, suffix: String;

        //prefix = "enc: <font color=\"#996666\">";
        //suffix = "</font>";
        prefix = "enc: ";
        suffix = "";

        return prefix + super.getExtendedCaption() + suffix;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
