module DeviseIosRails
  module OAuth
    def self.included receiver
      receiver.extend ClassMethods
      receiver.validates_with OauthTokenValidator, unless: 'provider.blank?'
      receiver.validates :uid, uniqueness: { scope: :provider },
                               allow_nil: true, allow_blank: true
    end

    def email_required?
      super && password_required?
    end

    def password_required?
      super && provider.blank?
    end

    module ClassMethods
      def from_oauth(attributes, new_user_callback = -> {})
        created = false
        user = nil
        existing_user = where(email: attributes[:email]).first

        if existing_user.present?
          if existing_user.uid.nil?
            existing_user.update(attributes.slice(:uid, :provider))
          end
          
          user = existing_user.reload
        else
          user = where(attributes.slice(:uid, :provider)).first_or_create do |user|
            user.email = attributes[:email]
            user.password = Devise.friendly_token[0,20]
            user.provider    = attributes[:provider]
            user.uid         = attributes[:uid]
            user.oauth_token = attributes[:oauth_token]
            created = true
          end
        end

        if created
          new_user_callback.call
        end

        user
      end
    end
  end
end
