# frozen_string_literal: true

class PagesController < ApplicationController
  include I18nHelper

  layout "layouts/pages"

  skip_before_action :authenticate_user!

  def home
    return redirect_to organizations_path if logged_in?
  end

  def homev2
    @teacher_count = User.last.id if User.last

    if AssignmentRepo.last && GroupAssignmentRepo.last.id
      @repo_count = AssignmentRepo.last.id + GroupAssignmentRepo.last.id
    end

    return not_found unless home_v2_enabled?
    render layout: "layouts/pagesv2"
  end

  def assistant
    return not_found unless assistant_landing_page_enabled?
    render layout: "layouts/pagesv2"
  end
end
