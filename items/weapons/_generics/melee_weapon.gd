extends Weapon
class_name MeleeWeapon

enum SlashState {
    IDLE,
    PREPARING,
    SWINGING,
    RESETTING,
}

const ANIMATION_PREPARE_DURATION: float = 1.0
const ANIMATION_SLASH_DURATION: float = 2.0
const ANIMATION_RESET_DURATION: float = 1.0

var animation_speed: float = 1.0
var slash_state: SlashState = SlashState.IDLE

func _init() -> void:
    flip_vertical = true
    ignore_spread = true

# TODO
# - ajouter une animation pour armer le coup
# - ajouter une animation pour faire tourner l'arme vers le bas
# - déclencher le lancement du projectile à la moitié de cette animation
# - ajouter une animation de retour à la position initiale
# /!\ il faut faire en sorte que la somme de la durée de ces trois animations soit égale à la fréquence de tir de l'arme
# (?) compter les collisions entre l'arme et les ennemis pendant l'animation de rotation ?

func update_from_stats() -> void:
    super.update_from_stats()

    var total_animation_duration: float = 1 / weapon_stats.shots_per_s
    var initial_animation_duration = ANIMATION_PREPARE_DURATION + ANIMATION_SLASH_DURATION + ANIMATION_RESET_DURATION
    animation_speed =  initial_animation_duration / total_animation_duration
    %AnimationPlayer.speed_scale = animation_speed

func change_swing_state(new_state: SlashState):
    # print(E.to_str(SlashState, new_state))
    slash_state = new_state

func shoot() -> bool:
    if slash_state != SlashState.IDLE:
        return false

    change_swing_state(SlashState.PREPARING)
    %AnimationPlayer.play_section_with_markers("slash", "prepare", "swing")
    var shoot_delay = (ANIMATION_PREPARE_DURATION + ANIMATION_SLASH_DURATION / 2) / animation_speed
    %ShootDelay.start(shoot_delay)
    return false

func swing_weapon():
    change_swing_state(SlashState.SWINGING)
    %AnimationPlayer.play_section_with_markers("slash", "swing", "reset")

func back_to_initial_position():
    change_swing_state(SlashState.RESETTING)
    %AnimationPlayer.play_section_with_markers("slash", "reset", "end")

func on_slash_end():
    change_swing_state(SlashState.IDLE)
    %AnimationPlayer.play("RESET")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
    match slash_state:
        SlashState.PREPARING: swing_weapon()
        SlashState.SWINGING: back_to_initial_position()
        SlashState.RESETTING: on_slash_end()


func _on_shoot_delay_timeout() -> void:
    super.shoot()
