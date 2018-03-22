/**
 * Created by IntelliJ IDEA.
 * User: mini
 * Date: 12/01/08
 * Time: 7:39
 * To change this template use File | Settings | File Templates.
 */
package org.as3commons.logging.util {
    public function extractPaths(message:String):Object {
        var result: Object = {};
        var pass: Object;
        var start: int;
        var end: int = 0;
        while( (start = message.indexOf("{", end)) != -1 && (end = message.indexOf("}", start)) != -1 ) {
            var field: String = message.substring(start+1, end);
            var dot: int = 0;
            var lastDot: int = 0;
            var obj: Object = result;
            while( (dot = field.indexOf(".", lastDot)) != -1 ) {
                var part: String = field.substring(lastDot, dot);
                obj = (obj[part] is Object) ? obj[part] : (obj[part] = {});
                lastDot = dot+1;
            }
            obj[field.substr(lastDot)] ||= true;
        }
        return result;
    }
}
const FIELD_REGEXP: RegExp = /{((.*\:\:)?([\w_]+\.?)+)}/ig;