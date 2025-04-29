# HyperCode Engine Lua API

---

This document outlines the Lua API extensions available in the HyperCode Engine. These extensions provide additional functionality beyond standard Lua, allowing for more complex and powerful modding capabilities.
WAIT FOR 2.0 Document.

---


### **BrainFuck**
**Purpose:**  
This class allows you to run Brainfuck code in Lua through the `runBrainFuckCode` callback.

**Functions:**
- **runBrainFuckCode(code: String, input: String): String**  
  - **Description:** Runs Brainfuck code and returns the output.  
  - **Arguments:**
    - `code` (String) - The Brainfuck code to execute.
    - `input` (String) - Optional comma-separated input values for Brainfuck (e.g., `"1,2,3"`).
  - **Returns:** A string output of the Brainfuck execution, or an error message.

---

### **GetArgs**
**Purpose:**  
This class allows Lua to retrieve the arguments passed to the application.

**Functions:**
- **appGetArgs(): Table of String**  
  - **Description:** Retrieves the arguments passed to the application at startup.
  - **Returns:** An array of strings representing the command-line arguments.

---

### **HttpClient**
  **Purpose:**  
  This class allows Lua to interact with HTTP requests (GET, POST, PUT, DELETE, PATCH) and check for internet availability.
  
  **Functions:**
  - **hasInternet(): Table**  
    - **Description:** Checks if the system has internet access.
    - **Returns:** `true` if there is internet access, `false` otherwise.
  
  - **getRequest(url: String, headers: Dynamic, queryParams: Dynamic): Table**  
    - **Description:** Performs an HTTP GET request.
    - **Arguments:**
      - `url` (String) - The URL to send the request to.
      - `headers` (Dynamic) - Optional headers.
      - `queryParams` (Dynamic) - Optional query parameters.
    - **Returns:** The response from the GET request.
  
  - **postRequest(url: String, data: Table, headers: Dynamic, queryParams: Dynamic): Table**  
    - **Description:** Performs an HTTP POST request.
    - **Arguments:** Same as `getRequest`, with the addition of `data` for POST body.
    - **Returns:** The response from the POST request.
  
  - **putRequest(url: String, data: Table, headers: Dynamic, queryParams: Dynamic): Table**  
    - **Description:** Performs an HTTP PUT request.
    - **Returns:** The response from the PUT request.
  
  - **deleteRequest(url: String, headers: Dynamic, queryParams: Dynamic): Table**  
    - **Description:** Performs an HTTP DELETE request.
    - **Returns:** The response from the DELETE request.
  
  - **patchRequest(url: String, data: Dynamic, headers: Dynamic, queryParams: Dynamic): Table**  
    - **Description:** Performs an HTTP PATCH request.
    - **Returns:** The response from the PATCH request.

---

### **JsonHelper**
  **Purpose:**  
  This class allows Lua to easily parse and stringify JSON data.
  
  **Functions:**
  - **jsonParse(jsonString: String): Table**  
    - **Description:** Parses a JSON string into a Lua object.
    - **Returns:** A dynamic object representing the parsed JSON.
  
  - **jsonStringify(data: Table): String**  
    - **Description:** Converts a Lua object into a JSON string.
    - **Returns:** A JSON string representation of the Lua object.
  
  ---
  
  ### **ScreenInfo**
  **Purpose:**  
  This class allows Lua to retrieve screen resolutions.
  
  **Functions:**
  - **getScreensInfo(): Table**  
    - **Description:** Retrieves resolutions of all connected screens.
    - **Returns:** A map with screen ID as the key, and a map containing `width` and `height` as the value.
  
  - **getMainScreenInfo(): Table**  
    - **Description:** Retrieves the resolution of the main screen.
    - **Returns:** A map with screen ID as the key, and `width` and `height` as the value.

---

### **UrlGen**
  **Purpose:**  
  This class allows Lua to generate and manipulate URLs.
  
  **Functions:**
  - **createUrlGen(tag: String, url: String): Bool**  
    - **Description:** Creates a new `UrlGen` object with the specified tag and URL.
    - **Arguments:**
      - `tag` (String) - The identifier for the URL generator.
      - `url` (String) - The base URL.
    - **Returns:** `true` if the URL generator was created successfully, otherwise `false`.
  
  - **getUrlGen(tag: String): String**  
    - **Description:** Retrieves an existing `UrlGen` object by its tag.
    - **Returns:** The `UrlGen` object associated with the tag, or `null` if not found.
  
  - **removeUrlGen(tag: String): Bool**  
    - **Description:** Removes the `UrlGen` object associated with the given tag.
    - **Returns:** `true` if the `UrlGen` was successfully removed, otherwise `false`.
  
  - **clearUrlGen(): Void**  
    - **Description:** Clears all `UrlGen` objects.
    - **Returns:** None.
  
  - **appendQueryUrlGen(tag: String, query: String, value: String): Bool**  
    - **Description:** Appends a query parameter to the `UrlGen` object.
    - **Returns:** `true` if the query was added successfully, otherwise `false`.
  
  - **appendPathUrlGen(tag: String, path: String): Bool**  
    - **Description:** Appends a path segment to the `UrlGen` object.
    - **Returns:** `true` if the path was added successfully, otherwise `false`.

---

### **WindowManager** (Desktop Only)
  **Purpose:**  
  This class allows Lua to manage windows, including creating, retrieving, removing, and configuring them.
  
  **Functions:**
  - **createWindow(tag: String, attributes: Dynamic): Bool**  
    - **Description:** Creates a new window with the specified attributes.
    - **Returns:** `true` if the window was created successfully, otherwise `false`.
  
  - **getWindow(tag: String): Window**  
    - **Description:** Retrieves the window associated with the given tag.
    - **Returns:** The `Window` object associated with the tag, or `null` if not found.
  
  - **removeWindow(tag: String): Bool**  
    - **Description:** Closes and removes the window associated with the tag.
    - **Returns:** `true` if the window was removed successfully, otherwise `false`.
  
  - **clearWindow(): Void**  
    - **Description:** Closes and removes all windows.
    - **Returns:** None.
  
  - **configWindow(tag: String, variable: String, set: Dynamic): Void**  
    - **Description:** Configures a property of the window associated with the tag.
    - **Returns:** None.