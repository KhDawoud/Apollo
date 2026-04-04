cmake_minimum_required(VERSION 3.16)

project(Apollo VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appApollo
    main.cpp
)

qt_add_qml_module(appApollo
    URI Apollo
    VERSION 1.0
    QML_FILES
        Main.qml
    RESOURCES
        images/logo.png
        images/defaultpfp.png
        images/python.png
        images/cpp.png
        images/javascript.png
        images/go.png
        images/rust.png
        images/java.png
        images/csharp.png
        images/ruby.png
        images/1st.png
        images/2nd.png
        images/3rd.png
        QML_FILES LeaderBoard.qml
        QML_FILES Problems.qml
        QML_FILES LanguageSelect.qml
        QML_FILES ProblemTable.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appApollo PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appApollo
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appApollo
    PRIVATE Qt6::Quick
)
target_link_libraries(appApollo
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appApollo
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
