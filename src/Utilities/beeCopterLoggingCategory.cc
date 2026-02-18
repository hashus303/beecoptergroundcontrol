#include "beeCopterLoggingCategory.h"

#include <QtCore/QGlobalStatic>
#include <QtCore/QSettings>

beeCopter_LOGGING_CATEGORY(beeCopterLoggingCategoryRegisterLog, "Utilities.beeCopterLoggingCategoryManager")

Q_GLOBAL_STATIC(beeCopterLoggingCategoryManager, _beeCopterLoggingCategoryManagerInstance);

beeCopterLoggingCategoryManager *beeCopterLoggingCategoryManager::instance()
{
    return _beeCopterLoggingCategoryManagerInstance();
}

void beeCopterLoggingCategoryManager::_insertSorted(QmlObjectListModel* model, beeCopterLoggingCategoryItem* item)
{
    for (int i=0; i<model->count(); i++) {
        auto existingItem = qobject_cast<beeCopterLoggingCategoryItem*>(model->get(i));
        if (item->fullCategory < existingItem->fullCategory) {
            model->insert(i, item);
            return;
        }
    }
    model->append(item);
}

void beeCopterLoggingCategoryManager::registerCategory(const QString &fullCategory)
{
    //qDebug() << "Registering logging full category" << fullCategory;

    QString parentCategory;
    QString childCategory(fullCategory);
    auto currentParentModel = &_treeCategoryModel;

    auto hierarchyIndex = fullCategory.indexOf(".");
    if (hierarchyIndex != -1) {
        parentCategory = fullCategory.left(hierarchyIndex);
        childCategory = fullCategory.mid(hierarchyIndex + 1);
        QString fullParentCategory = parentCategory + ".";
        //qDebug() << "  Parent category" << parentCategory << "child category" << childCategory << "full parent category" << fullParentCategory;

        bool found = false;
        for (int j=0; j<currentParentModel->count(); j++) {
            auto item = qobject_cast<beeCopterLoggingCategoryItem*>(currentParentModel->get(j));
            if (item->fullCategory == fullParentCategory && item->children) {
                //qDebug() << "  Found existing parent full category" << item->fullCategory;
                currentParentModel = item->children;
                found = true;
                break;
            }
        }
        if (!found) {
            auto newParentItem = new beeCopterLoggingCategoryItem(parentCategory, fullParentCategory, false /* enabled */, currentParentModel);
            newParentItem->children = new QmlObjectListModel(newParentItem);
            _insertSorted(&_flatCategoryModel, newParentItem);
            _insertSorted(currentParentModel, newParentItem);
            currentParentModel = newParentItem->children;
            //qDebug() << "  New parent full category" << newParentItem->fullCategory;
        }
    }

    auto categoryItem = new beeCopterLoggingCategoryItem(childCategory, fullCategory, false /* enabled */, currentParentModel);
    _insertSorted(&_flatCategoryModel, categoryItem);
    _insertSorted(currentParentModel, categoryItem);
    //qDebug() << "  New category full category" << categoryItem->fullCategory << "childCategory" << childCategory;
}

void beeCopterLoggingCategoryManager::setCategoryLoggingOn(const QString &fullCategoryName, bool enable)
{
    qCDebug(beeCopterLoggingCategoryRegisterLog) << "Set category logging" << fullCategoryName << enable;

    QSettings settings;
    settings.beginGroup(kFilterRulesSettingsGroup);
    if (enable) {
        settings.setValue(fullCategoryName, enable);
    } else {
        settings.remove(fullCategoryName);
    }

    setFilterRulesFromSettings(QString());
}

bool beeCopterLoggingCategoryManager::categoryLoggingOn(const QString &fullCategoryName)
{
    QSettings settings;

    settings.beginGroup(kFilterRulesSettingsGroup);
    return settings.value(fullCategoryName, false).toBool();
}

