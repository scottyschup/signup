class EventsController < ApplicationController
  before_action :set_event, only: [:edit, :update, :destroy, :show]
  before_action :set_game_types, except: [:destroy]

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:notice] = ["Successsss!"]
      redirect_to action: :index
    else
      flash[:error] = @event.errors.full_messages
      render :new
    end
  end

  def destroy
    @event.destroy
  end

  def edit
  end

  def index
    @game_type_id = params[:game_type]
    now_ish = Time.now - 45.minutes
    @events = Event.where('date_time >= ?', now_ish).order(:date_time)
    @past_events = Event
      .where('date_time < ?', now_ish)
      .order(:date_time)
      .reverse_order
    if @game_type_id
      @events = @events.where(game_type_id: @game_type_id)
      @past_events = @past_events.where(game_type_id: @game_type_id)
    end
    @game_type_id = @game_type_id.to_i
  end

  def new
    @event = Event.new
  end

  def show
    @event = Event.find(params[:id])
    @new_user = User.new
  end

  def update
    if @event.update(event_params)
      redirect_to event_index_path(@event)
    else
      flash[:error] = @event.errors.full_messages
    end
  end

  private

  def event_params
    eps = params
      .require(:event)
      .permit(:name, :description, :game_type_id, :location_id, :minimum_number)

    if !params[:event][:location_text].empty?
      location = Location.create({ name: params[:event][:location_text] })
      eps[:location_id] = location.id
    end

    if !params[:event][:game_type_text].empty?
      game_type = GameType.create({ name: params[:event][:game_type_text] })
      eps[:game_type_id] = game_type.id
    end

    begin
      date_str = params[:event][:date] + params[:event][:time]
      # Add 2 hours due to dates constantly being 2 hours behind
      # may need to remove when DST is done in the fall (wtf right??)
      eps[:date_time] = Time.zone.parse(date_str) + 2.hours
    rescue
      puts 'Date Time invalid: ', params[:event][:date], params[:event][:time]
    end

    eps
  end

  def set_event
    @event = Event.find(params[:id])
  end

  def set_game_types
    @game_types = GameType.all
    @new_game_type = GameType.new
  end
end
