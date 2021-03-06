class Round < ActiveRecord::Base
  validates :creator_id, :prompt_id, :end_time, presence: true

  has_many :round_invites
  has_many :invites, through: :round_invites
  has_many :photos
  has_many :participant_rounds
  has_many :participants, through: :participant_rounds, class_name: "User", foreign_key: :participant_id
  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :prompt

  def has_photos?(user_id)
    self.photos.any?{ |photo| photo.user_id == user_id}
  end

  def attr_hash
    { round_id: self.id,
      creator_id: self.creator_id,
      creator_first_name: self.creator.first_name,
      prompt: self.prompt.body,
      end_time: self.end_time }
  end

  def add_participants(contact_numbers)
    self.participants = contact_numbers.map{ |phone_number| User.find_by(phone: phone_number) } if contact_numbers
    self.participants << User.find(self.creator_id)
  end

  def self.hash_collection(rounds_array)
    rounds_array.map { |round| round.attr_hash }
  end

  def submitted_participants
    self.participants.select { |participant| participant.photos.find_by(round_id: self.id) }
  end

  def pending_participants
    self.participants.select { |participant| !participant.photos.find_by(round_id: self.id) }
  end

  def submitted_participants_formatted
    self.submitted_participants.map { |user| { first_name: user.first_name,
      photo: user.photos.find_by(round_id: self.id).image_url.to_s } }
  end

  def pending_participants_formatted
    self.pending_participants.map{|user| { first_name: user.first_name } }
  end

end
