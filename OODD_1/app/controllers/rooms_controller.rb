class RoomsController < ApplicationController
  include SessionsHelper
  before_action :set_room, only: [:show, :edit, :update, :destroy]
  before_action :is_logged_in?
  before_action :checkauth?, only: [:new, :edit, :update, :destroy]
  
  def checkauth?
    unless is_admin?
      flash[:privileges]="Not enough privileges"
      redirect_to root_path
    end
  end
  def is_logged_in?
    if current_user == nil
      flash[:privileges]="Please log in"
      redirect_to login_path
    end
  end 

  # GET /rooms
  # GET /rooms.json
  def index
    #if
    if params[:search_option].present?                   #DO VALIDATiON 
      if(params[:search_option] == "size")
        @rooms = Room.where("room_size ILIKE '%#{params[:search]}%'")
      else
        @rooms = Room.where("building ILIKE '%#{params[:search]}%'")
      end
    else
      @rooms = Room.all
    end
  end

  # GET /rooms/1
  # GET /rooms/1.json
  def show
  end

  # GET /rooms/new
  def new
    @room = Room.new
  end

  # GET /rooms/1/edit
  def edit
  end

  # POST /rooms
  # POST /rooms.json
  def create
    @room = Room.new(room_params)

    respond_to do |format|
      if @room.save
        format.html { redirect_to @room, notice: 'Room was successfully created.' }
        format.json { render :show, status: :created, location: @room }
      else
        format.html { render :new }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rooms/1
  # PATCH/PUT /rooms/1.json
  def update
    respond_to do |format|
      if @room.update(room_params)
        format.html { redirect_to @room, notice: 'Room was successfully updated.' }
        format.json { render :show, status: :ok, location: @room }
      else
        format.html { render :edit }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rooms/1
  # DELETE /rooms/1.json
  def destroy
    reservations = Reservation.new
    reservations = Reservation.where("room_id=? and start_time>?", @room.id, Time.now)
    if reservations.empty?
    @room.destroy
    respond_to do |format|
      format.html { redirect_to rooms_url, notice: 'Room was successfully destroyed.' }
      format.json { head :no_content }
    end
    else
    redirect_to rooms_url, notice: "Room has pending reservations! Delete them before deleting the reservations"
  end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def room_params
      params.require(:room).permit(:room_id, :building, :room_size)
    end
end
