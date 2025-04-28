#if (windows && cpp)
package core.winapi;

import cpp.Lib;

@:cppInclude("./external/wintoastlib.h")
@:cppFileCode('
#include "./external/wintoastlib.cpp"
')
class ToastNotification {
    public static function showToast(title:String, message:String):Void {
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

            if (toast->showToast(templ, nullptr) == -1L) {
                printf("Failed to show toast\\n");
            }
        ', title, message);
    }
}
#end
