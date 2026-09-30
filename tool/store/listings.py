# -*- coding: utf-8 -*-
"""Emits docs/store/listing/<lang>.md for Google Play, and checks the limits.

Play rejects over-length fields silently, so every field is measured here.
Limits: title 30, short description 80, full description 4000.
"""
import os, sys

L = {}

L['en'] = dict(
  title="Tile Titans: Merge Trials",
  short="Daily merge puzzles, 18 built challenges and four modes that really differ.",
  full="""Tile Titans is a merging puzzle built around designed challenges, not an endless board.

TITAN TRIALS
18 hand-built puzzles across three chapters. Each starts from a fixed position with a specific objective and a real constraint: a move budget, a clock, blocked cells, or no undo. One of them spawns no tiles at all — a pure puzzle with an exact solution.

DAILY TITAN TRIAL
A new challenge every day, generated from the date, so every player in the world gets the same board and the same objective. Build a streak.

FOUR WAYS TO PLAY
Classic — the strategic baseline.
Zen — no score, and no game over. A stuck board clears its smallest tiles so you can keep going as long as you like.
Time Attack — ninety seconds, but every merge buys you more. Chain them.
Hardcore — a bigger board, two tiles per move, mostly fours, and no help at all.

CLIMB THE PATH OF THE TITANS
Fifteen achievements carry you from Novice to Legend. Rank comes from what you achieve — there is no currency and nothing to buy.

TRACK EVERYTHING
Records are kept per mode, because a Hardcore run and a Time Attack run are not the same game. Separate leaderboards for each.

MADE TO LOOK AT
Every tile carries its Titan rank sigil. Six themes, from Classic through Forge.

Plays offline. Free.""")

L['ru'] = dict(
  title="Tile Titans: испытания",
  short="Ежедневные головоломки, 18 испытаний и четыре по-настоящему разных режима.",
  full="""Tile Titans — головоломка со слиянием, построенная вокруг продуманных испытаний, а не бесконечного поля.

ИСПЫТАНИЯ ТИТАНОВ
18 собранных вручную головоломок в трёх главах. Каждая начинается с заданной позиции, со своей целью и настоящим ограничением: лимит ходов, таймер, закрытые клетки или запрет на отмену. В одной новые плитки не появляются вовсе — чистая головоломка с точным решением.

ЕЖЕДНЕВНОЕ ИСПЫТАНИЕ
Новое испытание каждый день, созданное из даты: у всех игроков мира одно и то же поле и одна и та же цель. Собирайте серию.

ЧЕТЫРЕ СПОСОБА ИГРАТЬ
Классика — стратегическая основа.
Дзен — без очков и без проигрыша. Застрявшее поле убирает самые мелкие плитки, и можно играть сколько угодно.
На время — девяносто секунд, но каждое слияние добавляет ещё. Стройте цепочки.
Хардкор — поле больше, две плитки за ход, в основном четвёрки, и никакой помощи.

ПУТЬ ТИТАНОВ
Пятнадцать достижений ведут от Новичка до Легенды. Ранг даётся за достижения — здесь нет валюты и нечего покупать.

ВСЯ СТАТИСТИКА
Рекорды ведутся по каждому режиму, потому что забег в Хардкоре и забег На время — разные игры. Для каждого своя таблица лидеров.

СДЕЛАНО, ЧТОБЫ СМОТРЕТЬ
На каждой плитке — знак ранга титана. Шесть тем, от Классики до Горна.

Играет офлайн. Бесплатно.""")

