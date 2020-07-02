// ----------------------------------------------------------------------------
abstract class IModUiSetting {
    // ------------------------------------------------------------------------
    public function isEditable() : bool;
    // ------------------------------------------------------------------------
    public function parseAndUpdate(input: String) : bool;
    // ------------------------------------------------------------------------
    public function getLastError() : String;
    // ------------------------------------------------------------------------
    public function asString() : String;
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class IModUiSettingValidator {}
// ----------------------------------------------------------------------------
abstract class CModUiSetting extends IModUiSetting {
    // ------------------------------------------------------------------------
    public var readOnly: bool;
    // ------------------------------------------------------------------------
    protected var lastErr: String;
    protected var null: String;
    // ------------------------------------------------------------------------
    public function isEditable() : bool {
        return !readOnly;
    }
    // ------------------------------------------------------------------------
    public function getLastError() : String {
        return lastErr;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModReadOnlyUiSetting extends CModUiSetting {
    // ------------------------------------------------------------------------
    default readOnly = true;
    // ------------------------------------------------------------------------
    public function parseAndUpdate(input: String) : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return null;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CModEditableUiSetting extends CModUiSetting {
    // ------------------------------------------------------------------------
    public var validator: IModUiSettingValidator;
    // ------------------------------------------------------------------------
    public function parseAndUpdate(input: String) : bool {
        lastErr = null;
        return parse(input) && isValid();
    }
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool;
    // ------------------------------------------------------------------------
    public function isValid() : bool {
        if (validator) {
            //TODO just return validate()?
            lastErr = validate();
            return !lastErr;
        }
        return true;
    }
    // ------------------------------------------------------------------------
    protected function validate() : String;
    // ------------------------------------------------------------------------
    // generic conversion helper
    // ------------------------------------------------------------------------
    protected function strToFloat(str: String, out f: float) : bool {
        f = StringToFloat(str, -6667666.6);
        if (f == -6667666.6) {
            lastErr = "UI_FloatParseError";
            return false;
        }
        return true;
    }
    // ------------------------------------------------------------------------
    protected function strToInt(str: String, out i: int) : bool {
        i = StringToInt(str, -6667666);
        if (i == -6667666) {
            lastErr = "UI_IntParseError";
            return false;
        }
        return true;
    }
    // ------------------------------------------------------------------------
    protected function strToBool(str: String, out b: bool) : bool {
        switch (str) {
            case "true": b = true; break;
            case "false": b = false; break;
            default:
                lastErr = "UI_BoolParseError";
                return false;
        }
        return true;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiStringSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: String;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        value = input;
        return true;
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        //validator.validate(value);
        return "testErrKey";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return value;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiFloatSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: float;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        return strToFloat(input, value);
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        //validator.validate(value);
        return "testErrKey";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return NoTrailZeros(value);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiIntSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: int;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        return strToInt(input, value);
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        //validator.validate(value);
        return "testErrKey";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return value;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiBoolSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: bool;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        return strToBool(input, value);
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        return "";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        if (value) {
            return "true";
        } else {
            return "false";
        }
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiVectorSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: Vector;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        var success: bool;
        var remaining, s1, s2, s3: String;

        success = StrSplitFirst(input, " ", s1, remaining);
        success = success && StrSplitFirst(remaining, " ", s2, s3);

        success = success && strToFloat(s1, value.X);
        success = success && strToFloat(s2, value.Y);
        success = success && strToFloat(s3, value.Z);

        return success;
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        //validator.validate(value);
        return "testErrKey";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return UiSettingVecToString(value);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiAnglesSetting extends CModEditableUiSetting {
    // ------------------------------------------------------------------------
    public var value: EulerAngles;
    // ------------------------------------------------------------------------
    protected function parse(input: String) : bool {
        var success: bool;
        var remaining, s1, s2, s3: String;

        success = StrSplitFirst(input, " ", s1, remaining);
        success = success && StrSplitFirst(remaining, " ", s2, s3);

        success = success && strToFloat(s1, value.Pitch);
        success = success && strToFloat(s2, value.Yaw);
        success = success && strToFloat(s3, value.Roll);

        return success;
    }
    // ------------------------------------------------------------------------
    protected function validate() : String {
        //validator.validate(value);
        return "testErrKey";
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return UiSettingAnglesToString(value);
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
class CModUiActionpointJobUiSetting extends CModUiSetting {
    // ------------------------------------------------------------------------
    default readOnly = false;
    public var value: String;
    // ------------------------------------------------------------------------
    public function parseAndUpdate(input: String) : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return null;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
abstract class CModUiGenericListUiSetting extends CModUiSetting {
    // ------------------------------------------------------------------------
    protected var valueListId: String;
    protected var workModeState: CName;
    // ------------------------------------------------------------------------
    default readOnly = false;
    public var value: String;
    // ------------------------------------------------------------------------
    public function getWorkmodeState() : CName {
        return workModeState;
    }
    // ------------------------------------------------------------------------
    public function getValueListId() : String {
        return valueListId;
    }
    // ------------------------------------------------------------------------
    public function parseAndUpdate(input: String) : bool {
        return false;
    }
    // ------------------------------------------------------------------------
    public function asString() : String {
        return value;
    }
    // ------------------------------------------------------------------------
    public function getValueId() : String {
        return value;
    }
    // ------------------------------------------------------------------------
    public function setValueId(valueId: String) {
        value = valueId;
    }
    // ------------------------------------------------------------------------
}
// ----------------------------------------------------------------------------
//IModUiSettingValidator
// ----------------------------------------------------------------------------
// settings builder
// ----------------------------------------------------------------------------
function StringToUiSetting(parentObj: CObject, value: String) : CModUiStringSetting
{
    var s: CModUiStringSetting;
    s = new CModUiStringSetting in parentObj;
    s.value = value;
    return s;
}
// ----------------------------------------------------------------------------
function FloatToUiSetting(parentObj: CObject, value: float,
    optional min: Float, optional max: Float) : CModUiFloatSetting
{
    var s: CModUiFloatSetting;
    s = new CModUiFloatSetting in parentObj;
    s.value = value;

    if (min || max) {
//        s.validator =
    }

    return s;
}
// ----------------------------------------------------------------------------
function IntToUiSetting(parentObj: CObject, value: int,
    optional min: int, optional max: int) : CModUiIntSetting
{
    var s: CModUiIntSetting;
    s = new CModUiIntSetting in parentObj;
    s.value = value;

    if (min || max) {
    //    s.validator =
    }
    return s;
}
// ----------------------------------------------------------------------------
function VecToUiSetting(parentObj: CObject, value: Vector) : CModUiVectorSetting
{
    var s: CModUiVectorSetting;
    s = new CModUiVectorSetting in parentObj;
    s.value = value;

    return s;
}
// ----------------------------------------------------------------------------
function AnglesToUiSetting(parentObj: CObject, value: EulerAngles) : CModUiAnglesSetting
{
    var s: CModUiAnglesSetting;
    s = new CModUiAnglesSetting in parentObj;
    s.value = value;

    return s;
}
// ----------------------------------------------------------------------------
function BoolToUiSetting(parentObj: CObject, value: bool) : CModUiBoolSetting {
    var s: CModUiBoolSetting;
    s = new CModUiBoolSetting in parentObj;
    s.value = value;

    return s;
}
// ----------------------------------------------------------------------------
function ReadOnlyUiSetting(parentObj: CObject) : CModUiSetting {
    return new CModReadOnlyUiSetting in parentObj;
}
// ----------------------------------------------------------------------------
function ActionpointJobToUiSetting(
    parentObj: CObject, category: String, action: String) : CModUiActionpointJobUiSetting
{
    var s: CModUiActionpointJobUiSetting;
    s = new CModUiActionpointJobUiSetting in parentObj;
    s.value = category + ":" + action;

    return s;
}
// ----------------------------------------------------------------------------
// Converter to values
// ----------------------------------------------------------------------------
function UiSettingToFloat(setting: IModUiSetting) : Float {
    return ((CModUiFloatSetting)setting).value;
}
// ----------------------------------------------------------------------------
function UiSettingToInt(setting: IModUiSetting) : int {
    return ((CModUiIntSetting)setting).value;
}
// ----------------------------------------------------------------------------
function UiSettingToVector(setting: IModUiSetting) : Vector {
    return ((CModUiVectorSetting)setting).value;
}
// ----------------------------------------------------------------------------
function UiSettingToAngles(setting: IModUiSetting) : EulerAngles {
    return ((CModUiAnglesSetting)setting).value;
}
// ----------------------------------------------------------------------------
function UiSettingToString(setting: IModUiSetting) : String {
    return ((CModUiStringSetting)setting).value;
}
// ----------------------------------------------------------------------------
function UiSettingToBool(setting: IModUiSetting) : bool {
    return ((CModUiBoolSetting)setting).value;
}
// ----------------------------------------------------------------------------
// Formatter
// ----------------------------------------------------------------------------
function UiSettingVecToString(value: Vector) : String {
    return NoTrailZeros(value.X)
            + " " + NoTrailZeros(value.Y)
            + " " + NoTrailZeros(value.Z);
}
// ----------------------------------------------------------------------------
function UiSettingAnglesToString(value: EulerAngles) : String {
    return NoTrailZeros(value.Pitch)
            + " " + NoTrailZeros(value.Yaw)
            + " " + NoTrailZeros(value.Roll);
}
// ----------------------------------------------------------------------------
function UiFormatString(input: String) : String {
    if (StrLen(input) > 40) {
        return "..." + StrRight(input, 40);
    } else {
        return input;
    }
}
// ----------------------------------------------------------------------------
