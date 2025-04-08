package hypsychenging;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flx3d.Flx3DCamera;
import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import backend.Paths;
import openfl.display3D.Context3D;
import openfl.display3D.textures.Texture;
import openfl.display3D.textures.TextureBase;
import openfl.display3D.textures.RectangleTexture;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

/**
 * A static utility class for managing 3D models and rendering within the HyPsychEngine.
 */
class Manager3D {
    /**
     * The main 3D camera used for rendering.
     */
    public static var camera:Flx3DCamera;

    /**
     * A map to store loaded 3D models, keyed by their asset path.
     */
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
            trace("Error: 3D camera not initialized. Call ThreeDManager.initCamera() first.");
            return;
        }

        camera.addModel(assetPath, function(event:Asset3DEvent) {
            if (event.asset != null && event.asset.assetType == away3d.library.assets.Asset3DType.MESH) {
                var mesh:Mesh = cast event.asset;
                loadedModels.set(assetPath, mesh);
                callback(event);
            } else {
                trace('Error loading model: $assetPath');
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
            trace("Error: 3D camera not initialized. Call ThreeDManager.initCamera() first.");
            return;
        }

        if (!loadedModels.exists(assetPath)) {
            trace("Error: Model not loaded: $assetPath. Call ThreeDManager.loadModel() first.");
            return;
        }

        var model:Mesh = loadedModels.get(assetPath);
        model.x = x;
        model.y = y;
        model.z = z;
        camera.addChild(model);
    }

    /**
     * Removes a model from the scene.
     * @param assetPath The path to the loaded 3D model.
     */
    public static function removeModelFromScene(assetPath:String):Void {
        if (camera == null) {
            trace("Error: 3D camera not initialized. Call ThreeDManager.initCamera() first.");
            return;
        }

        if (!loadedModels.exists(assetPath)) {
            trace("Error: Model not loaded: $assetPath.");
            return;
        }

        var model:Mesh = loadedModels.get(assetPath);
        camera.removeChild(model);
    }

    /**
     * Removes all models from the scene and clears the loaded models map.
     */
    public static function clearScene():Void {
        if (camera == null) {
            trace("Error: 3D camera not initialized. Call ThreeDManager.initCamera() first.");
            return;
        }

        for (model in loadedModels) {
            camera.removeChild(model);
        }
        loadedModels.clear();
    }

    /**
     * Destroys the 3D camera and clears the scene.
     */
    public static function destroy():Void {
        clearScene();
        if (camera != null) {
            camera.destroy();
            camera = null;
        }
    }

    /**
     * Helper function to apply a texture to a mesh.
     * @param mesh The mesh to apply the texture to.
     * @param texturePath The path to the texture.
     */
    public static function applyTexture(mesh:Mesh, texturePath:String):Void {
        #if sys
        var texture:FlxGraphic = Paths.image(texturePath);
        #else
        var texture:String = 'assets/images/$texturePath.png';
        #end
        if (texture != null) {
            camera.applyTexture(mesh, texture);
        } else {
            trace('Texture not found: $texturePath');
        }
    }
}
