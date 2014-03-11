class Challenge
  include Mongoid::Document
  include Mongoid::Timestamps

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

  validates_presence_of :suggestions, :due_date, :play_date, :location, :state, :challenging_player, :challenged_player
  validates_inclusion_of :state, in: [:created, :accepted, :finished, :challenged, :denied]

  def active?
    state.in? [:created, :accepted, :challenged]
  end

end
