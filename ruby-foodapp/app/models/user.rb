class User < ActiveRecord::Base
  has_many :food_images
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }, default_url: "https://placehold.it/100x100"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/  
  has_secure_password
  # validates :image,
  #     # attachment_content_type: { content_type: /\Aimage\/.*\Z/ },
  #     attachment_size: { less_than: 5.megabytes }

  # has_attached_file :image, styles: {
  #     thumb: '100x100>',
  #     square: '200x200#',
  #     medium: '300x300>'
  # }
        
  def self.for_oauth oauth
    oauth.get_data
    data = oauth.data

    user = find_by(oauth.provider => data[:id]) || find_or_create_by(email: data[:email]) do |u|
      u.password =  SecureRandom.hex
    end

    user.update(
      display_name: oauth.get_names.join(' '),
      email: data[:email],
      oauth.provider => data[:id]
    )

    user
  end

  def self.from_auth(params, current_user)
    params = params.smash.with_indifferent_access
    authorization = Authorization.find_or_initialize_by(provider: params[:provider], uid: params[:uid])
    if authorization.persisted?
      if current_user
        if current_user.id == authorization.user.id
          user = current_user
        else
          return false
        end
      else
        user = authorization.user
      end
    else
      if current_user
        user = current_user
      elsif params[:email].present?
        user = User.find_or_initialize_by(email: params[:email])
      else
        user = User.new
      end
    end
    authorization.secret = params[:secret]
    authorization.token  = params[:token]
    fallback_name        = params[:name].split(" ") if params[:name]
    fallback_first_name  = fallback_name.try(:first)
    fallback_last_name   = fallback_name.try(:last)
    user.first_name    ||= (params[:first_name] || fallback_first_name)
    user.last_name     ||= (params[:last_name]  || fallback_last_name)
    user.full_name       = ([user.first_name, user.last_name] - ['']).compact.join(' ') 

    if user.image_url.blank?
      user.avatar = URI.parse(params[:image_url])
      user.image_url = user.avatar.url
    end

    user.password = Devise.friendly_token[0,10] if user.encrypted_password.blank?

    if user.email.blank?
      user.save(validate: false)
    else
      user.save
    end
    authorization.user_id ||= user.id
    authorization.save
    user
  end


  def displayName= name
    self.display_name = name
  end

end
