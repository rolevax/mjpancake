.pragma library

var names = {
    // *** SYNC with libsaki/Girl.h enum 'Id'
    // *** SYNC with schoolData
    "-1": "???", "-2": "総合",
    "0": "須賀京太郎",

    // IH-71/A-block
    "710111": "宮永照", "710112": "弘世菫", "710113": "渋谷尭深",
        "710114": "亦野誠子", "710115": "大星淡",
    "710411": "花田煌", "710412": "安河内美子", "710413": "江崎仁美",
        "710414": "白水哩", "710415": "鶴田姫子",
    "712411": "松実玄", "712412": "松実宥", "712413": "新子憧",
        "712414": "鷺森灼", "712415": "高鴨穏乃",
    "712401": "小走やえ",
    "712611": "園城寺怜", "712612": "二条泉", "712613": "江口セーラ",
        "712614": "船久保浩子", "712615": "清水谷竜華",
    "712621": "荒川憩",

    // IH-71/B-block
    "712711": "神代小蒔", "712712": "狩宿巴", "712713": "滝見春",
        "712714": "薄墨初美", "712715": "石戸霞",
    "712701": "藤原利仙",
    "712911": "小瀬川白望", "712912": "Aislinn Wishart", "712913": "鹿倉胡桃",
        "712914": "臼沢塞", "712915": "姉帯豊音",
    "713311": "片岡優希", "713312": "染谷まこ", "713313": "竹井久",
        "713314": "原村和", "713315": "宮永咲",
    "713321": "井上純", "713322": "沢村智紀", "713323": "国広一",
        "713324": "龍門渕透華", "713325": "天江衣",
    "713331": "津山睦月", "713332": "妹尾佳織", "713333": "蒲原智美",
        "713334": "東横桃子", "713335": "加治木ゆみ",
    "713341": "福路美穂子", "713342": "吉留未春", "713343": "文堂星夏",
        "713344": "深堀純代", "713345": "池田華菜",
    "713301": "南浦数絵", "713302": "夢乃マホ",
    "713613": "佐々野いちご",
    "713811": "上重漫",  "713812": "真瀬由子", "713813": "愛宕洋榎",
        "713814": "愛宕絹恵", "713815": "末原恭子",
    "714911": "本内成香", "714912": "桧森誓子", "714913": "岩馆摇杏",
        "714914": "真屋由暉子", "714915": "獅子原爽",
    "715211": "辻垣内智葉", "715212": "郝慧宇", "715213": "雀明華",
        "715214": "Megan Davin", "715215": "Nelly Virsaladze",

    // 99xxxx are temporarily uncatagorized names
    // should be kept in this map and deleted in all other places
    // when an accurate id is assigned
    "990001": "稲村杏果", "990002": "白築慕", "990003": "本藤悠慧",
        "990004": "瑞原はやり", "990005": "石飛閑無",
    "990006": "赤土晴絵", "990007": "新子望", "990008": "小鍛治健夜",
        "990009": "戒能良子", "990010": "藤田靖子",
    "990011": "三尋木咏", "990012": "野依理沙", "990013": "小禄心",
        "990014": "多久和李緒", "990015": "森脇曖奈",
    "990016": "藤白七実", "990017": "椋千尋", "990018": "永見知子",
        "990019": "野上葉子", "990020": "Lotta Niemann",
    "990021": "白築ナナ", "990022": "Ai Arctander", "990023": "松実露子",
        "990024": "楫野結衣"
};

var allIds = Object.keys(names).reduce(
    function(a, str) {
        var num = Number(str);
        if (num >= 0)
            a.push(num);
        return a;
    },
    []
);

var schoolData = {
    "0": {
        "name": "Debug",
        "members": [ 0 ]
    },
    "71011": {
        "name": "白糸台高校",
        "members": [ 710112, 710113, 710114, 710115 ]
    },
    "71241": {
        "name": "阿知賀女子学院",
        "members": [ 712411, 712412, 712413 ]
    },
    "71261": {
        "name": "千里山女子高校",
        "members": [ 712611, 712613 ]
    },
    "71271": {
        "name": "永水女子高校",
        "members": [ 712714, 712715 ]
    },
    "71291": {
        "name": "宮守女子高校",
        "members": [ 712915 ]
    },
    "71331": {
        "name": "清澄高校",
        "members": [ 713311, 713314 ]
    },
    "71330": {
        "name": "Uncategorized 長野",
        "members": [ 713301 ]
    },
    "71381": {
        "name": "姫松高校",
        "members": [ 713811, 713815 ]
    },
    "71491": {
        "name": "有珠山高校",
        "members": [ 714915 ]
    },
    "71521": {
        "name": "臨海女子高校",
        "members": [ 715212 ]
    },
    "9900": {
        "name": "Uncategorized",
        "members": [ 990001, 990002, 990003, 990011, 990014, 990024 ]
    }
};

var availSchools = Object.keys(schoolData);

var availIds = availSchools.reduce(
    function(a, sid) { return a.concat(schoolData[sid].members); },
    []
);

function getName(girlKey, pEditor) {
    if (!girlKey)
        return "falsy key";

    if (girlKey.id === 1)
        return pEditor.getName(girlKey.path);

    return "" + names[girlKey.id];
}

function genId() {
    return availIds[Math.floor(Math.random() * availIds.length)];
}

function genAvailIndex() {
    return Math.floor(Math.random() * availIds.length);
}

function genIndices() {
    var res = [ 0, 0, 0, 0 ];
    res[0] = genAvailIndex();
    do {
        res[1] = genAvailIndex();
    } while (res[1] === res[0]);
    do {
        res[2] = genAvailIndex();
    } while (res[2] === res[0] || res[2] === res[1]);
    do {
        res[3] = genAvailIndex();
    } while (res[3] === res[0] || res[3] === res[1] || res[3] === res[2]);
    return res;
}

// "abc${710111}xyz" -> "abc宮永照xyz"
function replaceIdByName(str) {
    var res = str;

    for (var i in allIds) {
        var id = allIds[i];
        res = res.replace("${" + id + "}", names[id]);
    }

    return res;
}
