#!/usr/bin/env ruby
# frozen_string_literal: true

# Calculates the deployment frequency for a group of CircleCI projects.
# The output is written to stdout in CSV format.
#
# Usage: ./deployment_frequency.rb config.yml months_ago
#
# Example config.yml:
#
# ```yaml
# projects:
#   - slug: <vcs>/<org>/<repo>
#     branch: main
# ```
#
require 'httparty'
require 'date'
require 'yaml'
require 'csv'

def make_request(url, query, token)
  headers = { 'Circle-Token' => token }
  response = HTTParty.get(url, query:, headers:)
  JSON.parse(response)
end

def get_builds(token, slug, branch, start_date, end_date)
  url = "https://circleci.com/api/v2/project/#{slug}/pipeline"
  query = { 'branch' => branch, 'start_date' => start_date.to_s, 'end_date' => end_date.to_s }
  builds = []

  loop do
    response = make_request(url, query, token)
    builds.concat(response['items'])
    query['page-token'] = response['next_page_token']
    break if query['page-token'].nil?
  end

  builds
end

circleci_token = ENV['CIRCLECI_TOKEN']
raise 'CircleCI token not found. Set the CIRCLECI_TOKEN environment variable.' unless circleci_token

config_file = ARGV[0]
raise 'Configuration file not specified.' unless config_file
raise 'Configuration file does not exist.' unless File.exist?(config_file)

months_ago = ARGV[1].to_i
raise 'Months ago value not specified or invalid.' if months_ago <= 0

config = YAML.load_file(config_file)
projects = config['projects']
end_date = Date.today
start_date = end_date << months_ago

CSV($stdout) do |csv|
  csv << %w[date project deploys]

  projects.each do |project|
    builds = get_builds(circleci_token, project['slug'], project['branch'], start_date, end_date)
    builds.each do |build|
      next unless build['trigger']['type'] == 'webhook'

      csv << [Date.parse(build['created_at']).to_s, project['slug'], 1]
    end
  end
end
