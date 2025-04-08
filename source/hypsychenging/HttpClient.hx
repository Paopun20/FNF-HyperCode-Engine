package hypsychenging;

import haxe.Http;
import haxe.http.HttpStatus;
import haxe.Json;
import haxe.ds.StringMap;
import haxe.ds.Option;
import Reflect;

class HttpUrl {
    private static final regexp = ~/^(https?):\/\/([a-zA-Z0-9.-]+)(:[0-9]+)?(\/.*)?$/;

    public var url(default, null): String;
    public var valid(default, null): Bool;
    public var secure(default, null): Bool;
    public var host(default, null): String;
    public var port(default, null): Int;
    public var request(default, null): String;

    public function new(url: String) {
        this.url = url;
        var match = regexp.match(url);
        this.valid = match;

        if (match) {
            this.secure = regexp.matched(1) == "https";
            this.host = regexp.matched(2);
            this.port = parsePort(regexp.matched(3));
            this.request = regexp.matched(4) != null ? regexp.matched(4) : "/";
        } else {
            // Default values for invalid URLs
            this.secure = false;
            this.host = "";
            this.port = 80;
            this.request = "/";
        }
    }

    private function parsePort(portStr: String): Int {
        return portStr != null ? Std.parseInt(portStr.substr(1)) : (secure ? 443 : 80);
    }

    public function toString(): String {
        return url;
    }
}

/**
 * HttpClient is a utility class for sending HTTP requests.
 * It supports GET, POST, PUT, DELETE, and PATCH methods with retry logic.
 */
class HttpClient {
    public static var DEFAULT_TIMEOUT: Int = 10000;  // Default timeout in milliseconds (10 seconds)
    public static var MAX_RETRIES: Int = 3;          // Maximum number of retries for failed requests

    /**
     * Check if there is an active internet connection.
     */
    public static function hasInternet(callback: Bool -> Void): Void {
        // Attempt to send a request to Google's homepage
        sendRequest("https://www.google.com", null, function(success, _) {
            callback(success);
        });
    }

    /**
     * Send a GET request to the specified URL.
     */
    public static function getRequest(
        url: String, 
        callback: (Bool, Dynamic) -> Void, 
        headers: StringMap<String> = null,
        queryParams: StringMap<String> = null
    ): Void {
        sendRequest(url, null, callback, false, headers, 0, "GET", queryParams);
    }

    /**
     * Send a POST request with data to the specified URL.
     */
    public static function postRequest(
        url: String, 
        data: Dynamic, 
        callback: (Bool, Dynamic) -> Void, 
        headers: StringMap<String> = null,
        queryParams: StringMap<String> = null
    ): Void {
        sendRequest(url, data, callback, true, headers, 0, "POST", queryParams);
    }

    /**
     * Send a PUT request with data to the specified URL.
     */
    public static function putRequest(
        url: String, 
        data: Dynamic, 
        callback: (Bool, Dynamic) -> Void, 
        headers: StringMap<String> = null,
        queryParams: StringMap<String> = null
    ): Void {
        sendRequest(url, data, callback, true, headers, 0, "PUT", queryParams);
    }

    /**
     * Send a DELETE request to the specified URL.
     */
    public static function deleteRequest(
        url: String, 
        callback: (Bool, Dynamic) -> Void, 
        headers: StringMap<String> = null,
        queryParams: StringMap<String> = null
    ): Void {
        sendRequest(url, null, callback, false, headers, 0, "DELETE", queryParams);
    }

    /**
     * Send a PATCH request with data to the specified URL.
     */
    public static function patchRequest(
        url: String, 
        data: Dynamic, 
        callback: (Bool, Dynamic) -> Void, 
        headers: StringMap<String> = null,
        queryParams: StringMap<String> = null
    ): Void {
        sendRequest(url, data, callback, true, headers, 0, "PATCH", queryParams);
    }