L['de'] = dict(
  title="Tile Titans: Merge-Prüfung",
  short="Tägliche Merge-Rätsel, 18 gebaute Prüfungen und vier wirklich andere Modi.",
  full="""Tile Titans ist ein Merge-Rätsel, das um entworfene Prüfungen herum gebaut ist — nicht um ein endloses Feld.

TITANENPRÜFUNGEN
18 handgebaute Rätsel in drei Kapiteln. Jedes beginnt auf einer festen Stellung, mit einem eigenen Ziel und einer echten Einschränkung: ein Zugbudget, eine Uhr, blockierte Felder oder kein Rückgängig. In einem erscheinen überhaupt keine neuen Steine — ein reines Rätsel mit exakter Lösung.

TÄGLICHE TITANENPRÜFUNG
Jeden Tag eine neue Aufgabe, aus dem Datum erzeugt: Jeder Spieler weltweit bekommt dasselbe Feld und dasselbe Ziel. Baue eine Serie auf.

VIER ARTEN ZU SPIELEN
Klassisch — die strategische Grundlage.
Zen — keine Punkte, kein Spielende. Ein feststeckendes Feld löst seine kleinsten Steine auf, damit du weiterspielen kannst.
Zeitrennen — neunzig Sekunden, aber jede Verschmelzung bringt mehr. Verkette sie.
Hardcore — größeres Feld, zwei Steine pro Zug, meist Vieren, und keinerlei Hilfe.

DER PFAD DER TITANEN
Fünfzehn Erfolge führen vom Neuling zur Legende. Der Rang kommt aus dem, was du erreichst — es gibt keine Währung und nichts zu kaufen.

ALLES IM BLICK
Rekorde werden pro Modus geführt, denn ein Hardcore-Lauf und ein Zeitrennen sind nicht dasselbe Spiel. Für jeden eine eigene Bestenliste.

ZUM ANSCHAUEN GEMACHT
Jeder Stein trägt sein Titanen-Rangzeichen. Sechs Themes, von Klassisch bis Schmiede.

Spielt offline. Kostenlos.""")

L['fr'] = dict(
  title="Tile Titans : Épreuves",
  short="Puzzles quotidiens, 18 épreuves conçues et quatre modes vraiment différents.",
  full="""Tile Titans est un puzzle de fusion construit autour d'épreuves conçues, pas d'un plateau sans fin.

ÉPREUVES DES TITANS
18 puzzles faits à la main, répartis en trois chapitres. Chacun part d'une position fixe, avec un objectif précis et une contrainte réelle : un budget de coups, un chronomètre, des cases bloquées, ou pas d'annulation. Dans l'un d'eux, aucune tuile n'apparaît — un puzzle pur, à solution exacte.

ÉPREUVE DU JOUR
Un nouveau défi chaque jour, généré à partir de la date : tous les joueurs du monde reçoivent le même plateau et le même objectif. Construisez une série.

QUATRE FAÇONS DE JOUER
Classique — la base stratégique.
Zen — sans score et sans défaite. Un plateau bloqué dissout ses plus petites tuiles pour que vous continuiez aussi longtemps que vous voulez.
Contre-la-montre — quatre-vingt-dix secondes, mais chaque fusion en rachète. Enchaînez-les.
Extrême — un plateau plus grand, deux tuiles par coup, surtout des quatre, et aucune aide.

LA VOIE DES TITANS
Quinze succès vous mènent de Novice à Légende. Le rang vient de ce que vous accomplissez — il n'y a aucune monnaie et rien à acheter.

TOUT EST SUIVI
Les records sont tenus par mode, parce qu'une partie en Extrême et une partie Contre-la-montre ne sont pas le même jeu. Un classement distinct pour chacun.

FAIT POUR ÊTRE REGARDÉ
Chaque tuile porte le sigle de son rang de titan. Six thèmes, de Classique à Forge.

Fonctionne hors ligne. Gratuit.""")

L['es'] = dict(
  title="Tile Titans: Pruebas",
  short="Puzles diarios, 18 pruebas diseñadas y cuatro modos realmente distintos.",
  full="""Tile Titans es un puzle de fusión construido alrededor de pruebas diseñadas, no de un tablero infinito.

PRUEBAS DE TITANES
18 puzles hechos a mano en tres capítulos. Cada uno parte de una posición fija, con un objetivo concreto y una restricción real: un límite de movimientos, un reloj, casillas bloqueadas o sin deshacer. En uno de ellos no aparece ninguna ficha nueva — un puzle puro, con solución exacta.

PRUEBA DIARIA
Un reto nuevo cada día, generado a partir de la fecha: todos los jugadores del mundo reciben el mismo tablero y el mismo objetivo. Encadena una racha.

CUATRO FORMAS DE JUGAR
Clásico — la base estratégica.
Zen — sin puntuación y sin fin de partida. Un tablero atascado disuelve sus fichas más pequeñas para que sigas todo lo que quieras.
Contrarreloj — noventa segundos, pero cada fusión te da más. Encadénalas.
Extremo — un tablero mayor, dos fichas por movimiento, casi siempre cuatros, y ninguna ayuda.

EL CAMINO DE LOS TITANES
Quince logros te llevan de Novato a Leyenda. El rango viene de lo que consigues — no hay moneda ni nada que comprar.

TODO QUEDA REGISTRADO
Los récords se guardan por modo, porque una partida en Extremo y una Contrarreloj no son el mismo juego. Una clasificación distinta para cada uno.

HECHO PARA MIRARLO
Cada ficha lleva el sigilo de su rango de titán. Seis temas, de Clásico a Forja.

Funciona sin conexión. Gratis.""")

