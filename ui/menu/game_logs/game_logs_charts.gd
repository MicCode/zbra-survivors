extends Control

@onready var level_chart: Chart = %LevelChart
@onready var xp_chart: Chart = %XpChart
@onready var dps_chart: Chart = %DPSChart
@onready var player_health_chart: Chart = %PlayerHealthChart
@onready var player_max_health_chart: Chart = %PlayerMaxHealthChart
@onready var enemy_spawn_chart: Chart = %EnemySpawnChart
@onready var enemy_kill_chart: Chart = %EnemyKillChart

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
        [f(tr("LABEL_TOTAL_XP"), logs.player_xp, Color.ORANGE, Function.Interpolation.LINEAR)],
        cp("", Color.TRANSPARENT)
    )
    player_health_chart.plot(
        [f(tr("LABEL_HEALTH"), logs.player_health, Color.RED)],
        cp("LABEL_HEALTH")
    )
    player_max_health_chart.plot(
        [f(tr("LABEL_MAX_HEALTH"), logs.player_max_health, Color.ORANGE)],
        cp("", Color.TRANSPARENT)
    )
    dps_chart.plot(
        [f(tr("LABEL_DPS"), logs.dps, Color.CORAL)],
        cp(tr("LABEL_DPS"))
    )
    enemy_kill_chart.plot(
        [f(tr("LABEL_ENEMY_KILL_PER_M"), logs.enemy_kill_per_m, Color.ORANGE, Function.Interpolation.LINEAR)],
        cp(tr("LABEL_ENEMIES"))
    )
    enemy_spawn_chart.plot(
        [f(tr("LABEL_ENEMY_SPAWN_PER_M"), logs.enemy_spawn_per_m, Color.RED, Function.Interpolation.LINEAR)],
        cp("", Color.TRANSPARENT)
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
    props.draw_horizontal_grid = false
    props.show_tick_labels = false
    props.interactive = true
    props.max_samples = 10_000
    return props

func f(function_title: String, data: Array[GameStatLogEntry], color: Color, interpolation: Function.Interpolation = Function.Interpolation.STAIR) -> Function:
    return Function.new(
        data.map(func(e: GameStatLogEntry): return float(e.timestamp) / 1000),
        data.map(func(e: GameStatLogEntry): return e.value),
        function_title,
        {
            color = color,
            marker = Function.Marker.NONE,
            type = Function.Type.LINE,
            interpolation = interpolation
        }
    )
