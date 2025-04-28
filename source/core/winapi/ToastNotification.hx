#if (windows && cpp)
package core.winapi;

import cpp.Lib;

#if cpp
@:cppInclude("./external/wintoastlib.h")
@:cppInclude("./external/wintoastlib.cpp")
@:cppFileCode('#define WinToastLib')
#end
class ToastNotification {
    public static function showToast(title:String, message:String, duration:String = "Short"):Void {
        untyped __cpp__('
            static WinToast* toast = WinToast::instance();
            if (!toast->isInitialized()) {
                WinToast::WinToastError error;
                toast->setAppName(L"HaxeApp");
                const auto aumi = WinToast::configureAUMI(L"MyCompany", L"MyApp", L"MySubApp", L"2025");
                toast->setAppUserModelId(aumi);
                if (!toast->initialize(&error)) {
                    printf("Cannot initialize WinToast: %d\\n", error);
                    return;
                }
            }

            WinToastTemplate templ(WinToastTemplate::Text02);
            templ.setTextField(std::wstring({0}.c_str()), WinToastTemplate::FirstLine);
            templ.setTextField(std::wstring({1}.c_str()), WinToastTemplate::SecondLine);
            
            // Set the toast duration based on input
            if ({2} == "Short") {
                templ.setDuration(WinToastTemplate::Short);  // Short duration (5 seconds)
            } else if ({2} == "Long") {
                templ.setDuration(WinToastTemplate::Long);   // Long duration (25 seconds)
            } else {
                templ.setDuration(WinToastTemplate::Short);  // Default to Short if invalid value
            }

            if (toast->showToast(templ, nullptr) == -1L) {
                printf("Failed to show toast\\n");
            }
        ', title, message, duration);
    }
}
#end
