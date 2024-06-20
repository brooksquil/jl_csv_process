require 'csv'

def process_csv(in_file, out_file, first_object_field)
  parsed = {}
  primary_headers = []
  object_headers = []
  object_index = 0
  # get headers and store in array separated by index of given first column name
  CSV.read(in_file, headers: true).headers.each_with_index do |h, i|
    object_index = CSV.read(in_file, headers: true).headers.find_index(first_object_field).to_i
    i < object_index ? (primary_headers << h) : (object_headers << h)
  end
  # Read the CSV file with headers
  CSV.foreach(in_file, headers: true) do |row|
    unique_id = row[0] # get unique id from first column
    if parsed.key?(unique_id) # Create or append to the parsed hash
    else
      primary_headers.each do |val|
        parsed[unique_id] ||= {}  # create an empty hash if it doesn't exist
        parsed[unique_id][val] = row[val]  # assign the value to the hash key
        parsed[unique_id]['object count'] = 0  # add count for dynamic naming
        parsed[unique_id]['objects'] = []  # add object store
      end
    end

    object_fields = {}
    object_headers.each do |val|
        object_fields[val] = row[val]  # get object values
    end

    parsed[unique_id]['objects'] << object_fields # add values to object array
    parsed[unique_id]['object count'] += 1 # increase count

  end


    new_headers = primary_headers # primary headers
  # get the final object count for each unique_id
    max_count = parsed.values.map{ |val| val['object count']}.max|| 0
    # Generate dynamic headers based on count
    (1..max_count).each { |i|
      object_headers.each do |oh|
        new_headers += [
          "#{oh} #{i}",
        ]
      end
    }
  # Write the transformed data to a new CSV
  CSV.open(out_file, 'w', write_headers: true, headers: new_headers) do |csv|
    parsed.each{ |key, vals|
      # set primary object rows based on unique_id
      row = []
      primary_headers.each do |ph|
        row << vals[ph]
      end

      # add vehiclies to base row
      vals['objects'].each { |obj|
      object_headers.each do |oh|
        row << obj[oh]
      end
      }
      csv << row
    }
  end

  puts "Processed #{in_file} and wrote results to #{out_file}"
end

# get command line args
in_file = ARGV[0]
out_file = ARGV[1]
first_object_field = ARGV[2]

process_csv(in_file, out_file, first_object_field)

