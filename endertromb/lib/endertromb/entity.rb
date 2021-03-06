module Endertromb
  class Entity
    attr_reader :entity

    def initialize
      cost = self.class.cost
      klass = "Entity#{self.class.to_s.sub(/^Endertromb::/, '')}".to_sym
      if cost.nil? || Inventory.remove_items(cost)
        @entity = Java::NetMinecraftSrc.const_get(klass).new($world)
        place_in_front_of_player
        $world.spawn_entity_in_world(@entity)
      else
        raise "You need #{cost.count} #{cost.to_item_or_block.name} to make a #{self.class.to_s.sub(/^Endertromb::/, '')}"
      end
    end

    def cost
      nil
    end

    def place_in_front_of_player
      dir_x = net.minecraft.src.MathHelper.sin($player.rotationYaw * Math::PI / 180)
      dir_z = net.minecraft.src.MathHelper.cos($player.rotationYaw * Math::PI / 180)
      x = $player.posX + dir_x * -5
      y = $player.posY
      z = $player.posZ + dir_z * 5
      @entity.set_position(x, y, z)
    end

    def <=>(other)
      @entity.width*@entity.height <=> other.entity.width*other.entity.height
    end

    def mount(other)
      other = other.entity unless other.nil?
      @entity.mount_entity(other)
    end
    alias_method :/, :mount

    def unmount
      mount(nil)
    end

    def move_to(*args)
      args = [args[0], @entity.posY, args[1]] if args.length == 2
      if args.length == 3
        x, y, z = *args
        @entity.get_navigator.tryMoveToXYZ(x, y, z, 0.3)
      elsif args.length == 1 && args.first.is_a?(Entity)
        @entity.get_navigator.tryMoveToEntityLiving(args.first.entity, 0.3)
      end
    end

    def eventually_explode
      Thread.new do
        loop do
          sleep 1
          break if rand(100).zero?
        end
        if @entity.entity_alive?
          explode
        end
      end
    end

    def explode(intensity=10)
      $world.create_explosion(@entity, @entity.posX, @entity.posY, @entity.posZ, intensity, true)
    end

    def move(x, y, z)
      @entity.move_entity(x, y, z)
    end

    def burn(how_long = 1000)
      @entity.set_fire(how_long)
    end

    def extinguish
      @entity.extinguish
    end

    def kill
      @entity.kill
    end

    def to_s
      @entity.to_s
    end

    def method_missing(name, *args, &blk)
      @entity.send(name, *args, &blk)
    end
  end
end

