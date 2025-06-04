package backend;

class FFT {
    public var size:Int;
    private var log2Size:Int;
    private var bitrev:Array<Int>;
    private var cosTable:Array<Float>;
    private var sinTable:Array<Float>;

    public function new(size:Int) {
        if ((size & (size - 1)) != 0) throw "FFT size must be a power of two";

        this.size = size;
        this.log2Size = Std.int(Math.log(size) / Math.log(2));

        bitrev = [];
        for (i in 0...size) {
            var rev = 0;
            var x = i;
            for (j in 0...log2Size) {
                rev = (rev << 1) | (x & 1);
                x >>= 1;
            }
            bitrev.push(rev);
        }

        cosTable = [];
        sinTable = [];
        for (i in 0...Std.int(size / 2)) {
            var angle = -2 * Math.PI * i / size;
            cosTable.push(Math.cos(angle));
            sinTable.push(Math.sin(angle));
        }
    }

    public function forward(re:Array<Float>, im:Array<Float>):Void {
        for (i in 0...size) {
            var j = bitrev[i];
            if (j > i) {
                var tmpRe = re[i];
                var tmpIm = im[i];
                re[i] = re[j];
                im[i] = im[j];
                re[j] = tmpRe;
                im[j] = tmpIm;
            }
        }

        var halfSize = 1;
        for (stage in 0...log2Size) {
            var step = halfSize * 2;
            var twiddleStep = Std.int(size / step);
            for (m in 0...halfSize) {
                var idx = m * twiddleStep;
                var cosW = cosTable[idx];
                var sinW = sinTable[idx];
                var k = m;
                while (k < size) {
                    var tRe = cosW * re[k + halfSize] - sinW * im[k + halfSize];
                    var tIm = sinW * re[k + halfSize] + cosW * im[k + halfSize];
                    re[k + halfSize] = re[k] - tRe;
                    im[k + halfSize] = im[k] - tIm;
                    re[k] += tRe;
                    im[k] += tIm;
                    k += step;
                }
            }
            halfSize = step;
        }
    }
}
