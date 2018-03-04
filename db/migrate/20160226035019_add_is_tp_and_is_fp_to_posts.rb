# frozen_string_literal: true

class AddIsTpAndIsFpToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :is_tp, :boolean, default: false
    add_column :posts, :is_fp, :boolean, default: false

    tp_posts = Feedback.joins(:post).where('feedback_type LIKE \'%tp%\'').group(Arel.sql('posts.id')).count.map { |k, _v| k }
    fp_posts = Feedback.joins(:post).where('feedback_type LIKE \'%fp%\'').group(Arel.sql('posts.id')).count.map { |k, _v| k }

    Post.where(id: tp_posts).update_all is_tp: true
    Post.where(id: fp_posts).update_all is_fp: true
  end
end
