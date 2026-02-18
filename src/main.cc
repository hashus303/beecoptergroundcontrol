#include "beeCopterApplication.h"
#include "beeCopterCommandLineParser.h"
#include "beeCopterLogging.h"
#include "beeCopterLoggingCategory.h"
#include "Platform.h"

#ifdef beeCopter_UNITTEST_BUILD
    #include "UnitTestList.h"
#endif

beeCopter_LOGGING_CATEGORY(MainLog, "Main")

int main(int argc, char *argv[])
{
    // --- Parse command line arguments ---
    const auto args = beeCopterCommandLineParser::parse(argc, argv);
    if (const auto exitCode = beeCopterCommandLineParser::handleParseResult(args)) {
        return *exitCode;
    }

    // --- Platform initialization ---
    if (const auto exitCode = Platform::initialize(argc, argv, args)) {
        return *exitCode;
    }

    beeCopterApplication app(argc, argv, args);

    beeCopterLogging::installHandler();

    Platform::setupPostApp();

    app.init();

    // --- Run application or tests ---
    const auto run = [&]() -> int {
        using beeCopterCommandLineParser::AppMode;
        switch (beeCopterCommandLineParser::determineAppMode(args)) {
#ifdef beeCopter_UNITTEST_BUILD
        case AppMode::ListTests:
        case AppMode::Test:
            return beeCopterUnitTest::handleTestOptions(args);
#endif
        case AppMode::BootTest:
            qCInfo(MainLog) << "Simple boot test completed";
            return 0;
        case AppMode::Gui:
            qCInfo(MainLog) << "Starting application event loop";
            return app.exec();
        }
        Q_UNREACHABLE();
    };

    const int exitCode = run();

    // --- Cleanup ---
    app.shutdown();

    qCInfo(MainLog) << "Exiting main";
    return exitCode;
}
