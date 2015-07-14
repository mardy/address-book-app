 /*
 * Copyright (C) 2012-2015 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtContacts 5.0

import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0

import Ubuntu.Contacts 0.1
import Ubuntu.AddressBook.Base 0.1

ContactDetailBase {
    id: root

    property alias active: sourceModel.autoUpdate

    function save() {
        // only changes the target sync for new contacts
        if (!isNewContact) {
            return;
        }
        var activeSource = getSelectedSource()
        if (!activeSource) {
            return;
        }

        if (!root.detail) {
            root.detail = root.contact.syncTarget
        }
        root.detail.syncTarget = activeSource
    }

    function getSelectedSource() {
        var selectedContact = sources.model.contacts[sources.selectedIndex]
        if (selectedContact) {
            return selectedContact.guid.guid
        } else {
            return -1
        }
    }

    property bool isNewContact: contact && contact.contactId === "qtcontacts:::"
    property real myHeight: sources.currentlyExpanded ? sources.containerHeight + units.gu(6) + label.height : sources.itemHeight + units.gu(6) + label.height

    detail: root.contact ? contact.detail(ContactDetail.SyncTarget) : null
    implicitHeight: root.isNewContact &&  sources.model && (sources.model.contacts.length > 1) ? myHeight : 0

    ContactModel {
        id: sourceModel

        manager: (typeof(QTCONTACTS_MANAGER_OVERRIDE) !== "undefined") && (QTCONTACTS_MANAGER_OVERRIDE != "") ? QTCONTACTS_MANAGER_OVERRIDE : "galera"
        filter:  DetailFilter {
            detail: ContactDetail.Type
            field: Type.TypeField
            value: Type.Group
            matchFlags: DetailFilter.MatchExactly
        }
        autoUpdate: false
    }

    Label {
        id: label

        text: i18n.dtr("address-book-app", "Addressbook")
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            margins: units.gu(2)
        }
        height: units.gu(4)
    }

    ThinDivider {
        id: divider

        anchors.top: label.bottom
    }

    OptionSelector {
        id: sources

        model: sourceModel
        anchors {
            left: parent.left
            leftMargin: units.gu(2)
            top: divider.bottom
            topMargin: units.gu(2)
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(2)
        }

        delegate: OptionSelectorDelegate {
            text: contact.displayLabel.label
            constrainImage: true
            iconSource: {
                var details = contact.details(ContactDetail.ExtendedDetail)
                for(var i in details) {
                    if (details[i].name === "PROVIDER") {
                        if (details[i].data === "") {
                            return "image://theme/address-book-app-symbolic"
                        } else {
                            return "image://theme/online-accounts-%1".arg(details[i].data)
                        }
                    }
                }
                return "image://theme/address-book-app-symbolic"
            }
            height: units.gu(4)
        }

        containerHeight: sources.model && sources.model.contacts.length > 4 ? itemHeight * 4 : sources.model ? itemHeight * sources.model.contacts.length : 0
    }

    onActiveChanged: {
        if (active) {
            sourceModel.update()
        }
    }
}

