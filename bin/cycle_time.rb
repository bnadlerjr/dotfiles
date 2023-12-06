#!/usr/bin/env ruby
# frozen_string_literal: true

# Calculates cycle time for a group of GitHub repositories. Cycle time is
# defined as the time between the first commit and the time the pull request
# is merged. The output is written to stdout in CSV format.
#
require 'octokit'
require 'date'
require 'csv'
require 'set'

if ARGV.empty?
  puts 'Usage: ./cycle_time.rb months_ago'
  exit
end

repos = [
  'flatiron-labs/askbot',
  'flatiron-labs/canforce',
  'flatiron-labs/canvas-theme-files',
  'flatiron-labs/ci-tools-orb',
  'flatiron-labs/easely',
  'flatiron-labs/flatiron-graphql',
  'flatiron-labs/flatiron_auth',
  'flatiron-labs/healthcheck',
  'flatiron-labs/infra-gql-gateway',
  'flatiron-labs/ironboard',
  'flatiron-labs/ironbroker-v2',
  'flatiron-labs/ironlogger',
  'flatiron-labs/monorepo',
  'flatiron-labs/ops',
  'flatiron-labs/registrar',
  'flatiron-labs/service-catalog',
  'flatiron-labs/service-content',
  'flatiron-labs/service-documents',
  'flatiron-labs/service-educator',
  'flatiron-labs/service-identity',
  'flatiron-labs/service-milestones',
  'flatiron-labs/service-operations',
  'flatiron-labs/student-home',
  'flatiron-labs/service-student-progress'
]

months_ago = ARGV[0].to_i

if months_ago <= 0
  puts "Error: 'months_ago' should be a positive integer."
  exit
end

github_token = ENV['GITHUB_TOKEN']
unless github_token
  puts 'Error: GITHUB_TOKEN environment variable not set.'
  exit
end

Octokit.configure { |c| c.access_token = github_token }
search_start_date = Date.today << months_ago
headers = ['Repository', 'PR Number', 'Description', 'First Commit On', 'Merged On', 'Cycle Time']

CSV($stdout, headers:, write_headers: true) do |csv|
  repos.each do |repo|
    processed_pr_numbers = Set.new

    page = 1
    loop do
      closed_prs = Octokit.search_issues("repo:#{repo} type:pr state:closed created:>=#{search_start_date}", page:)

      break if closed_prs.items.empty?

      closed_prs.items.each do |pr|
        next if processed_pr_numbers.include?(pr.number)

        pull_request = Octokit.pull_request(repo, pr.number)

        next if pull_request.merged_at.nil?

        commits = Octokit.pull_commits(repo, pr.number)

        next if commits.empty?

        first_commit = Octokit.commit(repo, commits[0].sha)
        first_commit_date = first_commit.commit.author.date
        merge_date = pull_request.merged_at
        cycle_time = (merge_date.to_date - first_commit_date.to_date).to_i
        description = first_commit.commit.message.split("\n").first[0...72]
        csv << [repo, pr.number, description, first_commit_date, merge_date, cycle_time]
        processed_pr_numbers.add(pr.number)
      end

      page += 1
    end
  end
end
