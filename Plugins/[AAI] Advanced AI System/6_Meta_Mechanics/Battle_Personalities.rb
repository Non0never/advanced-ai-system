module AdvancedAI
  module BattlePersonalities

    PERSONALITIES = {
      :aggressive => {
        name: "Aggressive",
        description: "Prefers max damage and risky plays",
        modifiers: {
          damage_bonus: 25,
          setup_penalty: -20,
          healing_penalty: -30,
          priority_bonus: 15,
          ohko_bonus: 40,
          coverage_bonus: 10,
          switch_threshold: 55,
        }
      },

      :defensive => {
        name: "Defensive",
        description: "Prefers Stalling, Walls and Recovery",
        modifiers: {
          damage_bonus: -10,
          setup_bonus: 20,
          healing_bonus: 40,
          status_bonus: 30,
          protect_bonus: 35,
          hazard_bonus: 25,
          stall_bonus: 45,
          switch_threshold: 35,
        }
      },

      :balanced => {
        name: "Balanced",
        description: "Balanced mix of Offense and Defense",
        modifiers: {
          damage_bonus: 10,
          setup_bonus: 10,
          healing_bonus: 15,
          status_bonus: 15,
          pivot_bonus: 15,
          switch_threshold: 45,
        }
      },

      :hyper_offensive => {
        name: "Hyper Offensive",
        description: "Setup Sweeps, All-or-Nothing strategy",
        modifiers: {
          damage_bonus: 15,
          setup_bonus: 50,
          healing_penalty: -40,
          protect_bonus: 30,
          spread_bonus: 20,
          ohko_penalty: -20,
          switch_threshold: 60,
        }
      }
    }

    def self.detect_personality(battle, trainer_index)
      return :balanced if !battle || !AdvancedAI::AUTO_DETECT_PERSONALITY

      party = []
      battle.eachInTeamFromBattlerIndex(trainer_index) { |pkmn, i| party << pkmn }
      return :balanced if !party || party.empty?

      sweeper_count = 0
      wall_count = 0
      stall_count = 0
      tank_count = 0
      support_count = 0
      pivot_count = 0
      wallbreaker_count = 0
      lead_count = 0

      party.each do |pokemon|
        next if !pokemon || pokemon.egg?

        species_data = GameData::Species.try_get(pokemon.species)
        next unless species_data
        base = species_data.base_stats
        spd = base[:SPEED]
        atk = [base[:ATTACK], base[:SPECIAL_ATTACK]].max
        def_ = [base[:DEFENSE], base[:SPECIAL_DEFENSE]].min
        hp = base[:HP]
        has_recovery  = pokemon.moves.any? { |m| m && [:RECOVER,:ROOST,:MOONLIGHT,:SYNTHESIS,:MORNINGSUN,:SLACKOFF,:SOFTBOILED,:MILKDRINK,:WISH,:HEALORDER,:SHOREUP,:STRENGTHSAP,:REST,:LIFEDEW,:JUNGLEHEALING,:LUNARBLESSING].include?(m.id) }
        has_setup     = pokemon.moves.any? { |m| m && AdvancedAI.setup_move?(m.id) }
        has_u_turn    = pokemon.moves.any? { |m| m && [:UTURN,:VOLTSWITCH,:FLIPTURN,:PARTINGSHOT,:TELEPORT,:BATONPASS,:SHEDTAIL,:CHILLYRECEPTION].include?(m.id) }
        has_hazards   = pokemon.moves.any? { |m| m && [:STEALTHROCK,:SPIKES,:TOXICSPIKES,:STICKYWEB].include?(m.id) }
        is_fast       = spd >= 100
        is_bulky      = hp >= 80 && def_ >= 80
        is_offensive  = atk >= 110
        is_very_off   = atk >= 130

        sweeper_count      += 1 if is_fast && is_offensive && !is_bulky
        wallbreaker_count  += 1 if is_very_off
        wall_count         += 1 if is_bulky && has_recovery
        stall_count        += 1 if is_bulky && has_recovery && !is_offensive
        tank_count         += 1 if is_bulky && !has_recovery
        support_count      += 1 if has_hazards || pokemon.moves.any? { |m| m && [:SPORE,:WILLOWISP,:THUNDERWAVE,:TOXIC].include?(m.id) }
        pivot_count        += 1 if has_u_turn
        lead_count         += 1 if has_hazards && is_fast
      end

      total = party.count { |p| p && !p.egg? }
      return :balanced if total == 0

      if sweeper_count >= total * 0.6
        setup_count = 0
        party.each do |pokemon|
          next if !pokemon || pokemon.egg?
          pokemon.moves.each do |move|
            next if !move
            setup_count += 1 if AdvancedAI.setup_move?(move.id)
          end
        end
        return :hyper_offensive if setup_count >= 4
      end

      if wall_count >= total * 0.5 || stall_count >= 2
        return :defensive
      end

      offensive_count = sweeper_count + wallbreaker_count
      if offensive_count >= total * 0.5 && wall_count <= 1
        return :aggressive
      end

      if pivot_count >= 2 || (tank_count >= 2 && support_count >= 1)
        return :balanced
      end

      return :balanced
    end

    def self.apply_personality(score, move, personality)
      return score if !move || !personality
      return score if !PERSONALITIES.key?(personality)

      modifiers = PERSONALITIES[personality][:modifiers].merge(AdvancedAI::PERSONALITY_MODIFIERS.fetch(personality, {}))
      return score if !modifiers

      if move.damagingMove?
        score += modifiers[:damage_bonus] if modifiers[:damage_bonus]
      end

      if AdvancedAI.setup_move?(move.id)
        score += modifiers[:setup_bonus] if modifiers[:setup_bonus]
        score += modifiers[:setup_penalty] if modifiers[:setup_penalty]
      end

      if AdvancedAI.healing_move?(move.id)
        score += modifiers[:healing_bonus] if modifiers[:healing_bonus]
        score += modifiers[:healing_penalty] if modifiers[:healing_penalty]
      end

      if move.statusMove? && !AdvancedAI.setup_move?(move.id) && !AdvancedAI.healing_move?(move.id)
        score += modifiers[:status_bonus] if modifiers[:status_bonus]
      end

      if move.priority > 0 && move.damagingMove?
        score += modifiers[:priority_bonus] if modifiers[:priority_bonus]
      end

      if AdvancedAI.ohko_move?(move.id)
        score += modifiers[:ohko_bonus] if modifiers[:ohko_bonus]
        score += modifiers[:ohko_penalty] if modifiers[:ohko_penalty]
      end

      if AdvancedAI.protect_move?(move.id)
        score += modifiers[:protect_bonus] if modifiers[:protect_bonus]
      end

      if AdvancedAI.hazard_move?(move.id)
        score += modifiers[:hazard_bonus] if modifiers[:hazard_bonus]
      end

      if AdvancedAI.spread_move?(move.id)
        score += modifiers[:spread_bonus] if modifiers[:spread_bonus]
      end

      if AdvancedAI.stall_move?(move.id)
        score += modifiers[:stall_bonus] if modifiers[:stall_bonus]
      end

      if AdvancedAI.pivot_move?(move.id)
        score += modifiers[:pivot_bonus] if modifiers[:pivot_bonus]
      end

      return score
    end

    def self.get_switch_threshold(personality)
      return 45 if !personality || !PERSONALITIES.key?(personality)

      modifiers = PERSONALITIES[personality][:modifiers].merge(AdvancedAI::PERSONALITY_MODIFIERS.fetch(personality, {}))
      return modifiers[:switch_threshold] || 45
    end

    def self.get_name(personality)
      return "Balanced" if !personality || !PERSONALITIES.key?(personality)
      return PERSONALITIES[personality][:name]
    end

    def self.get_description(personality)
      return "" if !personality || !PERSONALITIES.key?(personality)
      return PERSONALITIES[personality][:description]
    end

    @personality_overrides = {}

    def self.set_personality(trainer_name, personality)
      return if !trainer_name || !personality
      return if !PERSONALITIES.key?(personality)

      @personality_overrides[trainer_name] = personality
      AdvancedAI.log("Set #{trainer_name} to #{get_name(personality)}", :personality)
    end

    def self.get_personality(battle, trainer_index)
      return :balanced if !battle

      explicit = battle.trainer_personalities[trainer_index]
      return explicit if PERSONALITIES.key?(explicit)
      trainer = battle.pbGetOwnerFromBattlerIndex(trainer_index)
      if trainer && @personality_overrides[trainer.name]
        return @personality_overrides[trainer.name]
      end

      return detect_personality(battle, trainer_index)
    end

  end
