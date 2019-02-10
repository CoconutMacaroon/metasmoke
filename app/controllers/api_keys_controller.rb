# frozen_string_literal: true

class APIKeysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_key, except: %i[index new create mine]
  before_action :verify_admin, except: %i[owner_edit owner_update owner_revoke mine]
  before_action :verify_ownership, only: %i[owner_edit owner_update owner_revoke]

  def index
    @keys = APIKey.all
  end

  def revoke_write_tokens
    if APIToken.where(api_key: @key).destroy_all
      flash[:success] = "Successfully removed all write tokens belonging to #{@key.app_name}."
    else
      flash[:danger] = 'Failed to revoke all API write tokens - tokens need to be removed manually.'
    end
    redirect_to url_for(controller: :api_keys, action: :index)
  end

  def new
    @key = APIKey.new
    @key.key = SecureRandom.hex 32
  end

  def create
    @key = APIKey.new(key_params)
    @key.save!
    flash[:success] = "Successfully registered API key #{@key.key}"
    redirect_to :admin_new_key
  end

  def edit; end

  def update
    if @key.update key_params
      flash[:success] = 'Successfully updated.'
      redirect_to url_for(controller: :api_keys, action: :index)
    else
      flash[:danger] = 'Failed to update.'
      render :edit
    end
  end

  def mine
    @keys = APIKey.where(user: current_user)
  end

  def owner_edit; end

  def owner_update
    if @key.update owner_edit_params
      flash[:success] = 'Successfully updated your API key.'
      redirect_to url_for(controller: :api_keys, action: :mine)
    else
      flash[:danger] = "Can't save your API key - contact an admin."
      render :edit
    end
  end

  def owner_revoke
    if APIToken.where(api_key: @key).destroy_all
      flash[:success] = "Removed all active write tokens for your app #{@key.app_name}."
    else
      flash[:danger] = 'Failed to remove active write tokens. Contact an admin.'
    end
    redirect_to url_for(controller: :api_keys, action: :mine)
  end

  def update_trust
    if @key.update(is_trusted: params[:trusted] == 'true')
      render plain: 'OK'
    else
      render plain: 'nope'
    end
  end

  private

  def key_params
    params.require(:api_key).permit(:key, :app_name, :user_id, :github_link)
  end

  def set_key
    @key = APIKey.find params[:id]
  end

  def verify_ownership
    raise ActionController::RoutingError, 'Not Found' unless current_user == @key.user || current_user.is_admin
  end

  def owner_edit_params
    params.require(:api_key).permit(:app_name, :github_link)
  end
end
