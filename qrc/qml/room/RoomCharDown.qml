import QtQuick 2.7
import rolevax.sakilogy 1.0
import "../widget"
import "../game"

Room {
    id: room

    property int _currIndex: -1

    PGirlDown {
        id: pGirlDown

        onSignedReposReplied: {
            fetchingRepoList.visible = false;
            entryList.model = repos;
        }

        onRepoDownloadProgressed: {
            if (percent < 0) {
                downloadingText.text = "下载失败: " + percent;
                downloadingButton.text = "返回";
            } else if (percent >= 100) {
                downloadingText.text = "人物包同步成功\n" +
                        "新人物已添加到单人模式选人列表";
                downloadingButton.text = "完成";
            } else {
                downloadingText.text = "正在下载 " + percent + "%";
                downloadingButton.text = "取消";
            }
        }
    }

    Rectangle {
        id: listBackground
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: buttonColumn.left
        anchors.topMargin: 0.1 * parent.height
        anchors.bottomMargin: 0.1 * parent.height
        anchors.leftMargin: 0.1 * parent.width
        anchors.rightMargin: global.size.gap
        color: global.color.back
    }

    LisdView {
        id: entryList

        anchors.fill: listBackground
        spacing: global.size.space
        width: 0.4 * room.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        model: []

        delegate: Item {
            width: parent.width
            height: itemColumn.height

            Rectangle {
                visible: _currIndex === index
                anchors.fill: parent
                color: "#000044"
            }

            Column {
                id: itemColumn
                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: "[" + _textOfStatus(modelData.status) + "] " + modelData.name
                }

                Texd {
                    anchors.left: parent.left
                    anchors.leftMargin: global.size.space
                    text: "- UP主：" + modelData.uploader + "\n" +
                          "- GitHub地址：" + modelData.repo + "\n" +
                          "- 简介：" + modelData.desc
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    _currIndex = index;
                }
            }
        }
    }

    Texd {
        id: fetchingRepoList
        anchors.centerIn: entryList
        text: "正在获取人物包列表……"
    }

    Column {
        id: buttonColumn

        anchors.right: parent.right
        anchors.rightMargin: 0.1 * parent.width
        anchors.top: listBackground.top
        width: 0.36 * listBackground.height

        spacing: global.size.space

        Buzzon {
            text: "更新人物包"
            width: parent.width
            enabled: _currIndex >= 0 &&
                     !!entryList.model[_currIndex] &&
                     entryList.model[_currIndex].updatable
            onClicked: {
                downloading.visible = true;
                let entry = entryList.model[_currIndex];
                pGirlDown.downloadRepo(entry.repo, entry.name);
            }
        }

        Buzzon {
            text: "长按删除"
            width: parent.width
            enabled: _currIndex >= 0 &&
                     !!entryList.model[_currIndex] &&
                     entryList.model[_currIndex].deletable
            onLongClicked: {
                PEditor.removeRepo(entryList.model[_currIndex].repo);
                _fetchRepoList();
            }
        }

        Buzzon {
            text: "投稿"
            width: parent.width
            onClicked: {
                Qt.openUrlExternally("https://mjpancake.github.io/upload-girl");
            }
        }
    }

    Rectangle {
        id: downloading
        visible: false
        anchors.fill: parent
        color: global.color.back

        Texd {
            id: downloadingText
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // click blocker
            }
        }

        Buzzon {
            id: downloadingButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: global.size.space
            textLength: 8
            onClicked: {
                pGirlDown.cancelDownload();
                downloading.visible = false;
                _fetchRepoList()
            }
        }
    }

    Component.onCompleted: {
        _fetchRepoList();
    }

    function _textOfStatus(status) {
        var dict = {
            CALCULATING: "计算中",
            LATEST: "已最新",
            CAN_INIT: "可下载",
            CAN_UPDATE: "可更新",
            INVALID_NAME: "仓库名非法",
            REMOTE_TAN90: "仓库不存在",
            REMOTE_DATE_ERROR: "仓库异常"
        };

        var str = dict[status];
        return !!str ? str : status;
    }

    function _fetchRepoList() {
        entryList.model = [];
        fetchingRepoList.visible = true;
        pGirlDown.fetchSignedRepos();
    }
}
