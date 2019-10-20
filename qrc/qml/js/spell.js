.pragma library

function spell(str) {
    var dict = {
        Rci: "立直",  Ipt: "一発",  Tmo: "自摸",  Tny: "断么",  Pnf: "平和",
        Y1y: "白",  Y2y: "發",  Y3y: "中",
        Y1f: "東",  Y2f: "南",  Y3f: "西",  Y4f: "北",
        Ipk: "一盃口",  Rns: "嶺上",  Hai: "海底",  Hou: "河底",  Ckn: "搶槓",

        Wri: "Ｗ立",  Ssk: "三色",  Itt: "一通",  Cta: "全帯",
        Ctt: "七対子",  Toi: "対々", Sak: "三暗刻",  Skt: "三槓子",
        Stk: "三色同刻",  Hrt: "混老頭",  S3g: "小三元",  H1t: "混一",

        Mnh: "門混",  Jnc: "純全",  Rpk: "二盃口",  C1t: "清一",  Mnc: "門清",

        Mtp: "門断平", Mpn: "門平", Mtn: "門断", Tpn: "断平",
        Rtm: "立自摸", Ptm: "平自摸", Ttm: "断自摸",
        W1f: "Ｗ東",  W2f: "Ｗ南",  W3f: "Ｗ西",  W4f: "Ｗ北",
        Kah: "開花・", Rye: "撈月・",

        Nmi: "のみ",
        Dra: "ドラ", Ura: "裏", Aka: "赤",
        Ddr: "ドラドラ", Uur: "裏々",

        X13: "国士無双", Xd3: "大三元", X4a: "四暗刻",  Xt1: "字一色",
        Xs4: "小四喜", Xd4: "大四喜", Xcr: "清老頭", Xr1: "緑一色",
        Xth: "天和", Xch: "地和", X4k: "四槓子", X9r: "九蓮宝燈",
        W13: "国士無双・十三面", W4a: "四暗刻・単騎",
        W9r: "純正・九蓮宝燈",
    };

    for (var i in dict)
        str = str.replace(i, dict[i]);

    return str;
}

function charge(str) {
    str = str.replace(/Mg/, "満貫");
    str = str.replace(/Hnm/, "跳満");
    str = str.replace(/Bm/, "倍満");
    str = str.replace(/Sbm/, "三倍満");
    str = str.replace(/Kzeykm/, "数え役満");
    str = str.replace(/Ykm/, "役満");

    str = str.replace(/Dot/, "・");
    str = str.replace(/All/, "オール");

    str = str.replace(/Fu/, "符");
    str = str.replace(/Han/, "飜");
    str = str.replace(/Hb/, "本場");
    return str;
}

function logtr(str) {
    if (str.startsWith("Lua")) {
        return luaLogTr(str)
    }

    str = str.replace(/DRAW/g, "取:");
    str = str.replace(/DISCARD/g, "出:");
    str = str.replace(/0J/g, "怜");
    str = str.replace(/1J/g, "下家");
    str = str.replace(/2J/g, "対面");
    str = str.replace(/3J/g, "上家");
    str = str.replace(/AIM_FAILURE/g, "目标不在射程内");

    str = str.replace(/PON/g, "碰");
    str = str.replace(/CHII/g, "吃");
    str = str.replace(/DAIMINKAN/g, "大明槓");
    str = str.replace(/ANKAN/g, "暗槓");
    str = str.replace(/KAKAN/g, "加槓");
    str = str.replace(/RII/g, "立");
    str = str.replace(/KANDORAINDIC/g, "槓ドラ表示牌");
    str = str.replace(/URADORAINDIC/g, "裏ドラ表示牌");
    str = str.replace(/TSUMO/g, "自摸");
    str = str.replace(/RON/g, "栄和");

    str = str.replace(/HP/g, "流局");
    str = str.replace(/TENPAI/g, "聴牌");
    str = str.replace(/KSKP/g, "九種九牌");
    str = str.replace(/SFRT/g, "四風連打");
    str = str.replace(/SKSR/g, "四槓散了");
    str = str.replace(/SCRC/g, "四家立直");
    str = str.replace(/SCHR/g, "三家和了");
    str = str.replace(/NGSMG/g, "流し満貫");

    // in winning hand, barks are omitted
    // in kan predict, 4 chars are too verbose
    // so just use one char
    str = str.replace(/1111f/g, "東");
    str = str.replace(/2222f/g, "南");
    str = str.replace(/3333f/g, "西");
    str = str.replace(/4444f/g, "北");
    str = str.replace(/1111y/g, "白");
    str = str.replace(/2222y/g, "發");
    str = str.replace(/3333y/g, "中");

    var lookF = false, posF;
    var lookY = false, posY;
    str = "$" + str; // temp terminater
    for (var i = str.length - 1; i >= 0; i--) {
        var c = str[i], zstr;

        if (lookF) {
            if (c !== "1" && c !== "2" && c !== "3" && c !== "4") {
                zstr = str.substring(i + 1, posF);
                zstr = zstr.replace(/1/g, "東");
                zstr = zstr.replace(/2/g, "南");
                zstr = zstr.replace(/3/g, "西");
                zstr = zstr.replace(/4/g, "北");
                str = str.substring(0, i + 1) + zstr + str.substring(posF + 1, str.length);
                lookF = false;
            }
        } else if (lookY) {
            if (c !== "1" && c !== "2" && c !== "3") {
                zstr = str.substring(i + 1, posY);
                zstr = zstr.replace(/1/g, "白");
                zstr = zstr.replace(/2/g, "發");
                zstr = zstr.replace(/3/g, "中");
                str = str.substring(0, i + 1) + zstr + str.substring(posY + 1, str.length);
                lookY = false;
            }
        }

        if (!lookF && !lookY) {
            if (c === "f") {
                lookF = true;
                posF = i;
            } else if (c === "y") {
                lookY = true;
                posY = i;
            }
        }
    }
    str = str.substring(1); // remove temp terminater

    return str;
}

