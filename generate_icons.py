#!/usr/bin/env python3
"""ShopMemo アプリアイコン生成スクリプト（1024x1024）
ライト・ダーク・Tinted の3種類を生成する。
"""

from PIL import Image, ImageDraw

SIZE = 1024
OUTPUT_DIR = "ShopMemo/Assets.xcassets/AppIcon.appiconset"


def create_icon(bg_color, cart_color, badge_bg, badge_fg, filename):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img, "RGBA")

    # ── 背景（角丸） ──────────────────────────────────────
    draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=224, fill=bg_color)

    lw = 58   # カートの線幅
    hr = lw // 2

    # ── バスケット（メイン矩形） ──────────────────────────
    bx0, by0 = 200, 440
    bx1, by1 = 720, 660
    draw.rounded_rectangle([bx0, by0, bx1, by1], radius=44, fill=cart_color)

    # ── ハンドルバー（水平）──────────────────────────────
    # 上部に水平の持ち手バーを描画
    hx0, hx1 = 155, bx1   # 左端 〜 バスケット右端
    hy = 290
    draw.line([(hx0, hy), (hx1, hy)], fill=cart_color, width=lw)
    # 両端キャップ
    for px in [hx0, hx1]:
        draw.ellipse([px - hr, hy - hr, px + hr, hy + hr], fill=cart_color)

    # ── ストラット（斜め：ハンドル左端 → バスケット左上） ──
    sx0, sy0 = hx0, hy          # ハンドル左端と同じ点
    sx1, sy1 = bx0 + 24, by0   # バスケット左上付近
    draw.line([(sx0, sy0), (sx1, sy1)], fill=cart_color, width=lw)
    # 端点キャップ（ハンドル側はハンドルのキャップで済んでいるので省略、下端のみ）
    draw.ellipse([sx1 - hr, sy1 - hr, sx1 + hr, sy1 + hr], fill=cart_color)

    # ── 車輪 ─────────────────────────────────────────────
    wr = 48
    wy = by1 + wr + 16          # バスケット底辺の下
    for wx in [bx0 + 85, bx1 - 85]:
        draw.ellipse([wx - wr, wy - wr, wx + wr, wy + wr], fill=cart_color)

    # ── チェックバッジ（右下） ───────────────────────────
    badge_cx, badge_cy, badge_r = 748, 790, 148

    # バッジ背景円
    draw.ellipse(
        [badge_cx - badge_r, badge_cy - badge_r,
         badge_cx + badge_r, badge_cy + badge_r],
        fill=badge_bg,
    )

    # チェックマーク（線 + 丸キャップで綺麗に）
    ck_w = 52
    p1 = (badge_cx - int(badge_r * 0.44), badge_cy + int(badge_r * 0.04))
    p2 = (badge_cx - int(badge_r * 0.05), badge_cy + int(badge_r * 0.44))
    p3 = (badge_cx + int(badge_r * 0.50), badge_cy - int(badge_r * 0.32))
    draw.line([p1, p2], fill=badge_fg, width=ck_w)
    draw.line([p2, p3], fill=badge_fg, width=ck_w)
    ck_r = ck_w // 2
    for px, py in [p1, p2, p3]:
        draw.ellipse([px - ck_r, py - ck_r, px + ck_r, py + ck_r], fill=badge_fg)

    out_path = f"{OUTPUT_DIR}/{filename}"
    img.save(out_path, "PNG")
    print(f"Saved: {out_path}")


# ── ライトモード ──────────────────────────────────────────
create_icon(
    bg_color   = (52, 199, 89, 255),    # iOS グリーン
    cart_color = (255, 255, 255, 255),  # 白カート
    badge_bg   = (255, 255, 255, 255),  # 白バッジ
    badge_fg   = (52, 199, 89, 255),    # グリーンチェック
    filename   = "AppIcon.png",
)

# ── ダークモード ──────────────────────────────────────────
create_icon(
    bg_color   = (28, 28, 30, 255),     # iOS ダーク背景
    cart_color = (48, 209, 88, 255),    # グリーンカート
    badge_bg   = (48, 209, 88, 255),    # グリーンバッジ
    badge_fg   = (255, 255, 255, 255),  # 白チェック
    filename   = "AppIcon-dark.png",
)

# ── Tinted（モノクロ。iOS がアクセントカラーで着色する） ──
create_icon(
    bg_color   = (0, 0, 0, 255),
    cart_color = (255, 255, 255, 255),
    badge_bg   = (255, 255, 255, 255),
    badge_fg   = (0, 0, 0, 255),
    filename   = "AppIcon-tinted.png",
)

print("Done.")
