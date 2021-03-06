IF (${CMAKE_BUILD_TYPE} STREQUAL Release)

  IF(UNIX AND NOT APPLE)
    string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWERCASE)
    SET(BIN_INSTALL_DIR "bin")
    SET(DOC_INSTALL_DIR "share/doc/${PROJECT_NAME_LOWERCASE}/")
  else()
    SET(BIN_INSTALL_DIR ".")
    SET(DOC_INSTALL_DIR ".")
  ENDIF()

  IF(APPLE)
    SET(MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")
    SET(MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_NAME} ${PROJECT_VERSION}")
    SET(MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_NAME} ${PROJECT_VERSION}")
    SET(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}")
    SET(MACOSX_BUNDLE_COPYRIGHT "${PROJECT_COPYRIGHT_YEAR} ${PROJECT_VENDOR}")
    SET(MACOSX_BUNDLE_GUI_IDENTIFIER "${PROJECT_DOMAIN_SECOND}.${PROJECT_DOMAIN_FIRST}")
    SET(MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}")
    SET(MACOSX_BUNDLE_RESOURCES "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.app/Contents/Resources")
    # SET(MACOSX_BUNDLE_ICON_FILE "audio-input-microphone.icns")
    # SET(MACOSX_BUNDLE_ICON "${ICONS_DIR}/${MACOSX_BUNDLE_ICON_FILE}")
    # execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${MACOSX_BUNDLE_RESOURCES})
    # execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${MACOSX_BUNDLE_ICON} ${MACOSX_BUNDLE_RESOURCES})
  ENDIF()

  IF(APPLE)
    SET(CMAKE_INSTALL_PREFIX "/Applications")
  ENDIF()
  MESSAGE(STATUS "${PROJECT_NAME} will be installed to ${CMAKE_INSTALL_PREFIX}")
  INSTALL(TARGETS ${PROJECT_NAME} DESTINATION ${BIN_INSTALL_DIR})

  SET(LICENSE_FILE "LICENSE.txt")
  SET(README_FILE "README.md")
  IF(NOT APPLE)
    INSTALL(FILES "${LICENSE_FILE}" "${README_FILE}" DESTINATION ${DOC_INSTALL_DIR})
  ENDIF()

  SET(CPACK_GENERATOR "TBZ2")
  SET(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
  SET(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
  SET(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
  SET(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
  SET(CPACK_PACKAGE_VENDOR "${PROJECT_VENDOR}")
  SET(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/${README_FILE}")
  IF(WIN32)
    SET(CPACK_GENERATOR "NSIS")
    SET(CPACK_PACKAGE_EXECUTABLES "${PROJECT_NAME}" "${PROJECT_NAME}")
    SET(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}")
    SET(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME} ${PROJECT_VERSION}")
    SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/${LICENSE_FILE}")
    SET(CPACK_NSIS_EXECUTABLES_DIRECTORY "${BIN_INSTALL_DIR}")
    #SET(CPACK_NSIS_MUI_ICON "${PROJECT_ICONS_DIRECTORY}/NSIS.ico")
    #SET(CPACK_PACKAGE_ICON "${PROJECT_ICONS_DIRECTORY}\\\\NSISHeader.bmp")
    SET(CPACK_NSIS_URL_INFO_ABOUT "http://${PROJECT_DOMAIN}")
    SET(CPACK_NSIS_INSTALLED_ICON_NAME "${PROJECT_NAME}${CMAKE_EXECUTABLE_SUFFIX}")
    SET(CPACK_NSIS_MENU_LINKS "${LICENSE_FILE}" "License" "${README_FILE}" "Readme")
    SET(CPACK_NSIS_MUI_FINISHPAGE_RUN "${CPACK_NSIS_INSTALLED_ICON_NAME}")
  ELSEIF(APPLE)
    SET(CPACK_GENERATOR "DragNDrop")
    SET(CPACK_DMG_FORMAT "UDBZ")
    SET(CPACK_DMG_VOLUME_NAME "${PROJECT_NAME}")
    SET(CPACK_SYSTEM_NAME "OSX")
    SET(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}")
    #SET(CPACK_PACKAGE_ICON "${ICONS_DIR}/DMG.icns")
    #SET(CPACK_DMG_DS_STORE "${ICONS_DIR}/DMGDSStore")
    #SET(CPACK_DMG_BACKGROUND_IMAGE "${ICONS_DIR}/DMGBackground.png")
  ELSEIF(UNIX)
    SET(CPACK_SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
  ENDIF()

  INCLUDE(CPack)

  IF(APPLE)
    SET(EXECUTABLE "${PROJECT_NAME}.app")
  ELSEIF(WIN32)
    SET(EXECUTABLE "${PROJECT_NAME}${CMAKE_EXECUTABLE_SUFFIX}")
  ELSE()
    SET(EXECUTABLE "${BIN_INSTALL_DIR}/${PROJECT_NAME}${CMAKE_EXECUTABLE_SUFFIX}")
  ENDIF()

  IF(APPLE)
    SET(EXE_CONTENTS "${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}/Contents")
    FILE(WRITE
      ${EXE_CONTENTS}/Resources/qt.conf
      "[Paths]\nPlugins=PlugIns\n")
    FILE(COPY ${QT_PLUGINS_DIR}/imageformats
      DESTINATION ${EXE_CONTENTS}/PlugIns/
      PATTERN "*_debug.*" EXCLUDE)
    ADD_CUSTOM_COMMAND(
      TARGET ${PROJECT_NAME} POST_BUILD
      COMMAND ruby ${CMAKE_SOURCE_DIR}/ruby/fixup/fixup.rb ${EXECUTABLE}
      COMMENT "Fixing up the app bundle")
  ENDIF(APPLE)

ENDIF (${CMAKE_BUILD_TYPE} STREQUAL Release)