function luaLogTr(str) {
    str = str.substr(3);
    str = str.replace(/EInvT34Id/g, "你的ID-34超出范围");
    str = str.replace(/EInvT34Str/g, "你的T34字符串非法");
    str = str.replace(/EInvT37Str/g, "你的T37字符串非法");
    str = str.replace(/EInvM37Idx/g, "你的M37下标超出范围");
    str = str.replace(/EInvMntExt/g, "你的Mount出口非法");
    str = str.replace(/EInvSuit/g, "你的花色非法");
    str = str.replace(/EFrmNoAgr/g, "没和你Form个鸡8");
    str = str.replace(/EDrmCntDrw/g, "你的梦中手牌并非可摸牌状态");
    str = str.replace(/EDrmCntSwp/g, "你的梦中手牌不能这么切牌");
    str = str.replace(/ERefNil/g, "你使用了过期的全局变量");
    str = str.replace(/ERefCon/g, "你修改了只读变量");
    return str
}

function irsCheckTr(name, index) {
    var dict = {
        SUMIRE: ["射贯", "下家", "对面", "上家", "接受数牌19", "接受字牌" ],
        AWAI: [ "☆☆☆☆☆☆" ],
        KASUMI: [ "降神" ],
        SAWAYA_CLOUD: [ "青云", "黄云", "赤云", "自", "他", "白云", "黑云" ],
        SAWAYA_KAMUY: [
            "瘟神威 PA KOR", "下家", "对面", "上家",
            "海神威 AT KOR", "蛇神威 HOYAW", "鸟神威 HURI", "淫神威 PAWCI"
        ]
    };

    return dict[name] && dict[name][index] ? dict[name][index] : "未命名能力";
}

function fantr(fans) {
    var dict = [
        "大三元88", "大四喜88", "九莲宝灯88", "连七对88", "四杠88", "绿一色88", "十三么88",
        "清么九64", "小三元64", "小四喜64", "字一色64", "四暗刻64", "一色双龙会64",
        "一色四同顺48", "一色四节高48",
        "一色四步高32", "三杠32", "混么九32",
        "七对24", "全双刻24", "清一色24", "一色三同顺24", "一色三节高24", "全大24", "全中24", "全小24",
        "清龙16", "三色双龙会16", "一色三步高16", "全带五16", "三同刻16", "三暗刻16",
        "大于五12", "小于五12", "双风刻12",
        "花龙8", "推不倒8", "三色三同顺8", "三色三节高8", "无番和8",
        "妙手回春8", "海底捞月8", "杠上开花8", "抢杠和8",
        "碰碰和6", "混一色6", "三色三步高6", "五门齐6", "全求人6", "双暗杠6", "双箭刻6",
        "明暗杠5",
        "全带么4", "不求人4", "双明杠4", "和绝张4",
        "箭刻2", "圈风刻2", "门风刻2", "门前清2", "平和2", "四归一2",
        "双同刻2", "双暗刻2", "暗杠2", "断么2",
        "一般高1", "喜相逢1", "连六1", "老少副1", "么九刻1", "明杠1", "缺一门1", "无字1",
        "边张1", "坎张1", "单调将1", "自摸1"
    ];

    var res = "";
    for (var i in fans)
        res += dict[fans[i]] + (i === fans.length - 1 ? "" : " ");

    return res;
}

