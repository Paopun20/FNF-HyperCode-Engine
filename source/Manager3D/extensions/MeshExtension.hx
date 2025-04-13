package manager3D.extensions;

import away3d.entities.Mesh;
import openfl.geom.Vector3D;
import openfl.geom.ColorTransform;
import away3d.materials.ColorMaterial;

class MeshExtension {
    /**
     * Move mesh to a new position
     * @param mesh Mesh to move
     * @param x New X position
     * @param y New Y position
     * @param z New Z position
     */
    public static function moveTo(mesh:Mesh, x:Float, y:Float, z:Float):Void {
        mesh.position = new Vector3D(x, y, z);
    }

    /**
     * Change the color of the mesh
     * @param mesh Mesh to change color
     * @param color New color (in 0xRRGGBB format)
     */
    public static function setColor(mesh:Mesh, color:Int):Void {
        mesh.material = new ColorMaterial(color);
    }

    /**
     * Add mesh to the scene
     * @param mesh Mesh to add
     * @param scene Scene to add the mesh into
     */
    public static function addToScene(mesh:Mesh, scene:away3d.containers.Scene3D):Void {
        scene.addChild(mesh);
    }

    /**
     * Remove mesh from the scene
     * @param mesh Mesh to remove
     * @param scene Scene to remove the mesh from
     */
    public static function removeFromScene(mesh:Mesh, scene:away3d.containers.Scene3D):Void {
        scene.removeChild(mesh);
    }

    /**
     * Make the mesh move with a new position
     * @param mesh Mesh to animate
     * @param x X position
     * @param y Y position
     * @param z Z position
     * @param speed Speed of movement
     */
    // public static function animateMove(mesh:Mesh, x:Float, y:Float, z:Float, speed:Float):Void {
    //     var targetPos = new Vector3D(x, y, z);
    //     var delta = targetPos.subtract(mesh.position);
    //     var newPos = mesh.position.add(delta.clone().scaleBy(speed));
    //     mesh.position = newPos;
    // }

    /**
     * Rotate mesh along the specified axis
     * @param mesh Mesh to rotate
     * @param axis Axis to rotate ('x', 'y', 'z')
     * @param angle Rotation angle (degrees)
     */
    public static function rotateMesh(mesh:Mesh, axis:String, angle:Float):Void {
        switch (axis) {
            case 'x': mesh.rotationX += angle;
            case 'y': mesh.rotationY += angle;
            case 'z': mesh.rotationZ += angle;
        }
    }
}
