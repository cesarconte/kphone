set(kphone_SRCS
    main.cpp
    PhoneController.h
    PhoneController.cpp
    ContactsModel.h
    ContactsModel.cpp
    RecentsModel.h
    RecentsModel.cpp
    DtmfGenerator.h
    DtmfGenerator.cpp
    kphone.qrc
)

add_executable(kphone ${kphone_SRCS})

target_link_libraries(kphone PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::DBus
    Qt6::Multimedia
    KF6::CoreAddons
    KF6::I18n
    KF6::Kirigami
)

target_include_directories(kphone PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

install(TARGETS kphone DESTINATION ${KDE_INSTALL_BINDIR})
install(FILES ../data/org.cesar.kphone.desktop DESTINATION ${KDE_INSTALL_APPDIR})
install(FILES resources/icons/kphone.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
