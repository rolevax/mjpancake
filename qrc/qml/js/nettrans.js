function level(l) {
    var levels = [
        "萌新", "9级", "8级", "7级", "6级",
        "5级", "4级", "3级", "2级", "1级",
        "初段", "二段", "三段", "四段", "五段",
        "六段", "七段", "八段", "九段", "十段"
    ];

    return levels[l];
}

function points(l, pt) {
    var maxs = [
        30, 30, 30, 60, 60,
        60, 90, 100, 100, 100,
        400, 800, 1200, 1600, 2000,
        2400, 2800, 3200, 3600, 4000
    ];

    return pt + "/" + maxs[l] + "pt"
}

function rating(r) {
    return "R" + Math.round(r);
}
