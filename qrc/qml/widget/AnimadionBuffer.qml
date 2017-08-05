import QtQuick 2.7

Item {
    id: buffer

    property var _buf: []

    ParallelAnimation {
        id: head

        property int prelude
        property int duration
        property var callback

        running: false

        SequentialAnimation {
            PauseAnimation { duration: head.prelude }
            ScriptAction { script: head.callback() }
        }

        PauseAnimation { duration: head.duration }

        onStopped: {
            buffer._dispatch();
        }
    }

    function push(anim) {
        _buf.push(anim);
        _dispatch();
    }

    function clear() {
        head.stop();
        _buf = [];
    }

    function _dispatch() {
        if (_buf.length > 0 && !head.running) {
            var patch = _buf.shift();
            head.prelude = !!patch.prelude ? patch.prelude : 0;
            head.callback = patch.callback;
            head.duration = patch.duration;
            head.start();
        }
    }
}

