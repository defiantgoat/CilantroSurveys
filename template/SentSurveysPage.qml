/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.3
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0


SurveysListPage {
    title: qsTr("Sent %1").arg(surveyTitle)
    statusFilter: xformsDatabase.statusSubmitted
    showDelete: false

    listAction: ConfirmButton {
        text: qsTr("Empty")
        iconSource: "images/trash_bin.png"

        onClicked: {
            xformsDatabase.deleteSurveyBox(surveyInfo.name, xformsDatabase.statusSubmitted);
            closePage();
        }
    }
}
