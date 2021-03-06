require 'micro_q'
require 'time'
require 'timecop'
require 'celluloid'

require 'helpers/methods_examples'

Celluloid.logger = nil

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true

  config.order = 'default'

  config.before :each do
    MicroQ.send :clear
  end

  config.before :each, :active_record => true do
    require 'active_record'
    require 'sqlite3' # https://github.com/luislavena/sqlite3-ruby

    db_name = ENV['TEST_DATABASE'] || 'micro_q-test.db'

    (@_db = SQLite3::Database.new(db_name)).
    execute(<<-SQL)
      create table if not exists repositories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name varchar(255)
      );
    SQL

    # ** Transactional fixtures. **
    @_db.transaction

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database =>  db_name
    )
  end

  config.after :each, :active_record => true do
    @_db.rollback
  end

  config.before :each, :middleware => true do
    class WorkerClass; end

    @worker = WorkerClass.new
    @payload = { 'class' => 'WorkerClass', 'args' => [1, 2]}
  end
end

def safe(method, *args)
  send(method, *args)
rescue Exception
  nil
end
