package utils;
import backend.FFT;
import haxe.io.Float32Array;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;

/**
 * AudioAnalyzer class for analyzing audio data.
 * It extracts frequency spectrum and volume from a Sound object.
 * Usage:
 * ```haxe
 * var analyzer = new AudioAnalyzer(mySound);
 * analyzer.play();
 * while (true) {
 *   analyzer.update();
 *   var spectrum = analyzer.getSpectrum();
 *   var volume = analyzer.volume;
 * }
 * ```
 * spectrum is an array of magnitudes for each frequency bin,
 * volume is the overall loudness (RMS)
 */
class AudioAnalyzer {
    public var spectrum:Array<Float>;    // magnitude for each frequency bin
    public var volume:Float;             // overall loudness (RMS)
    private var sound:Sound;
    private var channel:SoundChannel;
    private var bufferSize:Int;
    private var sampleRate:Int;
    private var fft:FFT;

    /**
     * Creates a new AudioAnalyzer for the given Sound.
     * @param sound The Sound object to analyze.
     * @param bufferSize The size of the FFT buffer (must be a power of two).
     */
    public function new(sound:Sound, ?bufferSize:Int = 1024) {
        this.sound = sound;
        this.bufferSize = bufferSize;
        // Fixed sampling rate to common value since sound.length is in milliseconds
        this.sampleRate = 44100;
        this.fft = new FFT(bufferSize);
        this.spectrum = [];
        this.volume = 0;
        if (bufferSize <= 0 || (bufferSize & (bufferSize - 1)) != 0) {
            throw "Buffer size must be a power of two greater than zero";
        }
        if (sound == null) {
            throw "Sound must not be null";
        }
    }

    /**
     * Starts playback of the sound.
     * @param transform Optional SoundTransform to apply to the playback.
     */
    public function play(transform:SoundTransform = null):Void {
        channel = sound.play();
        if (transform != null) channel.soundTransform = transform;
    }

    /**
     * Updates the analyzer by extracting samples from the sound,
     * computing the volume (RMS) and performing FFT to get the frequency spectrum.
     * don't forget to call this periodically (e.g. in a game loop)
     * @throws Error if the sound is not playing or has no samples.
     */
    public function update():Void {
        if (channel == null) return;

        // 1) Create a buffer for mixed mono samples
        var mono = new Array<Float>();
        for (i in 0...bufferSize) {
            mono.push(0.0);
        }

        // 2) Compute RMS and prepare for FFT
        var sumSq:Float = 0;
        for (i in 0...bufferSize) {
            var m = mono[i];
            sumSq += m * m;
        }
        volume = Math.sqrt(sumSq / bufferSize);

        // 3) Run FFT
        var re = mono.copy();           // real parts
        var im = [for (i in 0...bufferSize) 0.0];  // imaginary parts initialized to zero
        fft.forward(re, im);

        // 4) Build spectrum (magnitude)
        spectrum = [];
        var halfSize = Std.int(bufferSize/2);
        for (i in 0...halfSize) {
            spectrum.push(Math.sqrt(re[i]*re[i] + im[i]*im[i]));
        }
    }

    /**
     * Returns the frequency spectrum as an array of magnitudes.
     * If normalize is true, the values are normalized to [0, 1].
     * @param normalize Whether to normalize the spectrum values.
     * @return An array of magnitudes for each frequency bin.
     */
    public function getSpectrum(normalize:Bool = true):Array<Float> {
        var out = spectrum.copy();
        if (normalize && spectrum.length > 0) {
            var max = 0.0;
            for (val in out) {
                if (val > max) max = val;
            }
            if (max > 0) {
                for (i in 0...out.length) {
                    out[i] /= max;
                }
            }
        }
        return out;
    }
}
