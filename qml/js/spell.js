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
    str = str.replace(/DRAW/g, "取:");
    str = str.replace(/DISCARD/g, "出:");
    str = str.replace(/0J/g, "怜");
    str = str.replace(/1J/g, "下家");
    str = str.replace(/2J/g, "対面");
    str = str.replace(/3J/g, "上家");

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
    // TODO FIXIT continues f or y is translated partially
    str = str.replace(/1111f/g, "東");
    str = str.replace(/2222f/g, "南");
    str = str.replace(/3333f/g, "西");
    str = str.replace(/4444f/g, "北");
    str = str.replace(/1111y/g, "白");
    str = str.replace(/2222y/g, "發");
    str = str.replace(/3333y/g, "中");

    str = str.replace(/111f/g, "東東東");
    str = str.replace(/222f/g, "南南南");
    str = str.replace(/333f/g, "西西西");
    str = str.replace(/444f/g, "北北北");
    str = str.replace(/111y/g, "白白白");
    str = str.replace(/222y/g, "發發發");
    str = str.replace(/333y/g, "中中中");

    str = str.replace(/11f/g, "東東");
    str = str.replace(/22f/g, "南南");
    str = str.replace(/33f/g, "西西");
    str = str.replace(/44f/g, "北北");
    str = str.replace(/11y/g, "白白");
    str = str.replace(/22y/g, "發發");
    str = str.replace(/33y/g, "中中");

    str = str.replace(/1f/g, "東");
    str = str.replace(/2f/g, "南");
    str = str.replace(/3f/g, "西");
    str = str.replace(/4f/g, "北");
    str = str.replace(/1y/g, "白");
    str = str.replace(/2y/g, "發");
    str = str.replace(/3y/g, "中");

    return str;
}

function skilltr(str) {
    var dict = {
        AWAI_DABURI: "☆☆☆☆☆☆",
        KASUMI_ZIM: "降神",
        SAWAYA_C_BLUE: "青云",
        SAWAYA_C_YELLOW: "黄云",
        SAWAYA_C_RED: "赤云",
        SAWAYA_C_RED_SELF: "自",
        SAWAYA_C_RED_RIVALS: "他",
        SAWAYA_C_WHITE: "白云",
        SAWAYA_C_BLACK: "黑云",
        SAWAYA_K_PA_KOR: "瘟神威 PA KOR",
        SAWAYA_K_AT_KOR: "海神威 AT KOR",
        SAWAYA_K_HOYAW: "蛇神威 HOYAW",
        SAWAYA_K_HURI: "鸟神威 HURI",
        SAWAYA_K_PAWCI: "淫神威 PAWCI",
    };

    return dict[str] ? dict[str] : str;
}

