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
        this.sampleRate = Std.int(sound.length / 1000 * 44100) / Std.int(sound.length / 1000); 
        this.fft = new FFT(bufferSize);
        this.spectrum = [];
        this.volume = 0;
        if (bufferSize <= 0 || (bufferSize & (bufferSize - 1)) != 0) {
            throw "Buffer size must be a power of two greater than zero";
        }
        if (sound.length <= 0) {
            throw "Sound must have a valid length";
        }
        if (sound.isCompressed) {
            throw "Sound must be uncompressed PCM format for FFT analysis";
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
        // 1) extract raw samples
        var samples = new Float32Array(bufferSize * 2); // stereo
        var extracted = sound.extract(samples, bufferSize, channel.position);
        if (extracted == 0) return;

        // 2) down-mix to mono & compute RMS
        var mono = new Array<Float>();
        var sumSq:Float = 0;
        for (i in 0...extracted) {
            var left  = samples[i*2 + 0];
            var right = samples[i*2 + 1];
            var m = (left + right) * 0.5;
            mono.push(m);
            sumSq += m * m;
        }
        volume = Math.sqrt(sumSq / extracted);

        // 3) zero-pad if needed
        while (mono.length < bufferSize) mono.push(0);

        // 4) run FFT
        var re = mono.copy();           // real parts
        var im = new Array<Float>(bufferSize);
        fft.forward(re, im);

        // 5) build spectrum (magnitude)
        spectrum = [];
        for (i in 0 ... bufferSize/2) {
            spectrum.push(Math.sqrt(re[i]*re[i] + im[i]*im[i]));
        }
    }

    /**
     * Returns the frequency spectrum as an array of magnitudes.
     * If normalize is true, the values are normalized to [0, 1].
     * @param normalize Whether to normalize the spectrum values.
     * @return An array of magnitudes for each frequency bin.
     * ```haxe
     * var analyzer = new AudioAnalyzer(mySound);
     * analyzer.play();
     * while (true) {
     *   analyzer.update();
     *   var spectrum = analyzer.getSpectrum();
     *   trace(spectrum); // prints the frequency magnitudes
     * }
     */
    public function getSpectrum(normalize:Bool = true):Array<Float> {
        var out = spectrum.copy();
        if (normalize) {
            var max = Lambda.max(out);
            if (max > 0) for (i in 0 ... out.length) out[i] /= max;
        }
        return out;
    }
}
