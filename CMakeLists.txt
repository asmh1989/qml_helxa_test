cmake_minimum_required(VERSION 3.16)

project(qt-websockerts_demo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(OPENSSL_ROOT_DIR "C:/OpenSSL-Win64")


find_package(Qt6 6.2 REQUIRED COMPONENTS QML Gui Charts Quick Core QuickControls2 WebSockets)


qt_add_executable(appqt-websockerts_demo
    main.cpp
)

qt6_add_qml_module(appqt-websockerts_demo
    URI qt-websockerts_demo
    VERSION 1.0
    QML_FILES
        "Main.qml"
        "Header.qml"

    RESOURCES
        "qmldir"
        "qtquickcontrols2.conf"
        QML_FILES common.js
        QML_FILES Status.qml
        QML_FILES Mylabel.qml
        QML_FILES Toast.qml
        QML_FILES ToastManager.qml
        QML_FILES Mychart.qml
        SOURCES fileio.h fileio.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appqt-websockerts_demo PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqt-websockerts_demo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


target_link_libraries(appqt-websockerts_demo
    PRIVATE Qt6::QuickControls2
    Qt6::Quick
    Qt6::Core
    Qt6::Qml
    Qt6::WebSockets
    Qt6::Charts
    Qt::Gui
)

include(GNUInstallDirs)
install(TARGETS appqt-websockerts_demo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
