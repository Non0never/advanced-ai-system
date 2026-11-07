
module AdvancedAI
  module CustomContent

    OFFENSIVE_ABILITIES = {
      :HUGEPOWER          => 3.0,
      :PUREPOWER          => 3.0,
      :ADAPTABILITY       => 2.5,
      :SHEERFORCE         => 2.0,
      :IRONFIST           => 1.5,
      :TOUGHCLAWS         => 1.8,
      :STRONGJAW          => 1.5,
      :MEGALAUNCHER       => 1.5,

      :TECHNICIAN         => 2.0,
      :ANALYTIC           => 1.5,
      :SNIPER             => 1.5,
      :TINTEDLENS         => 2.0,
      :SCRAPPY            => 1.5,

      :SUPERLUCK          => 1.5,
      :MERCILESS          => 2.0,

      :SKILLLINK          => 2.0,
      :PARENTALBOND       => 2.5,

      :DOWNLOAD           => 1.5,
      :INTREPIDSWORD      => 2.0,
      :DAUNTLESSSHIELD    => 1.0,
      :BEASTBOOST         => 1.8,
      :MOXIE              => 1.8,
      :SOULHEART          => 1.5,

      :MOLDBREAKER        => 1.8,
      :TERAVOLT           => 1.8,
      :TURBOBLAZE         => 1.8,
      :NEUTRALIZINGGAS    => 2.0,

      :ORICHALCUMPULSE    => 2.5,
      :HADRONENGINE       => 2.5,
      :SUPREMEOVERLORD    => 2.0,
      :PROTOSYNTHESIS     => 1.8,
      :QUARKDRIVE         => 1.8,
      :TOXICDEBRIS        => 1.5,

      :SWORDOFRUIN        => 2.5,
      :BEADSOFRUIN        => 2.5,
      :TABLETSOFRUIN      => 1.5,
      :VESSELOFRUIN       => 1.5,

      :TOXICBOOST         => 2.0,
      :FLAREBOOST         => 2.0,

      :POISONPUPPETEER    => 2.0,
      :SUPERSWEETSYRUP    => 1.5,
      :EMBODYASPECT       => 1.8,
      :ZEROTOHERO         => 2.5,

      :ASONEGLASTRIER     => 2.5,
      :ASONESPECTRIER     => 2.5,

      :MINDSEYE           => 1.5,

      :GORILLATACTICS     => 2.0,
    }

    DEFENSIVE_ABILITIES = {
      :MULTISCALE         => -2.5,
      :SHADOWSHIELD       => -2.5,
      :FILTER             => -1.5,
      :SOLIDROCK          => -1.5,
      :PRISMARMOR         => -1.8,
      :FURCOAT            => -3.0,
      :FLUFFY             => -2.0,

      :WONDERGUARD        => -5.0,
      :LEVITATE           => -1.5,
      :VOLTABSORB         => -1.5,
      :WATERABSORB        => -1.5,
      :FLASHFIRE          => -1.5,
      :SAPSIPPER          => -1.5,
      :STORMDRAIN         => -2.0,
      :LIGHTNINGROD       => -2.0,
      :MOTORDRIVE         => -1.8,
      :DRYSKIN            => -1.5,
      :THICKFAT           => -1.5,

      :REGENERATOR        => -2.0,
      :POISONHEAL         => -2.0,
      :ICEBODY            => -1.0,
      :RAINDISH           => -1.0,

      :CONTRARY           => -1.5,
      :UNAWARE            => -2.0,
      :CLEARBODY          => -1.0,
      :WHITESMOKE         => -1.0,
      :FULLMETALBODY      => -1.0,
      :HYPERCUTTER        => -0.5,
      :KEENEYE            => -0.5,
      :BIGPECKS           => -0.5,

      :IMMUNITY           => -1.0,
      :WATERVEIL          => -0.8,
      :MAGMAARMOR         => -0.8,
      :LIMBER             => -0.8,
      :INSOMNIA           => -0.8,
      :VITALSPIRIT        => -0.8,
      :OBLIVIOUS          => -1.0,
      :INNERFOCUS         => -0.8,

      :WELLBAKEDBODY      => -2.0,
      :EARTHEATER         => -2.0,
      :WINDRIDER          => -1.8,
      :GUARDDOG           => -1.0,
      :PURIFYINGSALT      => -2.0,

      :ICESCALES          => -2.5,

      :STAMINA            => -1.5,
      :COTTONDOWN         => -0.5,
      :WEAKARMOR          => -0.5,
      :ANGERSHELL         => -0.5,
      :ELECTROMORPHOSIS   => -0.5,
      :WINDPOWER          => -0.3,

      :TERASHELL          => -3.0,
      :TERAFORMZERO       => -1.0,
      :TERASHIFT          => -0.5,

      :SEEDSOWER          => -1.0,

      :GOODASGOLD         => -2.5,
    }

    SPEED_ABILITIES = {
      :SPEEDBOOST         => 2.0,
      :MOTORDRIVE         => 1.5,
      :QUICKFEET          => 1.5,
      :UNBURDEN           => 2.5,
      :CHLOROPHYLL        => 2.0,
      :SWIFTSWIM          => 2.0,
      :SANDRUSH           => 2.0,
      :SLUSHRUSH          => 2.0,
      :PROTOSYNTHESIS     => 1.5,
      :QUARKDRIVE         => 1.5,
      :SURGESURFER        => 2.0,

      :PRANKSTER          => 2.5,
      :GALEWINGS          => 2.0,
      :TANGLINGHAIR       => 1.0,

    }

    SUPPORT_ABILITIES = {
      :INTIMIDATE         => 1.5,
      :DROUGHT            => 1.5,
      :DRIZZLE            => 1.5,
      :SANDSTREAM         => 1.5,
      :SNOWWARNING        => 1.5,
      :ELECTRICSURGE      => 1.5,
      :GRASSYSURGE        => 1.5,
      :MISTYSURGE         => 1.5,
      :PSYCHICSURGE       => 1.5,

      :LIGHTNINGROD       => 1.5,
      :STORMDRAIN         => 1.5,

      :MAGICBOUNCE        => 2.0,
      :MAGICGUARD         => 1.5,

      :ROUGHSKIN          => 1.0,
      :IRONBARBS          => 1.0,
      :POISONPOINT        => 0.8,
      :STATIC             => 0.8,
      :FLAMEBODY          => 0.8,

      :COSTAR             => 1.5,
      :OPPORTUNIST        => 1.8,
      :COMMANDER          => 2.0,
      :HOSPITALITY        => 1.0,
    }

    def self.get_ability_threat(ability_id)
      return 0.0 if !ability_id

      ability_id = ability_id.to_sym if ability_id.is_a?(String)

      threat = 0.0
      threat += OFFENSIVE_ABILITIES[ability_id] if OFFENSIVE_ABILITIES.key?(ability_id)
      threat += DEFENSIVE_ABILITIES[ability_id] if DEFENSIVE_ABILITIES.key?(ability_id)
      threat += SPEED_ABILITIES[ability_id] if SPEED_ABILITIES.key?(ability_id)
      threat += SUPPORT_ABILITIES[ability_id] if SUPPORT_ABILITIES.key?(ability_id)

      return threat
    end

    def self.defensive_ability?(ability_id)
      return false if !ability_id
      ability_id = ability_id.to_sym if ability_id.is_a?(String)
      return DEFENSIVE_ABILITIES.key?(ability_id)
    end

    def self.offensive_ability?(ability_id)
      return false if !ability_id
      ability_id = ability_id.to_sym if ability_id.is_a?(String)
      return OFFENSIVE_ABILITIES.key?(ability_id)
    end

    def self.speed_ability?(ability_id)
      return false if !ability_id
      ability_id = ability_id.to_sym if ability_id.is_a?(String)
      return SPEED_ABILITIES.key?(ability_id)
    end

    def self.support_ability?(ability_id)
      return false if !ability_id
      ability_id = ability_id.to_sym if ability_id.is_a?(String)
      return SUPPORT_ABILITIES.key?(ability_id)
    end

    def self.categorize_ability(ability_id)
      return :unknown if !ability_id
      ability_id = ability_id.to_sym if ability_id.is_a?(String)

      return :offensive if OFFENSIVE_ABILITIES.key?(ability_id)
      return :defensive if DEFENSIVE_ABILITIES.key?(ability_id)
      return :speed if SPEED_ABILITIES.key?(ability_id)
      return :support if SUPPORT_ABILITIES.key?(ability_id)

      return :unknown
    end

    def self.benefits_from_weather?(battler, weather)
      return false if !battler || !weather
      return false unless battler.respond_to?(:hasActiveAbility?)

      case weather
      when :Sun, :HarshSun
        return [:CHLOROPHYLL, :SOLARPOWER, :FLOWERGIFT, :LEAFGUARD,
                :HARVEST, :PROTOSYNTHESIS, :ORICHALCUMPULSE].any? { |a| battler.hasActiveAbility?(a) }
      when :Rain, :HeavyRain
        return [:SWIFTSWIM, :RAINDISH, :DRYSKIN, :HYDRATION].any? { |a| battler.hasActiveAbility?(a) }
      when :Sandstorm
        return [:SANDRUSH, :SANDVEIL, :SANDFORCE].any? { |a| battler.hasActiveAbility?(a) }
      when :Hail, :Snow
        return [:SLUSHRUSH, :SNOWCLOAK, :ICEBODY, :ICEFACE].any? { |a| battler.hasActiveAbility?(a) }
      end

      return false
    end

    def self.benefits_from_terrain?(battler, terrain)
      return false if !battler || !terrain
      return false unless battler.respond_to?(:hasActiveAbility?)

      case terrain
      when :Electric
        return [:SURGESURFER, :QUARKDRIVE, :HADRONENGINE].any? { |a| battler.hasActiveAbility?(a) }
      when :Grassy
        return battler.hasActiveAbility?(:GRASSPELT)
      when :Psychic
        return false
      when :Misty
        return false
      end

      return false
    end

    def self.ignores_abilities?(attacker)
      return false if !attacker
      return false unless attacker.respond_to?(:hasActiveAbility?)

      return [:MOLDBREAKER, :TERAVOLT, :TURBOBLAZE,
              :NEUTRALIZINGGAS].any? { |a| attacker.hasActiveAbility?(a) }
    end

    def self.ability_suppressed?(attacker, target)
      return false if !attacker || !target
      return true if ignores_abilities?(attacker)
      return true if target.respond_to?(:effects) && target.effects[PBEffects::GastroAcid]
      return false
    end

    def self.calculate_ability_damage_modifier(attacker, target, move, battle)
      modifier = 1.0
      return modifier if !attacker || !target || !move

      if attacker.respond_to?(:hasActiveAbility?)
        attacker_ability = attacker.ability_id
        attacker_suppressed = !attacker.hasActiveAbility?(attacker_ability)
      else
        attacker_ability = attacker.respond_to?(:ability_id) ? attacker.ability_id : nil
        attacker_suppressed = false
      end
      if target.respond_to?(:hasActiveAbility?)
        target_ability = target.ability_id
      else
        target_ability = target.respond_to?(:ability_id) ? target.ability_id : nil
      end
      if attacker_ability && !attacker_suppressed
        case attacker_ability
        when :HUGEPOWER, :PUREPOWER
          modifier *= 2.0 if move.physicalMove?
        when :ADAPTABILITY
          atk_types = attacker.respond_to?(:pbTypes) ? attacker.pbTypes(true) : (attacker.respond_to?(:types) ? attacker.types : [attacker.type1, attacker.type2].compact)
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          modifier *= (4.0 / 3.0) if atk_types.include?(resolved_type)
        when :TOUGHCLAWS
          modifier *= 1.3 if move.contactMove?
        when :SHEERFORCE
          modifier *= 1.3 if move.addlEffect.to_i > 0
        when :TECHNICIAN
          modifier *= 1.5 if move.power <= 60
        when :IRONFIST
          modifier *= 1.2 if move.punchingMove?
        when :STRONGJAW
          modifier *= 1.5 if move.bitingMove?
        when :TINTEDLENS
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          effectiveness = AdvancedAI::Utilities.type_mod(resolved_type, target)
          modifier *= 2.0 if Effectiveness.not_very_effective?(effectiveness)
        when :MINDSEYE
          modifier *= 1.0
        end
      end

      if target_ability && !ability_suppressed?(attacker, target)
        case target_ability
        when :MULTISCALE, :SHADOWSHIELD
          modifier *= 0.5 if target.hp == target.totalhp
        when :FILTER, :SOLIDROCK, :PRISMARMOR
          resolved_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          effectiveness = AdvancedAI::Utilities.type_mod(resolved_type, target)
          modifier *= 0.75 if Effectiveness.super_effective?(effectiveness)
        when :FURCOAT
          modifier *= 0.5 if move.physicalMove?
        when :FLUFFY
          modifier *= 0.5 if move.contactMove?
          fluffy_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          modifier *= 2.0 if fluffy_type == :FIRE
        when :THICKFAT
          thick_fat_type = AdvancedAI::CombatUtilities.resolve_move_type(attacker, move)
          modifier *= 0.5 if [:FIRE, :ICE].include?(thick_fat_type)
        when :ICESCALES
          modifier *= 0.5 if move.specialMove?
        when :TERASHELL
          modifier *= 0.5 if target.hp == target.totalhp
        end
      end

      if attacker_ability && !attacker_suppressed
        if attacker_ability == :SWORDOFRUIN && move.physicalMove?
          modifier *= 4.0 / 3.0
        end
        if attacker_ability == :BEADSOFRUIN && move.specialMove?
          modifier *= 4.0 / 3.0
        end
        if attacker_ability == :TOXICBOOST && attacker.respond_to?(:poisoned?) && attacker.poisoned? && move.physicalMove?
          modifier *= 1.5
        end
        if attacker_ability == :FLAREBOOST && attacker.respond_to?(:burned?) && attacker.burned? && move.specialMove?
          modifier *= 1.5
        end
      end
      if target_ability && !ability_suppressed?(attacker, target)
        if target_ability == :TABLETSOFRUIN && move.physicalMove?
          modifier *= 0.75
        end
        if target_ability == :VESSELOFRUIN && move.specialMove?
          modifier *= 0.75
        end
      end

      return modifier
    end

  end
end

module AdvancedAI
  def self.get_ability_threat(ability_id)
    CustomContent.get_ability_threat(ability_id)
  end

  def self.defensive_ability?(ability_id)
    CustomContent.defensive_ability?(ability_id)
  end

  def self.offensive_ability?(ability_id)
    CustomContent.offensive_ability?(ability_id)
  end

  def self.categorize_ability(ability_id)
    CustomContent.categorize_ability(ability_id)
  end

  def self.benefits_from_weather?(battler, weather)
    CustomContent.benefits_from_weather?(battler, weather)
  end

  def self.benefits_from_terrain?(battler, terrain)
    CustomContent.benefits_from_terrain?(battler, terrain)
  end

  def self.ignores_abilities?(attacker)
    CustomContent.ignores_abilities?(attacker)
  end

  def self.ability_suppressed?(attacker, target)
    CustomContent.ability_suppressed?(attacker, target)
  end

  def self.calculate_ability_damage_modifier(attacker, target, move, battle)
    CustomContent.calculate_ability_damage_modifier(attacker, target, move, battle)
  end
end
