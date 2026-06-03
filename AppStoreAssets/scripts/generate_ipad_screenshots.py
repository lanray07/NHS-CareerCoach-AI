from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
IPAD_OUT_DIR = ROOT / "screenshots" / "ipad-13"
IPHONE_OUT_DIR = ROOT / "screenshots" / "iphone-6.5"
SOURCE_BACKGROUND = ROOT / "source" / "human-healthcare-background.png"
FONT_REGULAR = Path("C:/Windows/Fonts/segoeui.ttf")
FONT_BOLD = Path("C:/Windows/Fonts/segoeuib.ttf")
FONT_SEMIBOLD = Path("C:/Windows/Fonts/seguisb.ttf")
SIZE = (2048, 2732)


@dataclass(frozen=True)
class ScreenshotSpec:
    filename: str
    eyebrow: str
    title: str
    subtitle: str
    section: str
    cards: tuple[tuple[str, str, str], ...]
    focus: str
    cta: str
    score: int | None = None


SPECS = [
    ScreenshotSpec(
        "01-dashboard.png",
        "NHS CareerCoach AI",
        "Premium career coaching for NHS applicants.",
        "Track readiness, applications, statements and interview confidence in one polished workspace.",
        "Executive Dashboard",
        (
            ("4", "Active applications", "Two interviews due this month"),
            ("91%", "NHS values mastery", "Compassion, respect, teamwork"),
            ("7", "Supporting statements", "Three ready for export"),
            ("18", "Mock interviews", "Safeguarding and pressure practice"),
        ),
        "AI coaching insight: sharpen STAR results and values reflection before the next interview.",
        "Open Dashboard",
        84,
    ),
    ScreenshotSpec(
        "02-supporting-statement.png",
        "Tailored Applications",
        "Supporting statements with professional polish.",
        "Convert experience notes into NHS-style paragraphs aligned to the person specification.",
        "Statement Builder",
        (
            ("Criteria", "Essential experience mapped", "Communication, accuracy, patient-facing service"),
            ("Tone", "Professional and confident", "Supportive | Direct | Strict | Confidence-building"),
            ("Values", "NHS examples included", "Compassion, respect, improving lives"),
            ("Export", "Premium PDF pack", "Statement, STAR sheet and interview prep"),
        ),
        "Generated draft: clear evidence, measurable impact and authentic healthcare motivation.",
        "Export Premium PDF",
        None,
    ),
    ScreenshotSpec(
        "03-voice-coach.png",
        "Voice Coaching",
        "Speak it. Shape it. Submit with confidence.",
        "Dictate STAR examples and interview answers, then convert them into polished evidence.",
        "Voice Transcript",
        (
            ("Live", "Speech-to-text transcription", "Pause, resume and refine your experience"),
            ("AI", "Polished supporting statement", "Cleaner structure and stronger verbs"),
            ("Score", "Confidence feedback", "Clarity, pacing and structure notes"),
            ("Save", "Reusable evidence bank", "Keep examples for future applications"),
        ),
        "When a patient became anxious, I listened carefully, explained the next steps...",
        "Polish Transcript",
        78,
    ),
    ScreenshotSpec(
        "04-mock-interview.png",
        "Interview Practice",
        "NHS interviews that feel calm and prepared.",
        "Practise values, safeguarding, teamwork, conflict and band-specific questions.",
        "Mock Interview",
        (
            ("Question", "NHS Values", "Tell us about a time you demonstrated compassion under pressure."),
            ("Answer", "STAR response draft", "Situation, task, action, result and reflection"),
            ("Feedback", "Structure and confidence", "Sharper result, fewer filler words, stronger learning"),
            ("Mode", "Rapid-fire practice", "Short focused prompts for momentum"),
        ),
        "Feedback: add a measurable result and connect the reflection to patient care quality.",
        "Start Voice Interview",
        82,
    ),
    ScreenshotSpec(
        "05-nhs-values.png",
        "Values Mastery",
        "Understand NHS values. Answer with credibility.",
        "Build examples around compassion, respect, teamwork, improving lives and quality.",
        "NHS Values Coach",
        (
            ("Compassion", "Patient-aware examples", "Listening, dignity and empathy"),
            ("Respect", "Inclusive communication", "Calm, clear and professional"),
            ("Teamwork", "Escalation and collaboration", "Support colleagues and services"),
            ("Quality", "Reflective practice", "Learning and continuous improvement"),
        ),
        "Coach prompt: turn your real example into a values-led answer with concise reflection.",
        "Practise Values",
        91,
    ),
    ScreenshotSpec(
        "06-star-builder.png",
        "STAR Evidence",
        "Better STAR answers, not memorised scripts.",
        "Structure your situation, task, action and result into concise NHS interview evidence.",
        "STAR Builder",
        (
            ("Situation", "Busy clinic with competing priorities", "Context without over-explaining"),
            ("Task", "Maintain safe flow and communication", "Clear responsibility"),
            ("Action", "Listened, prioritised, documented and escalated", "Professional judgement"),
            ("Result", "Reduced confusion and improved visibility", "Impact and learning"),
        ),
        "AI improves clarity, professionalism, NHS alignment and confidence tone.",
        "Improve STAR Answer",
        None,
    ),
    ScreenshotSpec(
        "07-application-tracker.png",
        "Application Pipeline",
        "Stay organised from draft to interview.",
        "Track NHS applications, statuses, interview dates, reminders and follow-up notes.",
        "Application Tracker",
        (
            ("Drafting", "Healthcare Assistant", "King College Hospital | Band 3"),
            ("Submitted", "Patient Pathway Admin", "UCLH | Band 4"),
            ("Interview", "Junior Analyst", "NHS England | Band 5"),
            ("Reminder", "Follow-up due", "Prepare STAR examples and documents"),
        ),
        "Pipeline insight: two applications need stronger values evidence before submission.",
        "Review Tracker",
        None,
    ),
    ScreenshotSpec(
        "08-readiness-analytics.png",
        "Readiness Analytics",
        "See progress like a premium coaching dashboard.",
        "Understand confidence trends, mock interview performance and weaker competency areas.",
        "Confidence Dashboard",
        (
            ("88", "Interview readiness", "Up 12 points after three mock sessions"),
            ("Strong", "Communication", "Clear examples and calm tone"),
            ("Focus", "Safeguarding", "Use policy-aware escalation language"),
            ("Trend", "Confidence improving", "Voice practice builds fluency"),
        ),
        "Next focus: safeguarding, concise STAR results and reflective practice prompts.",
        "Open Analytics",
        88,
    ),
    ScreenshotSpec(
        "09-career-roadmap.png",
        "Career Progression",
        "Plan your next NHS band with clarity.",
        "Explore role suggestions, band progression roadmaps and CPD prompts.",
        "Career Roadmap",
        (
            ("Band 2-3", "Reliability and safe communication", "Build evidence from day-to-day service"),
            ("Band 4-5", "Autonomy and quality improvement", "Show ownership and prioritisation"),
            ("Band 6-7", "Leadership and service change", "Demonstrate influence and judgement"),
            ("CPD", "Skill gap prompts", "Training ideas and reflective learning"),
        ),
        "Career insight: strengthen leadership examples before targeting the next band.",
        "View Roadmap",
        None,
    ),
    ScreenshotSpec(
        "10-premium-paywall.png",
        "Included Access",
        "Career coaching tools, no purchase required.",
        "This submitted build includes the visible coaching workflows for review and user evaluation.",
        "Included Tools",
        (
            ("Access", "Included", "No digital purchase is sold in this build"),
            ("Local AI", "On-device workflow", "Drafts and answers stay local by default"),
            ("Voice", "Apple permission", "Speech-to-text only when the user chooses"),
            ("Privacy", "Clear disclosure", "No developer AI server or third-party AI provider"),
        ),
        "Independent coaching platform. Not affiliated with the NHS.",
        "View Included Tools",
        None,
    ),
]


