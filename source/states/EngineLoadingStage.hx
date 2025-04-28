package states;

class EngineLoadingStage extends MusicBeatState
{
    public function new()
    {
        super();
    }
    
    override public function create()
    {
        super.create();
    }
    
    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        MusicBeatState.switchCustomStage("TitleState");
    }
    
    override public function destroy()
    {
        super.destroy();
        trace("Loading is complete, switching to TitleState.");
    }
}