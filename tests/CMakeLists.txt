add_executable(test_phone
    test_phone.cpp
    ../src/ContactsModel.cpp
    ../src/RecentsModel.cpp
    ../src/PhoneController.cpp
    ../src/DtmfGenerator.cpp
)

target_link_libraries(test_phone PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::DBus
    Qt6::Multimedia
    Qt6::Test
    KF6::CoreAddons
    KF6::I18n
)

target_include_directories(test_phone PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/../src)

add_test(NAME test_phone COMMAND test_phone)
