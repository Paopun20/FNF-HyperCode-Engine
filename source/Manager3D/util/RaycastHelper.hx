package manager3D.util;

import away3d.entities.Mesh;
import away3d.containers.View3D;
import openfl.geom.Vector3D;

class RaycastHelper {
    public static function raycastFrom(view:View3D, origin:Vector3D, direction:Vector3D):Array<Mesh> {
        var result:Array<Mesh> = [];
        for (i in 0...view.scene.numChildren) {
            var obj = view.scene.getChildAt(i);
            if (Std.is(obj, Mesh)) {
                var mesh = cast(obj, Mesh);
                result.push(mesh);
            }
        }
        
        return result;
    }
}
