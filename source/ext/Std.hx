package ext;

extern inline final PI:Float = 3.1415926535897932384626433832795; // PI 
extern inline final TWO_PI:Float = PI * 2;
extern inline final HALF_PI:Float = PI / 2;
extern inline final E:Float = 2.7182818284590452353602874713527;
extern inline final LOG2:Float = 0.693147180559945309417232121458176568075500134360255;
extern inline final LOG10:Float = 2.30258509299404568409875017057736332492598758037004;

overload extern inline function abs(a:Int):Int {
	return a < 0 ? -a : a;
}

overload extern inline function abs(a:Float):Float {
	return a < 0 ? -a : a;
}

overload extern inline function sign(a:Int):Int {
	return a < 0 ? -1 : a > 0 ? 1 : 0;
}

overload extern inline function sign(a:Float):Int {
	return a < 0 ? -1 : a > 0 ? 1 : 0;
}

overload extern inline function min(a:Int, b:Int):Int {
	return a < b ? a : b;
}

overload extern inline function min(a:Float, b:Float):Float {
	return a < b ? a : b;
}

overload extern inline function max(a:Int, b:Int):Int {
	return a > b ? a : b;
}

overload extern inline function max(a:Float, b:Float):Float {
	return a > b ? a : b;
}

overload extern inline function clamp(a:Int, min:Int, max:Int):Int {
	return a < min ? min : a > max ? max : a;
}

overload extern inline function clamp(a:Float, min:Float, max:Float):Float {
	return a < min ? min : a > max ? max : a;
}

overload extern inline function mix(a:Float, b:Float, t:Float):Float {
	return a + (b - a) * t;
}

overload extern inline function mix<T>(a:T, b:T, t:Bool):T {
	return t ? b : a;
}

overload extern inline function linearstep(a:Float, b:Float, t:Float):Float {
	return clamp((t - a) / (b - a), 0, 1);
}

overload extern inline function zip<A, B, C>(as:Array<A>, bs:Array<B>, f:(a:A, b:B) -> C):Array<C> {
	assert(as.length == bs.length);
	final res = [];
	final len = as.length;
	for (i in 0...len) {
		res.push(f(as[i], bs[i]));
	}
	return res;
}

overload extern inline function sum(as:Array<Int>):Int {
	var res = 0;
	for (a in as)
		res += a;
	return res;
}

overload extern inline function sum(as:Array<Float>):Float {
	var res = 0.0;
	for (a in as)
		res += a;
	return res;
}

overload extern inline function prod(as:Array<Int>):Int {
	var res = 1;
	for (a in as)
		res *= a;
	return res;
}

overload extern inline function prod(as:Array<Float>):Float {
	var res = 1.0;
	for (a in as)
		res *= a;
	return res;
}

extern inline function toInt(a:Float):Int {
	return std.Std.int(a);
}

#if java
extern inline function popcount(i:Int):Int {
	return java.lang.Integer.bitCount(i);
}
#else
extern inline function popcount(i:Int):Int {
	i = (i & 0x55555555) + (i >> 1 & 0x55555555);
	i = (i & 0x33333333) + (i >> 2 & 0x33333333);
	i = (i & 0x0f0f0f0f) + (i >> 4 & 0x0f0f0f0f);
	i = (i & 0x00ff00ff) + (i >> 8 & 0x00ff00ff);
	return (i & 0x0000ffff) + (i >> 16);
}
#end

extern inline function assert(a:Bool, s:String = "assertion error"):Void {
	if (!a)
		throw s;
}
