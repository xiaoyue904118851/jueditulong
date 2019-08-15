Const={
	WIN_WIDTH=1334, -- 设计尺寸
	WIN_HEIGHT=750, -- 设计尺寸
	VISIBLE_X=cc.Director:getInstance():getVisibleOrigin().x,
	VISIBLE_Y=cc.Director:getInstance():getVisibleOrigin().y,
	VISIBLE_WIDTH=cc.Director:getInstance():getVisibleSize().width,
	VISIBLE_HEIGHT=cc.Director:getInstance():getVisibleSize().height,

	GHOST_NPC=500,
	GHOST_PLAYER=501,
	GHOST_MONSTER=502,
	GHOST_ITEM=503,
	GHOST_SLAVE=504,
	GHOST_NEUTRAL=505,
	GHOST_DART=508,
	GHOST_THIS=999,

	ITEM_BAG_BEGIN = 0,
	ITEM_BAG_SIZE = 42,
	ITEM_DEPOT_BEGIN = 1000, -- 随身仓库
	ITEM_DEPOT_SIZE = 40,
    ITEM_LOTTERYDEPOT_BEGIN = 3000, --祈宝仓库
    ITEM_LOTTERYSIZE = 210,
	ITEM_XUANJING_BEGIN =4000,
	ITEM_XUANJING_SIZE =140,

	ITEM_GUILDDEPOT_BEGIN = 3500,
	ITEM_GUILDDEPOT_SIZE = 200,

	SEX_MALE=200,
	SEX_FEMALE=201,

	AVATAR_ID=0,
	AVATAR_TYPE=1,
	AVATAR_STATE=2,
	AVATAR_X=3,
	AVATAR_Y=4,
	AVATAR_DIR=5,
	AVATAR_TARGET_X=6,
	AVATAR_TARGET_Y=7,
	AVATAR_DEADANIM=8,
	AVATAR_DISABLE_MAGIC=9,
	AVATAR_DISABLE_PRE=10,
	AVATAR_DISABLE_RUN=11,
	AVATAR_AUTOMOVE_FLAG=12,
	AVATAR_SET_CHANGE=13,
	AVATAR_ATTR_MAX=14,

	JOB_ZS=100,
	JOB_FS=101,
	JOB_DS=102,

	DIR_UP=0,
	DIR_UP_RIGHT=1,
	DIR_RIGHT=2,
	DIR_DOWN_RIGHT=3,
	DIR_DOWN=4,
	DIR_DOWN_LEFT=5,
	DIR_LEFT=6,
	DIR_UP_LEFT=7,

	SKILL_TYPE_YiBanGongJi = 100,

	SKILL_TYPE_JiChuJianShu = 101,
	SKILL_TYPE_GongShaJianShu = 102,
	SKILL_TYPE_CiShaJianShu = 103,
	SKILL_TYPE_BanYueWanDao = 104,
	SKILL_TYPE_YeManChongZhuang = 105,
	SKILL_TYPE_LieHuoJianFa = 106,
	SKILL_TYPE_PoTianZhan = 107,
	SKILL_TYPE_ZhuRiJianFa = 109,
    SKILL_TYPE_LeiTingChongJi = 110,
    SKILL_TYPE_PoKongJianFa = 111,
    SKILL_TYPE_LongYingJianQi = 112,
    SKILL_TYPE_ZhuTianJianFa = 113,

	SKILL_TYPE_HuoQiuShu = 401,
	SKILL_TYPE_KangJuHuoHuan = 402,
	SKILL_TYPE_YouHuoZhiGuang = 403,
	SKILL_TYPE_DiYuHuo = 404,
	SKILL_TYPE_LeiDianShu = 405,
	SKILL_TYPE_ShunJianYiDong = 406,
	SKILL_TYPE_DaHuoQiu = 407,
	SKILL_TYPE_BaoLieHuoYan = 408,
	SKILL_TYPE_HuoQiang = 409,
	SKILL_TYPE_JiGuangDianYing = 410,
	SKILL_TYPE_DiYuLeiGuang = 411,
	SKILL_TYPE_MoFaDun = 412,
	SKILL_TYPE_ShengYanShu = 413,
	SKILL_TYPE_BingPaoXiao = 414,
	SKILL_TYPE_HuoLongQiYan = 416,
	SKILL_TYPE_LiuXingHuoYu = 417,
    SKILL_TYPE_XuanGuangDun = 418,
    SKILL_TYPE_LieHuoLiaoYuan = 419,
    SKILL_TYPE_HanBingZhang = 420,
    SKILL_TYPE_FenTianLieYan = 421,


	SKILL_TYPE_ZhiYuShu = 501,
	SKILL_TYPE_JinShenLiZhanFa = 502,
	SKILL_TYPE_ShiDuShu = 503,
	SKILL_TYPE_LingHunHuoFu = 504,
	SKILL_TYPE_ZhaoHuanKuLou = 505,
	SKILL_TYPE_YinShenShu = 506,
	SKILL_TYPE_JiTiYinShenShu = 507,
	SKILL_TYPE_YouLingDun = 508,
	SKILL_TYPE_ShenShengZhanJiaShu = 509,
	SKILL_TYPE_XinLingQiShi = 510,
	SKILL_TYPE_KunMoZhou = 511,
	SKILL_TYPE_QunTiZhiLiao = 512,
	SKILL_TYPE_ZhaoHuanShenShou = 513,
	SKILL_TYPE_QiGongBo = 514,
	SKILL_TYPE_ZhaoHuanYueLing = 518,
    SKILL_TYPE_TianZunQunDu = 519,
    SKILL_TYPE_ZuZhouShu = 520,
    SKILL_TYPE_DuoHunJianYU = 521,
    SKILL_TYPE_BaiHuZhaoHuan = 522,
    SKILL_TYPE_JuFengPo = 523,

	SKILL_TYPE_MonArrow = 601,
	SKILL_TYPE_LevelUp = 602,
	SKILL_TYPE_Jump=614,

    ICONTYPE = {
        POS = 1,
        UPGRADE = 2,
    },
}


Const.SCALE_X = Const.VISIBLE_WIDTH / Const.WIN_WIDTH
Const.SCALE_Y = Const.VISIBLE_HEIGHT / Const.WIN_HEIGHT
Const.SCALE = nil

Const.minScale = math.min(Const.VISIBLE_HEIGHT/Const.WIN_HEIGHT,Const.VISIBLE_WIDTH/Const.WIN_WIDTH)
Const.maxScale = math.max(Const.VISIBLE_HEIGHT/Const.WIN_HEIGHT,Const.VISIBLE_WIDTH/Const.WIN_WIDTH)

Const.str_zs   = "战士"
Const.str_fs   = "法师"
Const.str_ds   = "道士"

Const.GUILD_TITLE = {
	[1000] = "会长",
	[300] = "副会长",
	[200] = "长老",
	[102] = "忠义会员",
}

Const.GUILD_TITLE_TYPE =
{
    GUILD_TITLE_TYPE_OUT=100,
    GUILD_TITLE_TYPE_NORMAL=102,
    GUILD_TITLE_TYPE_LEADER=200,  --会长长老
    GUILD_TITLE_TYPE_ADV=300,	  --副会长
    GUILD_TITLE_TYPE_ADMIN=1000,  --会长
};

Const.GENDER = {
	[200] = "男",
	[201] = "女",
}

