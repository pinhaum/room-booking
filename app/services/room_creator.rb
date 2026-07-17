# Creates a Room from attributes.
# Returns the persisted Room on success; raises InvalidRoom otherwise (ADR-009).
class RoomCreator
  class InvalidRoom < StandardError
    attr_reader :room

    def initialize(room)
      @room = room
      super("Sala inválida")
    end
  end

  def self.call(attributes)
    new(attributes).call
  end

  def initialize(attributes)
    @attributes = attributes
  end

  def call
    room = Room.new(@attributes)
    raise InvalidRoom, room unless room.save

    room
  end
end
