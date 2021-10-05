class Book < ApplicationRecord
  belongs_to :user
	has_many :favorites, dependent: :destroy
	has_many :book_comments, dependent: :destroy
  validates :title, presence: true
  validates :body, presence: true, length: { maximum: 200 }

	def favorited_by?(user)
		favorites.where(user_id: user.id).exists?
	end
	
#検索方法分岐
  def self.search_for(value, how)                  #def search_forでhowとvalueの処理
    # 選択した検索方法がが完全一致だったら
    if how == 'match'
      Book.where(title: value)                      #whereでvalueと完全一致するnameを探します
      # 選択した検索方法がが前方一致だったら
    elsif how == 'forward'
      Book.where('title LIKE ?', value+'%')
      # 選択した検索方法がが後方一致だったら
    elsif how == 'backward'
      Book.where('title LIKE ?', '%'+value)
    else
      # 選択した検索方法がが部分一致だったら
      Book.where('title LIKE ?', '%'+value+'%')
    end
  end
  
end