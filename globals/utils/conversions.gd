extends Node

func game_pixels_to_m(game_pixels: float) -> float:
    # considering player is 1m20 high, sprite is 16px multiplied by 1.5 scale factor, so 25px = 1.25m, 1m = 20px
    return game_pixels / 20

func game_speed_to_kmh(game_speed: float) -> float:
    # 200 should approximately be 5km/h
    return game_speed / 40

func dps(gun_stats: GunStats, bullet_stats: BulletStats) -> float:
    return bullet_stats.damage * gun_stats.bullets_per_shot * gun_stats.shots_per_s
