# frozen_string_literal: true

class ReleasesController < ApplicationController
  before_action :authenticate_login!, except: %i[index show auth]
  before_action :set_channel
  before_action :set_release, only: %i[show auth destroy]
  before_action :authenticate_app!, only: :show

  def index
    if @channel.releases.empty?
      return redirect_to friendly_channel_overview_path(@channel),
        notice: t('releases.messages.errors.not_found_release_and_redirect_to_channel')
    end

    @release = @channel.releases.last
    @title = @release.app_name
    render :show
  end

  def show
    authorize @release
  end

  def new
    @title = t('releases.new.title')
    @release = @channel.releases.new
    authorize @release
  end

  def create
    @title = t('releases.new.title')
    @release = @channel.releases.upload_file(release_params)
    authorize @release

    return render :new, status: :unprocessable_entity unless @release.save

    # 触发异步任务
    @release.channel.perform_web_hook('upload_events', current_user.id)
    @release.perform_teardown_job(current_user.id) if @release.bundle_id.present?

    message = t('activerecord.success.create', key: "#{t('releases.title')}")
    redirect_to channel_release_path(@channel, @release), notice: message
  end

  def destroy
    authorize @release
    @release.destroy

    notice = t('activerecord.success.destroy', key: "#{t('releases.title')}")
    redirect_to friendly_channel_releases_path(@channel), status: :see_other, notice: notice
  end

  def auth
    unless @release.password_match?(cookies, params[:password])
      @error_message = t('releases.messages.errors.invalid_password')
      return render :show, status: :unprocessable_entity
    end

    redirect_to friendly_channel_release_path(@channel, @release), status: :see_other
  end

  protected

  def authenticate_login!
    authenticate_user! unless app_limited? || Setting.guest_mode
  end

  def authenticate_app!
    return if app_limited? || @channel.password.present? || user_signed_in? || Setting.guest_mode
  end

  def app_limited?
    Setting.preset_install_limited
      .find {|q| request.user_agent.include?(q) }
      .present?
  end

  def set_release
    @release = Release.find params[:id]
  end

  def set_channel
    @channel = Channel.friendly.find params[:channel_id] || params[:channel]
  end

  def release_params
    params.require(:release).permit(
      :file, :changelog, :release_type, :branch, :git_commit, :ci_url
    )
  end

  def not_found(e)
    @e = e
    @title = t('releases.messages.errors.not_found')
    @link_title = t('releases.messages.errors.redirect_to_app_list')
    @link_href = apps_path

    case e
    when ActiveRecord::RecordNotFound
      case e.model
      when 'Channel'
        @title = t('releases.messages.errors.not_found_app')
      when 'Release'
        @title = t('releases.messages.errors.not_found_release')
        if (current_user || Setting.guest_mode)
          @link_title = t('releases.messages.errors.reidrect_channel_detal')
          @link_href = friendly_channel_overview_path(@channel)
        else
          @link_title = t('releases.messages.errors.not_found_release_and_redirect_to_latest_release')
          @link_href = friendly_channel_releases_path(@channel)
        end

      end
    end

    render :not_found, status: :not_found
  end
end