L['it'] = dict(
  title="Tile Titans: Prove",
  short="Puzzle quotidiani, 18 prove costruite e quattro modi davvero diversi.",
  full="""Tile Titans è un puzzle di fusione costruito attorno a prove progettate, non a una plancia infinita.

PROVE DEI TITANI
18 puzzle fatti a mano in tre capitoli. Ognuno parte da una posizione fissa, con un obiettivo preciso e un vincolo reale: un budget di mosse, un orologio, caselle bloccate o nessun annullamento. In uno non compare alcuna tessera — un puzzle puro, con soluzione esatta.

PROVA QUOTIDIANA
Una sfida nuova ogni giorno, generata dalla data: tutti i giocatori del mondo ricevono la stessa plancia e lo stesso obiettivo. Costruisci una serie.

QUATTRO MODI DI GIOCARE
Classico — la base strategica.
Zen — senza punteggio e senza sconfitta. Una plancia bloccata dissolve le tessere più piccole così puoi continuare quanto vuoi.
Contro il tempo — novanta secondi, ma ogni fusione ne restituisce. Concatenale.
Estremo — plancia più grande, due tessere per mossa, quasi sempre quattro, e nessun aiuto.

LA VIA DEI TITANI
Quindici obiettivi ti portano da Novizio a Leggenda. Il grado nasce da ciò che ottieni — non c'è valuta e non c'è nulla da comprare.

TUTTO REGISTRATO
I record sono tenuti per modo, perché una partita in Estremo e una Contro il tempo non sono lo stesso gioco. Una classifica separata per ciascuno.

FATTO PER ESSERE GUARDATO
Ogni tessera porta il sigillo del suo grado di titano. Sei temi, da Classico a Fucina.

Funziona offline. Gratis.""")

L['pt'] = dict(
  title="Tile Titans: Provas",
  short="Puzzles diários, 18 provas criadas e quatro modos mesmo diferentes.",
  full="""Tile Titans é um puzzle de fusão construído à volta de provas desenhadas, e não de um tabuleiro infinito.

PROVAS DOS TITÃS
18 puzzles feitos à mão em três capítulos. Cada um parte de uma posição fixa, com um objetivo concreto e uma restrição real: um limite de jogadas, um relógio, casas bloqueadas ou sem desfazer. Num deles não aparece qualquer peça nova — um puzzle puro, de solução exata.

PROVA DIÁRIA
Um desafio novo todos os dias, gerado a partir da data: todos os jogadores do mundo recebem o mesmo tabuleiro e o mesmo objetivo. Constrói uma sequência.

QUATRO FORMAS DE JOGAR
Clássico — a base estratégica.
Zen — sem pontuação e sem derrota. Um tabuleiro preso dissolve as peças mais pequenas para continuares o tempo que quiseres.
Contrarrelógio — noventa segundos, mas cada fusão devolve mais. Encadeia-as.
Extremo — tabuleiro maior, duas peças por jogada, quase sempre quatros, e nenhuma ajuda.

O CAMINHO DOS TITÃS
Quinze proezas levam-te de Novato a Lenda. O nível vem do que alcanças — não há moeda nem nada para comprar.

TUDO REGISTADO
Os recordes são guardados por modo, porque uma partida em Extremo e uma Contrarrelógio não são o mesmo jogo. Uma tabela separada para cada um.

FEITO PARA SE VER
Cada peça traz o selo do seu nível de titã. Seis temas, de Clássico a Forja.

Joga offline. Gratuito.""")