void beeCopterLoggingCategoryManager::setFilterRulesFromSettings(const QString &commandLineLoggingOptions)
{
    QString filterRules;
    QString filterRuleFormat("%1.debug=true\n");

    QSettings settings;
    settings.beginGroup(kFilterRulesSettingsGroup);
    for (const QString &fullCategoryName : settings.childKeys()) {
        QString parentCategory;
        QString childCategory;
        _splitFullCategoryName(fullCategoryName, parentCategory, childCategory);

        qCDebug(beeCopterLoggingCategoryRegisterLog) << "Setting filter rule for saved settings" << fullCategoryName << parentCategory << childCategory << settings.value(fullCategoryName).toBool();

        auto categoryItem = _findLoggingCategory(fullCategoryName);
        if (categoryItem) {
            categoryItem->setEnabled(settings.value(fullCategoryName).toBool());
            if (categoryItem->enabled()) {
                if (childCategory.isEmpty()) {
                    // Wildcard parent category
                    filterRules += filterRuleFormat.arg(fullCategoryName + "*");
                } else {
                    filterRules += filterRuleFormat.arg(fullCategoryName);
                }
            }
        } else {
            qCWarning(beeCopterLoggingCategoryRegisterLog) << "Category not found for saved settings" << fullCategoryName;
        }
    }

    // Command line rules take precedence, so they go last in the list
    if (!commandLineLoggingOptions.isEmpty()) {
        const QStringList categoryList = commandLineLoggingOptions.split(",");

        if (categoryList[0] == QStringLiteral("full")) {
            filterRules += filterRuleFormat.arg("*");
        } else {
            for (const QString &category: categoryList) {
                filterRules += filterRuleFormat.arg(category);
            }
        }
    }

    filterRules += QStringLiteral("qt.qml.connections=false");

    qCDebug(beeCopterLoggingCategoryRegisterLog) << "Filter rules" << filterRules;
    QLoggingCategory::setFilterRules(filterRules);
}

void beeCopterLoggingCategoryManager::_splitFullCategoryName(const QString &fullCategoryName, QString &parentCategory, QString &childCategory)
{
    const int hierarchyIndex = fullCategoryName.indexOf(".");
    if (hierarchyIndex == -1) {
        parentCategory = QString();
        childCategory = fullCategoryName;
    } else {
        parentCategory = fullCategoryName.left(hierarchyIndex);
        childCategory = fullCategoryName.mid(hierarchyIndex + 1);
    }
}

void beeCopterLoggingCategoryManager::disableAllCategories()
{
    QSettings settings;
    settings.beginGroup(kFilterRulesSettingsGroup);
    settings.remove("");

    for (int i=0; i<_flatCategoryModel.count(); i++) {
        auto item = qobject_cast<beeCopterLoggingCategoryItem*>(_flatCategoryModel.get(i));
        item->setEnabled(false);
    }

    setFilterRulesFromSettings(QString());
}

beeCopterLoggingCategoryItem *beeCopterLoggingCategoryManager::_findLoggingCategory(const QString &fullCategoryName)
{
    for (int i=0; i<_flatCategoryModel.count(); i++) {
        auto item = qobject_cast<beeCopterLoggingCategoryItem*>(_flatCategoryModel.get(i));
        if (item->fullCategory == fullCategoryName) {
            return item;
        }
    }

    return nullptr;
}

beeCopterLoggingCategoryItem::beeCopterLoggingCategoryItem(const QString& shortCategory_, const QString& fullCategory_, bool enabled_, QObject* parent)
    : QObject(parent)
    , shortCategory(shortCategory_)
    , fullCategory(fullCategory_)
    , _enabled(enabled_)
{
    connect(this, &beeCopterLoggingCategoryItem::enabledChanged, this, [this]() {
        beeCopterLoggingCategoryManager::instance()->setCategoryLoggingOn(this->fullCategory, this->_enabled);
    });
}

void beeCopterLoggingCategoryItem::setEnabled(bool enabled)
{
    if (enabled != _enabled) {
        _enabled = enabled;
        emit enabledChanged();
    }
}
