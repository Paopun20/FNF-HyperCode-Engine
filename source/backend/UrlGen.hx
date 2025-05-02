package backend;

class UrlGen {
    private static final URL_REGEX = ~/^(https?):\/\/([a-zA-Z0-9.-]+)(:[0-9]+)?(\/.*)?$/;
    
    private var baseUrl:String;
    private var pathSegments:Array<String>;
    private var queryParams:Map<String, String>;

    public function new(baseUrl:String) {
        if (!isValidUrl(baseUrl)) {
            throw 'Invalid base URL: $baseUrl';
        }
        
        this.baseUrl = normalizeBaseUrl(baseUrl);
        this.pathSegments = [];
        this.queryParams = new Map();
    }

    // Public API
    public function addPathSegment(segment:String):UrlGen {
        if (segment == null) return this;
        
        var normalized = normalizeSegment(segment);
        if (normalized != "") {
            pathSegments.push(normalized);
        }
        return this;
    }

    public function addQueryParam(key:String, value:String):UrlGen {
        if (key == null || value == null) return this;
        
        queryParams.set(normalizeSegment(key), value);
        return this;
    }

    public function generate():String {
        var url = buildBasePath();
        var queryString = buildQueryString();
        
        return queryString != "" ? '$url?$queryString' : url;
    }

    // Private implementation
    private function buildBasePath():String {
        return pathSegments.length > 0 
            ? '${baseUrl}/${pathSegments.join("/")}'
            : baseUrl;
    }

    private function buildQueryString():String {
        var parts = [];
        for (key in queryParams.keys()) {
            parts.push('${encodeComponent(key)}=${encodeComponent(queryParams.get(key))}');
        }
        return parts.join("&");
    }

    // Static helpers
    private static function isValidUrl(url:String):Bool {
        return URL_REGEX.match(url);
    }

    private static function normalizeBaseUrl(url:String):String {
        return url.endsWith("/") ? url.substr(0, url.length - 1) : url;
    }

    private static function normalizeSegment(segment:String):String {
        while (segment.endsWith("/")) {
            segment = segment.substr(0, segment.length - 1);
        }
        return segment;
    }

    private static function encodeComponent(str:String):String {
        return StringTools.urlEncode(str);
    }
}