L['tr'] = dict(
  title="Tile Titans: Sınavlar",
  short="Günlük bulmacalar, 18 tasarlanmış sınav ve gerçekten farklı dört mod.",
  full="""Tile Titans, sonsuz bir tahta yerine tasarlanmış sınavlar üzerine kurulu bir birleştirme bulmacasıdır.

TİTAN SINAVLARI
Üç bölümde, elle kurulmuş 18 bulmaca. Her biri sabit bir konumdan başlar; kendi hedefi ve gerçek bir kısıtı vardır: hamle bütçesi, saat, kapalı kareler ya da geri alma yok. Birinde hiç yeni taş çıkmaz — tam çözümü olan saf bir bulmaca.

GÜNLÜK TİTAN SINAVI
Her gün tarihten üretilen yeni bir meydan okuma: dünyadaki her oyuncu aynı tahtayı ve aynı hedefi alır. Seri yap.

DÖRT OYNAYIŞ
Klasik — stratejik temel.
Zen — puan yok, yenilgi yok. Tıkanan tahta en küçük taşlarını eritir, istediğin kadar devam edersin.
Zamana Karşı — doksan saniye, ama her birleşme sana zaman kazandırır. Zincirle.
Zorlu — daha büyük tahta, hamle başına iki taş, çoğunlukla dörtler ve hiçbir yardım yok.

TİTANLARIN YOLU
On beş başarım seni Acemi'den Efsane'ye taşır. Rütbe başardığından gelir — para birimi yok, satın alınacak bir şey yok.

HER ŞEY KAYITLI
Rekorlar moda göre tutulur; Zorlu bir oyun ile Zamana Karşı bir oyun aynı şey değildir. Her biri için ayrı sıralama.

BAKMAK İÇİN YAPILDI
Her taş kendi titan rütbe mührünü taşır. Klasik'ten Ocak'a altı tema.

Çevrimdışı çalışır. Ücretsiz.""")

L['ja'] = dict(
  title="Tile Titans: 試練",
  short="毎日のパズル、18の作り込まれた試練、そして本当に異なる4つのモード。",
  full="""Tile Titans は、終わりのない盤面ではなく、設計された試練を中心に作られた合体パズルです。

タイタンの試練
3章にわたる、手作りの18のパズル。それぞれ決まった配置から始まり、固有の目的と本物の制約があります。手数の上限、制限時間、閉じたマス、取り消しの禁止。ひとつは新しいタイルがまったく出現しません — 正確な解を持つ純粋なパズルです。

デイリータイタン試練
日付から生成される、毎日新しい挑戦。世界中のプレイヤーが同じ盤面と同じ目的に挑みます。連続記録を伸ばしましょう。

4つの遊び方
クラシック — 戦略の基本。
ゼン — スコアなし、ゲームオーバーなし。詰まった盤面は最小のタイルを溶かすので、好きなだけ続けられます。
タイムアタック — 90秒。ただし合体するたびに時間が増えます。つなげましょう。
ハードコア — 広い盤面、1手につき2枚、ほとんどが4、そして一切の補助なし。

タイタンへの道
15の実績が初心者から伝説へと導きます。階級は達成から生まれます — 通貨はなく、買うものもありません。

すべてを記録
記録はモードごとに残ります。ハードコアの一戦とタイムアタックの一戦は同じゲームではないからです。それぞれに別のランキング。

見るために作られた
すべてのタイルがタイタンの階級印を帯びています。クラシックからフォージまで、6つのテーマ。

オフラインで遊べます。無料。""")

