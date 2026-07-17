# Updates a Room with new attributes.
# Returns the Room on success; raises InvalidRoom otherwise (ADR-009).
class RoomUpdater
  class InvalidRoom < StandardError
    attr_reader :room

    def initialize(room)
      @room = room
      super("Sala inválida")
    end
  end

  def self.call(room, attributes)
    new(room, attributes).call
  end

  def initialize(room, attributes)
    @room = room
    @attributes = attributes
  end

  def call
    raise InvalidRoom, @room unless @room.update(@attributes)

    @room
  end
end
