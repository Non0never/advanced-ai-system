

module AdvancedAI

  ENABLED = true

  MIN_SKILL_FOR_AUTO_ACTIVATION = 70

  DEBUG_MODE = false

  DEBUG_SWITCH_INTELLIGENCE = false

  SHOW_MOVE_EXPLANATIONS = true

  DETERMINISTIC_MOVE_CHOICE = false

  DETERMINISTIC_SWITCH_LOGIC = true

  LOG_TO_CONSOLE = false
  LOG_TO_FILE = false

  ENABLE_WILD_POKEMON_AI = true

  ENABLE_LEAD_SELECTION = true

  WILD_POKEMON_SKILL_LEVEL = 100

  SKILL_THRESHOLDS = {
    :core              => 50,
    :switch_intelligence => 50,
    :setup             => 55,
    :endgame           => 60,
    :personalities     => 65,
    :items             => 85,
    :prediction        => 85,
    :mega_evolution    => 90,
    :z_moves           => 90,
    :dynamax           => 95,
    :terastallization  => 100
  }

  SWITCH_THRESHOLDS = {
    :beginner => 65,
    :mid      => 55,
    :pro      => 45,
    :extreme  => 35
  }

  TIER_FEATURES = {
    :beginner => {
      :switch_prediction   => false,
      :setup_detection     => false,
      :hazard_awareness    => false,
      :pivot_preference    => false,
      :recovery_timing     => false,
      :status_value        => 0.5,
      :prediction_depth    => 0,
      :learn_patterns      => false
    },
    :mid => {
      :switch_prediction   => true,
      :setup_detection     => true,
      :hazard_awareness    => true,
      :pivot_preference    => true,
      :recovery_timing     => true,
      :status_value        => 1.0,
      :prediction_depth    => 1,
      :learn_patterns      => false
    },
    :pro => {
      :switch_prediction   => true,
      :setup_detection     => true,
      :hazard_awareness    => true,
      :pivot_preference    => true,
      :recovery_timing     => true,
      :status_value        => 1.2,
      :prediction_depth    => 2,
      :learn_patterns      => true
    },
    :extreme => {
      :switch_prediction   => true,
      :setup_detection     => true,
      :hazard_awareness    => true,
      :pivot_preference    => true,
      :recovery_timing     => true,
      :status_value        => 1.5,
      :prediction_depth    => 3,
      :learn_patterns      => true
    }
  }

  ADVANCED_FLAGS = {
    :switch_prediction    => 0b00000001,
    :setup_chains         => 0b00000010,
    :hazard_calc          => 0b00000100,
    :weather_abuse        => 0b00001000,
    :terrain_abuse        => 0b00010000,
    :ko_prediction        => 0b00100000,
    :revenge_kill         => 0b01000000,
    :momentum_control     => 0b10000000
  }

  DEFAULT_FLAGS = 0b11111111

  AUTO_DETECT_PERSONALITY = true

  PERSONALITY_MODIFIERS = {
    aggressive: { damage_bonus: 25, setup_penalty: -20, healing_penalty: -30, priority_bonus: 15, ohko_bonus: 40, coverage_bonus: 10, switch_threshold: 55 },
    defensive: { damage_bonus: -10, setup_bonus: 20, healing_bonus: 40, status_bonus: 30, protect_bonus: 35, hazard_bonus: 25, stall_bonus: 45, switch_threshold: 35 },
    balanced: { damage_bonus: 10, setup_bonus: 10, healing_bonus: 15, status_bonus: 15, pivot_bonus: 15, switch_threshold: 45 },
    hyper_offensive: { damage_bonus: 15, setup_bonus: 50, healing_penalty: -40, protect_bonus: 30, spread_bonus: 20, ohko_penalty: -20, switch_threshold: 60 },
  }

  RESPECT_RESERVE_LAST_POKEMON = true

  RESERVE_LAST_POKEMON_STRICT = false

  ENFORCE_SLEEP_CLAUSE = true

  DBK_PLUGINS = {
    :mega_evolution   => true,
    :dynamax          => true,
    :terastallization => true,
    :z_moves          => true,
    :raid_battles     => true,
    :sos_battles      => true
  }

  GEN9_PACK_COMPAT = true

  def self.log(message, source = "AAI")
    return unless DEBUG_MODE || LOG_TO_CONSOLE || LOG_TO_FILE

    safe_message = message.to_s
    stamp = Time.now.strftime("%H:%M:%S.%L") rescue "--:--:--.---"
    formatted = "[#{stamp}] [SC/AI      ] DEBUG #{source}: #{safe_message}"

    if DEBUG_MODE || LOG_TO_CONSOLE
      puts formatted
    end

    if LOG_TO_FILE
      begin
        Dir.mkdir("Logs") unless Dir.exist?("Logs")
        File.open("Logs/ai_log.txt", "a") do |f|
          f.puts "[#{Time.now.strftime("%H:%M:%S")}] #{formatted}"
        end
      rescue SystemCallError, IOError

      end
    end
  end

  def self.active?(skill_level = nil)
    return false unless ENABLED
    return @manually_activated unless @manually_activated.nil?
    return true if mode_skill_override
    return true if DEBUG_MODE
    return !skill_level.nil? && skill_level >= MIN_SKILL_FOR_AUTO_ACTIVATION
  end

  def self.activate!
    @manually_activated = true
  end

  def self.deactivate!
    @manually_activated = false
  end

  def self.qualifies_for_advanced_ai?(skill_level)
    return false unless skill_level && active?(skill_level)
    return skill_level >= SKILL_THRESHOLDS[:core]
  end

  AI_MODE_VARIABLE = nil

  def self.mode_skill_override
    return nil unless AI_MODE_VARIABLE && defined?($game_variables) && $game_variables
    { 1 => 60, 2 => 80, 3 => 95, 4 => 100 }[$game_variables[AI_MODE_VARIABLE]]
  end

  def self.get_ai_tier(skill_level)

    if AI_MODE_VARIABLE && defined?($game_variables) && $game_variables
      override = $game_variables[AI_MODE_VARIABLE]
      return :beginner if override == 1
      return :mid      if override == 2
      return :pro      if override == 3
      return :extreme  if override == 4
    end

    return :beginner if skill_level <= 60
    return :mid if skill_level <= 85
    return :pro if skill_level <= 99
    return :extreme
  end

  def self.tier_feature(skill_level, feature)
    tier = get_ai_tier(skill_level)
    return TIER_FEATURES.dig(tier, feature)
  end

  def self.prediction_depth(skill_level)
    value = tier_feature(skill_level, :prediction_depth)
    value.is_a?(Numeric) ? value.to_i.clamp(0, 3) : 0
  end

  def self.feature_enabled?(feature, skill_level)
    threshold = SKILL_THRESHOLDS[feature]
    return false unless skill_level && threshold && active?(skill_level)
    return skill_level >= threshold
  end

  def self.get_setting(key, default = 0)
    flag = ADVANCED_FLAGS[key]
    return default unless flag
    return DEFAULT_FLAGS & flag
  end

  def self.dbk_enabled?(plugin)
    return false unless DBK_PLUGINS[plugin]

    if defined?(PluginManager) && PluginManager.respond_to?(:installed?)
      plugin_id = case plugin
        when :dynamax           then "[DBK] Dynamax"
        when :terastallization  then "[DBK] Terastallization"
        when :z_moves           then "[DBK] Z-Power"
        when :raid_battles      then "[DBK] Raid Battles"
        when :sos_battles       then "[DBK] SOS Battles"
        else nil
      end
      return true if plugin_id && PluginManager.installed?(plugin_id)
    end

    case plugin
    when :mega_evolution
      return true
    when :dynamax

      return defined?(Battle) && Battle.instance_methods.include?(:pbCanDynamax?)
    when :terastallization

      return defined?(Battle) && Battle.instance_methods.include?(:pbCanTerastallize?)
    when :z_moves
      return defined?(Battle) && Battle.instance_methods.include?(:pbCanZMove?)
    when :raid_battles
      return defined?(Battle) && Battle.instance_methods.include?(:pbRaidBattle?)
    when :sos_battles
      return defined?(Battle) && Battle.instance_methods.include?(:pbSOSBattle?)
    else
      return false
    end
  end