    /**
     * Centralized method for handling HTTP requests.
     * Includes error categorization and retry logic.
     */
    private static function sendRequest(
        url: String, 
        data: Dynamic, 
        callback: (Bool, Dynamic) -> Void, 
        isPost: Bool = false, 
        headers: StringMap<String> = null, 
        retries: Int = 0,
        method: String = "GET", 
        queryParams: StringMap<String> = null
    ): Void {
        // Check if max retries have been exceeded
        if (retries > MAX_RETRIES) {
            logError("Max retries exceeded", url, retries);
            safeCallback(callback, false, { error: "Max retries exceeded", url: url });
            return;
        }

        // Validate the URL
        var parsedUrl = validateUrl(url);
        if (parsedUrl == null) {
            logError("Invalid URL", url);
            safeCallback(callback, false, { error: "Invalid URL", url: url });
            return;
        }

        // Append query parameters if provided
        if (queryParams != null) {
            parsedUrl += "?" + buildQueryString(queryParams);
        }

        // Create a new HTTP request
        var http = new Http(parsedUrl);
        http.cnxTimeout = DEFAULT_TIMEOUT;

        // Set headers if provided
        if (headers != null) {
            for (key in headers.keys()) {
                http.setHeader(key, headers.get(key));
            }
        }

        // Prepare the HTTP request
        if (isPost || method != "GET") {
            http.setHeader("Content-Type", "application/json");
            if (data != null) {
                http.setPostData(Json.stringify(data));
            }
            //trace("Sending " + method + " request with data: " + Json.stringify(data));
        } else {
            //trace("Sending " + method + " request to: " + parsedUrl);
        }

        // Handle the response status
        http.onStatus = function(status) {
            //trace(method + " Status: " + status);
        };

        // Handle successful response
        http.onData = function(response) {
            //trace("Response received: " + response);
            safeCallback(callback, true, response);
        };

        // Handle errors
        http.onError = function(error) {
            var errorType = categorizeError(error);
            logError(errorType, url, retries);
            if (shouldRetry(errorType)) {
                //trace("Retrying... Attempt " + (retries + 1));
                sendRequest(url, data, callback, isPost, headers, retries + 1, method, queryParams);
            } else {
                safeCallback(callback, false, { error: errorType, details: error, url: url });
            }
        };

        // Execute the request
        http.request();
    }

    /**
     * Build a query string from a map of parameters.
     */
    private static function buildQueryString(params: StringMap<String>): String {
        var queryParams = [];
        for (key in params.keys()) {
            queryParams.push(key + "=" + StringTools.urlEncode(params.get(key)));
        }
        return queryParams.join("&");
    }

    /**
     * Categorize the error to determine its type (e.g., network, timeout).
     */
    private static function categorizeError(error: String): String {
        if (error.indexOf("Timeout") != -1) return "Timeout Error";
        if (error.indexOf("Connection refused") != -1) return "Connection Refused";
        if (error.indexOf("Invalid URL") != -1) return "Invalid URL";
        if (error.indexOf("Failed to connect") != -1) return "Failed to Connect";
        if (error.indexOf("Bad Request") != -1) return "Bad Request";
        if (error.indexOf("Unauthorized") != -1) return "Unauthorized";
        if (error.indexOf("Forbidden") != -1) return "Forbidden";
        if (error.indexOf("Not Found") != -1) return "Not Found";
        if (error.indexOf("Internal Server Error") != -1) return "Internal Server Error";
        if (error.indexOf("Service Unavailable") != -1) return "Service Unavailable";
        if (error.indexOf("Network is unreachable") != -1) return "Network Unreachable";
        if (error.indexOf("Host is down") != -1) return "Host Down";
        if (error.indexOf("SSL") != -1) return "SSL Error";
        if (error.indexOf("Too Many Requests") != -1) return "Too Many Requests";
        if (error.indexOf("Request Entity Too Large") != -1) return "Request Entity Too Large";
        if (error.indexOf("Unsupported Media Type") != -1) return "Unsupported Media Type";
        if (error.indexOf("Not Implemented") != -1) return "Not Implemented";
        if (error.indexOf("Gateway Timeout") != -1) return "Gateway Timeout";
        if (error.indexOf("HTTP") != -1) return "HTTP Error";
        return "General Error";
    }

    /**
     * Determine whether the request should be retried based on the error type.
     */
    private static function shouldRetry(errorType: String): Bool {
        return (
            errorType == "Network Error" || 
            errorType == "Timeout Error" || 
            errorType == "General Error" ||
            errorType == "Service Unavailable" ||
            errorType == "Connection Refused" ||
            errorType == "Failed to Connect" ||
            errorType == "Network Unreachable" ||
            errorType == "Host Down" ||
            errorType == "Gateway Timeout"
        );
    }

    /**
     * Log errors with relevant information (error type, URL, and retries).
     */
    private static function logError(error: String, url: String, retries: Int = 0): Void {
        //trace("Error occurred: " + error + " | URL: " + url + " | Retry: " + retries);
    }

    /**
     * Validate the URL and return it if valid; otherwise, return null.
     */
    private static function validateUrl(url: String): String {
        if (url == null || url.trim() == "") return null;
        var parsedUrl = new HttpUrl(url);
        return parsedUrl.valid ? parsedUrl.toString() : null;
    }

    /**
     * Safely execute the callback to avoid null references or crashes.
     */
    private static function safeCallback(
        callback: (Bool, Dynamic) -> Void, 
        success: Bool, 
        result: Dynamic
    ): Void {
        try {
            if (callback != null) {
                callback(success, result);
            } else {
                //trace("Warning: No callback provided.");
            }
        } catch (e: Dynamic) {
            //trace("Callback execution failed: " + e);
        }
    }
}
