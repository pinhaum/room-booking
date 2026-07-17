# Destroys a Room.
# Returns the destroyed Room on success; raises UndeletableRoom otherwise (ADR-009).
class RoomDestroyer
  class UndeletableRoom < StandardError
    attr_reader :room

    def initialize(room)
      @room = room
      super("Não foi possível remover a sala")
    end
  end

  def self.call(room)
    new(room).call
  end

  def initialize(room)
    @room = room
  end

  def call
    raise UndeletableRoom, @room unless @room.destroy

    @room
  end
end