def font(size: int, bold: bool = False, semibold: bool = False) -> ImageFont.FreeTypeFont:
    if bold:
        source = FONT_BOLD
    elif semibold and FONT_SEMIBOLD.exists():
        source = FONT_SEMIBOLD
    else:
        source = FONT_REGULAR
    return ImageFont.truetype(str(source), size)


def cover_crop(image: Image.Image, size: tuple[int, int], focus_x: float = 0.64, focus_y: float = 0.32) -> Image.Image:
    width, height = size
    source = image.convert("RGBA")
    scale = max(width / source.width, height / source.height)
    resized = source.resize((round(source.width * scale), round(source.height * scale)), Image.Resampling.LANCZOS)
    left = int((resized.width - width) * focus_x)
    top = int((resized.height - height) * focus_y)
    left = min(max(0, left), max(0, resized.width - width))
    top = min(max(0, top), max(0, resized.height - height))
    return resized.crop((left, top, left + width, top + height))


def rounded(draw: ImageDraw.ImageDraw, xy, radius: int, fill, outline=None, width: int = 1) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def draw_background(canvas: Image.Image) -> None:
    width, height = canvas.size
    draw = ImageDraw.Draw(canvas, "RGBA")
    for y in range(height):
        t = y / height
        color = (
            round(4 + 14 * t),
            round(14 + 26 * t),
            round(31 + 38 * t),
            255,
        )
        draw.line((0, y, width, y), fill=color)

    if SOURCE_BACKGROUND.exists():
        source = Image.open(SOURCE_BACKGROUND)
        photo = cover_crop(source, canvas.size)
        tint = Image.new("RGBA", canvas.size, (0, 22, 48, 44))
        photo.alpha_composite(tint)
        mask = Image.new("L", canvas.size, 0)
        mask_draw = ImageDraw.Draw(mask)
        mask_draw.rectangle((1100, 20, width, 1060), fill=168)
        mask_draw.rectangle((880, 540, width, 1560), fill=98)
        mask = mask.filter(ImageFilter.GaussianBlur(30))
        canvas.alpha_composite(Image.composite(photo, Image.new("RGBA", canvas.size, (0, 0, 0, 0)), mask))

        panel = cover_crop(source, (760, 980), focus_y=0.16)
        panel.alpha_composite(Image.new("RGBA", panel.size, (0, 22, 48, 26)))
        panel_mask = Image.new("L", panel.size, 0)
        panel_draw = ImageDraw.Draw(panel_mask)
        panel_draw.rounded_rectangle((0, 0, panel.width, panel.height), radius=96, fill=192)
        panel_mask = panel_mask.filter(ImageFilter.GaussianBlur(4))
        canvas.alpha_composite(Image.composite(panel, Image.new("RGBA", panel.size, (0, 0, 0, 0)), panel_mask), (1232, 118))

    draw.ellipse((-260, 1820, 760, 2960), fill=(45, 194, 207, 24))
    draw.rounded_rectangle((1060, 130, 2150, 1040), radius=120, fill=None, outline=(92, 205, 245, 34), width=3)


