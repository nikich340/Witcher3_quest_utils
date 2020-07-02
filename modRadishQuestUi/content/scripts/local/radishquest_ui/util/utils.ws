// ----------------------------------------------------------------------------
function RadUi_escapeAsId(input: String) : String {
    var i, s: int;
    var result, char: String;

    s = StrLen(input);
    for (i = 0; i < s; i += 1) {
        char = StrMid(input, i, 1);
        if (StrFindFirst("abcdefghijklmnopqrstuvwxyz_1234567890~", char) >= 0) {
            result += char;
        } else {
            result += "_";
        }
    }
    return result;
}
// ----------------------------------------------------------------------------
function RadUi_LayerEntityIdFromString(id: String) : SRadUiLayerEntityId {
    var entityId: SRadUiLayerEntityId;
    var layerName, layerContext, layerEncoded, entityName, entitySpecialization, no: String;

    // meshtests:context:true:env|areaname#no
    StrSplitFirst(id, ":", layerName, entityName);
    StrSplitFirst(entityName, ":", layerContext, entityName);
    StrSplitFirst(entityName, ":", layerEncoded, entityName);
    StrSplitFirst(entityName, "|", entitySpecialization, entityName);
    StrSplitFirst(entityName, "#", entityName, no);

    return SRadUiLayerEntityId(
        SRadUiLayerId(layerName, layerContext, layerEncoded == "true"),
        entityName,
        StringToInt(no));
}
// ----------------------------------------------------------------------------
function RadUi_extractMeshBoxSize(box: Box, optional minSize: float) : Vector {
    var result: Vector;

    if (minSize == 0.0) {
        minSize = 1.0;
    }

    result.X = MaxF(box.Max.X - box.Min.X, minSize);
    result.Y = MaxF(box.Max.Y - box.Min.Y, minSize);
    result.Z = MaxF(box.Max.Z - box.Min.Z, minSize);
    result.W = 1;

    return result;
}
// ----------------------------------------------------------------------------
function RadUi_getGroundPosFromCam(placement: SRadishPlacement) : Vector {
    //FIXME Matrix: (Translation * Rotation)
    /*var pos, outPos, outNormal: Vector;
    pos = placement.pos + 5000 * MatrixGetDirectionVector(RotToMatrix(placement.rot));
    if (theGame.GetWorld().StaticTrace(placement.pos, pos, outPos, outNormal)) {
        return outPos;
    }
    return placement.pos;
    */
    var groundZ: Float;
    var pos: Vector;

    pos = placement.pos + MaxF(5, MinF(100, placement.pos.Z)) * VecFromHeading(placement.rot.Yaw);
    pos.Z = placement.pos.Z;
    pos.W = 1.0;

    while (pos.Z > -5.0) {
        if (theGame.GetWorld().PhysicsCorrectZ(pos, groundZ)) {
            pos.Z = groundZ;
            return pos;
        }
        pos.Z -= 1;
    }
    // at this point it seems no ground level data is loaded
    // -> fallback 10 meters in front of cam at camlevel - 3m
    pos = placement.pos + 10 * VecFromHeading(placement.rot.Yaw);
    pos.Z = placement.pos.Z - 3;
    pos.W = 1.0;

    theGame.GetGuiManager().ShowNotification(
        GetLocStringByKeyExt("RADUI_eGroundDetectionFailed"));

    return pos;
}
// ----------------------------------------------------------------------------
function RadUi_TimeToHHmm(input: int) : String {
    var hours, mins: int;
    var HH, MM: String;

    if (input > 0) {
        hours = input / 3600;
        mins = (input - hours * 3600) / 60;
        if (mins < 10) {
            MM = "0" + mins;
        } else {
            MM = mins;
        }

        if (hours < 10) {
            return "0" + hours + ":" + MM;
        } else if (hours < 24) {
            return  hours + ":" + MM;
        } else {
            return "23:59";
        }

    } else {
        return "00:00";
    }
}
// ----------------------------------------------------------------------------
