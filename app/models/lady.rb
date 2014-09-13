class Lady < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  belongs_to :previous_holder, class: "Player", foreign_key: :last_holder_id

  def to_json
    {
      self.player.to_json,
      self.previous_holder.to_json
    }
  end
end
