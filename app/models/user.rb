class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :books
	has_many :favorites, dependent: :destroy
	has_many :book_comments, dependent: :destroy
	
	# 自分がフォローされる側の中間テーブルへのアソシエーション
  has_many :reverse_of_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  # 自分がフォローする側の中間テーブルへのアソシエーション
  has_many :relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  # フォローされる側からフォローしているユーザを取得する
  has_many :followers, through: :reverse_of_relationships, source: :follower
  # フォローする側からフォローされたユーザを取得する
  has_many :followings, through: :relationships, source: :followed
  
  attachment :profile_image, destroy: false

  validates :name, length: { minimum: 2, maximum: 20 }, uniqueness: true
  validates :introduction, length: { maximum: 50 }
  
  # あるユーザが引数で渡されたuserにフォローされているか調べるメソッド
  def is_followed_by?(user)
    reverse_of_relationships.find_by(follower_id: user.id).present?
  end
  
  #検索方法分岐
  def self.search_for(value, how)                  #def search_forでhowとvalueの処理
    # 選択した検索方法がが完全一致だったら
    if how == 'match'
      User.where(name: value)                      #whereでvalueと完全一致するnameを探します
      # 選択した検索方法がが前方一致だったら
    elsif how == 'forward'
      User.where('name LIKE ?', value+'%')
      # 選択した検索方法がが後方一致だったら
    elsif how == 'backward'
      User.where('name LIKE ?', '%'+value)
    else
      # 選択した検索方法がが部分一致だったら
      User.where('name LIKE ?', '%'+value+'%')
    end
  end
  
  
end

