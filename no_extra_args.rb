require 'csv'

def process_csv(in_file, out_file)
  object_headers, primary_headers, parsed = get_headers(in_file)['object'], get_headers(in_file)['primary'], get_headers(in_file)['parsed']

  CSV.foreach(in_file, headers: true) do |row|
    unique_id = row[0] # Assuming first primary header is the unique id

    object_fields = {}
    # populate object data
    object_headers.each do |oh|
      object_fields[oh] = row[oh]
    end

    # add object fields and increase count
    parsed[unique_id]['objects'] << object_fields
    parsed[unique_id]['object count'] += 1
  end

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
    # write to output file
    CSV.open(out_file, 'w', write_headers: true, headers: new_headers) do |csv|
      parsed.each do |key, vals|
        row = primary_headers.map { |ph| vals[ph] }
        vals['objects'].each { |obj| object_headers.each { |oh| row << obj[oh] } }
        csv << row
      end
    end

    puts "Multiple duplicate primary records from #{in_file} have been transformed and written to #{out_file} with single rows representing primary and multiple associated objects"
end


def get_headers(in_file)
  object_headers = []
  parsed = {}
  primary_headers = CSV.read(in_file, headers: true).headers.uniq.freeze
  # puts primary_headers
  CSV.foreach(in_file, headers: true) do |row|
    unique_id = row[0] # get unique id from first column
    if parsed.key?(unique_id) # Create or append to the parsed hash
      # Find columns with unique data in the current row
      object_headers << row.headers.select do |header|
        row[header] != parsed[unique_id][header]
      end
      primary_headers -= object_headers
    else
      primary_headers.each do |val|
        parsed[unique_id] ||= {}  # create an empty hash if it doesn't exist
        parsed[unique_id][val] = row[val]  # assign the value to the hash key
        parsed[unique_id]['object count'] = 0  # add count for dynamic naming
        parsed[unique_id]['objects'] = []  # add object store
      end
    end
  end

  return {'object' => object_headers.first, 'primary' => (primary_headers -= object_headers.first), 'parsed' => parsed}
end


# get user provided args
in_file = ARGV[0]
out_file = ARGV[1]

process_csv(in_file, out_file)

