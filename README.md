The challenge:

- create a flexible solution to process csv files with duplicate primary records representing multiple associated objects, and output a new file with each primary record contained in a single row with associated objects
- dynamicalyy label object column headers
- assume first column is unique id

My approach:

1) I started with a brute force soltion specific to provided sample file to get a feel for working with the csv. This solution uses two args, in_file and out_file

run brute solution          ```
                                ruby brute.rb sol_client_vehicles.csv brute_results.csv
                            ```

2) Next I made the code dynamic so that a file with the same data relationships but varying content could be processed. I felt like I needed one more user arg to determine where the object headers begin. I added the third arg, the first object header string, and use it to find the index, then split headers into primary and object header arrays. using those I was able to dynamically access and store the values in the parsed hash. I tested this solution by creating a second csv to consume with similiar primary columns and pets for objects and was able to get the desired output from each.

run dynamic solution:
                            ```
                                ruby dynamic.rb sol_client_vehicles.csv dynamic_vehicles_results.csv "make"
                            ```
                            ```
                                ruby dynamic.rb pets.csv dynamic_pets_results.csv "species"
                            ```

1) Automagical Solution ( I like the term ): I refactored thy dynamic solution to make it more efficient and concise.


run automagical solution:
                            ```
                            ruby automagical.rb sol_client_vehicles.csv automagical_vehicle_results.csv "make"
                            ```
                            ```
                            ruby automagical.rb pets.csv automagical_pets_results.csv "species"
                            ```


Conclusion: This was fun to work on, My final solution is flexible but I imagine that my third argument could be a chanllenge to find in a large csv. It might be useful to have a UI with a categery drop down that could be used to recognize the object headers by key category words. I think that would be complex in intself because you would need dictionaries of categories and keywords to isolate those columns. It would also limit flixibilit to known categories.

If I had more time to spend I would test with larger files with a lot more data to see if it remains accurate. I would also try out other possible args to use instead of the first object header.

Looking forward to any input or suggestions