def draw_status_bar(draw: ImageDraw.ImageDraw) -> None:
    draw.rounded_rectangle((918, 34, 1130, 54), radius=10, fill=(2, 8, 16, 238))


def draw_eyebrow(draw: ImageDraw.ImageDraw, text: str, x: int, y: int) -> None:
    rounded(draw, (x, y, x + 420, y + 58), 29, fill=(20, 92, 133, 162))
    draw.text((x + 28, y + 14), text, font=font(25, semibold=True), fill=(84, 220, 205, 235))


def wrap_text(draw: ImageDraw.ImageDraw, text: str, text_font: ImageFont.FreeTypeFont, max_width: int) -> str:
    words = text.split()
    lines: list[str] = []
    current = ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if current and draw.textlength(candidate, font=text_font) > max_width:
            lines.append(current)
            current = word
        else:
            current = candidate
    if current:
        lines.append(current)
    return "\n".join(lines)


def draw_text_block(draw: ImageDraw.ImageDraw, spec: ScreenshotSpec) -> None:
    draw_eyebrow(draw, spec.eyebrow, 104, 120)
    title_font = font(76, True)
    title = wrap_text(draw, spec.title, title_font, 840)
    draw.multiline_text((104, 235), title, font=title_font, fill=(248, 252, 255, 255), spacing=8)
    title_lines = title.count("\n") + 1
    subtitle_y = 235 + title_lines * 90 + 42
    subtitle_font = font(36)
    subtitle = wrap_text(draw, spec.subtitle, subtitle_font, 900)
    draw.multiline_text((104, subtitle_y), subtitle, font=subtitle_font, fill=(188, 210, 222, 238), spacing=8)


