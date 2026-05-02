cmake_minimum_required(VERSION 3.15)
project(ApolloBackend VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_CXX_EXTENSIONS OFF)

find_package(Threads REQUIRED)
find_package(Boost REQUIRED COMPONENTS json thread)

if(APPLE)
    list(APPEND CMAKE_PREFIX_PATH "/opt/homebrew" "/usr/local")
    find_package(PkgConfig REQUIRED)
    set(ENV{PKG_CONFIG_PATH} "/opt/homebrew/opt/libpq/lib/pkgconfig:/usr/local/opt/libpq/lib/pkgconfig:/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
    pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
    set(PQXX_LINK_TARGET PkgConfig::PQXX)

elseif(WIN32)
    find_package(libpqxx REQUIRED)
    set(PQXX_LINK_TARGET libpqxx::pqxx)

else()
    find_package(libpqxx QUIET)

    if(libpqxx_FOUND)
        set(PQXX_LINK_TARGET libpqxx::pqxx)
    else()
        find_package(PkgConfig REQUIRED)
        pkg_check_modules(PQXX REQUIRED IMPORTED_TARGET libpqxx)
        set(PQXX_LINK_TARGET PkgConfig::PQXX)
    endif()
endif()

find_package(OpenSSL REQUIRED)

add_executable(${PROJECT_NAME}
    main.cpp
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        Threads::Threads
        Boost::json
        Boost::thread 
        ${PQXX_LINK_TARGET}
        OpenSSL::SSL
        OpenSSL::Crypto
)

if(UNIX AND NOT APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE stdc++fs)
endif()
#try to avoid changing anything in the apple one because it took like an hour to get it to work on my laptop