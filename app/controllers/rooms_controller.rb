class RoomsController < ApplicationController
  before_action :require_authentication
  before_action :set_room, only: %i[show edit update destroy]

  def index
    @rooms = policy_scope(Room).filter_by(filter_params).order(:name)
  end

  def show
    authorize @room
  end

  def new
    @room = Room.new
    authorize @room
  end

  def create
    authorize Room.new
    @room = RoomCreator.call(room_params)
    redirect_to @room, notice: I18n.t("rooms.created")
  rescue RoomCreator::InvalidRoom => e
    @room = e.room
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize @room
  end

  def update
    authorize @room
    RoomUpdater.call(@room, room_params)
    redirect_to @room, notice: I18n.t("rooms.updated")
  rescue RoomUpdater::InvalidRoom => e
    @room = e.room
    render :edit, status: :unprocessable_entity
  end

  def destroy
    authorize @room
    RoomDestroyer.call(@room)
    redirect_to rooms_path, notice: I18n.t("rooms.destroyed")
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:name, :capacity, :description, :available)
  end

  def filter_params
    params.permit(:name, :min_capacity, :available)
  end
end