end

class Battle
  attr_accessor :advanced_ai_active
  attr_accessor :trainer_personalities

  alias_method :aai_initialize, :initialize unless method_defined?(:aai_initialize) || private_method_defined?(:aai_initialize)
  def initialize(*args)
    aai_initialize(*args)
    @advanced_ai_active = false
    @trainer_personalities = {}
  end

  def uses_advanced_ai?(trainer_index)
    return false unless trainer_index
    trainer = pbGetOwnerFromBattlerIndex(trainer_index)
    return false unless trainer
    skill = AdvancedAI.mode_skill_override || trainer.skill_level || 50
    return AdvancedAI.qualifies_for_advanced_ai?(skill)
  end

  def get_trainer_personality(trainer_index)
    AdvancedAI.get_personality(self, trainer_index)
  end

  def set_trainer_personality(trainer_index, personality)
    @trainer_personalities[trainer_index] = personality
    AdvancedAI.log("Trainer #{trainer_index} personality set to #{personality}", "Personality")
  end

  private

  def detect_personality(trainer_index)
    return :balanced unless AdvancedAI::AUTO_DETECT_PERSONALITY
    AdvancedAI.detect_personality(self, trainer_index)
  end
end

class Battle::Battler

  def ai_skill_level
    return 0 unless @battle.opposes?(@index)
    trainer = @battle.pbGetOwnerFromBattlerIndex(@index)
    return 50 unless trainer
    return AdvancedAI.mode_skill_override || trainer.skill_level || 50
  end

  def ai_tier
    return AdvancedAI.get_ai_tier(ai_skill_level)
  end
end
