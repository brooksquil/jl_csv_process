require 'csv'
# Non - automagical solution - too specific to this file and it's data
def process_csv(in_file, out_file)
  parsed = {}

  # Read the CSV file with headers
  CSV.foreach(in_file, headers: true) do |row|
    # get client_id
    sfid = row['sfid']

    # Create or append to the parsed hash
    parsed.key?(sfid) ? "" : parsed[sfid] = {
          'sfid' => sfid,
          'first name' => row['first name'],
          'last name' => row['last name'],
          'address' => row['address'],
          'city' => row['city'],
          'state' => row['state'],
          'zip code' => row['zip code'],
          'email' => row['email'],
          'mobile phone' => row['mobile phone'],
          'sms permission' => row['sms permission'],
          # initialize vehicle count for dynamic headers in output file
          'vehicle count' => 0,
          # initialize vehicle array to store multiple vehicles per sfid entry
          'vehicles' => []
    }

    # get field values
    vehicle_fields = {
      'make' => row['make'],
      'model' => row['model'],
      'year' => row['year'],
      'vin' => row['vin'],
      'mileage' => row['mileage'],
      'sol expires' => row['sol expires']
    }
    # add values to vehicle array
    parsed[sfid]['vehicles'] << vehicle_fields
    # increase count
    parsed[sfid]['vehicle count'] += 1
  end

  # client headers
  headers = ['sfid', 'first name', 'last name', 'address', 'city', 'state', 'zip code', 'email', 'mobile phone', 'sms permission']
  # get the final vehicle count of each unique_id
  max_count = parsed.values.map{ |val| val['vehicle count']}.max|| 0
  # Generate dynamic headers based on count
  (1..max_count).each { |i|
    headers += [
      "vehicle #{i} make",
      "vehicle #{i} model",
      "vehicle #{i} year",
      "vehicle #{i} vin",
      "vehicle #{i} mileage",
      "vehicle #{i} sol expires"
    ]
  }

  # Write the transformed data to a new CSV
  CSV.open(out_file, 'w', write_headers: true, headers: headers) do |csv|
    parsed.each{ |key, vals|
      # set base of row of vals per sfid
      row = [
        vals['sfid'],
        vals['first name'],
        vals['last name'],
        vals['address'],
        vals['city'],
        vals['state'],
        vals['zip code'],
        vals['email'],
        vals['mobile phone'],
        vals['sms permission'],
      ]
      # add vehiclies to base row
      vals['vehicles'].each { |v|
        row += [
          v['make'],
          v['model'],
          v['year'],
          v['vin'],
          v['mileage'],
          v['sol expires'],
        ]
      }
      csv << row
    }
  end

  puts "Processed #{in_file} and wrote results to #{out_file}"
end

# get command line args
in_file = ARGV[0]
out_file = ARGV[1]

process_csv(in_file, out_file)

