class Challenge
  include Mongoid::Document
  include Mongoid::Timestamps

  VALID_STATES = ['created', 'accepted', 'finished', 'challenged', 'denied']

  belongs_to :challenging_player, inverse_of: :own_challenges, class_name: 'User', autosave: true
  belongs_to :challenged_player, inverse_of: :foreign_challenges, class_name: 'User', autosave: true

  field :winner, type: User

  field :suggestions, type: Array
  field :due_date, type: Date
  field :play_date, type: DateTime
  field :location, type: String
  field :comment, type: String
  field :state, type: String
  field :after_neutralization, type: Boolean, default: false

  validates_presence_of :suggestions, :due_date, :location, :state, :challenging_player, :challenged_player
  validates_inclusion_of :state, in: VALID_STATES
  validate :using_different_dates, :dates_in_next_two_weeks, :all_dates_in_future

  def active?
    state.in? ['created', 'accepted', 'challenged']
  end

  def set_winner(usr)
    update_attributes(state: 'finished', winner: usr)
    usr.wins += 1
    challenged_player.equal?(usr) ? challenging_player.losses += 1 : challenged_player.losses += 1
    challenged_player.save
    challenging_player.save
  end

  # Validation Methods
  def using_different_dates
    if suggestions.map{ |d| d.to_date }.uniq.size < 3
      errors.add :suggestions, "All suggestions must be on different days."
    end
  end

  def dates_in_next_two_weeks
    if suggestions.any? { |s| s > Time.now.to_date+14.days }
      errors.add :suggestions, "Must all be within the next 14 days."
    end
  end

  def all_dates_in_future
    if suggestions.any? { |s| s < Time.now }
      errors.add :suggestions, "Must be in the future."
    end
  end

  # static methods
  def self.with_participation_of(user)
    criteria = any_of({challenging_player: user}, {challenged_player: user})
    criteria = criteria.any_of({state: :created}, {state: :accepted}, {state: :challenged})
    criteria
  end

  def self.challenged_challenges
    Challenge.where(state: 'challenged')
  end

  def self.active_challenges
    Challenge.any_of({state: 'created'}, {state: 'accepted'}, {state: 'challenged'})
  end

  def self.history
    Challenge.where(state: 'finished')
  end
end
