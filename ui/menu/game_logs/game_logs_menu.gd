extends Control

@onready var level_chart: Chart = %LevelChart
@onready var xp_chart: Chart = %XpChart
@onready var dps_chart: Chart = %DPSChart

var logs: GameStatLogs

func _ready() -> void:
    logs = GameLogger.load_from_latest_file()
    render_charts()

func render_charts():
    logs.add_last_points()

    level_chart.plot(
        [build_data_function("Player level", logs.player_level, Color.AQUA)],
        build_chart_properties("Player level")
    )
    xp_chart.plot(
        [build_data_function("Player total XP", logs.player_xp, Color.ORANGE)],
        build_chart_properties("Player total XP")
    )
    dps_chart.plot(
        [build_data_function("DPS", logs.player_level, Color.CORAL)],
        build_chart_properties("DPS")
    )

    set_process(false)

func build_chart_properties(title: String) -> ChartProperties:
    var cp: ChartProperties = ChartProperties.new()
    cp.colors.frame = Color("#161a1d")
    cp.colors.background = Color.TRANSPARENT
    cp.colors.grid = Color("#283442")
    cp.colors.ticks = Color("#283442")
    cp.colors.text = Color.WHITE_SMOKE
    cp.draw_bounding_box = false
    cp.title = title
    cp.x_scale = 5
    cp.y_scale = 10
    cp.interactive = true
    return cp

func build_data_function(function_title: String, data: Array[GameStatLogEntry], color: Color) -> Function:
    return Function.new(
        data.map(func(e: GameStatLogEntry): return float(e.timestamp) / 1000),
        data.map(func(e: GameStatLogEntry): return e.value),
        function_title,
        {
            color = color,
            marker = Function.Marker.CIRCLE,
            type = Function.Type.LINE,
            interpolation = Function.Interpolation.STAIR
        }
    )
