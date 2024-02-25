DEFINITIONS = {
  Studio::Ability => Serializable.new(32, {
    id: :i16,
    db_symbol: :symbol,
    text_id: :vlv
  }),
  Studio::Group => Serializable.new(33, {
    id: :i16,
    db_symbol: :symbol,
    system_tag: :symbol,
    terrain_tag: :u8,
    tool: nil,
    is_double_battle: nil,
    is_horde_battle: nil,
    custom_conditions: [34],
    encounters: [35],
    steps_average: :u8
  }),
  Studio::Group::CustomCondition => Serializable.new(34, {
    type: :symbol,
    value: nil,
    relation_with_previous_condition: :symbol,
  }),
  Studio::Group::Encounter => Serializable.new(35, {
    specie: :symbol,
    form: :u8,
    shiny_setup: 36,
    level_setup: 37,
    encounter_rate: :vlv,
    extra: :symbolic_hash
  }),
  Studio::Group::Encounter::ShinySetup => Serializable.new(36, {
    kind: :symbol,
    rate: :double,
  }),
  Studio::Group::Encounter::LevelSetup => Serializable.new(37, {
    kind: :symbol,
    range: :range,
  }),
  Studio::Item => Serializable.new(38, item = {
    id: :i16,
    db_symbol: :symbol,
    icon: :string,
    price: :vlv,
    socket: :u8,
    position: :i16,
    is_battle_usable: nil,
    is_map_usable: nil,
    is_limited: nil,
    is_holdable: nil,
    fling_power: :u8
  }),
  Studio::Move => Serializable.new(39, {
    id: :i16,
    db_symbol: :symbol,
    map_use: :vlv,
    battle_engine_method: :symbol,
    type: :symbol,
    power: :u8,
    accuracy: :u8,
    pp: :u8,
    category: :symbol,
    movecritical_rate: :u8,
    priority: :i8,
    is_direct: nil,
    is_charge: nil,
    is_recharge: nil,
    is_blocable: nil,
    is_snatchable: nil,
    is_mirror_move: nil,
    is_punch: nil,
    is_gravity: nil,
    is_magic_coat_affected: nil,
    is_unfreeze: nil,
    is_sound_attack: nil,
    is_slicing_attack: nil,
    is_wind: nil,
    is_distance: nil,
    is_heal: nil,
    is_authentic: nil,
    is_bite: nil,
    is_pulse: nil,
    is_ballistics: nil,
    is_mental: nil,
    is_non_sky_battle: nil,
    is_dance: nil,
    is_king_rock_utility: nil,
    is_powder: nil,
    effect_chance: :vlv,
    battle_engine_aimed_target: :symbol,
    battle_stage_mod: [40],
    move_status: [41]
  }),
  Studio::Move::BattleStageMod => Serializable.new(40, {
    stat: :symbol,
    count: :i8,
  }),
  Studio::Move::MoveStatus => Serializable.new(41, {
    status: :symbol,
    luck_rate: :u8,
  }),
  Studio::Creature => Serializable.new(42, {
    id: :i16,
    db_symbol: :symbol,
    forms: [43]
  }),
  Studio::CreatureForm => Serializable.new(43, {
    id: :i16,
    db_symbol: :symbol,
    form: :u8,
    height: :double,
    weight: :double,
    type1: :symbol,
    type2: :symbol,
    base_hp: :u8,
    base_atk: :u8,
    base_dfe: :u8,
    base_spd: :u8,
    base_ats: :u8,
    base_dfs: :u8,
    ev_hp: :i8,
    ev_atk: :i8,
    ev_dfe: :i8,
    ev_spd: :i8,
    ev_ats: :i8,
    ev_dfs: :i8,
    evolutions: [44],
    experience_type: :u8,
    base_experience: :vlv,
    base_loyalty: :vlv,
    catch_rate: :vlv,
    female_rate: nil,
    breed_groups: [:vlv],
    hatch_steps: :vlv,
    baby_db_symbol: :symbol,
    baby_form: :u8,
    item_held: [45],
    abilities: [:symbol],
    front_offset_y: :i8,
    move_set: :array,
    resources: 46
  }),
  Studio::CreatureForm::Evolution => Serializable.new(44, {
    db_symbol: :symbol,
    form: :u8,
    conditions: [:symbolic_hash],
  }),
  Studio::CreatureForm::ItemHeld => Serializable.new(45, {
    db_symbol: :symbol,
    chance: :u8,
  }),
  Studio::CreatureForm::Resources => Serializable.new(46, {
    icon: nil,
    icon_f: nil,
    icon_shiny: nil,
    icon_shiny_f: nil,
    front: nil,
    front_f: nil,
    front_shiny: nil,
    front_shiny_f: nil,
    back: nil,
    back_f: nil,
    back_shiny: nil,
    back_shiny_f: nil,
    footprint: nil,
    character: nil,
    character_f: nil,
    character_shiny: nil,
    character_shiny_f: nil,
    cry: nil,
    has_female: nil,
  }),
  Studio::LearnableMove => Serializable.new(47, {
    move: :symbol,
  }),
  Studio::LevelLearnableMove => Serializable.new(48, {
    move: :symbol,
    level: :u8,
  }),
  Studio::TutorLearnableMove => Serializable.new(49, {
    move: :symbol,
  }),
  Studio::TechLearnableMove => Serializable.new(50, {
    move: :symbol,
  }),
  Studio::BreedLearnableMove => Serializable.new(51, {
    move: :symbol,
  }),
  Studio::EvolutionLearnableMove => Serializable.new(52, {
    move: :symbol,
  }),
  Studio::Dex => Serializable.new(53, {
    db_symbol: :symbol,
    id: :i16,
    start_id: :vlv,
    creatures: [54],
    csv: 55
  }),
  Studio::Dex::CreatureInfo => Serializable.new(54, {
    db_symbol: :symbol,
    form: :u8,
  }),
  Studio::CSVAccess => Serializable.new(55, {
    file_id: :vlv,
    text_index: :vlv,
  }),
  Studio::Quest => Serializable.new(56, {
    id: :i16,
    db_symbol: :symbol,
    is_primary: nil,
    resolution: :symbol,
    objectives: [57],
    earnings: [58]
  }),
  Studio::Quest::Objective => Serializable.new(57, {
    objective_method_name: :symbol,
    objective_method_args: :array,
    text_format_method_name: :symbol,
    hidden_by_default: nil,
  }),
  Studio::Quest::Earning => Serializable.new(58, {
    earning_method_name: :symbol,
    earning_args: :array,
    text_format_method_name: :symbol,
  }),
  Studio::Trainer => Serializable.new(59, {
    id: :i16,
    db_symbol: :symbol,
    vs_type: :u8,
    is_couple: nil,
    base_money: :vlv,
    battle_id: :vlv,
    ai: :u8,
    party: [35],
    bag_entries: :static_array, # TODO: figure out if that's a static array of symbolic hash or not
    resources: 60
  }),
  Studio::Trainer::Resources => Serializable.new(60, {
    sprite: nil,
    artwork_full: nil,
    artwork_small: nil,
    character: nil,
    encounter_bgm: nil,
    victory_bgm: nil,
    defeat_bgm: nil,
    battle_bgm: nil,
  }),
  Studio::Type => Serializable.new(61, {
    id: :i16,
    db_symbol: :symbol,
    text_id: :vlv,
    damage_to: [62]
  }),
  Studio::Type::DamageTo => Serializable.new(62, {
    defensive_type: :symbol,
    factor: :double,
  }),
  Studio::WorldMap => Serializable.new(63, {
    id: :i16,
    db_symbol: :symbol,
    image: :string,
    grid: [[:i16]],
    region_name: 55
  }),
  Studio::Zone => Serializable.new(64, {
    id: :i16,
    db_symbol: :symbol,
    maps: [:vlv],
    worldmaps: [:vlv],
    panel_id: :u8,
    warp: 65,
    position: 65,
    is_fly_allowed: nil,
    is_warp_disallowed: nil,
    forced_weather: nil,
    wild_groups: [:symbol],
  }),
  Studio::Zone::MapCoordinate => Serializable.new(65, {
    x: nil,
    y: nil,
  }),
  Studio::MapLink => Serializable.new(66, {
    id: :i16,
    db_symbol: :symbol,
    map_id: nil,
    north_maps: [67],
    east_maps: [67],
    south_maps: [67],
    west_maps: [67]
  }),
  Studio::MapLink::Link => Serializable.new(67, {
    map_id: :vlv,
    offset: :i16
  }),
  Studio::EventItem => Serializable.new(68, item.merge({
    event_id: :vlv,
  })),
  Studio::FleeingItem => Serializable.new(69, item),
  Studio::RepelItem => Serializable.new(70, item.merge({
    repel_count: :vlv
  })),
  Studio::StoneItem => Serializable.new(71, item),
  Studio::TechItem => Serializable.new(72, item.merge({
    move: :symbol,
    is_hm: nil,
  })),
  Studio::BallItem => Serializable.new(73, item.merge({
    sprite_filename: :string,
    catch_rate: nil,
    color: :color,
  })),
  Studio::HealingItem => Serializable.new(74, healing_item = item.merge({
    loyalty_malus: :i16,
  })),
  Studio::ConstantHealItem => Serializable.new(75, constant_heal_item = healing_item.merge({
    hp_count: :vlv,
  })),
  Studio::LevelIncreaseItem => Serializable.new(76, healing_item.merge({
    level_count: :u8,
  })),
  Studio::PPHealItem => Serializable.new(77, pp_heal_item = healing_item.merge({
    pp_count: :u8,
  })),
  Studio::PPIncreaseItem => Serializable.new(78, healing_item.merge({
    is_max: nil,
  })),
  Studio::RateHealItem => Serializable.new(79, rate_heal_item = healing_item.merge({
    hp_rate: :double,
  })),
  Studio::StatBoostItem => Serializable.new(80, stat_boost_item = healing_item.merge({
    stat: :symbol,
    count: :i8,
  })),
  Studio::StatusHealItem => Serializable.new(81, healing_item.merge({
    status_list: [:symbol],
  })),
  Studio::AllPPHealItem => Serializable.new(82, pp_heal_item),
  Studio::EVBoostItem => Serializable.new(83, stat_boost_item),
  Studio::StatusConstantHealItem => Serializable.new(84, constant_heal_item.merge({
    status_list: [:symbol]
  })),
  Studio::StatusRateHealItem => Serializable.new(85, rate_heal_item.merge({
    status_list: [:symbol]
  }))
}