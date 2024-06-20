require 'csv'

def process_csv(in_file, out_file, first_object_field)
  parsed = {}
  primary_headers = []
  object_headers = []

  # get primary and object headers
  CSV.read(in_file, headers: true).headers.each_with_index do |h, i|
    if h == first_object_field
      object_headers = CSV.read(in_file, headers: true).headers[i..-1]
      primary_headers = CSV.read(in_file, headers: true).headers[0...i]
      break
    end
  end

  # process each row in the CSV
  CSV.foreach(in_file, headers: true) do |row|
    unique_id = row[primary_headers.first] # Assuming first primary header is the unique id
    # if not existing, create parsed record
    parsed[unique_id] ||= {
      'objects' => [],
      'object count' => 0
    }
    # populate primary fields
    primary_headers.each do |ph|
      parsed[unique_id][ph] = row[ph]
    end

    # populate object fields
    object_fields = {}
    object_headers.each do |oh|
      object_fields[oh] = row[oh]
    end

    # add object fields and increase count
    parsed[unique_id]['objects'] << object_fields
    parsed[unique_id]['object count'] += 1
  end

  # generate new headers for output
  max_count = parsed.values.map{ |val| val['object count']}.max|| 0  # get the final object count for each unique_id
  new_headers = primary_headers # primary headers to initialize array
    # Generate dynamic headers based on count
    (1..max_count).each { |i|
      object_headers.each do |oh|
        new_headers += [
          "#{oh} #{i}",
        ]
      end
    }

  # Write to output CSV
  CSV.open(out_file, 'w', write_headers: true, headers: new_headers) do |csv|
    parsed.each do |key, vals|
      row = primary_headers.map { |ph| vals[ph] }
      vals['objects'].each { |obj| object_headers.each { |oh| row << obj[oh] } }
      csv << row
    end
  end

  puts "Multiple duplicate primary records from #{in_file} have been transformed and written to #{out_file} with single rows representing primary and multiple associated objects"
end

# get user provided args
in_file = ARGV[0]
out_file = ARGV[1]
first_object_field = ARGV[2]

process_csv(in_file, out_file, first_object_field)
# To Run - ruby script_name.rb input.csv output.csv first_object_field_name
