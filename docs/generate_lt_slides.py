"""LT(ライトニングトーク)用スライド生成スクリプト."""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
import os

# Catppuccin Mocha カラーパレット
BG_PRIMARY = RGBColor(0x1E, 0x1E, 0x2E)
BG_SURFACE = RGBColor(0x31, 0x32, 0x44)
BG_HOVER = RGBColor(0x45, 0x47, 0x5A)
TEXT_PRIMARY = RGBColor(0xCD, 0xD6, 0xF4)
TEXT_SECONDARY = RGBColor(0xA6, 0xAD, 0xC8)
TEXT_MUTED = RGBColor(0x6C, 0x70, 0x86)
ACCENT = RGBColor(0x89, 0xB4, 0xFA)
SUCCESS = RGBColor(0xA6, 0xE3, 0xA1)
WARNING = RGBColor(0xF9, 0xE2, 0xAF)
ERROR = RGBColor(0xF3, 0x8B, 0xA8)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)

SLIDE_WIDTH = Inches(13.333)
SLIDE_HEIGHT = Inches(7.5)


def set_slide_bg(slide, color):
    """スライドの背景色を設定."""
    bg = slide.background
    fill = bg.fill
    fill.solid()
    fill.fore_color.rgb = color


def add_text_box(slide, left, top, width, height, text, font_size=18,
                 color=TEXT_PRIMARY, bold=False, alignment=PP_ALIGN.LEFT,
                 font_name='Yu Gothic UI'):
    """テキストボックスを追加."""
    txBox = slide.shapes.add_textbox(left, top, width, height)
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = text
    p.font.size = Pt(font_size)
    p.font.color.rgb = color
    p.font.bold = bold
    p.font.name = font_name
    p.alignment = alignment
    return txBox


def add_rounded_rect(slide, left, top, width, height, fill_color, text="",
                     font_size=14, text_color=TEXT_PRIMARY):
    """角丸四角形を追加."""
    shape = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE, left, top, width, height
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = fill_color
    shape.line.fill.background()
    if text:
        tf = shape.text_frame
        tf.word_wrap = True
        tf.paragraphs[0].text = text
        tf.paragraphs[0].font.size = Pt(font_size)
        tf.paragraphs[0].font.color.rgb = text_color
        tf.paragraphs[0].font.name = 'Yu Gothic UI'
        tf.paragraphs[0].alignment = PP_ALIGN.CENTER
        tf.vertical_anchor = MSO_ANCHOR.MIDDLE
    return shape


def add_multi_text(slide, left, top, width, height, lines, default_size=18,
                   default_color=TEXT_PRIMARY):
    """複数行テキストを追加（行ごとにスタイル指定可能）."""
    txBox = slide.shapes.add_textbox(left, top, width, height)
    tf = txBox.text_frame
    tf.word_wrap = True
    for i, line_info in enumerate(lines):
        if isinstance(line_info, str):
            line_info = {'text': line_info}
        text = line_info.get('text', '')
        size = line_info.get('size', default_size)
        color = line_info.get('color', default_color)
        bold = line_info.get('bold', False)
        if i == 0:
            p = tf.paragraphs[0]
        else:
            p = tf.add_paragraph()
        p.text = text
        p.font.size = Pt(size)
        p.font.color.rgb = color
        p.font.bold = bold
        p.font.name = 'Yu Gothic UI'
        p.space_after = Pt(line_info.get('space_after', 6))
        p.alignment = line_info.get('align', PP_ALIGN.LEFT)
    return txBox


