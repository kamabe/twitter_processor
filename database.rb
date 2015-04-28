require "pg"
require "yaml"

module DB
  def get_postgres_connection(database)
    config = YAML.load_file('database.yml')[database]

    unless config.nil?
      PGconn.open(
        :dbname   => config['dbname'],
        :host     => config['host'],
        :port     => config['port'],
        :user     => config['user'],
        :password => config['password']
      )
    else
      raise "There is no databases named #{database} in the config file"
    end
  end
end
