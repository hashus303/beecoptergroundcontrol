#include "beeCopterFileDialogController.h"
#include "beeCopterLoggingCategory.h"
#include "SettingsManager.h"
#include "AppSettings.h"

#include <QtCore/QDir>

beeCopter_LOGGING_CATEGORY(beeCopterFileDialogControllerLog, "QMLControls.beeCopterFileDialogController")

beeCopterFileDialogController::beeCopterFileDialogController(QObject *parent)
    : QObject(parent)
{
    qCDebug(beeCopterFileDialogControllerLog) << this;
}

beeCopterFileDialogController::~beeCopterFileDialogController()
{
    qCDebug(beeCopterFileDialogControllerLog) << this;
}

QStringList beeCopterFileDialogController::getFiles(const QString &directoryPath, const QStringList &nameFilters)
{
    qCDebug(beeCopterFileDialogControllerLog) << "getFiles" << directoryPath << nameFilters;

    QDir fileDir(directoryPath);
    const QFileInfoList fileInfoList = fileDir.entryInfoList(nameFilters,  QDir::Files, QDir::Name);

    QStringList files;
    for (const QFileInfo &fileInfo: fileInfoList) {
        qCDebug(beeCopterFileDialogControllerLog) << "getFiles found" << fileInfo.fileName();
        files << fileInfo.fileName();
    }

    return files;
}

bool beeCopterFileDialogController::fileExists(const QString &filename)
{
    return QFile(filename).exists();
}

QString beeCopterFileDialogController::fullyQualifiedFilename(const QString& directoryPath, const QString& filename, const QStringList& nameFilters)
{
    QString firstFileExtention;

    // Check that the filename has one of the specified file extensions

    bool extensionFound = true;
    if (nameFilters.count()) {
        extensionFound = false;
        for (const QString& nameFilter: nameFilters) {
            if (nameFilter.startsWith("*.")) {
                const QString fileExtension = nameFilter.right(nameFilter.length() - 2);
                if (fileExtension != "*") {
                    if (firstFileExtention.isEmpty()) {
                        firstFileExtention = fileExtension;
                    }
                    if (filename.endsWith(fileExtension)) {
                        extensionFound = true;
                        break;
                    }
                }
            } else if (nameFilter != "*") {
                qCWarning(beeCopterFileDialogControllerLog) << "unsupported name filter format" << nameFilter;
            }
        }
    }

    // Add the extension if it is missing
    QString filenameWithExtension = filename;
    if (!extensionFound) {
        filenameWithExtension = QStringLiteral("%1.%2").arg(filename).arg(firstFileExtention);
    }

    return (directoryPath + QStringLiteral("/") + filenameWithExtension);
}

void beeCopterFileDialogController::deleteFile(const QString &filename)
{
    QFile::remove(filename);
}

QString beeCopterFileDialogController::fullFolderPathToShortMobilePath(const QString &fullFolderPath)
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    const QString defaultSavePath = SettingsManager::instance()->appSettings()->savePath()->rawValueString();
    if (fullFolderPath.startsWith(defaultSavePath)) {
        const int lastDirSepIndex = fullFolderPath.lastIndexOf(QStringLiteral("/"));
        return (QCoreApplication::applicationName() + QStringLiteral("/") + fullFolderPath.right(fullFolderPath.length() - lastDirSepIndex));
    }
#else
    qCWarning(beeCopterFileDialogControllerLog) << Q_FUNC_INFO << "should only be used in mobile builds";
#endif
    return fullFolderPath;
}

QString beeCopterFileDialogController::urlToLocalFile(QUrl url)
{
    // For some strange reason on Qt6 running on Linux files returned by FileDialog are not returned as local file urls.
    // Seems to be new behavior with Qt6.
    if (url.isLocalFile()) {
        return url.toLocalFile();
    }

    return url.toString();
}