L['hy'] = dict(
  title="Tile Titans: Փորձություն",
  short="Օրական հանելուկներ, 18 կառուցված փորձություն և չորս իրապես տարբեր ռեժիմ։",
  full="""Tile Titans-ը միաձուլման հանելուկ է, որը կառուցված է մտածված փորձությունների, և ոչ թե անվերջ դաշտի շուրջ։

ՏԻՏԱՆՆԵՐԻ ՓՈՐՁՈՒԹՅՈՒՆՆԵՐ
18 ձեռքով կառուցված հանելուկ՝ երեք գլխով։ Յուրաքանչյուրը սկսվում է հաստատուն դիրքից՝ իր նպատակով և իրական սահմանափակմամբ՝ քայլերի սահման, ժամանակ, փակ վանդակներ կամ առանց հետարկման։ Մեկում ընդհանրապես նոր սալիկ չի հայտնվում — մաքուր հանելուկ՝ ճշգրիտ լուծումով։

ՕՐԱԿԱՆ ՓՈՐՁՈՒԹՅՈՒՆ
Ամեն օր նոր մարտահրավեր՝ ստեղծված ամսաթվից. աշխարհի բոլոր խաղացողները ստանում են նույն դաշտը և նույն նպատակը։ Կառուցեք շարք։

ԽԱՂԱԼՈՒ ՉՈՐՍ ԵՂԱՆԱԿ
Դասական — ռազմավարական հիմքը։
Զեն — առանց միավորների և առանց պարտության։ Խցանված դաշտը լուծում է ամենափոքր սալիկները, որպեսզի շարունակեք որքան ցանկանաք։
Ժամանակի դեմ — իննսուն վայրկյան, բայց ամեն միաձուլում ավելացնում է։ Շղթայեք դրանք։
Ծայրահեղ — ավելի մեծ դաշտ, երկու սալիկ մեկ քայլում, հիմնականում չորսեր, և ոչ մի օգնություն։

ՏԻՏԱՆՆԵՐԻ ՈՒՂԻՆ
Տասնհինգ նվաճում տանում է Նորընծայից մինչև Լեգենդ։ Աստիճանը գալիս է նվաճածից — չկա արժույթ և գնելու բան չկա։

ԱՄԵՆ ԻՆՉ ԳՐԱՆՑՎՈՒՄ Է
Ռեկորդները պահվում են ըստ ռեժիմի, քանի որ Ծայրահեղ խաղը և Ժամանակի դեմ խաղը նույն բանը չեն։ Յուրաքանչյուրի համար՝ առանձին աղյուսակ։

ՍՏԵՂԾՎԱԾ Է ՆԱՅԵԼՈՒ ՀԱՄԱՐ
Ամեն սալիկ կրում է իր տիտանի աստիճանի նշանը։ Վեց թեմա՝ Դասականից մինչև Հնոց։

Աշխատում է օֆլայն։ Անվճար։""")

LIMITS = {'title': 30, 'short': 80, 'full': 4000}
# en-GB, not en-US: the live listing's default language is en-GB, and uploading
# to en-US would add a second English listing while leaving the live one as it
# is. Checked against the API, not assumed.
PLAY_LOCALE = {'en':'en-GB','ru':'ru-RU','de':'de-DE','fr':'fr-FR','es':'es-ES',
               'it':'it-IT','pt':'pt-PT','tr':'tr-TR','ja':'ja-JP','hy':'hy-AM'}

def main():
    out = 'docs/store/listing'
    os.makedirs(out, exist_ok=True)
    bad = []
    for lang in sorted(L):
        d = L[lang]
        for field, limit in LIMITS.items():
            n = len(d[field])
            if n > limit:
                bad.append(f'{lang}.{field}: {n} > {limit}')
        with open(f'{out}/{lang}.md', 'w', encoding='utf-8') as f:
            f.write(f"# Google Play listing — {lang} ({PLAY_LOCALE[lang]})\n\n")
            f.write(f"**Title** ({len(d['title'])}/30)\n\n```\n{d['title']}\n```\n\n")
            f.write(f"**Short description** ({len(d['short'])}/80)\n\n```\n{d['short']}\n```\n\n")
            f.write(f"**Full description** ({len(d['full'])}/4000)\n\n```\n{d['full']}\n```\n")
        print(f"  {lang}  title {len(d['title']):>2}/30   short {len(d['short']):>2}/80   full {len(d['full']):>4}/4000")
    if bad:
        print('\nOVER LIMIT:'); [print('  '+b) for b in bad]; sys.exit(1)
    print(f'\n{len(L)} listings written to {out}/')

if __name__ == '__main__':
    main()
