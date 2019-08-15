--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/27 14:18
-- To change this template use File | Settings | File Templates.
--

GuideDef = {}

GuideDef.FUNCID_QIANGHUA = 4
GuideDef.FUNCID_YUANSHEN = 6
GuideDef.FUNCID_GUILD = 7
GuideDef.FUNCID_WING = 11
GuideDef.FUNCID_SHENQI = 14
GuideDef.FUNCID_CHENGJIU = 19
GuideDef.FUNCID_SHENLU = 20
GuideDef.FUNCID_ZHUANSHENG = 21
GuideDef.FUNCID_ZHANSHEN = 25

-- 新功能开启定义

GuideDef.list = {
    [1] = {name = "每日活动",funcId = 1, isopen = 0,  guideType = 0, level = 40, needTask = 0, awardId = 0,rein=0,},
    [2] = {name = "我要变强",funcId = 2, isopen = 0,  guideType = 0, level = 40, needTask = 0, awardId = 0,rein=0,},
    [3] = {name = "神将",    funcId = 3, isopen = 0,  guideType = 1, level = 60, needTask = 25, awardId = 0,rein=0,},
    [4] = {name = "强化", 	  funcId = 4,isopen = 1,  guideType = 1, level = 22, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_make2.png",desp="行走在玛法大陆，装备的强化必不可少。屠龙城的铁匠巧夺天工，通过他们强化的装备强力无比，成为了众多旅行者的必备之物。"},
    [5] = {name = "世界BOSS",funcId = 5, isopen = 0,  guideType = 0, level = 59, needTask = 80, awardId = 0,rein=0,},
    [GuideDef.FUNCID_YUANSHEN] = {name = "元神", 	 funcId = GuideDef.FUNCID_YUANSHEN, isopen = 1,  guideType = 0, level = 48, needTask = 80, awardId = 0,rein=0,icon = "sysbtn_yuanshen.png",desp="真正的武者绝非好勇斗狠，他必是立于天地之间，观沧海桑田变化而心坦然的英雄。"},
    [7] = {name = "行会", 	 funcId = 7, isopen = 0,  guideType = 1, level = 60, needTask = 0, awardId = 0,rein=0},
    [8] = {name = "装备回收", funcId = 8,isopen = 0,  guideType = 1, level = 0, needTask = 0, awardId = 0,rein=0},
    [9] = {name = "坐骑",  	funcId = 9, isopen = 0, guideType = 1, level = 55, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_zuoqi.png",desp="坐骑预告，策划还没填写"},
    [10] = {name = "披风", 	funcId = 10,  isopen = 0, guideType = 1, level = 60, needTask = 52, awardId = 0,rein=0},
    [GuideDef.FUNCID_WING] = {name = "翅膀", 	funcId = GuideDef.FUNCID_WING,  isopen = 1, guideType = 1, level = 60, needTask = 0, awardId = 0,rein=0, icon = "sysbtn_wing2.png",desp="传说修为达到一定境界的人，会得到天神赐福，生出华丽的羽翼。"},
    [12] = {name = "招财灵兽", funcId = 12,  isopen = 0, guideType = 0, level = 62, needTask = 82, awardId = 0,rein=0},
    [13] = {name = "寻宝", funcId = 13,  isopen = 1, guideType = 0, level = 60, needTask = 0, awardId = 0,rein=0,},
    [GuideDef.FUNCID_SHENQI] = {name = "神器", funcId = GuideDef.FUNCID_SHENQI,  isopen = 1, guideType = 0, level = 70, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_shenqi.png",desp="上古之战中，众神遗留在世界各地的宝物，终于又重见天日了！"},
    [15] = {name = "目标系统", funcId = 15,  isopen = 0, guideType = 1, level = 62, needTask = 82, awardId = 0,rein=0,},
    [16] = {name = "活跃度", funcId = 16,  isopen = 0, guideType = 0, level = 45, needTask = 0, awardId = 0,rein=0,},
    [17] = {name = "锁妖塔", funcId = 17,  isopen = 0, guideType = 0, level = 60, needTask = 82, awardId = 0,rein=0,},
    [18] = {name = "每日副本", funcId = 18,  isopen = 0, guideType = 0, level = 60, needTask = 34, awardId = 0,rein=0,},
    [GuideDef.FUNCID_CHENGJIU] = {name = "成就", funcId = GuideDef.FUNCID_CHENGJIU,  isopen = 1, guideType = 0, level = 42, needTask = 34, awardId = 0,rein=0,icon = "sysbtn_chengjiu.png",desp="探索玛法大陆，记录你传奇的一生。"},
    [GuideDef.FUNCID_SHENLU] = {name = "神炉", funcId = GuideDef.FUNCID_SHENLU,  isopen = 1, guideType = 0, level = 34, needTask = 0, awardId = 0,rein=0, icon = "sysbtn_smelter2.png",desp="行走在玛法大陆，结实的护具必不可少。屠龙城的铁匠对传承多年的神炉技术进行改良，使原本厚重的护甲变得轻便易携，成为了众多旅者的必备之物。"},
    [21] = {name = "转生", funcId = GuideDef.FUNCID_ZHUANSHENG,  isopen = 1, guideType = 0, level = 80, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_zhuansheng.png",desp="不知道是哪个道士发现了转生之法，通过对精元的压缩与再生，可以极大增强体魄，拥有更强的攻击和防御能力。"},
    [22] = {name = "特戒", funcId = 22,  isopen = 1, guideType = 0, level = 50, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_tejie.png",desp="象征身份的贵族之戒，能力非凡。"},
    [23] = {name = "器灵", funcId = 23,  isopen = 1, guideType = 0, level = 75, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_qiling.png",desp="器灵预告，策划还没填写"},
    [GuideDef.FUNCID_ZHANSHEN] = {name = "战神", funcId = GuideDef.FUNCID_ZHANSHEN,  isopen = 1, guideType = 1, level = 10, needTask = 0, awardId = 0,rein=0,icon = "sysbtn_zhanshen.png",desp="行走在玛法大陆，战神是一个强有力的伙伴。拥有了战神伙伴会使自身的战斗力更强，很多旅行者都想拥有他。"},
    [26] = {name = "神技", funcId = 26,  isopen = 1, guideType = 0, level = 80, needTask = 0, awardId = 0,rein=4},
}

