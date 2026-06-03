import '../models/models.dart';

/// 内置标准孕期数据(只读预置表 standard_pregnancy_data 的代码版),覆盖第 4–40 周。
///
/// 数据综合自:北京市卫生健康委妇产科普、多家三甲医院通用产检时间表、
/// 中国营养学会《孕期妇女膳食指南》及孕期微量营养素补充专家共识等公开资料,
/// 经整理归纳。胎儿大小为常见的「水果对照」形象化描述,仅供参考。
///
/// 内容仅供参考,正式上架请逐条对齐最新《中国妇产科指南》/ WHO 标准,
/// 并在 App 内附「不构成医疗诊断建议」免责声明。
class StandardData {
  static const Map<int, StandardWeekData> _weeks = {
    4: StandardWeekData(
      week: 4,
      fruitEmoji: '🫘',
      fetusSummary: '受精卵着床,生命刚刚开始。',
      bodyChange: '可能尚无明显感觉,或有轻微乏力。',
      dietGood: ['叶酸 400–800μg', '规律作息', '戒烟戒酒'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('确认怀孕', '可验血查 HCG / 验孕棒'),
      ],
      dadTasks: [
        DadTask('一起戒烟戒酒,营造无烟环境'),
        DadTask('帮忙记录末次月经,推算孕周', true),
      ],
    ),
    5: StandardWeekData(
      week: 5,
      fruitEmoji: '🌱',
      fetusSummary: '胚胎像一颗芝麻,神经管开始发育。',
      bodyChange: '可能停经、乳房胀痛,情绪波动。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('继续补充叶酸', '神经管发育关键期'),
      ],
      dadTasks: [
        DadTask('体谅情绪波动,多包容'),
        DadTask('分担家务,让老婆多休息'),
      ],
    ),
    6: StandardWeekData(
      week: 6,
      fruitEmoji: '🫛',
      fetusSummary: '胚胎像一颗小扁豆,心脏开始跳动。',
      bodyChange: '孕吐可能开始,嗜睡乏力。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('首次 B 超(可选)', '确认宫内孕及胎心'),
      ],
      dadTasks: [
        DadTask('准备清淡小零食缓解孕吐'),
        DadTask('陪同首次 B 超'),
      ],
    ),
    7: StandardWeekData(
      week: 7,
      fruitEmoji: '🫐',
      fetusSummary: '胚胎像一颗蓝莓,手脚芽开始出现。',
      bodyChange: '孕吐、尿频、嗅觉敏感。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('观察早孕反应', '严重孕吐及时就医'),
      ],
      dadTasks: [
        DadTask('避免做重口味食物的气味刺激'),
        DadTask('夜里多体谅起夜'),
      ],
    ),
    8: StandardWeekData(
      week: 8,
      fruitEmoji: '🍇',
      fetusSummary: '胚胎像一颗葡萄,初具人形。',
      bodyChange: '疲乏嗜睡,孕吐可能加重。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('建小卡 / 母子健康手册', '带身份证、社保卡'),
      ],
      dadTasks: [
        DadTask('陪同建卡,负责排队挂号'),
        DadTask('学习孕吐应对方法'),
      ],
    ),
    9: StandardWeekData(
      week: 9,
      fruitEmoji: '🍒',
      fetusSummary: '正式称为胎儿啦,像一颗樱桃。',
      bodyChange: '孕吐持续,可能便秘。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)', '膳食纤维防便秘'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('常规监测', '保持心情放松'),
      ],
      dadTasks: [
        DadTask('准备高纤维食物,帮助缓解便秘'),
        DadTask('陪散步放松心情'),
      ],
    ),
    10: StandardWeekData(
      week: 10,
      fruitEmoji: '🫒',
      fetusSummary: '胎儿像一颗橄榄,手腕脚踝成形。',
      bodyChange: '症状可能稍缓,情绪仍敏感。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('常规产检', '按医嘱补充'),
      ],
      dadTasks: [
        DadTask('多给情绪支持'),
        DadTask('分担提重物等家务', true),
      ],
    ),
    11: StandardWeekData(
      week: 11,
      fruitEmoji: '🥝',
      fetusSummary: '胎儿像一颗奇异果,长约 4–6cm。',
      bodyChange: '可能出现妊娠线,腰部变化。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('准备 NT 预约', 'NT 最佳 11–13⁺⁶ 周'),
      ],
      dadTasks: [
        DadTask('提前预约 NT 检查'),
        DadTask('陪同产检'),
      ],
    ),
    12: StandardWeekData(
      week: 12,
      fruitEmoji: '🍋',
      fetusSummary: '宝宝像一颗青柠,身长约 6.5cm,已初具人形。',
      bodyChange: '孕吐逐渐缓解,子宫增大可在下腹摸到。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('NT 颈项透明层筛查', '需 11–13⁺⁶ 周完成,提前预约'),
        CheckItem('正式建档 / 首次产检', '带身份证、社保卡'),
      ],
      dadTasks: [
        DadTask('陪同首次正式产检并负责挂号排队', true),
        DadTask('学习如何缓解孕吐,备好清淡零食'),
      ],
    ),
    13: StandardWeekData(
      week: 13,
      fruitEmoji: '🍑',
      fetusSummary: '宝宝像一颗水蜜桃,孕早期即将结束。',
      bodyChange: '孕吐基本缓解,食欲开始回升。',
      dietGood: ['叶酸 400–800μg', '清淡易消化', '优质蛋白(蛋奶)', '逐步增加营养'],
      dietBad: ['生食 / 半熟蛋', '酒精', '高汞鱼', '浓茶咖啡'],
      checks: [
        CheckItem('NT 结果复查', '确认筛查结果'),
      ],
      dadTasks: [
        DadTask('一起庆祝度过孕早期'),
        DadTask('规划孕中期营养'),
      ],
    ),
    14: StandardWeekData(
      week: 14,
      fruitEmoji: '🍋',
      fetusSummary: '宝宝像一颗柠檬,开始有表情。',
      bodyChange: '进入孕中期,精神状态好转。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('唐筛 / 无创 DNA 准备', '唐筛需空腹,无创无需空腹'),
      ],
      dadTasks: [
        DadTask('陪同唐筛 / 无创抽血'),
        DadTask('开始研究孕妇营养食谱'),
      ],
    ),
    15: StandardWeekData(
      week: 15,
      fruitEmoji: '🍊',
      fetusSummary: '宝宝像一颗橙子,骨骼快速发育。',
      bodyChange: '食欲旺盛,注意均衡。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('唐筛 / 无创 DNA', '结果约 10 个工作日'),
      ],
      dadTasks: [
        DadTask('陪做产检,记录结果'),
        DadTask('准备补钙食材(牛奶/豆制品)'),
      ],
    ),
    16: StandardWeekData(
      week: 16,
      fruitEmoji: '🥑',
      fetusSummary: '宝宝像一个牛油果,能听到外界声音了。',
      bodyChange: '食欲回升,可能轻微水肿,注意补钙。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('唐筛 / 无创 DNA 出结果', '高危需进一步羊穿'),
        CheckItem('血压体重监测', '常规项目'),
      ],
      dadTasks: [
        DadTask('准备孕妇枕,缓解老婆腰酸'),
        DadTask('开始陪听胎教音乐'),
        DadTask('包揽提重物等家务', true),
      ],
    ),
    17: StandardWeekData(
      week: 17,
      fruitEmoji: '🍐',
      fetusSummary: '宝宝像一个梨,可能感到初次胎动。',
      bodyChange: '可能初感胎动(经产妇更早)。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '听胎心、量宫高'),
      ],
      dadTasks: [
        DadTask('和宝宝说话、做胎教'),
        DadTask('陪散步增进感情'),
      ],
    ),
    18: StandardWeekData(
      week: 18,
      fruitEmoji: '🍠',
      fetusSummary: '宝宝像一个红薯,听力进一步发育。',
      bodyChange: '腰背可能酸胀,注意姿势。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('预约大排畸', '大排畸 20–24 周进行,需提前预约'),
      ],
      dadTasks: [
        DadTask('提前预约大排畸(三维/四维)'),
        DadTask('帮忙按摩缓解腰酸'),
      ],
    ),
    19: StandardWeekData(
      week: 19,
      fruitEmoji: '🍅',
      fetusSummary: '宝宝像一个番茄,感官迅速发展。',
      bodyChange: '胎动渐明显,皮肤可能瘙痒。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '关注体重增长'),
      ],
      dadTasks: [
        DadTask('记录胎动的美好时刻'),
        DadTask('准备无刺激护肤品'),
      ],
    ),
    20: StandardWeekData(
      week: 20,
      fruitEmoji: '🍌',
      fetusSummary: '宝宝像一根香蕉,孕程过半啦。',
      bodyChange: '能清晰感到胎动,腰背酸胀。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('大排畸(系统超声)', '约 30–40 分钟,不需空腹憋尿,可适当进食增加胎动'),
        CheckItem('补充铁剂复查', '按医嘱'),
      ],
      dadTasks: [
        DadTask('陪同大排畸,全程录像记录'),
        DadTask('研究并预约月子中心 / 月嫂'),
      ],
    ),
    21: StandardWeekData(
      week: 21,
      fruitEmoji: '🥕',
      fetusSummary: '宝宝像一根胡萝卜,开始吞咽羊水。',
      bodyChange: '可能食欲大增,注意控重。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '监测血压尿蛋白'),
      ],
      dadTasks: [
        DadTask('帮忙准备低 GI 餐'),
        DadTask('一起控制体重增长'),
      ],
    ),
    22: StandardWeekData(
      week: 22,
      fruitEmoji: '🌽',
      fetusSummary: '宝宝像一根玉米,眉毛睫毛长出。',
      bodyChange: '体重稳步增长,可能腿抽筋。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收', '补钙防抽筋'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '腿抽筋提示补钙'),
      ],
      dadTasks: [
        DadTask('夜里帮忙缓解腿抽筋'),
        DadTask('准备补钙食材'),
      ],
    ),
    23: StandardWeekData(
      week: 23,
      fruitEmoji: '🍈',
      fetusSummary: '宝宝像一个甜瓜,肺部开始发育。',
      bodyChange: '腹部明显隆起,重心变化。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('准备糖耐预约', '糖耐 24–28 周,需空腹'),
      ],
      dadTasks: [
        DadTask('提前了解糖耐流程,准备早餐安排'),
        DadTask('陪散步注意安全'),
      ],
    ),
    24: StandardWeekData(
      week: 24,
      fruitEmoji: '🌽',
      fetusSummary: '宝宝像一根玉米,听力快速发育,可以多和 TA 说话。',
      bodyChange: '体重增长加快,留意血糖。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('糖耐量试验 OGTT', '需空腹 8 小时,前一晚 22:00 后禁食,糖水 5 分钟内喝完,空腹/1h/2h 各抽一次血'),
        CheckItem('血常规复查', '排查贫血'),
      ],
      dadTasks: [
        DadTask('陪做糖耐,提前安排好早餐'),
        DadTask('学做低糖餐,一起控糖'),
      ],
    ),
    25: StandardWeekData(
      week: 25,
      fruitEmoji: '🥦',
      fetusSummary: '宝宝像一棵西兰花,大脑快速发育。',
      bodyChange: '可能气短、消化不适。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '关注糖耐结果'),
      ],
      dadTasks: [
        DadTask('若血糖偏高,陪同调整饮食'),
        DadTask('分担弯腰类家务'),
      ],
    ),
    26: StandardWeekData(
      week: 26,
      fruitEmoji: '🥬',
      fetusSummary: '宝宝像一棵生菜,眼睛能睁开了。',
      bodyChange: '可能出现假性宫缩。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '了解假性宫缩'),
      ],
      dadTasks: [
        DadTask('学习辨别真假宫缩'),
        DadTask('陪做孕妇瑜伽 / 散步'),
      ],
    ),
    27: StandardWeekData(
      week: 27,
      fruitEmoji: '🥒',
      fetusSummary: '宝宝像一根黄瓜,孕中期即将结束。',
      bodyChange: '睡眠可能受影响。',
      dietGood: ['钙 + 维 D', 'DHA(深海鱼)', '含铁食物(红肉/动物血)', '维 C 助铁吸收'],
      dietBad: ['高糖甜点', '腌制品', '生海鲜', '过量咖啡'],
      checks: [
        CheckItem('常规产检', '准备进入孕晚期'),
      ],
      dadTasks: [
        DadTask('改善睡眠环境,准备孕妇枕'),
        DadTask('规划待产物品清单'),
      ],
    ),
    28: StandardWeekData(
      week: 28,
      fruitEmoji: '🍆',
      fetusSummary: '宝宝像一个茄子,进入孕晚期,会睁眼了。',
      bodyChange: '宫缩偶现(假性),开始数胎动。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('产检改为两周一次', '正式进入孕晚期'),
        CheckItem('每日自数胎动', '发现异常立即就医'),
        CheckItem('胎心监护', '按医嘱'),
      ],
      dadTasks: [
        DadTask('教老婆数胎动并一起记录'),
        DadTask('规划去医院的最快路线'),
      ],
    ),
    29: StandardWeekData(
      week: 29,
      fruitEmoji: '🎃',
      fetusSummary: '宝宝像一个小南瓜,肌肉脂肪增加。',
      bodyChange: '可能尿频、便秘加重。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水', '膳食纤维'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('两周一次产检', '监测胎位'),
      ],
      dadTasks: [
        DadTask('准备待产包并逐项核对'),
        DadTask('陪散步缓解水肿'),
      ],
    ),
    30: StandardWeekData(
      week: 30,
      fruitEmoji: '🥥',
      fetusSummary: '宝宝像一个椰子,可做小排畸复查。',
      bodyChange: '耻骨可能酸痛,行动变缓。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('小排畸 + 基础复查', '补充大排畸,查双顶径、体重等'),
      ],
      dadTasks: [
        DadTask('陪同小排畸'),
        DadTask('帮忙穿鞋袜等不便动作'),
      ],
    ),
    31: StandardWeekData(
      week: 31,
      fruitEmoji: '🍍',
      fetusSummary: '宝宝像一个菠萝,各器官趋于成熟。',
      bodyChange: '睡眠姿势受限,建议左侧卧。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('两周一次产检', '关注血压'),
      ],
      dadTasks: [
        DadTask('准备孕妇侧卧枕'),
        DadTask('学习分娩相关知识'),
      ],
    ),
    32: StandardWeekData(
      week: 32,
      fruitEmoji: '🥥',
      fetusSummary: '宝宝像一个大椰子,皮下脂肪增多。',
      bodyChange: '可能耻骨痛、尿频,注意休息。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('胎位评估', '关注是否头位'),
        CheckItem('胎心监护(NST)', '按医嘱'),
      ],
      dadTasks: [
        DadTask('准备并核对待产包'),
        DadTask('陪老婆散步,缓解水肿'),
      ],
    ),
    33: StandardWeekData(
      week: 33,
      fruitEmoji: '🍠',
      fetusSummary: '宝宝像一个大红薯,免疫系统发育。',
      bodyChange: '假性宫缩更频繁。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('两周一次产检', '辨别真假宫缩'),
      ],
      dadTasks: [
        DadTask('了解临产征兆'),
        DadTask('确认住院所需证件'),
      ],
    ),
    34: StandardWeekData(
      week: 34,
      fruitEmoji: '🍈',
      fetusSummary: '宝宝像一个哈密瓜,中枢神经成熟。',
      bodyChange: '可能水肿加重。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('产检 + 胎心监护', '监测胎动胎心'),
      ],
      dadTasks: [
        DadTask('帮忙抬高腿部缓解水肿'),
        DadTask('安装好婴儿安全座椅'),
      ],
    ),
    35: StandardWeekData(
      week: 35,
      fruitEmoji: '🍯',
      fetusSummary: '宝宝继续长肉,为出生做准备。',
      bodyChange: '胃部受压,食量受限。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('两周一次产检', '少食多餐'),
      ],
      dadTasks: [
        DadTask('准备易消化的小份餐食'),
        DadTask('再次核对待产包'),
      ],
    ),
    36: StandardWeekData(
      week: 36,
      fruitEmoji: '🍈',
      fetusSummary: '宝宝像一个大哈密瓜,即将足月。',
      bodyChange: '宫缩更频繁,关注见红破水。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('产检改为每周一次', '进入临产准备期'),
        CheckItem('B 族链球菌筛查 (GBS)', '按医嘱'),
      ],
      dadTasks: [
        DadTask('确认住院证件与流程'),
        DadTask('保持手机畅通,随时待命'),
      ],
    ),
    37: StandardWeekData(
      week: 37,
      fruitEmoji: '🥬',
      fetusSummary: '宝宝已足月,随时可能发动。',
      bodyChange: '可能感到胎儿下降、呼吸轻松。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('每周产检 + 胎心监护', '足月待产'),
      ],
      dadTasks: [
        DadTask('熟悉入院流程和病房位置'),
        DadTask('请好陪产假'),
      ],
    ),
    38: StandardWeekData(
      week: 38,
      fruitEmoji: '🎃',
      fetusSummary: '宝宝继续储备能量,等待出生。',
      bodyChange: '宫缩、腰酸可能加重。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('每周产检', '关注规律宫缩'),
      ],
      dadTasks: [
        DadTask('保持车辆油量充足、随时可出发', true),
        DadTask('安抚老婆情绪'),
      ],
    ),
    39: StandardWeekData(
      week: 39,
      fruitEmoji: '🍉',
      fetusSummary: '宝宝足月,随时准备见面。',
      bodyChange: '警惕破水、规律宫缩。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('每周产检 + 评估', '出现规律宫缩 / 破水即就医'),
      ],
      dadTasks: [
        DadTask('待产包放在门口随手可取', true),
        DadTask('演练去医院的流程'),
      ],
    ),
    40: StandardWeekData(
      week: 40,
      fruitEmoji: '🍉',
      fetusSummary: '宝宝足月啦,随时迎接 TA 的到来!',
      bodyChange: '关注规律宫缩、破水,及时入院。',
      dietGood: ['少食多餐', '优质脂肪(坚果/橄榄油)', '钙 1000mg', '足量饮水'],
      dietBad: ['高糖饮料', '高盐重口', '夜宵油腻', '过量水果'],
      checks: [
        CheckItem('每日胎动监测', '密切关注'),
        CheckItem('随时入院评估', '规律宫缩 5-1-1 或破水立即就医'),
      ],
      dadTasks: [
        DadTask('陪产准备就绪,保持冷静'),
        DadTask('做好后勤,记录宝宝出生时刻'),
      ],
    ),
  };

  /// 取不大于 [week] 的最近一周数据;若早于第一个关键周,则取第一个。
  /// 现已覆盖 4–40 周,正常情况下都能精确命中当周。
  static StandardWeekData resolve(int week) {
    if (_weeks.containsKey(week)) return _weeks[week]!;
    final keys = _weeks.keys.toList()..sort();
    int chosen = keys.first;
    for (final k in keys) {
      if (k <= week) chosen = k;
    }
    return _weeks[chosen]!;
  }

  static bool isMilestone(int week) => _weeks.containsKey(week);
}
