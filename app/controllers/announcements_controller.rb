# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :verify_core, except: [:index]
  before_action :verify_admin, only: [:expire]

  def index
    @announcements = Announcement.all.order(created_at: :desc)
  end

  def expire
    @announcement = Announcement.find(params[:id])

    if @announcement.update(expiry: DateTime.now)
      flash[:success] = 'Announcement expired'
    else
      flash[:danger] = 'Something went wrong'
    end

    redirect_to announcements_path
  end

  def new
    @announcement = Announcement.new
  end

  def create
    html = helpers.render_markdown(params[:text])
    date = Date.parse(params[:expiry_date])
    time = Time.parse(params[:expiry_time])
    expiry = DateTime.new(date.year, date.month, date.day, time.hour, time.min, time.sec, time.zone)

    @announcement = Announcement.new(text: html, expiry: expiry)
    if @announcement.save
      flash[:success] = 'Created your announcement.'
      AnnouncementsMailer.announce(@announcement).deliver_now
      redirect_to url_for(controller: :announcements, action: :new)
    else
      flash[:error] = "Couldn't create your announcement."
      render :new, status: 500
    end
  end
end
