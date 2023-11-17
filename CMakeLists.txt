cmake_minimum_required(VERSION 3.16)

project(qt-websockerts VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.3 REQUIRED COMPONENTS Gui
    Charts Quick Core QuickControls2 WebSockets SerialPort
    PrintSupport
)

add_subdirectory(Qt-AES)

if(QT_KNOWN_POLICY_QTP0001)
    qt_policy(SET QTP0001 OLD)
endif()

qt_add_executable(appqt-websockerts
    images.qrc
    src/main.cpp
)

qt6_add_qml_module(appqt-websockerts
    URI qt-websockerts
    VERSION 1.0
    QML_FILES
        "Main.qml"
        "Header.qml"

    RESOURCES
#        "qmldir"
        "qtquickcontrols2.conf"
        QML_FILES common.js
        QML_FILES Status.qml
        QML_FILES Toast.qml
        QML_FILES ToastManager.qml
        QML_FILES Sno.qml
        SOURCES src/fileio.h src/fileio.cpp
        SOURCES src/singletonmanager.h src/singletonmanager.cpp
        SOURCES src/utils.h src/utils.cpp
        SOURCES src/model.h
        QML_FILES Fenomode.qml
        QML_FILES Ball.qml
        QML_FILES view/MyLabel.qml
        QML_FILES view/MyEdit.qml
        QML_FILES Snodataview.qml
        QML_FILES Rootview.qml
        QML_FILES view/MySlide.qml
        SOURCES src/qmlemsocket.h src/qmlemsocket.cpp
        QML_FILES view/PreviewWindow.qml
        QML_FILES view/Smile.qml
        QML_FILES view/NewFenoMode.qml
)




# foreach(RESOURCE ${RESOURCE_FILES})
#     configure_file(${CMAKE_CURRENT_SOURCE_DIR}/${RESOURCE} ${CMAKE_CURRENT_BINARY_DIR}/${RESOURCE} COPYONLY)
# endforeach()


# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appqt-websockerts PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appqt-websockerts
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


target_link_libraries(appqt-websockerts
    PRIVATE Qt6::QuickControls2
    Qt6::Quick
    Qt6::Core
    Qt6::WebSockets
    Qt6::Charts
    Qt::Gui
    Qt6::SerialPort
    Qt6::PrintSupport
    QtAES
)

include(GNUInstallDirs)
install(TARGETS appqt-websockerts
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
