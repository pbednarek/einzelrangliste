class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin!

  def index
    @challenges = Challenge.active_challenges
    @need_action = Challenge.challenged_challenges
  end

  def accept_reason
    challenge = Challenge.find(params[:challenge_id])
    challenge.update_attribute(state: 'denied')
    redirect_to admin_path, notice: 'The challenge has been denied'
  end

  def deny_reason
    challenge = Challenge.find(params[:challenge_id])
    challenge.update_attributes(state: 'accepted', play_date: challenge.due_date.at_midnight+18.hours)
    redirect_to admin_path, notice: 'The challenge has been set to "accepted"'
  end
end