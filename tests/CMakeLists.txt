add_subdirectory(qml)

if(ENABLE_AUTOPILOT)
    add_subdirectory(autopilot)
    add_subdirectory(data)
endif()
