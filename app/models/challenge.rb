class Challenge
  include Mongoid::Document
  include Mongoid::Timestamps

  VALID_STATES = ['created', 'accepted', 'finished', 'challenged', 'denied']

  belongs_to :challenging_player, inverse_of: :own_challenges, class_name: 'User', autosave: true
  belongs_to :challenged_player, inverse_of: :foreign_challenges, class_name: 'User', autosave: true

  has_one :winner, class_name: 'User'

  field :suggestions, type: Array
  field :due_date, type: Date
  field :play_date, type: Date
  field :location, type: String
  field :comment, type: String
  field :state, type: String
  field :after_neutralization, type: Boolean, default: false

  validates_presence_of :suggestions, :due_date, :location, :state, :challenging_player, :challenged_player
  validates_inclusion_of :state, in: VALID_STATES

  def active?
    state.in? [:created, :accepted, :challenged]
  end

  def set_winner(usr)
    update_attributes(state: 'finished', winner: usr)
    usr.wins += 1
    challenged_player.equal?(usr) ? challenging_player.losses += 1 : challenged_player.losses += 1
    challenged_player.save
    challenging_player.save
  end

  # static methods
  def self.with_participation_of(user)
    criteria = any_of({challenging_player: user}, {challenged_player: user})
    criteria = criteria.any_of({state: :created}, {state: :accepted}, {state: :challenged})
    criteria
  end

end
