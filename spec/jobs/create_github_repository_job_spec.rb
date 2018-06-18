# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentRepo::CreateGitHubRepositoryJob, type: :job do
  subject { AssignmentRepo::CreateGitHubRepositoryJob }

  let(:organization) { classroom_org }
  let(:student)      { classroom_student }
  let(:teacher)      { classroom_teacher }

  let(:assignment) do
    options = {
      title: "Learn Elm",
      starter_code_repo_id: 1_062_897,
      organization: organization,
      students_are_repo_admins: true
    }

    create(:assignment, options)
  end

  before do
    Octokit.reset!
  end

  after(:each) do
    AssignmentRepo.destroy_all
  end

  it "uses the :create_repository queue", :vcr do
    assert_performed_with(job: subject, args: [assignment, student], queue: "create_repository") do
      subject.perform_later(assignment, student)
    end
  end
end
