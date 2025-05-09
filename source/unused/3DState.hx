package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import manager3D.Manager3D;
import away3d.entities.Mesh;
import away3d.events.Asset3DEvent;
import backend.Paths;

class TestState extends MusicBeatState {
    override public function create() {
        super.create();
		var text:FlxText = new FlxText(10, 10, 0, "Test State [3D TEST]", 32);
		text.color = FlxColor.WHITE;
		add(text);

        Manager3D.initCamera();
        Manager3D.loadModel(Paths.getSharedPath(Paths.obj("3DTEST")), onModelLoaded);
    }

    function onModelLoaded(event:Asset3DEvent) {
        var mesh:Mesh = cast event.asset;
        Manager3D.addModelToScene(Paths.getSharedPath(Paths.obj("3DTEST")), 0, 0, 0);
        Manager3D.moveMesh(mesh, 100, 0, 0);
        Manager3D.rotateMesh(mesh, 'y', 45);
        Manager3D.changeMeshColor(mesh, 0xFF0000);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
		
    }
}
