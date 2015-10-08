#! /usr/bin/env ruby
#
# metrics-postgres-query
#
# DESCRIPTION:
#   This plugin collects metrics from the results of a postgres query. Can optionally
#   count the number of tuples (rows) returned by the query.
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: pg
#   gem: sensu-plugin
#
# USAGE:
#   metrics-postgres-query.rb -u db_user -p db_pass -h db_server -d db -q 'select foo from bar'
#
# NOTES:
#
# LICENSE:
#   Copyright 2015, Eric Heydrick <eheydrick@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'pg'

class MetricsPostgresQuery < Sensu::Plugin::Metric::CLI::Graphite
  option :user,
    description: 'Postgres User',
    short: '-u USER',
    long: '--user USER'

  option :password,
    description: 'Postgres Password',
    short: '-p PASS',
    long: '--password PASS'

  option :hostname,
    description: 'Hostname to login to',
    short: '-h HOST',
    long: '--hostname HOST',
    default: 'localhost'

  option :port,
    description: 'Database port',
    short: '-P PORT',
    long: '--port PORT',
    default: 5432

  option :db,
    description: 'Database name',
    short: '-d DB',
    long: '--db DB',
    default: 'postgres'

  option :query,
    description: 'Database query to execute',
    short: '-q QUERY',
    long: '--query QUERY',
    required: true

  option :count_tuples,
    description: 'Count the number of tuples (rows) returned by the query',
    short: '-t',
    long: '--tuples',
    boolean: true,
    default: false

  option :scheme,
    description: 'Metric naming scheme, text to prepend to metric',
    short: '-s SCHEME',
    long: '--scheme SCHEME',
    default: 'postgres'

  def run
    begin
      con = PG::Connection.new(config[:hostname], config[:port], nil, nil, config[:db], config[:user], config[:password])
      res = con.exec("#{config[:query]}")
    rescue PG::Error => e
      unknown "Unable to query PostgreSQL: #{e.message}"
    end

    if config[:check_tuples]
      value = res.ntuples
    else
      value = res.first.values.first
    end

    output config[:scheme], value
    ok
  end
end
