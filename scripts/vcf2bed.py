import sys

# Check if the correct number of arguments is provided
if len(sys.argv) != 3:
    print("Usage: python script.py arg1 arg2")
    sys.exit(1)

# Read the input file name from argument
input_file = sys.argv[1]
output_file = sys.argv[2]

# Open the input and output files
with open(input_file, "r", encoding="utf-8") as infile, open(output_file, "w", encoding="utf-8") as outfile:
    # Iterate through each line in the input file
    for line in infile:
        if not line.startswith("#"):
            # Split the line into columns based on tabs
            columns = line.strip().split("\t")
            
            new_columns = [
                columns[0],
                columns[2].split(":")[-1].split("-")[-2],
                columns[2].split(":")[-1].split("-")[-1],
                columns[4][1:-1]
            ]
            
            # Create a new line with only the desired columns
            new_line = "\t".join(new_columns)
            
            # Write the new line to the output file
            outfile.write(new_line + "\n")