def draw_score_ring(draw: ImageDraw.ImageDraw, cx: int, cy: int, score: int) -> None:
    bbox = (cx - 134, cy - 134, cx + 134, cy + 134)
    draw.arc(bbox, start=0, end=360, fill=(61, 98, 133, 190), width=24)
    draw.arc(bbox, start=-90, end=-90 + round(360 * score / 100), fill=(84, 218, 196, 255), width=24)
    draw.arc(bbox, start=-90, end=-25, fill=(31, 169, 239, 255), width=24)
    draw.text((cx - 56, cy - 62), str(score), font=font(72, True), fill=(248, 252, 255, 255))
    draw.text((cx - 58, cy + 20), "Ready", font=font(28), fill=(192, 214, 225, 235))


def draw_waveform(draw: ImageDraw.ImageDraw, x: int, y: int, width: int, height: int) -> None:
    bars = 42
    gap = 10
    bar_width = (width - (bars - 1) * gap) // bars
    for i in range(bars):
        phase = abs(((i * 31) % 100) - 50) / 50
        h = round(height * (0.24 + 0.72 * phase))
        bx = x + i * (bar_width + gap)
        by = y + (height - h) // 2
        color = (36, 174, 239, 245) if i % 3 else (84, 218, 196, 245)
        draw.rounded_rectangle((bx, by, bx + bar_width, by + h), radius=bar_width // 2, fill=color)


def draw_chart(draw: ImageDraw.ImageDraw, x: int, y: int, width: int, height: int) -> None:
    points = [(x + 30, y + height - 42), (x + width * 0.28, y + height - 88), (x + width * 0.48, y + height - 70), (x + width * 0.68, y + height - 122), (x + width - 28, y + 38)]
    draw.line(points, fill=(88, 223, 211, 245), width=7, joint="curve")
    for px, py in points:
        draw.ellipse((px - 8, py - 8, px + 8, py + 8), fill=(248, 252, 255, 255))


def draw_card(draw: ImageDraw.ImageDraw, box, title: str, value: str, body: str, accent=(32, 169, 239, 255)) -> None:
    x1, y1, x2, y2 = box
    rounded(draw, box, 34, fill=(15, 50, 84, 198), outline=(89, 130, 171, 128), width=2)
    draw.ellipse((x1 + 34, y1 + 32, x1 + 86, y1 + 84), fill=accent)
    draw.text((x1 + 112, y1 + 30), title, font=font(34, True), fill=(248, 252, 255, 255))
    draw.text((x1 + 112, y1 + 82), value, font=font(29, semibold=True), fill=(204, 223, 233, 238))
    draw.multiline_text((x1 + 112, y1 + 128), body, font=font(24), fill=(168, 191, 204, 232), spacing=5)


def draw_tablet_frame(draw: ImageDraw.ImageDraw) -> None:
    rounded(draw, (92, 690, 1956, 2460), 54, fill=(7, 22, 42, 154), outline=(72, 127, 170, 120), width=3)
    rounded(draw, (126, 728, 1922, 2424), 36, fill=(6, 24, 45, 145), outline=(41, 90, 128, 90), width=2)


def draw_content(draw: ImageDraw.ImageDraw, spec: ScreenshotSpec) -> None:
    draw.text((160, 760), spec.section, font=font(46, True), fill=(248, 252, 255, 255))

    if spec.score is not None:
        draw_score_ring(draw, 1664, 850, spec.score)

    left_x, right_x = 160, 1060
    top_y = 875
    card_w, card_h = 800, 250
    accents = [(31, 169, 239, 255), (84, 218, 196, 255), (232, 172, 44, 255), (82, 190, 113, 255)]
    for index, (title, value, body) in enumerate(spec.cards):
        col = left_x if index % 2 == 0 else right_x
        row = top_y + (index // 2) * 306
        draw_card(draw, (col, row, col + card_w, row + card_h), title, value, body, accents[index % len(accents)])

    insight_y = 1560
    rounded(draw, (160, insight_y, 1888, insight_y + 290), 34, fill=(8, 31, 56, 190), outline=(79, 127, 169, 126), width=2)
    draw.text((212, insight_y + 44), "AI coaching insight", font=font(35, True), fill=(248, 252, 255, 255))
    draw.multiline_text((212, insight_y + 104), spec.focus, font=font(30), fill=(189, 211, 222, 238), spacing=8)

    if "voice" in spec.filename:
        draw_waveform(draw, 262, 1934, 1524, 260)
    elif "analytics" in spec.filename:
        rounded(draw, (260, 1935, 1788, 2205), 30, fill=(12, 42, 72, 200), outline=(80, 128, 169, 118), width=2)
        draw_chart(draw, 330, 1980, 1388, 165)
    else:
        for i, label in enumerate(("Scan JD", "Voice Interview", "STAR Builder", "Values Coach")):
            x = 230 + i * 410
            rounded(draw, (x, 1970, x + 330, 2205), 28, fill=(17, 58, 96, 188), outline=(79, 127, 169, 105), width=2)
            draw.ellipse((x + 38, 2008, x + 92, 2062), fill=(31, 169, 239, 230))
            draw.text((x + 38, 2118), label, font=font(26, semibold=True), fill=(232, 244, 250, 238))

    rounded(draw, (670, 2284, 1378, 2380), 48, fill=(30, 152, 229, 238))
    text_width = draw.textlength(spec.cta, font=font(30, True))
    draw.text((1024 - text_width / 2, 2314), spec.cta, font=font(30, True), fill=(248, 252, 255, 255))


def render(spec: ScreenshotSpec, out_dir: Path = IPAD_OUT_DIR, size: tuple[int, int] = SIZE) -> None:
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 255))
    draw_background(canvas)
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw_status_bar(draw)
    draw_text_block(draw, spec)
    draw_tablet_frame(draw)
    draw_content(draw, spec)
    if size != SIZE:
        canvas = canvas.resize(size, Image.Resampling.LANCZOS)
    out_dir.mkdir(parents=True, exist_ok=True)
    canvas.convert("RGB").save(out_dir / spec.filename, "PNG", optimize=True)


def update_manifest() -> None:
    manifest = ROOT / "ASSET_MANIFEST.txt"
    current = manifest.read_text(encoding="utf-8").splitlines()
    ipad_line = "iPad screenshots: AppStoreAssets/screenshots/ipad-13 - 10 PNG files, 2048 x 2732 px, RGB, 72 dpi, premium tablet-specific healthcare career coaching layouts."
    if not any(line.startswith("iPad screenshots:") for line in current):
        insert_at = 3 if len(current) > 3 else len(current)
        current.insert(insert_at, ipad_line)
    else:
        current = [ipad_line if line.startswith("iPad screenshots:") else line for line in current]
    manifest.write_text("\n".join(current) + "\n", encoding="utf-8")


def main(specs: Iterable[ScreenshotSpec] = SPECS) -> None:
    for spec in specs:
        render(spec)
        render(spec, IPHONE_OUT_DIR, (1242, 2688))
    update_manifest()


if __name__ == "__main__":
    main()