def create_presentation():
    """プレゼンテーションを生成."""
    prs = Presentation()
    prs.slide_width = SLIDE_WIDTH
    prs.slide_height = SLIDE_HEIGHT

    # ============================================================
    # Slide 1: タイトル
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # Blank
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(1.5), Inches(1.2), Inches(10), Inches(1),
                 'ユメログ (YumeLog)', font_size=52, color=ACCENT, bold=True,
                 alignment=PP_ALIGN.CENTER)

    add_text_box(slide, Inches(1.5), Inches(2.4), Inches(10), Inches(0.8),
                 '夢を持つことで、大きな壁も乗り越えられる。',
                 font_size=28, color=TEXT_PRIMARY, alignment=PP_ALIGN.CENTER)

    add_text_box(slide, Inches(1.5), Inches(3.2), Inches(10), Inches(0.8),
                 'あなたの「やりたいこと」を、行動に変えるアプリ',
                 font_size=22, color=TEXT_SECONDARY, alignment=PP_ALIGN.CENTER)

    # QRコード
    qr_path = os.path.join(os.path.dirname(__file__), 'LP用QRコード.png')
    if os.path.exists(qr_path):
        slide.shapes.add_picture(qr_path, Inches(5.4), Inches(4.2),
                                 Inches(2.5), Inches(2.5))

    add_text_box(slide, Inches(3.5), Inches(6.8), Inches(6), Inches(0.5),
                 'QRコードからすぐに体験できます（無料・登録不要）',
                 font_size=14, color=TEXT_MUTED, alignment=PP_ALIGN.CENTER)

    # ============================================================
    # Slide 2: 自己紹介
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 '自己紹介', font_size=36, color=ACCENT, bold=True)

    # 左側: プロフィール
    add_rounded_rect(slide, Inches(0.8), Inches(1.5), Inches(5.5), Inches(5.2),
                     BG_SURFACE)

    add_multi_text(slide, Inches(1.2), Inches(1.7), Inches(4.8), Inches(4.8), [
        {'text': 'プロフィール', 'size': 22, 'color': ACCENT, 'bold': True,
         'space_after': 16},
        {'text': '27歳 / IT業界 5年目', 'size': 20, 'color': TEXT_PRIMARY,
         'bold': True, 'space_after': 16},
        {'text': '', 'size': 8, 'space_after': 4},
        {'text': 'IT業界経験', 'size': 14, 'color': TEXT_MUTED, 'space_after': 2},
        {'text': 'パッケージ開発（約3年）/ ローコード開発（約3年）',
         'size': 16, 'color': TEXT_PRIMARY, 'space_after': 12},
        {'text': 'スクラッチ開発経験', 'size': 14, 'color': TEXT_MUTED,
         'space_after': 2},
        {'text': 'なし（ユメログが初のスクラッチ開発）', 'size': 16,
         'color': WARNING, 'bold': True, 'space_after': 12},
        {'text': 'Flutter / Dart 経験', 'size': 14, 'color': TEXT_MUTED,
         'space_after': 2},
        {'text': 'なし（ユメログが初）', 'size': 16, 'color': WARNING,
         'bold': True, 'space_after': 12},
    ])

    # 右側: このLTで伝えたいこと
    add_rounded_rect(slide, Inches(6.8), Inches(1.5), Inches(5.7), Inches(5.2),
                     BG_SURFACE)

    add_multi_text(slide, Inches(7.2), Inches(1.7), Inches(5.0), Inches(4.8), [
        {'text': 'このLTで伝えたいこと', 'size': 22, 'color': ACCENT,
         'bold': True, 'space_after': 20},
        {'text': '', 'size': 8, 'space_after': 4},
        {'text': '1. 夢を行動に変えるアプリを作った話',
         'size': 18, 'color': TEXT_PRIMARY, 'space_after': 16},
        {'text': '2. AI駆動開発で実現した驚異的な生産性',
         'size': 18, 'color': TEXT_PRIMARY, 'space_after': 16},
        {'text': '3. 未経験技術でもプロダクトが作れる',
         'size': 18, 'color': TEXT_PRIMARY, 'space_after': 16},
        {'text': '', 'size': 12, 'space_after': 8},
        {'text': 'スクラッチ開発未経験 + Flutter未経験',
         'size': 16, 'color': TEXT_MUTED, 'space_after': 4},
        {'text': '→ 3週間でプロダクション品質のアプリを完成',
         'size': 18, 'color': SUCCESS, 'bold': True},
    ])

    # ============================================================
    # Slide 3: 課題 → 解決
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 'こんな悩み、ありませんか？', font_size=36, color=ACCENT,
                 bold=True)

    pains = [
        'やりたいことはあるけど、何から始めればいいか分からない',
        '目標を立てても、いつの間にか忘れてしまう',
        '毎日忙しくて、夢に向かう時間が取れない',
    ]
    for i, pain in enumerate(pains):
        y = Inches(1.6 + i * 1.2)
        add_rounded_rect(slide, Inches(1.2), y, Inches(10.8), Inches(0.9),
                         BG_SURFACE)
        add_text_box(slide, Inches(1.6), y + Inches(0.15), Inches(10), Inches(0.6),
                     f'  {pain}', font_size=22, color=TEXT_PRIMARY)

    # 矢印
    add_text_box(slide, Inches(5.5), Inches(5.0), Inches(2), Inches(0.6),
                 '       ', font_size=28, color=ACCENT, bold=True,
                 alignment=PP_ALIGN.CENTER)

    add_rounded_rect(slide, Inches(2.5), Inches(5.5), Inches(8), Inches(1.2),
                     ACCENT,
                     'ユメログは「最初の一歩」を踏み出すきっかけと\n'
                     '動き続けるための仕組みを提供します',
                     font_size=20, text_color=BG_PRIMARY)

    # ============================================================
    # Slide 4: 3ステップ
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 '3ステップで、夢を行動に変える', font_size=36, color=ACCENT,
                 bold=True)

    steps = [
        {
            'num': '1', 'title': '書き出す',
            'desc': '夢を言葉にして書き出すだけ。\n脳がそれを「目標」として認識し始めます。',
            'color': ACCENT,
        },
        {
            'num': '2', 'title': '分解する',
            'desc': '夢を目標に、目標をタスクに分解。\n大きな壁が、毎日の小さな行動に変わります。',
            'color': SUCCESS,
        },
        {
            'num': '3', 'title': '続ける',
            'desc': '活動の積み重ねが星座として輝きます。\n星座を完成させる旅が、成長の証に。',
            'color': WARNING,
        },
    ]

    for i, step in enumerate(steps):
        x = Inches(0.8 + i * 4.1)
        add_rounded_rect(slide, x, Inches(1.6), Inches(3.8), Inches(5.0),
                         BG_SURFACE)
        # ステップ番号
        circle = slide.shapes.add_shape(
            MSO_SHAPE.OVAL, x + Inches(1.4), Inches(2.0),
            Inches(1), Inches(1)
        )
        circle.fill.solid()
        circle.fill.fore_color.rgb = step['color']
        circle.line.fill.background()
        tf = circle.text_frame
        tf.paragraphs[0].text = step['num']
        tf.paragraphs[0].font.size = Pt(36)
        tf.paragraphs[0].font.color.rgb = BG_PRIMARY
        tf.paragraphs[0].font.bold = True
        tf.paragraphs[0].font.name = 'Yu Gothic UI'
        tf.paragraphs[0].alignment = PP_ALIGN.CENTER
        tf.vertical_anchor = MSO_ANCHOR.MIDDLE

        add_text_box(slide, x + Inches(0.3), Inches(3.2), Inches(3.2),
                     Inches(0.6), step['title'], font_size=26,
                     color=step['color'], bold=True, alignment=PP_ALIGN.CENTER)

        add_text_box(slide, x + Inches(0.3), Inches(4.0), Inches(3.2),
                     Inches(2.0), step['desc'], font_size=16,
                     color=TEXT_SECONDARY, alignment=PP_ALIGN.CENTER)

    # ============================================================
    # Slide 5: 主な機能
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 '主な機能', font_size=36, color=ACCENT, bold=True)

    features = [
        ('夢・目標・タスク管理', '夢→目標→タスクの\n階層で整理'),
        ('活動予定', 'タイムラインで\nタスクを可視化'),
        ('書籍管理', '本棚風UIで\n読書を管理'),
        ('統計・分析', '活動時間・連続記録を\nグラフで可視化'),
        ('星座システム', '活動で星が灯り\n星座が完成'),
        ('ダッシュボード', '必要な情報を\nカスタマイズ表示'),
    ]

    for i, (title, desc) in enumerate(features):
        col = i % 3
        row = i // 3
        x = Inches(0.8 + col * 4.1)
        y = Inches(1.5 + row * 2.8)
        add_rounded_rect(slide, x, y, Inches(3.8), Inches(2.4), BG_SURFACE)
        add_text_box(slide, x + Inches(0.3), y + Inches(0.3), Inches(3.2),
                     Inches(0.5), title, font_size=22, color=ACCENT, bold=True,
                     alignment=PP_ALIGN.CENTER)
        add_text_box(slide, x + Inches(0.3), y + Inches(1.0), Inches(3.2),
                     Inches(1.2), desc, font_size=16, color=TEXT_SECONDARY,
                     alignment=PP_ALIGN.CENTER)

    add_text_box(slide, Inches(2), Inches(6.8), Inches(9), Inches(0.5),
                 '* 各画面のスクリーンショットは後ほどデモでお見せします',
                 font_size=13, color=TEXT_MUTED, alignment=PP_ALIGN.CENTER)

    # ============================================================
    # Slide 6: AI駆動開発の成果
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 'AI駆動開発の成果', font_size=36, color=ACCENT, bold=True)

    # 左: 開発条件
    add_rounded_rect(slide, Inches(0.8), Inches(1.5), Inches(5.5), Inches(2.5),
                     BG_SURFACE)
    add_multi_text(slide, Inches(1.2), Inches(1.7), Inches(4.8), Inches(2.2), [
        {'text': '開発条件', 'size': 20, 'color': ACCENT, 'bold': True,
         'space_after': 12},
        {'text': 'Flutter / Dart 経験: ゼロ', 'size': 16,
         'color': TEXT_PRIMARY, 'space_after': 6},
        {'text': 'スクラッチ開発経験: ゼロ', 'size': 16,
         'color': TEXT_PRIMARY, 'space_after': 6},
        {'text': 'AI: Claude Code（ペアプログラミング）', 'size': 16,
         'color': TEXT_PRIMARY},
    ])

    # 右: 実績
    add_rounded_rect(slide, Inches(6.8), Inches(1.5), Inches(5.7), Inches(2.5),
                     BG_SURFACE)
    add_multi_text(slide, Inches(7.2), Inches(1.7), Inches(5.0), Inches(2.2), [
        {'text': '実績', 'size': 20, 'color': SUCCESS, 'bold': True,
         'space_after': 12},
        {'text': '開発期間: 約3週間（実稼働21日）', 'size': 16,
         'color': TEXT_PRIMARY, 'space_after': 6},
        {'text': 'コード規模: 約48,000行（テスト含む）', 'size': 16,
         'color': TEXT_PRIMARY, 'space_after': 6},
        {'text': 'テスト: 813ケース（全件パス）', 'size': 16,
         'color': TEXT_PRIMARY},
    ])

    # 比較表
    add_text_box(slide, Inches(0.8), Inches(4.3), Inches(6), Inches(0.6),
                 '従来開発との比較', font_size=22, color=WARNING, bold=True)

    metrics = [
        ('開発期間', '6〜9ヶ月', '21日', '6〜9倍 短縮'),
        ('コード生産速度', '50〜100行/日', '2,281行/日', '23〜46倍'),
        ('テスト密度', '0〜3件/KLOC', '16.9件/KLOC', '6倍以上'),
        ('学習コスト', '1〜2ヶ月', '0日', '省略'),
    ]

    # ヘッダー行
    header_y = Inches(4.9)
    add_text_box(slide, Inches(0.8), header_y, Inches(2.8), Inches(0.4),
                 '指標', font_size=14, color=TEXT_MUTED, bold=True)
    add_text_box(slide, Inches(3.6), header_y, Inches(2.8), Inches(0.4),
                 '従来開発', font_size=14, color=TEXT_MUTED, bold=True)
    add_text_box(slide, Inches(6.4), header_y, Inches(2.8), Inches(0.4),
                 'AI駆動開発', font_size=14, color=TEXT_MUTED, bold=True)
    add_text_box(slide, Inches(9.5), header_y, Inches(3), Inches(0.4),
                 '効果', font_size=14, color=TEXT_MUTED, bold=True)

    for i, (label, trad, ai, effect) in enumerate(metrics):
        y = Inches(5.3 + i * 0.5)
        bg = BG_SURFACE if i % 2 == 0 else BG_PRIMARY
        if bg == BG_SURFACE:
            add_rounded_rect(slide, Inches(0.6), y - Inches(0.05),
                             Inches(12), Inches(0.45), BG_SURFACE)
        add_text_box(slide, Inches(0.8), y, Inches(2.8), Inches(0.4),
                     label, font_size=15, color=TEXT_PRIMARY)
        add_text_box(slide, Inches(3.6), y, Inches(2.8), Inches(0.4),
                     trad, font_size=15, color=TEXT_SECONDARY)
        add_text_box(slide, Inches(6.4), y, Inches(2.8), Inches(0.4),
                     ai, font_size=15, color=ACCENT, bold=True)
        add_text_box(slide, Inches(9.5), y, Inches(3), Inches(0.4),
                     effect, font_size=15, color=SUCCESS, bold=True)

    # ============================================================
    # Slide 7: 開発者の想い
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(0.8), Inches(0.4), Inches(10), Inches(0.8),
                 '開発者の想い', font_size=36, color=ACCENT, bold=True)

    add_rounded_rect(slide, Inches(1.5), Inches(1.5), Inches(10.3), Inches(4.5),
                     BG_SURFACE)

    add_multi_text(slide, Inches(2.0), Inches(1.8), Inches(9.3), Inches(4.0), [
        {'text': '学生時代、夢を持てず将来に希望を見出せない時期がありました。',
         'size': 20, 'color': TEXT_SECONDARY, 'space_after': 20},
        {'text': '', 'size': 10, 'space_after': 4},
        {'text': '本との出会いを通じて',
         'size': 20, 'color': TEXT_SECONDARY, 'space_after': 4},
        {'text': '「生き生きと生きるには夢が必要」',
         'size': 26, 'color': ACCENT, 'bold': True, 'space_after': 4},
        {'text': 'と気づきました。',
         'size': 20, 'color': TEXT_SECONDARY, 'space_after': 20},
        {'text': '', 'size': 10, 'space_after': 4},
        {'text': '夢を言語化し、行動に移す仕組みを',
         'size': 20, 'color': TEXT_SECONDARY, 'space_after': 4},
        {'text': 'アプリとして形にしたのがユメログです。',
         'size': 20, 'color': TEXT_SECONDARY, 'space_after': 20},
    ])

    add_text_box(slide, Inches(2.5), Inches(6.2), Inches(8), Inches(0.6),
                 'ユメログは「最初の一歩」を支えるアプリです。',
                 font_size=24, color=WARNING, bold=True,
                 alignment=PP_ALIGN.CENTER)

    # ============================================================
    # Slide 8: CTA（QRコード）
    # ============================================================
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_bg(slide, BG_PRIMARY)

    add_text_box(slide, Inches(1.5), Inches(0.8), Inches(10), Inches(0.8),
                 '今すぐ体験してみてください', font_size=40, color=ACCENT,
                 bold=True, alignment=PP_ALIGN.CENTER)

    add_text_box(slide, Inches(1.5), Inches(1.8), Inches(10), Inches(0.6),
                 'Webブラウザですぐに使えます。アカウント登録不要・完全無料。',
                 font_size=20, color=TEXT_SECONDARY, alignment=PP_ALIGN.CENTER)

    # QRコード（大きく）
    if os.path.exists(qr_path):
        slide.shapes.add_picture(qr_path, Inches(4.9), Inches(2.6),
                                 Inches(3.5), Inches(3.5))

    add_text_box(slide, Inches(2), Inches(6.3), Inches(9), Inches(0.5),
                 'https://teppei19980914.github.io/GrowthEngine/',
                 font_size=18, color=ACCENT, alignment=PP_ALIGN.CENTER)

    add_text_box(slide, Inches(4), Inches(6.9), Inches(5), Inches(0.4),
                 'ご清聴ありがとうございました',
                 font_size=16, color=TEXT_MUTED, alignment=PP_ALIGN.CENTER)

    # ============================================================
    # 保存
    # ============================================================
    output_path = os.path.join(os.path.dirname(__file__), 'LT_ユメログ.pptx')
    prs.save(output_path)
    print(f'Generated: {output_path}')


if __name__ == '__main__':
    create_presentation()
