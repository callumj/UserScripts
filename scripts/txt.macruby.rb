require 'rubygems'
require 'yaml'
require 'clickatell'
require 'sqlite3'
framework "Cocoa"
framework "AddressBook"

# get stuff out of AddressBook.app
def get_numbers_from_ab(args = {})
  globalAddressBook = ABAddressBook.sharedAddressBook

  queryString = args[:string].nil? ? "*" : args[:string]
  matchValidator = Regexp.compile "^#{args[:validator].nil? ? "04" : args[:validator].nil?}"
  numberPrefix = Regexp.compile "^#{args[:prefix].nil? ? "61" : args[:prefix].nil?}"
  
  # query the address book
  firstCriteriaElement = ABPerson.searchElementForProperty(KABFirstNameProperty, label:nil, key:nil, value:queryString, comparison: KABContainsSubStringCaseInsensitive)
  lastCriteriaElement = ABPerson.searchElementForProperty(KABLastNameProperty, label:nil, key:nil, value:queryString, comparison: KABContainsSubStringCaseInsensitive)

  findResults = globalAddressBook.recordsMatchingSearchElement(firstCriteriaElement)
  findResults = [] if findResults.nil?
  findResults = findResults + globalAddressBook.recordsMatchingSearchElement(lastCriteriaElement)
  findResults = [] if findResults.nil?

  phone_numbers = [] # store it

  findResults.each do |record|
    # query for phone data
    multiDataHolder = record.valueForProperty("Phone")
    unless multiDataHolder.nil?
      for index in 0..(multiDataHolder.count - 1)
        # normalise the data
        phoneNumber = multiDataHolder.valueAtIndex(index).mutableCopy.strip
        phoneNumber.gsub!(/[\s+-]/,'')
        phoneNumber.gsub!(numberPrefix,'0')
        # verify
        unless matchValidator.match(phoneNumber).nil?
          phone_numbers << {
            :first_name => record.valueForProperty("FirstName"),
            :last_name => record.valueForProperty("LastName"),
            :number => phoneNumber,
            :ref => record.uniqueId
          }
        end
      end
    end
  end
  
  phone_numbers # done
end

def interact_with_cli()
  # do some dummy checking
  abort "Usage: #{__FILE__} [name] [message]" if ARGV.length < 2
  
  # setup options
  configFile = File.open(File.join(ENV['HOME'], '.clickatell'))
  config = YAML.load(configFile)
  name = ARGV[0].strip
  messageOffset = 1
  message = (ARGV[messageOffset, ARGV.length - messageOffset] * " ").strip
  
  # verify
  abort "Unable to read clickatell config file" if config.nil?
  abort "You need to supply a recipient" if name.empty?
  abort "You need to supply a text message" if message.empty?  
  
  # find the peeps
  people = get_numbers_from_ab(:string => name)
  
  abort "Couldn't find anyone matching #{name}" if people.length == 0
  
  targetPerson = nil
  if people.length > 1
    targetPerson = invoke_picker(people)
  else
    targetPerson = people.first
  end
  
  abort "Unable to locate user" if targetPerson.nil?
  
  # perform rewrite
  number = targetPerson[:number]
  number.gsub!(/^0/, '61')
  api = construct_api(:api_key => config["api_key"], :username => config["username"], :password => config["password"])
  puts "Hey, your balance is $#{api.account_balance}"
  sendTime = Time.now
  messageId = send_message(api, config["from"], number, message)
  puts "Message send, reference #{messageId}"
  # Sqlite3 does not work well with MacRuby
  #record_message(:message => message, :message_id => messageId, :time => sendTime, :recipient => number)
end

def invoke_picker(data)
  puts "Select the person to send to"
  selectedPerson = nil
  while selectedPerson.nil?
    data.each do |person|
      name = "#{person[:first_name]} #{person[:last_name]}".strip
      puts " [#{data.index(person) + 1}] #{name} (#{person[:number]})"
    end
  
    print "Enter person index: "
    index = STDIN.gets
    if (/\d+/.match(index) != nil)
      arrayIndex = (index.to_i - 1)
      selectedPerson = data[arrayIndex] if arrayIndex >= 0 && arrayIndex < data.length
    end
  end
  
  selectedPerson
end

def construct_api(args = {})
  Clickatell::API.authenticate(args[:api_key], args[:username], args[:password])
end

def send_message(api, from, number, message)
  abort "Message is too long, Try with #{message[0,160]}" if message.length > 160
  
  api.send_message(from, message, {:from => from})
end

def record_message(args = {})
  database = SQLite3::Database.new(File.join(ENV['HOME'], '.txtdb.db'))
  puts 'okay'
  init_table_if_needed(database)
  
  database.execute("INSERT INTO 'messages' VALUES ('#{args[:time]}', '#{args[:recipient]}', '#{args[:message]}', '#{args[:message_id]}')")
end

def init_table_if_needed(database)
  db_exists = (database.execute("SELECT COUNT(*) FROM messages") rescue false)
  
  unless db_exists
    database.execute('CREATE TABLE "messages" ("time" INTEGER PRIMARY KEY, "recipient" TEXT, "message" TEXT, "message_id" TEXT);')
  end
  
end

# MacRuby is too pedantic and likes to raise exceptions
def abort(msg)
  puts msg
  exit(1)
end

#puts get_numbers_from_ab(:string => "Callum").inspect

interact_with_cli