end

module AdvancedAI
  def self.detect_personality(battle, trainer_index)
    BattlePersonalities.detect_personality(battle, trainer_index)
  end

  def self.apply_personality(score, move, personality)
    BattlePersonalities.apply_personality(score, move, personality)
  end

  def self.get_personality(battle, trainer_index)
    BattlePersonalities.get_personality(battle, trainer_index)
  end

  def self.set_personality(trainer_name, personality)
    BattlePersonalities.set_personality(trainer_name, personality)
  end

  def self.get_personality_switch_threshold(personality)
    BattlePersonalities.get_switch_threshold(personality)
  end
end

class Battle::AI
  def apply_personality_modifiers(score, move, user, target)
    return score unless move
    personality = AdvancedAI.get_personality(@battle, user.index)
    return score unless personality
    score = AdvancedAI.apply_personality(score, move, personality)
    return score unless target && move.damagingMove?
    real_user = user.respond_to?(:battler) ? user.battler : user
    real_target = target.respond_to?(:battler) ? target.battler : target
    native_move = move.respond_to?(:move) && move.move.is_a?(Battle::Move) ? move.move : move
    move_type = AdvancedAI::CombatUtilities.resolve_move_type(real_user, native_move)
    return score if real_user.pbHasType?(move_type)
    effectiveness = Effectiveness.calculate(move_type, *real_target.pbTypes(true))
    return score unless Effectiveness.super_effective?(effectiveness)
    return score unless AdvancedAI::CombatUtilities.estimate_damage(real_user, native_move, real_target) > 0
    base = AdvancedAI::BattlePersonalities::PERSONALITIES.dig(personality, :modifiers) || {}
    modifiers = base.merge(AdvancedAI::PERSONALITY_MODIFIERS.fetch(personality, {}))
    score + modifiers.fetch(:coverage_bonus, 0)
  end
end
