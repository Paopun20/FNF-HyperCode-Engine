package manager3D;

import away3d.containers.View3D;
import flixel.FlxG;
import openfl.display.DisplayObject;
import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import openfl.geom.Vector3D;
import openfl.display.BitmapData;
import away3d.textures.BitmapTexture;
import flx3d.Flx3DCamera;
import away3d.materials.TextureMaterial;
import manager3D.util.RaycastHelper;
import manager3D.extensions.MeshExtension;
import openfl.Assets;
import away3d.library.assets.Asset3DType;

class Manager3D {
    public static var camera:Flx3DCamera;
    public static var view:View3D;
    public static var loadedModels:Map<String, Mesh> = new Map<String, Mesh>();

    /**
     * Initializes the 3D camera.
     *
     * @param x The x-coordinate of the camera.
     * @param y The y-coordinate of the camera.
     * @param width The width of the camera's viewport.
     * @param height The height of the camera's viewport.
     */
    public static function initCamera(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0):Void {
        if (camera != null)
            return;

        if (width == 0)
            width = FlxG.width;
        if (height == 0)
            height = FlxG.height;
        camera = new Flx3DCamera(x, y, width, height);
        FlxG.cameras.add(camera);
        view = camera.view;
    }

    /**
     * Loads a 3D model from the specified asset path.
     *
     * @param assetPath The path to the 3D model file.
     * @param callback The callback function to be executed when the model is loaded.
     * @param texturePath (Optional) The path to the texture file or a FlxGraphic to apply to the model.
     * @param smoothTexture (Optional) Whether to use smooth texture filtering (default: true).
     */
    public static function loadModel(assetPath:String, callback:Asset3DEvent->Void, ?texturePath:Dynamic, smoothTexture:Bool = true):Void {
        if (loadedModels.exists(assetPath)) {
            // Model already loaded, call the callback with the existing model
            var event:Asset3DEvent = new Asset3DEvent(Asset3DEvent.ASSET_COMPLETE, loadedModels.get(assetPath));
            callback(event);
            return;
        }

        if (camera == null) {
            trace("Error: 3D camera not initialized. Call Manager3D.initCamera() first.");
            return;
        }

        // In Manager3D.hx, inside loadModel
        camera.addModel(assetPath, function(event:Asset3DEvent) {
            if (event.asset != null && (event.asset.assetType == Asset3DType.MESH || event.asset.assetType == Asset3DType.CONTAINER || event.asset.assetType == Asset3DType.GEOMETRY)) {
                if (cast event.asset is Mesh) {
                    var mesh:Mesh = cast event.asset;
                    loadedModels.set(assetPath, mesh);
                    callback(event);
                } else {
                    trace('Error: Asset is not a Mesh: $assetPath');
                }
            }
            
        }, texturePath, smoothTexture);
    }

    /**
     * Adds a loaded 3D model to the scene.
     *
     * @param assetPath The path to the loaded 3D model.
     * @param x The x-coordinate of the model.
     * @param y The y-coordinate of the model.
     * @param z The z-coordinate of the model.
     */
    public static function addModelToScene(assetPath:String, x:Float = 0, y:Float = 0, z:Float = 0):Void {
        if (camera == null) {
            trace("Error: 3D camera not initialized. Call Manager3D.initCamera() first.");
            return;
        }

        if (!loadedModels.exists(assetPath)) {
            trace("Error: Model not loaded: $assetPath. Call Manager3D.loadModel() first.");
            return;
        }

        var model:Mesh = loadedModels.get(assetPath);
        if (model == null) return;
        model.x = x;
        model.y = y;
        model.z = z;
        view.scene.addChild(model);
    }

    /**
     * Removes a model from the scene.
     * @param assetPath The path to the loaded 3D model.
     */
    public static function removeModelFromScene(assetPath:String):Void {
        if (view == null) {
            trace("Error: 3D camera not initialized. Call Manager3D.initCamera() first.");
            return;
        }

        if (!loadedModels.exists(assetPath)) {
            trace("Error: Model not loaded: $assetPath.");
            return;
        }

        var model:Mesh = loadedModels.get(assetPath);
        if (model == null) return;
        view.scene.removeChild(cast model);
    }

    /**
     * Removes all models from the scene and clears the loaded models map.
     */
    public static function clearScene():Void {
        if (view == null) {
            trace("Error: 3D camera not initialized. Call Manager3D.initCamera() first.");
            return;
        }

        for (model in loadedModels) {
            if (view.scene.contains(model)) {
                view.scene.removeChild(cast model);
            }
        }
        loadedModels.clear();
    }

    /**
     * Destroys the 3D camera and clears the scene.
     */
    public static function destroy():Void {
        clearScene();
        if (view != null) {
            view.dispose();
            view = null;
        }
        loadedModels.clear();
        if (camera != null) {
            FlxG.cameras.remove(camera);
            camera = null;
        }
    }

    /**
     * Helper function to apply a texture to a mesh.
     * @param mesh The mesh to apply the texture to.
     * @param texturePath The path to the texture.
     */
    public static function applyTexture(mesh:Mesh, texturePath:String):Void {
        if (texturePath != null && texturePath.length > 0) {
            var texture = new BitmapTexture(Assets.getBitmapData(texturePath));
            mesh.material = new TextureMaterial(texture);
        } else {
            trace('Texture not found: $texturePath');
        }
    }
    
    /**
     * Move mesh in the scene by applying transformations.
     * @param mesh The mesh to move.
     * @param x The target X position.
     * @param y The target Y position.
     * @param z The target Z position.
     */
    public static function moveMesh(mesh:Mesh, x:Float, y:Float, z:Float):Void {
        MeshExtension.moveTo(mesh, x, y, z);
    }

    /**
     * Rotate mesh in the scene by applying a rotation.
     * @param mesh The mesh to rotate.
     * @param axis The axis of rotation ('x', 'y', 'z').
     * @param angle The angle of rotation in degrees.
     */
    public static function rotateMesh(mesh:Mesh, axis:String, angle:Float):Void {
        MeshExtension.rotateMesh(mesh, axis, angle);
    }

    /**
     * Change color of the mesh.
     * @param mesh The mesh to change color.
     * @param color The new color in hex format (e.g., 0xFF0000 for red).
     */
    public static function changeMeshColor(mesh:Mesh, color:Int):Void {
        MeshExtension.setColor(mesh, color);
    }
}
