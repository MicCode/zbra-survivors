extends Control

@onready var level_chart: Chart = %LevelChart
@onready var xp_chart: Chart = %XpChart
@onready var dps_chart: Chart = %DPSChart

const ANIMATION_DURATION: float = 2.0

var logs: GameStatLogs

func _ready() -> void:
    logs = GameLogger.load_from_latest_file()
    render_charts()

func render_charts():
    logs.create_bounding_points()

    level_chart.plot(
        [f(tr("LABEL_LEVEL"), logs.player_level, Color.AQUA)],
        cp(tr("LABEL_LEVEL"))
    )
    xp_chart.plot(
        [f(tr("LABEL_TOTAL_XP"), logs.player_xp, Color.ORANGE)],
        cp("", Color.TRANSPARENT)
    )
    dps_chart.plot(
        [f(tr("LABEL_DPS"), logs.dps, Color.CORAL)],
        cp(tr("LABEL_DPS"))
    )


func cp(title: String, font_color = Color.WHITE_SMOKE) -> ChartProperties:
    var props: ChartProperties = ChartProperties.new()
    props.colors.frame = Color.TRANSPARENT
    props.colors.background = Color.TRANSPARENT
    props.colors.grid = Color(font_color, min(font_color.a, 0.25))
    props.colors.ticks = Color.TRANSPARENT
    props.colors.text = font_color
    props.draw_bounding_box = false
    props.title = title
    props.x_scale = 10
    props.y_scale = 2
    props.interactive = true
    return props

func f(function_title: String, data: Array[GameStatLogEntry], color: Color) -> Function:
    return Function.new(
        data.map(func(e: GameStatLogEntry): return float(e.timestamp) / 1000),
        data.map(func(e: GameStatLogEntry): return e.value),
        function_title,
        {
            color = color,
            marker = Function.Marker.NONE,
            type = Function.Type.LINE,
            interpolation = Function.Interpolation.STAIR
        }
    )