Const.JOB = {
    [0]="通用",
	[100] = "战士",
	[101] = "法师",
	[102] = "道士",
}

Const.ONLINE = {
	[1] = "在线",
	[0] = "离线",
}

Const.JOB_AND_GENDER = {
    [100] = {[200]="mzs.png",[201]="fzs.png",},
    [101] = {[200]="mfs.png",[201]="ffs.png",},
    [102] = {[200]="mds.png",[201]="fds.png",},
}

Const.DEFAULT_STATEITEM = {
    [200] = 0,
    [201] = 1,
}

function Const.gameScale()
	if not Const.SCALE then
		if Const.SCALE_X > Const.SCALE_Y then
			Const.SCALE = Const.SCALE_X
		else
			Const.SCALE = Const.SCALE_Y
		end
	end
	return Const.SCALE
end

function Const.left(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(Const.VISIBLE_X + x, Const.VISIBLE_Y + Const.VISIBLE_HEIGHT/2 + y)
end
function Const.right(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X+Const.VISIBLE_WIDTH + x, Const.VISIBLE_Y + Const.VISIBLE_HEIGHT/2 + y)
end
function Const.top(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X + Const.VISIBLE_WIDTH/2 + x, Const.VISIBLE_Y + Const.VISIBLE_HEIGHT + y)
end
function Const.bottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X + Const.VISIBLE_WIDTH/2 + x, Const.VISIBLE_Y + y)
end
function Const.center(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(Const.WIN_WIDTH/2 + x,Const.WIN_HEIGHT/2 + y)
end
function Const.leftTop(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X + x, Const.VISIBLE_Y + Const.VISIBLE_HEIGHT + y)
end
function Const.rightTop(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X + Const.VISIBLE_WIDTH + x, Const.VISIBLE_Y + Const.VISIBLE_HEIGHT + y)
end
function Const.leftBottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
	return cc.p(Const.VISIBLE_X + x,Const.VISIBLE_Y + y)  
end
function Const.rightBottom(x,y)
	if not x then x = 0 end
	if not y then y = 0 end
    return cc.p(Const.VISIBLE_X + Const.VISIBLE_WIDTH + x, Const.VISIBLE_Y + y)  
end

-------------------------------人物属性-----------------------------------
local i=0

Const.net_id=i;i=i+1
Const.net_type=i;i=i+1
Const.net_cloth=i;i=i+1
Const.net_weapon=i;i=i+1
Const.net_mount=i;i=i+1
Const.net_wing=i;i=i+1
Const.net_exp=i;i=i+1
Const.net_x=i;i=i+1
Const.net_y=i;i=i+1
Const.net_dir=i;i=i+1
Const.net_speed=i;i=i+1
Const.net_hp=i;i=i+1
Const.net_maxhp=i;i=i+1
Const.net_mp=i;i=i+1
Const.net_maxmp=i;i=i+1
Const.net_burden=i;i=i+1
Const.net_state=i;i=i+1
Const.net_show=i;i=i+1
Const.net_fabao=i;i=i+1
Const.net_fashion=i;i=i+1
Const.net_level=i;i=i+1
Const.net_zslevel=i;i=i+1
Const.net_job=i;i=i+1
Const.net_gender=i;i=i+1
Const.net_dead=i;i=i+1
Const.net_teamid=i;i=i+1
Const.net_pkstate=i;i=i+1
Const.net_pkvalue=i;i=i+1
Const.net_fabaolv=i;i=i+1
Const.net_collecttime=i;i=i+1

Const.net_name=i;i=i+1
Const.net_seedname=i;i=i+1
Const.net_love_name=i;i=i+1
Const.net_team_name=i;i=i+1
Const.net_guild_name=i;i=i+1
Const.net_guild_title=i;i=i+1
Const.net_name_pre=i;i=i+1
Const.net_name_pro=i;i=i+1
Const.net_item_onwer=i;i=i+1
Const.net_itemtype=i;i=i+1
Const.net_fight_point=i;i=i+1
Const.net_cur_map=i;i=i+1
Const.net_ortype=i;i=i+1
Const.net_rn_zy=i;i=i+1
Const.net_ng=i;i=i+1
Const.net_maxng=i;i=i+1
Const.net_nglevel=i;i=i+1
Const.net_sound=i;i=i+1
Const.net_jingying=i;i=i+1
Const.net_flag=i;i=i+1
Const.net_belong_guild=i;i=i+1
Const.net_attr_num=i;i=i+1

local j = 0
Const.avatar_id = j; j = j + 1
Const.avatar_type = j; j = j + 1
Const.avatar_state = j; j = j + 1
Const.avatar_x = j; j = j + 1
Const.avatar_y = j; j = j + 1
Const.avatar_dir = j; j = j + 1
Const.avatar_target_x = j; j = j + 1
Const.avatar_target_y = j; j = j + 1
Const.avatar_deadanim = j; j = j + 1
Const.avatar_disable_magic = j; j = j + 1
Const.avatar_disable_pre = j; j = j + 1
Const.avatar_disable_run = j; j = j + 1
Const.avatar_attr_max = j; j = j + 1

j=0
Const.STATE_IDLE = j; j = j + 1
Const.STATE_WALK = j; j = j + 1
Const.STATE_RUN = j; j = j + 1
Const.STATE_PREPARE = j; j = j + 1
Const.STATE_ATTACK = j; j = j + 1
Const.STATE_MAGIC = j; j = j + 1
Const.STATE_INJURY = j; j = j + 1
Const.STATE_DIE = j; j = j + 1
Const.STATE_DAZUO = j; j = j + 1
Const.STATE_CAIKUANG = j; j = j + 1
Const.STATE_MIDLE = j; j = j + 1
Const.STATE_MWALK = j; j = j + 1
Const.STATE_MRUN = j; j = j + 1
Const.STATE_JUMP = j; j = j + 1
Const.STATE_COUNT = j; j = j + 1

Const.test_ip="47.94.37.110"
--Const.test_ip="192.168.3.130"
Const.test_port="80"
Const.test_mode=0

Const.ITEM_WEAPON_POSITION = -2 * 2 --装备里面的武器
Const.ITEM_CLOTH_POSITION =  -3 * 2 --装备里面的战衣
Const.ITEM_HAT_POSITION =  -4 * 2--装备里面的头盔
Const.ITEM_RING1_POSITION =  -5 * 2 --装备里面的戒指左
Const.ITEM_RING2_POSITION =  -5* 2 - 1 --装备里面的戒指右
Const.ITEM_GLOVE1_POSITION =  -6 * 2 --装备里面的护腕左
Const.ITEM_GLOVE2_POSITION =  -6* 2 - 1 --装备里面的护腕右
Const.ITEM_NICKLACE_POSITION =  -7 * 2 --装备里面的项链
Const.ITEM_HUIZHANG_POSITION =-8 * 2 --徽章？
Const.ITEM_BELT_POSITION =  -9 * 2 --装备里面的腰带
Const.ITEM_BOOT_POSITION = -10 * 2 --装备里面的战靴
Const.ITEM_SOUL_POSITION = -11 * 2  -- 装备里面的魂器
-- 魔血石 TODO 24
-- 坐骑 TODO 26
Const.ITEM_FASHION_WEAPON_POSITION = -14 * 2  --时装武器
Const.ITEM_FASHION_CLOTH_POSITION = -15 * 2 --时装衣服
Const.ITEM_WING_POSITION = -16 * 2 -- 装备里面的翅膀
Const.ITEM_TEJIE_POSITION = -17 * 2  --时装特戒
Const.ITEM_LINGPAI_POSITION  = -18*2		--令牌
Const.ITEM_YUPEI_POSITION  = -19*2		--玉佩
Const.ITEM_HUFU_POSITION  = -20*2		--护符
Const.ITEM_PIFENG_POSITION  = -21*2		--披风
Const.ITEM_SHENQI_POSTITION  = -22*2		--神器
Const.ITEM_SHENJIA_POSTITION =  -23*2		--神甲
Const.ITEM_LONGHUN_POSTITION =  -24*2		--龙魂
Const.ITEM_HUFU2_POSITION  = -25*2		--虎符
Const.ITEM_MEDAL_POSITION =	-27*2 -- 勋章
Const.ITEM_JIANJIA_POSITION =	-35*2 -- 肩甲
Const.ITEM_BAOSHI_POSITION =	-37*2 -- 宝石
Const.ITEM_DUNPAI_POSITION =	-39*2 -- 盾牌
Const.ITEM_ANQI_POSITION =	-33*2 -- 暗器
Const.ITEM_YUXI_POSITION =	-34*2 -- 玉玺

--Const.ITEM_WING_LIGHT_POSITION = -13 * 2 -- 时装里面的光翼
--Const.ITEM_FASHION_WEDDING_RING_POSITION = -16 * 2 - 1 --时装婚戒
--Const.ITEM_FASHION_HEADDRESS_POSITION = -18 * 2  --时装头饰
--Const.ITEM_FASHION_ORNAMENTS_POSITION = -19 * 2-- 挂饰没有
--Const.ITEM_FASHION_PAULDRON1_POSITION = -21 * 2 --时装护肩1
--Const.ITEM_FASHION_PAULDRON2_POSITION = -21 * 2 - 1 --时装护肩2


Const.ITEM_WEAPON_BEGIN = 20000--
Const.ITEM_WEAPON_END = 29999

Const.ITEM_CLOTH_BEGIN = 30000--
Const.ITEM_CLOTH_END = 39999

Const.ITEM_HAT_BEGIN = 40000--
Const.ITEM_HAT_END = 49999

Const.ITEM_RING_BEGIN = 50000--
Const.ITEM_RING_END = 59999

Const.ITEM_GLOVE_BEGIN = 60000--
Const.ITEM_GLOVE_END = 69999--

Const.ITEM_NECKLACE_BEGIN = 70000--
Const.ITEM_NECKLACE_END = 79999--

Const.ITEM_LINQI_BEGIN = 80000
Const.ITEM_LINQI_END = 89999

Const.ITEM_BELT_BEGIN = 90000--
Const.ITEM_BELT_END = 99999

Const.ITEM_BOOT_BEGIN = 100000--
Const.ITEM_BOOT_END = 109999

Const.ITEM_HUNQI_BEGIN = 110000--
Const.ITEM_HUNQI_END = 119999

Const.ITEM_MOXUESHI_BEGIN = 120000
Const.ITEM_MOXUESHI_END = 129999

Const.ITEM_ZUOJI_BEGIN = 130000
Const.ITEM_ZUOJI_END = 139999

Const.ITEM_FASHION_WEAPON_BEGIN = 140000
Const.ITEM_FASHION_WEAPON_END = 149999

Const.ITEM_FASHION_CLOTH_BEGIN = 150000
Const.ITEM_FASHION_CLOTH_END = 159999

Const.ITEM_XYFASHION_WEAPON_BEGIN = 149000
Const.ITEM_XYFASHION_WEAPON_END = 149999

Const.ITEM_XYFASHION_CLOTH_BEGIN = 159000
Const.ITEM_XYFASHION_CLOTH_END = 159999

Const.ITEM_WING_BEGIN = 160000
Const.ITEM_WING_END = 169999

Const.ITEM_TEJIE_BEGIN = 170000--
Const.ITEM_TEJIE_END = 179999--

Const.ITEM_LINGPAI_BEGIN = 180000--
Const.ITEM_LINGPAI_END = 189999--

Const.ITEM_YUPEI_BEGIN = 190000--
Const.ITEM_YUPEI_END = 199999--

Const.ITEM_HUFU_BEGIN = 200000--
Const.ITEM_HUFU_END = 209999

Const.ITEM_PIFENG_BEGIN = 210000--
Const.ITEM_PIFENG_END = 219999

Const.ITEM_SHENQI_BEGIN = 220000---
Const.ITEM_SHENQI_END = 229999

Const.ITEM_SHENJIA_BEGIN = 230000--
Const.ITEM_SHENJIA_END = 239999

Const.ITEM_LONGHUN_BEGIN = 240000--
Const.ITEM_LONGHUN_END = 249999

Const.ITEM_HUFU2_BEGIN = 250000--
Const.ITEM_HUFU2_END = 259999

Const.ITEM_MEDAL_BEGIN = 270000--
Const.ITEM_MEDAL_END = 279999

Const.ITEM_ANQI_BEGIN = 330000--
Const.ITEM_ANQI_END = 339999--

Const.ITEM_YUXI_BEGIN = 340000--
Const.ITEM_YUXI_END = 349999--

Const.ITEM_JIANJIA_BEGIN = 350000--
Const.ITEM_JIANJIA_END = 359999--

Const.ITEM_BAOSHI_BEGIN = 370000--
Const.ITEM_BAOSHI_END = 379999--

Const.ITEM_DUNPAI_BEGIN = 390000--
Const.ITEM_DUNPAI_END = 399999--

Const.ITEM_EQUIP_BEGIN = Const.ITEM_WEAPON_BEGIN
Const.ITEM_EQUIP_END = 1009999

Const.EQUIP_TAG = {
    WEAPON = 1,
    CLOTH = 2,
    HAT = 3,
    RING = 4,
    GLOVE = 5,
    NECKLACE = 6,
    BELT = 7,
    BOOT = 8,
    WING = 9,
    FASHION = 10,
    SOUL = 11,
    ALL = 12,
}

function Const.color( index )
    local color = {
        [1] = cc.c3b(255,255,240),
        [2] = cc.c3b(205,133,63),
        [3] = cc.c3b(250,250,210),
        [4] = cc.c3b(138,105,89),
        [5] = cc.c3b(169,169,169),
        [6] = cc.c3b(224,164,96),
        [7] = cc.c3b(105,105,105),
        [8] = cc.c3b(255,0,0),
        [9] = cc.c3b(20,160,20),
    }
    return color[index]
end

-- 道具表中一堆奇怪颜色
Const.Item_Def_color = {
    [1] = {imgstr = "icon_color_white.png", colors = {0xffffff}},
    [2] = {imgstr = "icon_color_green.png", colors = {0x12cf28}},
    [3] = {imgstr = "icon_color_blue.png", colors = {0x009dfe,0x9cff}},
    [4] = {imgstr = "icon_color_purple.png", colors = {0xfe30fc}},
    [5] = {imgstr = "icon_color_orange.png", colors = {0xff7901}},
    [6] = {imgstr = "icon_color_red.png", colors = {0xe70301}},
}

Const.COLOR_YELLOW_1 = "D4C08B";Const.COLOR_YELLOW_1_STR = "#"..Const.COLOR_YELLOW_1;Const.COLOR_YELLOW_1_OX = "0x"..Const.COLOR_YELLOW_1;Const.COLOR_YELLOW_1_C3B = cc.c3b(212,192,139)
Const.COLOR_YELLOW_2 = "E1AC08";Const.COLOR_YELLOW_2_STR = "#"..Const.COLOR_YELLOW_2;Const.COLOR_YELLOW_2_OX = "0x"..Const.COLOR_YELLOW_2;Const.COLOR_YELLOW_2_C3B = cc.c3b(225,172,8)
Const.COLOR_YELLOW_3 = "FFF68B";Const.COLOR_YELLOW_3_STR = "#"..Const.COLOR_YELLOW_3;Const.COLOR_YELLOW_3_OX = "0x"..Const.COLOR_YELLOW_3;Const.COLOR_YELLOW_3_C3B = cc.c3b(255,246,139)
Const.COLOR_GREEN_1 = "12CF18";Const.COLOR_GREEN_1_STR = "#"..Const.COLOR_GREEN_1;Const.COLOR_GREEN_1_OX = "0x"..Const.COLOR_GREEN_1;Const.COLOR_GREEN_1_C3B = cc.c3b(18,207,24)
Const.COLOR_RED_1 = "bb0000";Const.COLOR_RED_1_STR = "#"..Const.COLOR_RED_1;Const.COLOR_RED_1_OX = "0x"..Const.COLOR_RED_1;Const.COLOR_RED_1_C3B = cc.c3b(187,0,0)
Const.COLOR_GRAY_1 = "B2B2B2";Const.COLOR_GRAY_1_STR = "#"..Const.COLOR_GRAY_1;Const.COLOR_GRAY_1_OX = "0x"..Const.COLOR_GRAY_1;Const.COLOR_GRAY_1_C3B = cc.c3b(178,178,178)
Const.COLOR_BLUE_1 = "009DFE";Const.COLOR_BLUE_1_STR = "#"..Const.COLOR_BLUE_1;Const.COLOR_BLUE_1_OX = "0x"..Const.COLOR_BLUE_1;Const.COLOR_BLUE_1_C3B = cc.c3b(0,157,254)
Const.COLOR_WHITE_1 = "FFFFFF";Const.COLOR_WHITE_1_STR = "#"..Const.COLOR_WHITE_1;Const.COLOR_WHITE_1_OX = "0x"..Const.COLOR_WHITE_1;Const.COLOR_WHITE_1_C3B = cc.c3b(255,255,255)
Const.COLOR_ORANGE_1 = "FF7901";Const.COLOR_ORANGE_1_STR = "#"..Const.COLOR_ORANGE_1;Const.COLOR_ORANGE_1_OX = "0x"..Const.COLOR_ORANGE_1;Const.COLOR_ORANGE_1_C3B = cc.c3b(255,121,1)
Const.COLOR_PURPLE_1 = "FE30FC";Const.COLOR_PURPLE_1_STR = "#"..Const.COLOR_PURPLE_1;Const.COLOR_PURPLE_1_OX = "0x"..Const.COLOR_PURPLE_1;Const.COLOR_PURPLE_1_C3B = cc.c3b(254,48,252)

Const.DEFAULT_BTN_FONT_SIZE = 24
Const.DEFAULT_BTN_FONT_COLOR = Const.COLOR_YELLOW_2_C3B
Const.DEFAULT_BTN_FONT_NAME = "uilayout/FZHT.ttf"
Const.DEFAULT_FONT_NAME = "uilayout/PingHeiText.ttf"
Const.str_sure	= "确  认"
Const.str_cancel	= "取  消"
Const.str_close	= "知道了"

--------------------聊天----------------------------------------

Const.CHANNEL_TAG = {
    ALL = 1,
    WORLD = 2,
    YELL = 5,
    GUILD = 3,
    GROUP = 4,
    PRIVATE = 6,
    SYSTEM = 7,
    HORN = 8,
}

Const.chat_placeHolder = "请输入聊天内容"
Const.chat_prefix_nomal       = "[普通]"
Const.chat_prefix_world	    = "[世界]"
Const.chat_prefix_yell      = "[附近]"
Const.chat_prefix_guild     = "[行会]"
Const.chat_prefix_group	    = "[队伍]"
Const.chat_prefix_private	= "[私聊]"
Const.chat_prefix_horn	    = "[喇叭]"
Const.chat_prefix_system	    = "[系统]"

-- 不同频道的颜色
Const.CHANNEL_COLOR = {
    [Const.chat_prefix_nomal]       = {prefixColor = Const.COLOR_YELLOW_2_STR,},
    [Const.chat_prefix_world]       = {prefixColor = Const.COLOR_YELLOW_2_STR,},
    [Const.chat_prefix_yell]        = {prefixColor = "#ffffff",},
    [Const.chat_prefix_guild]       = {prefixColor = "#12cf28",},
    [Const.chat_prefix_group]       = {prefixColor = "#009dfe",},
    [Const.chat_prefix_private]     = {prefixColor = "#fe30fc",},
    [Const.chat_prefix_system]      = {prefixColor = "#e70301",},
}

-------------------------------layerAlert-----------------------------------
Const.str_titletext_alert = "朕知道了"
Const.str_titletext_confirm = "是"
Const.str_titletext_cancel = "否"
Const.str_tradegold = "点击输入金币"
Const.str_tradevcoin = "点击输入元宝"

Const.AVATAR_TYPE = {
    AVATAR_CLOTH = 0,
    AVATAR_WEAPON = 1,
    AVATAR_MOUNT = 2,
    AVATAR_WING = 3,
    AVATAR_NUM = 4,
}
Const.AVATAR_EFFECT = {
    AVATAR_EFFECT = Const.AVATAR_TYPE.AVATAR_NUM,
    AVATAR_FASHION = 5,
    AVATAR_FABAO = 6,
    AVATAR_MODEL_WING = 7,
    AVATAR_MAX_COUNT = 8,
}

-- 主界面提示类型
Const.NOTICE_TYPE = {
    GROUP_APPLY = 1,
    GROUP_INVITE = 2,
    TRADE = 3,
    MAIL = 4,
    HPMP = 5,
    YABIAO = 6,
    STRENGTH = 7, 
}
Const.str_notice_group = "组队"
Const.str_notice_trade = "交易"
Const.str_notice_mail = "邮件"

-- 组队
Const.str_group_joinToLeader = "申请入队"
Const.str_group_inviteGroupToMember = "邀请您入队"

Const.str_mDC 	= "物理攻击:"
Const.str_mMC 	= "魔法攻击:"
Const.str_mSC 	= "道术攻击:"
Const.str_mAC 	= "物理防御:"
Const.str_mMAC	= "魔法防御:"
Const.str_mHp 	= "生命上限:"
Const.str_mMp 	= "魔法上限:"

Const.str_attack = "攻击:"
Const.str_defense = "防御:"
Const.str_fight = "战力:"

Const.PLAYER_PARAM = {
    PP_VIP_LEVEL = 1018,
    HUNSHI = 1037, -- 魂石数量
    BOSSJIFEN = 1038, -- 神器积分
    FUMOPOINTS = 1039, -- 伏魔值
    PP_ZHANYAOLING_POINTS = 1041,-- 斩妖令
    PP_XUNBAO_POINTS = 1044,-- 寻宝积分
}

Const.ITEM_BETTER_SELF=0
Const.ITEM_WORSE_SELF=1
Const.ITEM_UNUSE_SELF=2
Const.ITEM_NONE_SELF=3

Const.VCOIN_SHOP = {
    VIP = 20, -- 随身商店
    HUNSHI = 6, -- 魂石商店
}

Const.ITEM_POSITION_EXCHANGE_BAG2DEPOT = -5001
Const.ITEM_POSITION_EXCHANGE_DEPOT2BAG = -5002

Const.GROUP_MAX_MEMBER = 14

Const.IS_DOWNLOAD = true

-- 键位设置界面可设置的道具 name没什么实际用处，便于查看而已
Const.Skill_Setting_Item = {
    [1] = {id = 10002, name = "回城卷"},
    [2] = {id = 10003, name = "王城传送卷"},
    [3] = {id = 15001, name = "回城石"},
    [4] = {id = 15002, name = "随机传送石"},
    [5] = {id = 10296, name = "太阳水"},
    [6] = {id = 10299, name = "强效太阳水"},
    [7] = {id = 10307, name = "大还丹"},
    [8] = {id = 10309, name = "强效大还丹"},
}

-- 主界面右侧两个快捷使用的道具
Const.MAIN_UI_ITEM = {
    {id = 15001,sellyb=50,priceflag=2,bindflag=1,name = "回城石"},
    {id = 10299, name = "强效太阳水"},
}
Const.RELIVE_USE_ITEM = {id=15311,sellyb=100,priceflag=1,bindflag=1,name="九转还魂丹"}

Const.STATUS_TYPE_INVALID = -1 --无效的状态标记
Const.STATUS_TYPE_MOFADUN = 0
Const.STATUS_TYPE_YINGSHEN = 1
Const.STATUS_TYPE_YOULINGDUN = 2--mMACMax
Const.STATUS_TYPE_SHENSHENGZHANJIASHU = 3--mACMax
Const.STATUS_TYPE_POSION_HP = 4
Const.STATUS_TYPE_POSION_ARMOR = 5 --修改为 降低目标攻击力 暂时占用这个字段
Const.STATUS_TYPE_HP_RECOVER = 6
Const.STATUS_TYPE_ADD_EXP = 7
Const.STATUS_TYPE_ADD_AC = 8--mACMax
Const.STATUS_TYPE_ADD_MAC = 9--mMACMax
Const.STATUS_TYPE_ADD_DC = 10--mDCMax
Const.STATUS_TYPE_ADD_MC = 11--mMCMax
Const.STATUS_TYPE_ADD_SC = 12--mSCMax
Const.STATUS_TYPE_ADD_DROP_ITEMADD_PROB = 13
Const.STATUS_TYPE_AUTO_ADD_EXP = 14
Const.STATUS_TYPE_NO_DAMAGE = 15
Const.STATUS_TYPE_ALL_YINGSHEN = 16
Const.STATUS_TYPE_NO_DROP = 17
Const.STATUS_TYPE_SHUT_PK_VALUE = 18
Const.STATUS_TYPE_SEVEN_COLOR_DAN = 19--mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax mMaxHp mMaxMp
Const.STATUS_TYPE_MABI = 20
Const.STATUS_TYPE_YUANSHENHUTI = 21--mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax
Const.STATUS_TYPE_BAQIHUTI = 22--mAC mACMax mMAC mMACMax mDC mDCMax mMC mMCMax mSC mSCMax
Const.STATUS_TYPE_ADD_HP = 23--mMaxHp
Const.STATUS_TYPE_ADD_MP = 24--mMaxMp
Const.STATUS_TYPE_TIANSHENHUTI = 25--mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
Const.STATUS_TYPE_SHENWEI = 26--mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
Const.STATUS_TYPE_ZHIZUN = 27--mMaxHp mDC mDCMax mMC mMCMax mSC mSCMax mDixiao_pres mFuyuan_cd
Const.STATUS_TYPE_FUQITONGXIN = 28--mAC mACMax mMAC mMACMax
Const.STATUS_TYPE_XUANTIANZHENQI=29
Const.STATUS_TYPE_KNXF = 31 --狂怒旋风
Const.STATUS_TYPE_WLMZ = 32
Const.STATUS_TYPE_ZHUANSHEN = 33
Const.STATUS_TYPE_VIP = 34
Const.STATUS_TYPE_ADD_EXP_2 = 35 --多倍经验
Const.STATUS_TYPE_GUANZHI = 36
Const.STATUS_TYPE_TOTAL_HP = 37
Const.STATUS_TYPE_ADD_NGEXP = 39 --内功多倍经验
Const.STATUS_TYPE_CHANGE_SHAPE = 40	--改变造型
Const.STATUS_TYPE_WUWEI = 41 --被动技能:无畏
Const.STATUS_TYPE_JIANDING = 42 --被动技能：坚定
Const.STATUS_TYPE_LUCKZERO = 43 --被动技能debuff：幸运为零
Const.STATUS_TYPE_ZHANGU = 44 --被动技能：战鼓
Const.STATUS_TYPE_LAOYIN = 45 --被动技能debuff：烙印
Const.STATUS_TYPE_YIZHI = 46 --被动技能：意志
Const.STATUS_TYPE_BOSSKILLER = 47 --被动技能：BOSS杀手
Const.STATUS_TYPE_LIEREN = 48 --被动技能：猎人经验
Const.STATUS_TYPE_MONKILLER = 49 --被动技能：怪物杀手
Const.STATUS_TYPE_MONTIANDI = 52 --被动技能：怪物天敌
Const.STATUS_TYPE_LAODAO = 53 --被动技能：老道
Const.STATUS_TYPE_SHULIAN = 54 --被动技能：熟练
Const.STATUS_TYPE_MONDAME = 55 --被动技能:怪物固定伤害
Const.STATUS_TYPE_WuJiZhenQi = 56
Const.STATUS_TYPE_MOFADUN_ADV = 57	--高级盾
Const.STATUS_TYPE_POSION_ATTACK = 58	--降低目标攻击力
Const.STATUS_TYPE_MOUNT_QN = 59 --坐骑潜能技能
Const.STATUS_TYPE_ADD_NGEXP2 = 60--内功多倍经验
Const.STATUS_TYPE_BOSS_HD = 63--boss护盾
Const.STATUS_TYPE_ADD_DAMPAGE_PER = 64--增加伤害百分比
Const.STATUS_TYPE_REM_DAMPAGE_PER = 65--减少受到的伤害百分比
Const.STATUS_TYPE_WUSHUANG_HD = 66--无双护盾 概率增加伤害减免数值
Const.STATUS_TYPE_DAMAGE_IGNORE = 67--伤害减免数值
Const.STATUS_TYPE_WUSHANG_ZZ = 68--无尚诅咒 降低对方幸运值
Const.STATUS_TYPE_LUCK_REM = 69--幸运值降低
Const.STATUS_TYPE_Burning = 70
Const.STATUS_BUFF_RING_RELIVE_CD = 73
Const.STATUS_BUFF_RING_YYH_CD = 74
Const.STATUS_BUFF_RING_HUSHEN_FORVIEW = 75 --护身
Const.STATUS_BUFF_RING_SELF_MABI_CD = 76
Const.STATUS_BUFF_SUPERBOX = 77	--超级宝盒
Const.STATUS_TYPE_WORLD_LEVEL = 78
Const.STATUS_TYPE_KINGDOM = 79
Const.STATUS_TYPE_YUANSHENG=80
Const.STATUS_SLAVE_STATUS=81 --宝宝状态
Const.STATUS_TYPE_PET_ATTRIBUTE=82 --战将附加属性
Const.STATUS_BUFF_DUOBAO_BOX=83	  --夺宝buff
Const.STATUS_BUFF_HONOUR_CRAZY_STATUS=84	--富贵兽狂暴状态
Const.STATUS_BUFF_JINZHONGZAO=85			--金钟罩保护
Const.STATUS_BUFF_YAOBAO=86 --回复药包
Const.STATUS_BUFF_ZCSL=87 --神魔战场:战场神力
Const.STATUS_BUFF_RING_RELIVE=88 --特戒:复活
Const.STATUS_BUFF_RING_ATTACK=89 --特戒:攻之力
Const.STATUS_BUFF_RING_DEFENSE=90 --特戒:防之力
Const.STATUS_BUFF_RING_YYH=91	--特戒:阴阳环
Const.STATUS_BUFF_RING_XIXUE=92	--特戒:吸血
Const.STATUS_BUFF_RING_IMMUNE_MABI=93 --特戒:麻痹免疫
Const.STATUS_BUFF_IGNORE_REM = 104 --降低忽视防御
Const.STATUS_BUFF_ATTRACT_REM = 105 --降低攻击
Const.STATUS_BUFF_BAOJI_REM = 106 --降低暴击伤害
Const.STATUS_BUFF_KING_LEADER = 107 --九五至尊
Const.STATUS_BUFF_XURUO = 147 --铭文被动技能 虚弱
Const.STATUS_BUFF_ZHICAI = 148 --铭文被动技能 制裁
Const.STATUS_BUFF_SHENFA = 149 --铭文被动技能 神罚
Const.STATUS_FUWEN_GJ=164 --攻击符文
Const.STATUS_FUWEN_RXG=165 --生命符文
Const.STATUS_FUWEN_GODGJ=166 --神圣攻击符文
Const.STATUS_FUWEN_BS=167 --暴击伤害符文
Const.STATUS_FUWEN_HGJ=168 --高级攻击符文
Const.STATUS_FUWEN_HBS=169 --高级爆伤符文
Const.STATUS_QILING_HP=180--器灵生命
Const.STATUS_QILING_AC=181--器灵物防
Const.STATUS_QILING_MAC=182--器灵魔防
Const.STATUS_QILING_DC=183--器灵物攻
Const.STATUS_QILING_MC=184--器灵魔攻
Const.STATUS_QILING_SC=185--器灵道攻
Const.STATUS_QILING_BAOJI=186--器灵暴击伤害减免
Const.STATUS_QILING_BAOSHANG=187--器灵爆伤
Const.STATUS_XILIAN_HGJ=188--洗练高级攻击符文
Const.STATUS_XILIAN_HBS=189--洗练高级暴伤符文
-- 190-199 称号的buff
Const.STATUS_TYPE_WUXIE = 200--被动技能:无懈
Const.STATUS_TYPE_BAOJIMUST = 201--两次必暴击
Const.STATUS_TYPE_SHOUHU = 202--被动技能:守护
Const.STATUS_TYPE_MIANYIMUST = 203--两次伤害免疫
Const.STATUS_TYPE_JIANXUE = 204--被动技能:溅血
Const.STATUS_TYPE_LIUXUE = 205--debuff 每秒掉血
Const.STATUS_TYPE_QINGSHEN = 206--被动技能:清神
Const.STATUS_TYPE_KUANGRE = 207--被动技能:狂热
Const.STATUS_TYPE_TIANEN = 208--被动技能:天恩
Const.STATUS_TYPE_HUYOU = 209--被动技能:护佑
Const.STATUS_TYPE_ADDRENXING = 210--增加韧性
Const.STATUS_TYPE_SHENYU = 211--被动技能:神谕
Const.STATUS_TYPE_BIHU = 212--被动技能:庇护
Const.STATUS_TYPE_RUSHAN = 213--被动技能:如山
Const.STATUS_TYPE_ADDJIANSHANG = 214--增加减伤
Const.STATUS_TYPE_RUNZE = 215--被动技能:润泽
Const.STATUS_TYPE_ZHUFU = 216--被动技能:祝福
Const.STATUS_TYPE_KUANGBAO = 217--被动技能:狂暴
Const.STATUS_TYPE_SHIXUE = 218--被动技能:嗜血
Const.STATUS_TYPE_XIAOJIE = 219--被动技能:消解
Const.STATUS_TYPE_BAOLEI = 220--被动技能:堡垒
Const.STATUS_TYPE_JIANREN = 221--被动技能:坚韧
Const.STATUS_TYPE_CANYING = 222--被动技能:残影
Const.STATUS_TYPE_TIEBI = 223--被动技能:铁壁
Const.STATUS_TYPE_JINGJIE = 224--被动技能:警戒
Const.STATUS_TYPE_QIZHAO = 225--被动技能:气罩
-- 226 - 236 新增的红包称号buff
Const.STATUS_TYPE_MOBAI = 237--膜拜至尊
Const.ShortCutType = {
    Item = 1,
    Skill = 2,
}

Const.OPEN_NEW = {
    SKILL = 1,--新技能
    FUNC = 2, -- 新功能
}

Const.ITEM_GOLD_ID = 19000
Const.ITEM_EXP_ID =  19001
Const.ITEM_RELIVE_COIN_ID = 19002
Const.ITEM_OFFLINE_EXP_MUL_1 = 19004
Const.ITEM_OFFLINE_EXP_MUL_2 = 19005
Const.ITEM_OFFLINE_EXP_MUL_4 = 19006
Const.ITEM_GOLD_BIND_ID = 19007
Const.ITEM_VCOIN_ID = 19008
Const.ITEM_VCOIN_BIND_ID = 19009
Const.ITEM_CAPACITY_ID = 19010
Const.ITEM_ZBJP = 15363--装备精魄
Const.ITEM_BOSSJF_1W = 15467--BOSS积分(10000)
Const.ITEM_GUILD_DEGREE_ID = 19023--行会贡献度
Const.ITEM_NG_EXP_ID = 19035 --内功经验
Const.ITEM_VIRTUAL_ITEM_MAXID = 20000--最大虚拟物品ID
Const.ITEM_FOUNTAIN_ITEM_ID = 200000--接泉水物品ID

Const.ACTIVIY_INDEX_WORLD_BOSS = 1 -- 世界boss
Const.ACTIVIY_INDEX_MAYA = 2 -- 玛雅神殿
Const.ACTIVIY_INDEX_BOSS_ZHIJIA = 3 -- BOSS之家
Const.ACTIVIY_INDEX_DAILY = 4 -- 每日活动大厅
Const.ACTIVIY_INDEX_YOUMINGSHENGYU = 7 -- 幽冥圣域
Const.ACTIVIY_INDEX_SINGLEBOSS = 99 -- 个人boss
Const.ACTIVIY_INDEX_KUAFU = 100 --跨服boss

Const.TOPBTN = {}
Const.TOPBTN.btnSaveGame       = 1      --收藏游戏
Const.TOPBTN.btnLoginAward     = 2      --登陆器
Const.TOPBTN.btnFirstCharge    = 3      --首冲大礼
Const.TOPBTN.btnOnlineTime = 4	 --在线时长奖励
Const.TOPBTN.btnTotalLoginReward = 5	 --累计登录奖励
Const.TOPBTN.btnSuperGift = 6	 --每日超值礼包
Const.TOPBTN.btnNewArea = 7 -- 新区活动
Const.TOPBTN.btnPhoneVerify = 8 -- 手机验证
Const.TOPBTN.btnShopFavorable = 9 -- 超值特惠
Const.TOPBTN.btncombinearea = 10 -- 合区活动
Const.TOPBTN.btnDailyChargeAward = 11 --每日充值礼包
Const.TOPBTN.btnMeiRiHuoDong = 12
Const.TOPBTN.btnMeWantPowerful = 13
Const.TOPBTN.btnWorldBoss = 14
Const.TOPBTN.btnNewYear = 15 --新春活动
Const.TOPBTN.btnYBInvest= 16 --元宝投资
Const.TOPBTN.btnDaySign= 17 --签到
Const.TOPBTN.btnSimpleAchieve= 18 --目标系统
Const.TOPBTN.btnXunBao = 19--寻宝
Const.TOPBTN.btnZhaoCaiLingShou = 20--招财灵兽
Const.TOPBTN.btnShenQi = 21--神器
Const.TOPBTN.btnLiveness = 22		--活跃度
Const.TOPBTN.btnFirstDayIco = 23	--首冲ICO
Const.TOPBTN.btnLockMonsterTower = 24 --锁妖塔
Const.TOPBTN.btnEveryDayCopy = 25 --每日副本
Const.TOPBTN.btnQQGruop = 26	--QQ群
Const.TOPBTN.btnSogoSkin = 27
Const.TOPBTN.btnSogoDatin = 28
Const.TOPBTN.btnBaiDuAward = 29
Const.TOPBTN.btnOfflineExp = 30 --离线经验
Const.TOPBTN.btnRefineExp = 31 --炼制经验
Const.TOPBTN.btnjiangli = 32 --奖励大厅
Const.TOPBTN.btnwar = 33 --王城争霸
Const.TOPBTN.btnDzsd = 34 --打折商店
Const.TOPBTN.btnFestival = 35 --节日活动
Const.TOPBTN.btnRing = 36 --特戒
Const.TOPBTN.btnGongce = 37 --公测活动
Const.TOPBTN.btnQiling = 38 --器灵狂欢
Const.TOPBTN.btnNewArea2 = 39 --新区活动(2016-07-16)
Const.TOPBTN.btn360Datin = 40 --360大厅
Const.TOPBTN.btnHundred = 41 --百服活动
Const.TOPBTN.btnNewArea3 = 42 --第三版新区活动
Const.TOPBTN.btnView = 43 --你提我改
Const.TOPBTN.btnVitality = 44 --活跃度
Const.TOPBTN.btnLuckyDraw = 45 --幸运大奖
Const.TOPBTN.btnVipCopy = 46 --VIP副本
Const.TOPBTN.btnPTIVILEGE = 47 --特权卡
Const.TOPBTN.btnZhuBo = 48 --主播
Const.TOPBTN.btnShengLin = 49 --圣麟
Const.TOPBTN.btnCZRank = 50 --充值排行
Const.TOPBTN.btnHonourDaily = 51 --尊贵礼包
Const.TOPBTN.btnPointAct = 52 --战力盛宴活动
Const.TOPBTN.btnLCSYAct = 53 --龙城盛宴活动
Const.TOPBTN.btnOneYearAct = 54 --周年庆活动
Const.TOPBTN.btnOldPlayerAct = 55 --老玩家回归活动
Const.TOPBTN.btnFanpai = 56 --乐翻天活动
Const.TOPBTN.btnXuyuan = 57 --许愿树
Const.TOPBTN.btnXiaofei = 58 --消费排行榜
Const.TOPBTN.btnDanyaolu = 59 --丹药
Const.TOPBTN.btnHongbao = 60 -- 红包
Const.TOPBTN.btnLevelInvest = 61 --等级投资

----------更新整型值索引定义-----------------
Const.INT_UPDATE_BAIBAODAI=100001 --百宝袋正常收益剩余次数
Const.INT_UPDATE_COPYMAPGUIDE=100002 --副本引导剩余次数
Const.INT_UPDATE_LIVENESSGIFTFLAG=100003 --活跃度奖励标识
Const.INT_UPDATE_ACHIEVEGIFTFLAG=100004  --成就奖励标识
Const.INT_UPDATE_COMBINEAREA_GIFTFLAG=100005  --合区活动奖励标识
Const.INT_UPDATE_HONOUR_POINT=100006  --击打富贵兽增加灵气值
Const.INT_UPDATE_GUILDCOPY_OPENTIMES=100007  --行会秘境开启次数
Const.INT_UPDATE_ENTERCOPY_FLAG=100008       --是否在副本
Const.INT_UPDATE_YB_RELIVE_TIMES=100009      --元宝复活次数
Const.INT_UPDATE_INVESTGIFTFLAG=100010  	   --投资返利奖励标识
Const.INT_UPDATE_TENCENT_HZ_AWARD=100011		--黄钻奖励标识
Const.INT_UPDATE_3366_LZ_AWARD=100012			--蓝钻奖励标识
Const.INT_UPDATE_ADD_BAG_FLAG=100013
Const.INT_UPDATE_QQ_DATING_AWARD=100014  --qq大厅奖励标识


Const.TEXTURE_TYPE = {
    PNG = ".png",
    PVR = ".pvr.ccz",
}

Const.TEXTURE_RES_TYPE = {
    PLIST = ".plist",
    XML = ".xml",
}

Const.SLOT_OPEN_TYPE = {
    LEVEL = 1,
    VCOIN = 2,
    LEVEL_OR_VCOIN = 3,
}

Const.EditBox_InputMode = {
    --/**
    -- * The user is allowed to enter any text, including line breaks.
    --*/
    ANY=0,

    --/**
    --* The user is allowed to enter an e-mail address.
    --*/
    EMAIL_ADDRESS=1,

    --/**
    --* The user is allowed to enter an integer value.
    --*/
    NUMERIC=2,

    --/**
    --* The user is allowed to enter a phone number.
    --*/
    PHONE_NUMBER=3,

    --/**
    --* The user is allowed to enter a URL.
    --*/
    URL=4,

    --/**
    --* The user is allowed to enter a real number value.
    --* This extends kEditBoxInputModeNumeric by allowing a decimal point.
    --*/
    DECIMAL=5,

    --/**
    --* The user is allowed to enter any text, except for line breaks.
    --*/
    SINGLE_LINE=6,
}



Const.FCM_TYPE = {
    UNVALID = 0,
    PASS = 101, --验证成功
    TEENAGE = 102,--未成年
}

-- 身上装备位置 顺序不可随意改变 etype 暂时没用到
Const.EQUIP_INFO = {
    {pos = Const.ITEM_WEAPON_POSITION,	},
    {pos = Const.ITEM_NICKLACE_POSITION, },
    {pos = Const.ITEM_GLOVE1_POSITION,	},
    {pos = Const.ITEM_RING1_POSITION,	},
    {pos = Const.ITEM_YUPEI_POSITION,	},

    {pos = Const.ITEM_HUFU2_POSITION,	},
    {pos = Const.ITEM_SHENQI_POSTITION,	},

    {pos = Const.ITEM_JIANJIA_POSITION,	},
    {pos = Const.ITEM_BAOSHI_POSITION,	},
    {pos = Const.ITEM_DUNPAI_POSITION,	},
    {pos = Const.ITEM_ANQI_POSITION,	},
    {pos = Const.ITEM_YUXI_POSITION,	},
    {pos = Const.ITEM_MEDAL_POSITION,	},

    {pos = Const.ITEM_CLOTH_POSITION,	},
    {pos = Const.ITEM_HAT_POSITION,	},
    {pos = Const.ITEM_BELT_POSITION,	},
    {pos = Const.ITEM_BOOT_POSITION,	},
    {pos = Const.ITEM_HUFU_POSITION,	},

    {pos = Const.ITEM_LONGHUN_POSTITION,	},
    {pos = Const.ITEM_SHENJIA_POSTITION,	},
}

-- 身上装备 时装 顺序不可随意改变 etype 暂时没用到
Const.FASHION_INFO = {
    {pos = Const.ITEM_WING_LIGHT_POSITION, etype = Const.EQUIP_TAG.NECKLACE},
    {pos = Const.ITEM_FASHION_WEAPON_POSITION,	etype = Const.EQUIP_TAG.WEAPON},
    {pos = Const.ITEM_PIFENG_POSITION,	etype = Const.EQUIP_TAG.GLOVE},
    {pos = Const.ITEM_FASHION_WEDDING_RING_POSITION,	etype = Const.EQUIP_TAG.RING},
    {pos = Const.ITEM_FASHION_PAULDRON1_POSITION,	etype = Const.EQUIP_TAG.BELT},

    {pos = nil,	etype = Const.EQUIP_TAG.BELT},
    {pos = nil,	etype = Const.EQUIP_TAG.BELT},
    {pos = nil,	etype = Const.EQUIP_TAG.BELT},

    {pos = Const.ITEM_FASHION_PAULDRON2_POSITION,	etype = Const.EQUIP_TAG.BOOT},
    {pos = Const.ITEM_TEJIE_POSITION,	etype = Const.EQUIP_TAG.RING},
    {pos = Const.ITEM_FASHION_CLOTH_POSITION,	etype = Const.EQUIP_TAG.GLOVE},
    {pos = Const.ITEM_FASHION_ORNAMENTS_POSITION,	etype = Const.EQUIP_TAG.CLOTH},
    {pos = Const.ITEM_FASHION_HEADDRESS_POSITION,		etype = Const.EQUIP_TAG.HAT},
}

Const.FRIEND_TITLE = {
    FRIEND = 100,
    ENEMY = 50,
    BLACK = 20,
}

Const.TASK_MAIN_ID=1000
Const.TASK_ID_CYCLE_TASK=1001 --跑环任务
Const.TASK_ID_FUBEN_SEXP=2001
Const.TASK_ID_FUBEN_MAINTASK=2010
Const.TASK_ID_SUPERBOX = 2023 --超级宝盒
Const.TASK_ID_FUBEN_I = 3001 --副本指引
Const.TASK_ID_RICHANG = 3002-- 日常任务
Const.TASK_ID_RICHANG3 = 3004 -- 采矿
Const.TASK_ID_YABIAO = 3005 -- 押镖
Const.TASK_ID_JINGYING_RC = 3007 -- 剿灭精英
Const.TASK_ID_XIANGMO = 4007   --降魔任务

Const.MAX_LOTTERY_LOG = 10

Const.SKILL_TYPE_DESC = {
    [1]="单",
    [2]="群",
    [3]="辅",
    [4]="召",
}

Const.SORT_FLAG = {
    BAG = 2,
    CANGKU = 1,
}

--  Const.SORT_FLAG11= {"actionid":"base_data","param":{
--   	"award":[
-- 		[{"num":3000,"typename":"绑定元宝","bindflag":1,"typeid":19009},
-- 		{"num":1,"typename":"寻宝兑换券","bindflag":1,"typeid":15270},
-- 		{"num":1,"typename":"玛雅令牌","bindflag":1,"typeid":15015},
-- 		{"num":2,"typename":"金条","bindflag":0,"typeid":10043}
-- 		],
-- 		[{"num":6288,"typename":"绑定元宝","bindflag":1,"typeid":19009},
-- 		{"num":5,"typename":"寻宝兑换券","bindflag":1,"typeid":15270},
-- 		{"num":5,"typename":"宝石碎片·小","bindflag":1,"typeid":15568},
-- 		{"num":5,"typename":"金条","bindflag":0,"typeid":10043}
-- 		],
-- 		[{"num":11288,"typename":"绑定元宝","bindflag":1,"typeid":19009},
-- 		{"num":2,"typename":"盾牌碎片·大","bindflag":1,"typeid":15566},
-- 		{"num":2,"typename":"玛雅令牌","bindflag":1,"typeid":15015},
-- 		{"num":10,"typename":"金条","bindflag":0,"typeid":10043}]
-- 		],
-- 	"vcoin":[18,38,68,100,124],
-- "attri":["背包药包不足自动购买<br>每日获得2颗九转还魂丹<br>每日获得500W绑定金币",
-- "获得内功经验增加10%<br>寻宝获得极品概率增加10%<br>每日免费获得2000装备精魄",
-- "获得经验永久增加10%<br>每日免费获得2000万经验<br>死亡时装备掉落概率降低10%"],
-- "desc":[
-- ["<font color='#ff942f'>直升Vip lv15<\/font>",
-- "<font color='#ff942f'>背包药包不足自动购买<\/font>",
-- "<font color='#2ac0ff'>每 天免费获得3000绑定元宝<\/font>",
-- "<font color='#ff942f'>每天免费获得抽奖卷*1<\/font>",
-- "<font color='#ff942f'>每天免费获得玛雅令牌*1<\/font>",
-- "<font color='#ff942f'>每天免费获得金条*2<\/font>",
-- "<font color='#2ac0ff'>增加属性:暴击几率:0.8%,职 业攻击:60-100<\/font>"],
-- ["<font color='#ff942f'>直升Vip lv16<\/font>",
-- "<font color='#ff942f'>获得内功经验永久增加10%<\/font>",
-- "<font color='#fc2cff'>每天免费获得6288绑定元宝<\/font>",
-- "<font color='#ff942f'>每天免费获得抽奖卷*5<\/font>",
-- "<font color='#ff942f'>每天免费获得宝石碎片（小）*5<\/font>",
-- "<font color='#ff942f'>每天免费获得金条*5<\/font>",
-- "<font color='#fc2cff'>寻宝获得高档道具概率增加10%<\/font>",
-- "<font color='#2ac0ff'>增加属性:暴击伤害:200,生命上限:500<\/font>"],
-- ["<font color='#ff942f'>直升Vip lv17<\/font>",
-- "<font color='#ff942f'>获得经验永久增加10%<\/font>",
-- "<font color='#ff942f'>每 天免费获得11288绑定元宝<\/font>",
-- "<font color='#ff942f'>每天免费获得抽奖卷*1<\/font>",
-- "<font color='#ff942f'>每天免费获 得玛雅令牌*2<\/font>",
-- "<font color='#ff942f'>每天免费获得盾牌碎片（大）*2<\/font>",
-- "<font color='#fc2cff'>死亡时装备掉落概率降低10%<\/font>",
-- "<font color='#2ac0ff'>增加属性:暴击伤害:488,生命上限:2000<\/font>"]]}
-- }


  -- <font color="#e70301" >[系统]</font>欢迎来到复古传说