class ChangeAnnouncementsTextToTextType < ActiveRecord::Migration[5.1]
  def change
    change_column :announcements, :text, :text
  end
end
