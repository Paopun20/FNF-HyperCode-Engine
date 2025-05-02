package backend;

import haxe.Http;
import haxe.http.HttpStatus;
import haxe.Json;
import haxe.ds.StringMap;
import haxe.ds.Option;
import Reflect;

class HttpClient {
    // Constants
    public static final DEFAULT_TIMEOUT:Int = 10000; // 10 seconds
    public static final MAX_RETRIES:Int = 3;

    // Public API methods
    public static function hasInternet(callback:Bool->Void):Void {
        sendRequest("https://www.google.com", null, function(success, _) {
            callback(success);
        });
    }

    public static function getRequest(
        url:String,
        callback:(Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendRequest(url, null, callback, false, headers, 0, "GET", queryParams);
    }

    public static function postRequest(
        url:String,
        data:Dynamic,
        callback:(Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendRequest(url, data, callback, true, headers, 0, "POST", queryParams);
    }

    public static function putRequest(
        url:String,
        data:Dynamic,
        callback:(Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendRequest(url, data, callback, true, headers, 0, "PUT", queryParams);
    }

    public static function deleteRequest(
        url:String,
        callback:(Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendRequest(url, null, callback, false, headers, 0, "DELETE", queryParams);
    }

    public static function patchRequest(
        url:String,
        data:Dynamic,
        callback:(Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendRequest(url, data, callback, true, headers, 0, "PATCH", queryParams);
    }

    public static function streamRequest(
        url:String,
        data:Dynamic,
        callback:(Bool, Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        sendStream(url, data, callback, headers, queryParams);
    }

    // Private implementation
    private static function sendRequest(
        url:String,
        data:Dynamic,
        callback:(Bool, Dynamic)->Void,
        isPost:Bool = false,
        headers:StringMap<String> = null,
        retries:Int = 0,
        method:String = "GET",
        queryParams:StringMap<String> = null
    ):Void {
        if (retries > MAX_RETRIES) {
            logError("Max retries exceeded", url, retries);
            safeCallback(callback, false, {error: "Max retries exceeded", url: url});
            return;
        }

        final parsedUrl = validateUrl(url);
        if (parsedUrl == null) {
            logError("Invalid URL", url);
            safeCallback(callback, false, {error: "Invalid URL", url: url});
            return;
        }

        final fullUrl = buildFullUrl(parsedUrl, queryParams);
        final http = new Http(fullUrl);
        http.cnxTimeout = DEFAULT_TIMEOUT;

        setHeaders(http, headers);
        
        if (isPost || method != "GET") {
            preparePostRequest(http, data, method);
        }

        http.onStatus = status -> httptrace('$method Status: $status');
        http.onData = response -> handleSuccess(response, callback);
        http.onError = error -> handleError(error, url, retries, () -> {
            sendRequest(url, data, callback, isPost, headers, retries + 1, method, queryParams);
        }, callback);

        http.request();
    }

    private static function sendStream(
        url:String,
        data:Dynamic,
        callback:(Bool, Bool, Dynamic)->Void,
        headers:StringMap<String> = null,
        queryParams:StringMap<String> = null
    ):Void {
        final parsedUrl = validateUrl(url);
        if (parsedUrl == null) {
            logError("Invalid URL", url);
            safeStreamCallback(callback, false, false, {error: "Invalid URL", url: url});
            return;
        }
    
        final fullUrl = buildFullUrl(parsedUrl, queryParams);
        final http = new Http(fullUrl);
        http.cnxTimeout = DEFAULT_TIMEOUT;
    
        setHeaders(http, headers);
        
        // Remove SSE-specific headers since we're handling raw stream
        http.setHeader("Accept", "application/json");
        http.setHeader("Connection", "keep-alive");
    
        final state = {
            closed: false,
            buffer: new StringBuf(),
            lastDataTime: haxe.Timer.stamp()
        };
    
        // Heartbeat check for stream timeout
        final heartbeatTimer = new haxe.Timer(1000);
        heartbeatTimer.run = function() {
            if (state.closed) {
                heartbeatTimer.stop();
                return;
            }
            
            if (haxe.Timer.stamp() - state.lastDataTime > 30) {
                state.closed = true;
                heartbeatTimer.stop();
                safeStreamCallback(callback, false, true, {
                    error: "Stream timeout", 
                    reason: "No data received for 30 seconds"
                });
            }
        };
    
        http.onBytes = function(bytes:haxe.io.Bytes) {
            if (state.closed) return;
            
            state.lastDataTime = haxe.Timer.stamp();
            final chunk = bytes.toString();
            
            // Directly pass through chunks without SSE parsing
            safeStreamCallback(callback, true, false, {
                chunk: chunk
            });
        };
    
        http.onError = function(error:String) {
            if (!state.closed) {
                state.closed = true;
                heartbeatTimer.stop();
                logError("Stream error: " + error, url);
                safeStreamCallback(callback, false, true, {
                    error: error,
                    closed: true
                });
            }
        };
    
        http.onStatus = function(status:Int) {
            if (!state.closed && status >= 400) {
                state.closed = true;
                heartbeatTimer.stop();
                final errorMsg = 'HTTP error $status';
                logError(errorMsg, url);
                safeStreamCallback(callback, false, true, {
                    error: errorMsg, 
                    status: status,
                    closed: true
                });
            }
            // Treat successful completion (status 200) as stream end
            else if (!state.closed && status == 200) {
                state.closed = true;
                heartbeatTimer.stop();
                safeStreamCallback(callback, true, true, {
                    complete: true,
                    status: status
                });
            }
        };
    
        try {
            if (data != null) {
                http.setHeader("Content-Type", "application/json");
                http.setPostData(Json.stringify(data));
                http.request(true);
            } else {
                http.request(false);
            }
        } catch (e:Dynamic) {
            if (!state.closed) {
                state.closed = true;
                heartbeatTimer.stop();
                logError("Request failed: " + e, url);
                safeStreamCallback(callback, false, true, {
                    error: e,
                    closed: true
                });
            }
        }
    }

    // Helper methods
    private static function buildFullUrl(baseUrl:String, queryParams:StringMap<String>):String {
        if (queryParams == null) return baseUrl;
        return baseUrl + "?" + buildQueryString(queryParams);
    }

    private static function buildQueryString(params:StringMap<String>):String {
        return [for (key in params.keys()) '$key=${StringTools.urlEncode(params.get(key))}'].join("&");
    }

    private static function setHeaders(http:Http, headers:StringMap<String>):Void {
        if (headers == null) return;
        for (key in headers.keys()) {
            http.setHeader(key, headers.get(key));
        }
    }

    private static function setStreamHeaders(http:Http):Void {
        http.setHeader("Accept", "text/event-stream");
        http.setHeader("Cache-Control", "no-cache");
        http.setHeader("Connection", "keep-alive");
    }

    private static function preparePostRequest(http:Http, data:Dynamic, method:String):Void {
        http.setHeader("Content-Type", "application/json");
        if (data != null) {
            http.setPostData(Json.stringify(data));
        }
        httptrace('Sending $method request with data: ${Json.stringify(data)}');
    }

    private static function handleSuccess(response:String, callback:(Bool, Dynamic)->Void):Void {
        httptrace("Response received: " + response);
        safeCallback(callback, true, response);
    }

    private static function handleError(
        error:String,
        url:String,
        retries:Int,
        retryCallback:Void->Void,
        callback:(Bool, Dynamic)->Void
    ):Void {
        final errorType = categorizeError(error);
        logError(errorType, url, retries);
        
        if (shouldRetry(errorType)) {
            httptrace('Retrying... Attempt ${retries + 1}');
            retryCallback();
        } else {
            safeCallback(callback, false, {error: errorType, details: error, url: url});
        }
    }

    private static function processStreamEvent(
        eventData:Dynamic,
        callback:(Bool, Bool, Dynamic)->Void,
        streamClosed:Bool
    ):Void {
        final choice = eventData.choices[0];
        
        if (choice.finish_reason != null) {
            streamClosed = true;
            safeStreamCallback(callback, true, true, {
                finish_reason: choice.finish_reason,
                usage: eventData.usage
            });
        } else if (choice.delta != null && choice.delta.content != null) {
            safeStreamCallback(callback, true, false, {
                content: choice.delta.content
            });
        }
    }

    private static function handleStreamError(
        error:String,
        url:String,
        callback:(Bool, Bool, Dynamic)->Void,
        streamClosed:Bool
    ):Void {
        if (!streamClosed) {
            streamClosed = true;
            logError("Stream error: " + error, url);
            safeStreamCallback(callback, false, true, {error: error});
        }
    }

    private static function handleStreamStatus(
        status:Int,
        url:String,
        callback:(Bool, Bool, Dynamic)->Void,
        streamClosed:Bool
    ):Void {
        if (status >= 400 && !streamClosed) {
            streamClosed = true;
            final errorMsg = 'HTTP error $status';
            logError(errorMsg, url);
            safeStreamCallback(callback, false, true, {error: errorMsg, status: status});
        }
    }

    private static function safeCallback(
        callback:(Bool, Dynamic)->Void,
        success:Bool,
        result:Dynamic
    ):Void {
        try {
            if (callback == null) return;
            callback(success, result);
        } catch (e:Dynamic) {
            httptrace("Callback execution failed: " + e);
        }
    }

    private static function safeStreamCallback(
        callback:(Bool, Bool, Dynamic)->Void,
        success:Bool,
        finished:Bool,
        data:Dynamic
    ):Void {
        try {
            if (callback == null) return;
            callback(success, finished, data);
        } catch (e:Dynamic) {
            logError("Stream callback failed: " + e, "");
        }
    }

    private static function categorizeError(error:String):String {
        return switch error {
            case error if (error.indexOf("Timeout") != -1): "Timeout Error";
            case error if (error.indexOf("Connection refused") != -1): "Connection Refused";
            case error if (error.indexOf("Invalid URL") != -1): "Invalid URL";
            case error if (error.indexOf("Failed to connect") != -1): "Failed to Connect";
            case error if (error.indexOf("Bad Request") != -1): "Bad Request";
            case error if (error.indexOf("Unauthorized") != -1): "Unauthorized";
            case error if (error.indexOf("Forbidden") != -1): "Forbidden";
            case error if (error.indexOf("Not Found") != -1): "Not Found";
            case error if (error.indexOf("Internal Server Error") != -1): "Internal Server Error";
            case error if (error.indexOf("Service Unavailable") != -1): "Service Unavailable";
            case error if (error.indexOf("Network is unreachable") != -1): "Network Unreachable";
            case error if (error.indexOf("Host is down") != -1): "Host Down";
            case error if (error.indexOf("SSL") != -1): "SSL Error";
            case error if (error.indexOf("Too Many Requests") != -1): "Too Many Requests";
            case error if (error.indexOf("Request Entity Too Large") != -1): "Request Entity Too Large";
            case error if (error.indexOf("Unsupported Media Type") != -1): "Unsupported Media Type";
            case error if (error.indexOf("Not Implemented") != -1): "Not Implemented";
            case error if (error.indexOf("Gateway Timeout") != -1): "Gateway Timeout";
            case error if (error.indexOf("HTTP") != -1): "HTTP Error";
            case _: "General Error";
        }
    }

    private static function shouldRetry(errorType:String):Bool {
        final retryableErrors = [
            "Network Error", "Timeout Error", "General Error",
            "Service Unavailable", "Connection Refused", "Failed to Connect",
            "Network Unreachable", "Host Down", "Gateway Timeout"
        ];
        return retryableErrors.contains(errorType);
    }

    private static function logError(error:String, url:String, retries:Int = 0):Void {
        httptrace('Error occurred: $error | URL: $url | Retry: $retries');
    }

    private static function validateUrl(url:String):String {
        if (url == null || url.trim() == "") return null;
        final parsedUrl = new HttpUrl(url);
        return parsedUrl.valid ? parsedUrl.toString() : null;
    }

    private static function httptrace(msg:String):Void {
        trace(msg);
    }
}

class HttpUrl {
    private static final URL_REGEX = ~/^(https?):\/\/([a-zA-Z0-9.-]+)(:[0-9]+)?(\/.*)?$/;

    public final url:String;
    public final valid:Bool;
    public final secure:Bool;
    public final host:String;
    public final port:Int;
    public final request:String;

    public function new(url:String) {
        this.url = url;
        this.valid = URL_REGEX.match(url);

        if (this.valid) {
            secure = URL_REGEX.matched(1) == "https";
            host = URL_REGEX.matched(2);
            port = parsePort(URL_REGEX.matched(3));
            request = URL_REGEX.matched(4) != null ? URL_REGEX.matched(4) : "/";
        } else {
            secure = false;
            host = "";
            port = 80;
            request = "/";
        }
    }

    private function parsePort(portStr:String):Int {
        return portStr != null ? Std.parseInt(portStr.substr(1)) : (secure ? 443 : 80);
    }

    public function toString():String {
        return url;
    }
}
