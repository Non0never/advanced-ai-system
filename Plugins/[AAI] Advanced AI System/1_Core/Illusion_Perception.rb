

unless defined?(Set)
  class Set
    include Enumerable
    def initialize(enum = nil); @hash = {}; enum&.each { |e| @hash[e] = true }; end
    def add(o); @hash[o] = true; self; end
    alias << add
    def include?(o); @hash.key?(o); end
    alias member? include?
    def delete(o); @hash.delete(o); self; end
    def each(&blk); return to_enum(:each) unless blk; @hash.each_key(&blk); self; end
    def to_a; @hash.keys; end
    def size; @hash.size; end
    def empty?; @hash.empty?; end
  end
end

module AdvancedAI
  module IllusionPerception
    @active_observer = nil
    @exposed_pids = {}

    class << self
      attr_reader :active_observer

      def with_perception(observer)
        prev = @active_observer
        @active_observer = observer
        yield
      ensure
        @active_observer = prev
      end

      def mark_exposed(battler)
        return unless battler && battler.respond_to?(:pokemon) && battler.pokemon
        battle = battler.respond_to?(:battle) ? battler.battle : nil
        return unless battle
        (@exposed_pids[battle.object_id] ||= Set.new) << battler.pokemon.personalID
      end

      def exposed?(battler)
        return false unless battler && battler.respond_to?(:pokemon) && battler.pokemon
        battle = battler.respond_to?(:battle) ? battler.battle : nil
        return false unless battle
        bucket = @exposed_pids[battle.object_id]
        return false unless bucket
        bucket.include?(battler.pokemon.personalID)
      end

      def clear_for_battle(battle)
        return unless battle
        @exposed_pids.delete(battle.object_id)
      end

      def disguise_for(target)
        return nil unless @active_observer
        return nil unless target.is_a?(Battle::Battler)
        disguise = target.effects[PBEffects::Illusion] rescue nil
        return nil unless disguise
        return nil unless target.opposes?(@active_observer)
        return nil if exposed?(target)
        disguise
      end
    end
  end
end

class Battle::Battler
  alias_method :pbTypes_aai_pre_illusion, :pbTypes
  def pbTypes(withExtraType = false)
    disguise = AdvancedAI::IllusionPerception.disguise_for(self)
    return pbTypes_aai_pre_illusion(withExtraType) unless disguise
    ret = Array(disguise.types).uniq
    if withExtraType && @effects[PBEffects::ExtraType] && !ret.include?(@effects[PBEffects::ExtraType])
      ret.push(@effects[PBEffects::ExtraType])
    end
    ret
  end

  alias_method :pbHasType_aai_pre_illusion?, :pbHasType?
  def pbHasType?(check_type)
    disguise = AdvancedAI::IllusionPerception.disguise_for(self)
    return pbHasType_aai_pre_illusion?(check_type) unless disguise
    return false unless check_type
    type_id = GameData::Type.get(check_type).id rescue nil
    return false unless type_id
    active = pbTypes(true)
    active.include?(type_id)
  end
end

class Battle::Battler
  alias_method :pbEffectsOnMakingHit_aai_pre_illusion, :pbEffectsOnMakingHit if method_defined?(:pbEffectsOnMakingHit)
end

if Battle::Battler.method_defined?(:pbEffectsOnMakingHit_aai_pre_illusion)
  class Battle::Battler
    def pbEffectsOnMakingHit(move, user, target)
      had_illusion = target.effects[PBEffects::Illusion] rescue nil
      pbEffectsOnMakingHit_aai_pre_illusion(move, user, target)
      if had_illusion && target.effects[PBEffects::Illusion].nil?
        AdvancedAI::IllusionPerception.mark_exposed(target)
      end
    end
  end
end

class Battle
  alias_method :pbStartBattle_aai_pre_illusion, :pbStartBattle
  def pbStartBattle
    AdvancedAI::IllusionPerception.clear_for_battle(self)
    pbStartBattle_aai_pre_illusion
  end
end

class Battle::AI
  alias_method :pbDefaultChooseEnemyCommand_aai_pre_illusion, :pbDefaultChooseEnemyCommand
  def pbDefaultChooseEnemyCommand(idxBattler)
    observer = @battlers[idxBattler] rescue nil
    AdvancedAI::IllusionPerception.with_perception(observer) do
      pbDefaultChooseEnemyCommand_aai_pre_illusion(idxBattler)
    end
  end

  alias_method :pbDefaultChooseNewEnemy_aai_pre_illusion, :pbDefaultChooseNewEnemy
  def pbDefaultChooseNewEnemy(idxBattler)
    observer = @battlers[idxBattler] rescue nil
    AdvancedAI::IllusionPerception.with_perception(observer) do
      pbDefaultChooseNewEnemy_aai_pre_illusion(idxBattler)
    end
  end
end
