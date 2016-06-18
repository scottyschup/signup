class UsersController < ApplicationController
  before_action :set_user

  def create
    @event = Event.find(params[:user][:event_id])
    @user.events << @event
    @user.save
    redirect_to action: :show, controller: :events, id: @event.id
  end

  def destroy
    @user.events.delete(Event.find(params[:event_id]))
    redirect_to action: :show, controller: :events, id: params[:event_id]
  end

  private

  def set_user
    if params[:id]
      @user = User.find(params[:id])
    else
      @user = User.where(email: user_params[:email])
        .first_or_initialize(user_params)
    end
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end