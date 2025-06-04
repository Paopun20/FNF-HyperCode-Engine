package shaders;

import flixel.system.FlxAssets.FlxShader;

class WaveEffect
{
    public var shader(default, null):WaveShader = new WaveShader();
    public var amplitude(default, set):Float = 0.1;
    public var frequency(default, set):Float = 3.0;
    public var speed(default, set):Float = 1.0;
    public var time:Float = 0;

    public function new():Void
    {
        shader.uTime.value = [0];
    }

    public function update(elapsed:Float):Void
    {
        time += elapsed;
        shader.uTime.value[0] = time;
    }

    function set_amplitude(value:Float):Float
    {
        amplitude = value;
        shader.uAmplitude.value = [value];
        return value;
    }

    function set_frequency(value:Float):Float
    {
        frequency = value;
        shader.uFrequency.value = [value];
        return value;
    }

    function set_speed(value:Float):Float
    {
        speed = value;
        shader.uSpeed.value = [value];
        return value;
    }
}

class WaveShader extends FlxShader
{
    @:glFragmentSource('
        #pragma header

        uniform float uTime;
        uniform float uAmplitude;
        uniform float uFrequency; 
        uniform float uSpeed;

        void main()
        {
            vec2 uv = openfl_TextureCoordv;
            
            // Create wave effect
            uv.x += sin(uv.y * uFrequency + uTime * uSpeed) * uAmplitude;
            uv.y += cos(uv.x * uFrequency + uTime * uSpeed) * uAmplitude;
            
            gl_FragColor = flixel_texture2D(bitmap, uv);
        }
    ')

    public function new()
    {
        super();
        uAmplitude.value = [0.1];
        uFrequency.value = [3.0];
        uSpeed.value = [1.0];
    }
}
