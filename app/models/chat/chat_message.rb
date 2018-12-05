module Chat
  class ChatMessage < ActiveRecord::Base
    self.table_name = 'chat_messages'

    belongs_to :provider_access
    belongs_to :provider, foreign_key: :sender_id, optional: true
    belongs_to :patient, foreign_key: :sender_id, optional: true
    belongs_to :sender, polymorphic: true, foreign_key: :sender_id, optional: true

    scope :with_sender, -> {includes(:provider, :patient)}

    def sender_name
      self.message_type == 'patient' ? self.patient.full_name : self.provider.proper_name
    end

    def self.params(params)
      params.require(:chat_message).permit!
    end
  end
end
