require 'optparse'
require 'tmpdir'
require 'fileutils'

options = {:time_span => 30, :verbose => false, :database => [], :mongo_bin => "", :mongo_data => nil}
last_update_info ={}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  
  opts.on("-t", "--time [MINUTES]", "Run backup every X minutes") do |time|
    options[:time_span] = time.to_i
  end
  
  opts.on("-d", "--database [DATABASE]", "MongoDB database to target") do |db|
    options[:database] << db
  end
  
  opts.on("-o", "--output_directory [DIRECTORY]", "Directory to dump to") do |dir|
    options[:output_directory] = File.absolute_path(dir)
  end
  
  opts.on("-b", "--mongo_bin [DIRECTORY]", "Location of MongoDB binaries") do |bin_path|
    options[:mongo_bin] = File.absolute_path(bin_path)
  end
  
  opts.on("-m", "--mongo_data [DIRECTORY]", "Location of MongoDB data") do |data_path|
    options[:mongo_data] = File.absolute_path(data_path)
  end
end.parse!
continue = true

options[:database].each {|db| last_update_info[db] = 0 }

# register
trap("SIGINT") do 
  abort unless continue
  continue = false
end

if options[:verbose]
  puts "INFO: Target DB is #{options[:database]}"
  puts "INFO: Output directory is #{options[:output_directory]}"
  puts "INFO: Data dump will occur every #{options[:time_span]} minutes"
end

# perform sanity checks
abort "ERROR: Directory '#{options[:output_directory]}' does not exist" unless Dir.exists?(options[:output_directory])

# check MongoDB is aware of the chosen DB(s)
abort "ERROR: No database specified" unless options[:database].length > 0
cmd = options[:mongo_bin].empty? ? "mongo" : "#{options[:mongo_bin]}/mongo"
mongo_dbs = `echo 'show dbs' | #{cmd} --quiet`
retry_count = 0
while retry_count < 5
  mongo_dbs = `echo 'show dbs' | #{cmd} --quiet`
  sleep 5
  retry_count = retry_count + 1
end
options[:database].each {|db| abort("ERROR: MongoDB is not aware of '#{db}'") unless mongo_dbs.include?(db)}

abort "ERROR: MongoDB data store does not exist" if options[:mongo_data] && !options[:mongo_data].empty? && !(Dir.exists?(options[:mongo_data]))

# run an initial dump
sleep_time = options[:time_span]
while continue do
  # begin ops
  kick_off = Time.now
  options[:database].each do |db|
    puts "INFO: Analysing #{db}" if options[:verbose]
    perform_save = false
    
    if options[:mongo_data] && !options[:mongo_data].empty?
      # check the MongoDB datastor for a more accurate updated at
      last_update_time = 0
      Dir.glob("#{options[:mongo_data]}/#{db}.*") do |jrnl_file|
        file_mtime = File.mtime(jrnl_file).to_i
        last_update_time = file_mtime if last_update_time < file_mtime
      end
      
      # update counters
      if last_update_time > last_update_info[db]
        puts "INFO: Will perform save, journal data is newer than previous run" if options[:verbose]
        last_update_info[db] = last_update_time
        perform_save = true
      end
    else
      perform_save = true
    end
    
    if perform_save
      puts "INFO: Will save #{db}" if options[:verbose]
      
      # allocate space for temporary writing
      tmp_dir = Dir.mktmpdir
      final_loc = "#{tmp_dir}/#{db}"
      arch_loc = "#{options[:output_directory]}/#{db}_#{kick_off.to_i}.tar.gz"
      
      # get a dump
      dump_cmd = "~/Applications/MongoDB/bin/mongodump --db #{db} -o #{tmp_dir}"
      # MongoDB really likes writing everything to STDERR
      out_err = ""
      IO.popen("#{dump_cmd} 2>&1") do |pipe| 
       while((line = pipe.gets)) 
         out_err << line 
       end
      end
      
      if $?.exitstatus == 0 && Dir.exists?(final_loc)
        # compress back to safe directory
        compress_run = `tar -czpPf #{arch_loc} #{final_loc}`
        if $?.exitstatus == 0 && File.exists?(arch_loc)
          puts "SAVED: #{db} to #{arch_loc}"
        else
          puts "ERROR: Compress failed for #{db}"
          puts compress_run
        end
      else
        puts "ERROR: Mongodump failed for #{db}"
        puts out_err
      end
      # clean up
      FileUtils.rm_rf(tmp_dir)
    end
    
  end
  
  puts "INFO: Sleeping for #{sleep_time}" if options[:verbose]
  sleep(sleep_time * 60)
end

puts "Ended" if options[:verbose]