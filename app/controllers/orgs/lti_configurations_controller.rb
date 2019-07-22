# frozen_string_literal: true

module Orgs
  class LtiConfigurationsController < Orgs::Controller
    before_action :ensure_lti_launch_flipper_is_enabled
    before_action :ensure_no_google_classroom, only: %i[create]
    before_action :ensure_current_lti_configuration, except: %i[new create]
    before_action :ensure_no_roster, only: [:create]

    skip_before_action :authenticate_user!, only: :autoconfigure
    skip_before_action :ensure_current_organization_visible_to_current_user, only: :autoconfigure

    # rubocop:disable Metrics/MethodLength
    def create
      lti_configuration = LtiConfiguration.create(
        organization: current_organization,
        consumer_key: SecureRandom.uuid,
        shared_secret: SecureRandom.uuid
      )

      if lti_configuration.present?
        redirect_to lti_configuration_path(current_organization)
      else
        redirect_to new_lti_configuration_path(current_lti_configuration),
          alert: "There was a problem creating the configuration. Please try again later."
      end
    end
    # rubocop:enable Metrics/MethodLength

    def show; end

    def new; end

    def edit; end

    def update
      if current_lti_configuration.update_attributes(lti_configuration_params)
        flash[:success] = "The configuration was sucessfully updated."
        redirect_to lti_configuration_path(current_organization)
      else
        flash[:error] = "The configuration could not be updated at this time. Please try again."
        redirect_to edit_lti_configuration_path(current_organization)
      end
    end

    def destroy
      current_lti_configuration.destroy!

      redirect_to edit_organization_path(id: current_organization), alert: "LTI configuration deleted."
    end

    # rubocop:disable Metrics/MethodLength
    def autoconfigure
      builder = GitHubClassroom::LTI::ConfigurationBuilder.new("GitHub Classroom", auth_lti_launch_url)

      builder.add_attributes(
        description: "Sync your GitHub Classroom organization with your Learning Management System.",
        icon: "https://classroom.github.com/favicon.ico",
        vendor_name: "GitHub Classroom",
        vendor_url: "https://classroom.github.com/"
      )

      ## LMS Specific Attributes ##
      # Note: LMS's will ignore vendor identifiers they do not understand

      # Canvas will not display an LTI application
      # unless specify a course_navigation location.
      builder.add_vendor_attributes(
        "canvas.instructure.com",
        privacy_level: "public",
        custom_fields: {
          custom_context_membership_url: "$ToolProxyBinding.memberships.url"
        },
        course_navigation: {
          windowTarget: "_blank",
          visibility: "admins", # only show the application to instructors
          enabled: "true"
        }
      )

      render xml: builder.to_xml, status: :ok
    end
    # rubocop:enable Metrics/MethodLength

    private

    def current_lti_configuration
      @current_lti_configuration ||= current_organization.lti_configuration
    end

    def ensure_current_lti_configuration
      redirect_to new_lti_configuration_path(current_organization) unless current_lti_configuration
    end

    def lti_configuration_params
      params.require(:lti_configuration).permit(:lms_link)
    end

    def ensure_no_google_classroom
      return unless current_organization.google_course_id
      redirect_to edit_organization_path(current_organization),
        alert: "A Google Classroom configuration exists. Please remove configuration before creating a new one."
    end

    def ensure_no_roster
      return unless current_organization.roster
      redirect_to edit_organization_path(current_organization),
        alert: "We are unable to link your classroom organization to an LMS"\
          "because a roster already exists. Please delete your current roster and try again."
    end
  end
end