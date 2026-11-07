
module AdvancedAI
  SNOWBALL_ABILITIES = {
    :MOXIE         => 1.8,
    :BEASTBOOST    => 1.8,
    :SOULDEVOURING => 1.8,
    :CHILLINGNEIGH => 1.7,
    :GRIMNEIGH     => 1.7,
    :ASONEGLASTRIER => 1.9,
    :ASONESPECTRIER => 1.9,
    :POWEROFALCHEMY => 1.5,
    :RECEIVER       => 1.5,
  }

  SPEED_SHIFT_ABILITIES = {
    :UNBURDEN      => 2.5,
    :SLOWSTART     => 0.3,
    :SPEEDBOOST    => 1.6,
  }

  REVERSE_ABILITIES = {
    :CONTRARY      => 2.0,
    :DEFIANT       => 1.7,
    :COMPETITIVE   => 1.7,
  }

  SWITCH_ABILITIES = {
    :REGENERATOR   => 1.4,
    :NATURALCURE   => 1.3,
    :SHEDSKIN      => 1.2,
  }
end

class Battle::AI

  alias_method :advanced_abilities_pbRegisterMove, :pbRegisterMove unless method_defined?(:advanced_abilities_pbRegisterMove) || private_method_defined?(:advanced_abilities_pbRegisterMove)
  def pbRegisterMove(user, move)
    score = advanced_abilities_pbRegisterMove(user, move)

    return score unless user && move

    target_data = move.pbTarget(user) rescue nil
    targets = []
    if target_data && target_data.num_targets > 0
      targets = @_resolved_targets || [@_resolved_target].compact
    end

    targets.each do |target|
      next unless target && !target.fainted?
      next unless target.opposes?(user)

      snowball_key = AdvancedAI::SNOWBALL_ABILITIES.keys.find { |a| target.hasActiveAbility?(a) }
      if snowball_key
        score += evaluate_snowball_threat(user, move, target)
      end

      reverse_key = AdvancedAI::REVERSE_ABILITIES.keys.find { |a| target.hasActiveAbility?(a) }
      if reverse_key
        score += evaluate_reverse_ability(user, move, target)
      end

      if target.hasActiveAbility?(:UNBURDEN) && target.item
        score += evaluate_unburden_threat(user, move, target)
      end
    end

    if ["SwitchOutTargetStatusMove", "SwitchOutTargetDamagingMove"].include?(move.function_code)
      target_battler = @_resolved_target
      if target_battler && target_battler.hasActiveAbility?(:REGENERATOR)
        score -= 15
        AdvancedAI.log("  #{move.name} vs Regenerator: -15 (free heal on force-out)", "Abilities")
      end
    end

    return score
  end

  def evaluate_snowball_threat(user, move, target)
    return 0 unless move.damagingMove?

    score = 0
    ability_name = ""
    AdvancedAI::SNOWBALL_ABILITIES.each do |ab, _|
      if target.hasActiveAbility?(ab)
        ability_name = GameData::Ability.try_get(ab)&.name || ab.to_s
        break
      end
    end

    rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)
    would_ko = (rough_damage >= target.hp.to_f / target.totalhp)

    if would_ko
      score += 30
      AdvancedAI.log("  KO #{target.name} (#{ability_name}): +30 (prevent snowball)", "Abilities")
    end

    if target.stages[:ATTACK] >= 1 || target.stages[:SPECIAL_ATTACK] >= 1
      score += 25
      AdvancedAI.log("  #{ability_name} already boosted: +25 (stop snowball)", "Abilities")
    end

    return score
  end

  def evaluate_reverse_ability(user, move, target)
    score = 0
    ability_id = AdvancedAI::REVERSE_ABILITIES.keys.find { |a| target.hasActiveAbility?(a) }

    case ability_id
    when :CONTRARY
      stat_drops = move.function_code.include?("LowerTarget") &&
                   !move.function_code.include?("LowerTargetHP")

      if stat_drops
        score -= 50
        AdvancedAI.log("  #{move.name} vs Contrary: -50 (inverts to buff!)", "Abilities")
      end

      if move.damagingMove?
        score += 15
        AdvancedAI.log("  Damage to Contrary: +15 (prevent reverse setup)", "Abilities")
      end

    when :DEFIANT, :COMPETITIVE

      stat_drops = move.function_code.include?("LowerTarget") &&
                   !move.function_code.include?("LowerTargetHP")
      if stat_drops
        score -= 40
        AdvancedAI.log("  #{move.name} vs #{ability_id}: -40 (triggers +2)", "Abilities")
      end

    end

    return score
  end

  def evaluate_unburden_threat(user, move, target)
    return 0 unless target.item

    score = 0

    if ["RemoveTargetItem", "UserTakesTargetItem"].include?(move.function_code)
      score -= 35
      AdvancedAI.log("  #{move.name} vs Unburden: -35 (doubles speed!)", "Abilities")

      rough_damage = AdvancedAI::CombatUtilities.estimate_damage(user, move, target, as_percent: true)
      if rough_damage >= target.hp.to_f / target.totalhp
        score += 50
        AdvancedAI.log("  But KOs: +50 (worth it)", "Abilities")
      end
    end

    consumable_items = [:SITRUSBERRY, :LUMBERRY, :ORANBERRY, :AGUAVBERRY,
                       :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :WIKIBERRY]
    if consumable_items.include?(target.item_id)
      score -= 10
      AdvancedAI.log("  Unburden + Berry: -10 (might auto-trigger)", "Abilities")
    end

    return score
  end

  def predict_regenerator_switch(target)
    return false unless target.hasActiveAbility?(:REGENERATOR)

    hp_percent = target.hp.to_f / target.totalhp

    if hp_percent < 0.6 && hp_percent > 0.2
      AdvancedAI.log("  Regenerator switch predicted (#{(hp_percent * 100).to_i}% HP)", "Abilities")
      return true
    end

    return false
  end

  def calculate_ability_threat_modifier(battler)
    return 1.0 unless battler

    multiplier = 1.0

    snowball_key = AdvancedAI::SNOWBALL_ABILITIES.keys.find { |a| battler.hasActiveAbility?(a) }
    if snowball_key
      base = AdvancedAI::SNOWBALL_ABILITIES[snowball_key]
      if battler.stages[:ATTACK] >= 1 || battler.stages[:SPECIAL_ATTACK] >= 1
        multiplier = base * 1.3
      else
        multiplier = base
      end
    end

    speed_key = AdvancedAI::SPEED_SHIFT_ABILITIES.keys.find { |a| battler.hasActiveAbility?(a) }
    if speed_key
      multiplier = AdvancedAI::SPEED_SHIFT_ABILITIES[speed_key]

      if speed_key == :UNBURDEN
        active = !battler.item && (battler.effects[PBEffects::Unburden] rescue false)
        multiplier = active ? 2.5 : 1.0
      end
    end

    reverse_key = AdvancedAI::REVERSE_ABILITIES.keys.find { |a| battler.hasActiveAbility?(a) }
    if reverse_key
      multiplier = AdvancedAI::REVERSE_ABILITIES[reverse_key]
    end

    switch_key = AdvancedAI::SWITCH_ABILITIES.keys.find { |a| battler.hasActiveAbility?(a) }
    if switch_key
      multiplier = AdvancedAI::SWITCH_ABILITIES[switch_key]
    end

    return multiplier
  end

  def gen9_switchin_bonus(pkmn)
    return 0 unless AdvancedAI::GEN9_PACK_COMPAT
    return 0 unless pkmn
    bonus = 0
    begin
      ab = pkmn.respond_to?(:ability_id) ? pkmn.ability_id : (pkmn.ability rescue nil)
      ab = ab.id if ab.is_a?(GameData::Ability)

      case ab
      when :ZEROTOHERO
        bonus += 60
      when :ORICHALCUMPULSE
        bonus += 25
      when :HADRONENGINE
        bonus += 25
      when :PROTOSYNTHESIS, :QUARKDRIVE
        if pkmn.respond_to?(:item_id) && pkmn.item_id == :BOOSTERENERGY
          bonus += 30
        end
        if @battle
          begin
            wx      = (@battle.field.weather rescue :None)
            terrain = (@battle.field.terrain rescue :None)
            if (ab == :PROTOSYNTHESIS && wx == :Sun) ||
               (ab == :QUARKDRIVE     && terrain == :Electric)
              bonus += 20
            end
          rescue
          end
        end
      when :GRIMNEIGH, :CHILLINGNEIGH
        bonus += 5
      when :REGENERATOR
        bonus += 10
      when :INTIMIDATE
        bonus += 15
      when :GOODASGOLD
        bonus += 15
      when :PURIFYINGSALT
        bonus += 15
      when :ICESCALES
        bonus += 20
      when :FURCOAT
        bonus += 18
      when :THERMALEXCHANGE
        bonus += 12
      when :GUARDDOG
        bonus += 10
      when :WINDPOWER
        bonus += 5
      when :CUDCHEW
        if pkmn.respond_to?(:item_id) && pkmn.item_id
          item_data = (GameData::Item.try_get(pkmn.item_id) rescue nil)
          if item_data && item_data.is_berry?
            bonus += 12
          end
        end
      when :ARMORTAIL, :DAZZLING, :QUEENLYMAJESTY
        bonus += 8
      when :MIRRORARMOR
        bonus += 8
      when :EMBODYASPECT_TEAL, :EMBODYASPECT_HEARTHFLAME, :EMBODYASPECT_WELLSPRING, :EMBODYASPECT_CORNERSTONE
        bonus += 20
      when :SUPERSWEETSYRUP
        bonus += 10
      when :OPPORTUNIST
        bonus += 5
      when :COSTAR
        if @battle && @user
          begin
            user_side = @user.idxOwnSide rescue (@user.index & 1)
            @battle.battlers.each do |a|
              next unless a && !a.fainted?
              a_side = a.idxOwnSide rescue (a.index & 1)
              next if a_side != user_side
              next if a.index == @user.index
              total = 0
              [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED, :ACCURACY, :EVASION].each do |st|
                stage = (a.stages[st] rescue 0)
                total += stage if stage > 0
              end
              bonus += total * 8
            end
          rescue
          end
        else
          bonus += 5
        end
      when :HOSPITALITY
        if @battle && @user
          begin
            user_side = @user.idxOwnSide rescue (@user.index & 1)
            @battle.battlers.each do |a|
              next unless a && !a.fainted?
              a_side = a.idxOwnSide rescue (a.index & 1)
              next if a_side != user_side
              next if a.index == @user.index
              hp_missing = 1.0 - (a.hp.to_f / [a.totalhp, 1].max)
              bonus += (hp_missing * 30).to_i
            end
          rescue
          end
        else
          bonus += 5
        end
      when :COMMANDER
        if @battle && @user
          begin
            user_side = @user.idxOwnSide rescue (@user.index & 1)
            has_dondozo_ally = @battle.battlers.any? do |b|
              next false unless b && !b.fainted?
              b_side = b.idxOwnSide rescue (b.index & 1)
              b_side == user_side && b.index != @user.index && b.isSpecies?(:DONDOZO)
            end
            bonus += 50 if has_dondozo_ally
          rescue
          end
        end
      end

      if pkmn.respond_to?(:item_id) && pkmn.item_id == :IRONBALL
        spd = (pkmn.respond_to?(:speed) ? pkmn.speed : (pkmn.calcStats[:SPEED] rescue 0))
        if @battle && (@battle.field.effects[PBEffects::TrickRoom] > 0 rescue false)
          bonus += 10
        elsif spd >= 90
          bonus -= 20
        else
          bonus -= 5
        end
        types = (pkmn.types rescue [])
        ab = pkmn.respond_to?(:ability_id) ? pkmn.ability_id : nil
        if types.include?(:FLYING) || ab == :LEVITATE
          bonus -= 15
        end
      end
    rescue
    end
    return bonus
  end
end

AdvancedAI.log("Advanced Abilities System loaded", "Core")
AdvancedAI.log("  - Snowball detection (Moxie, Beast Boost)", "Abilities")
AdvancedAI.log("  - Gen 9 switch-in awareness (Zero to Hero, Booster Energy paradoxes)", "Abilities")
AdvancedAI.log("  - Reverse abilities (Contrary, Defiant, Competitive)", "Abilities")
AdvancedAI.log("  - Speed shift (Unburden, Speed Boost)", "Abilities")
AdvancedAI.log("  - Switch abilities (Regenerator, Natural Cure)", "Abilities")
