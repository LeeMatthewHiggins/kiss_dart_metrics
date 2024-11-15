#!/bin/bash

# Initialize arrays for storing class relationships
classes=()
parents=()

# Initialize counters for regular Dart files
total_lines=0
total_files=0
total_classes=0
max_file_lines=0
max_file_name=""

# Initialize counters for generated Dart files
gen_total_lines=0
gen_total_files=0
gen_total_classes=0
gen_max_file_lines=0
gen_max_file_name=""

# Function to find classes and their parents
find_inheritance() {
  grep -oE "class [a-zA-Z0-9_]+ *(extends|implements) *[a-zA-Z0-9_]+" "$1" | awk '{print $2 " " $NF}'
}

# Function to process Dart files and update counters
process_file() {
  local file="$1"
  local is_generated="$2"

  # Count lines in the current file
  file_lines=$(wc -l < "$file")
  
  if [ "$is_generated" = true ]; then
    gen_total_files=$((gen_total_files + 1))
    gen_total_lines=$((gen_total_lines + file_lines))
    if (( file_lines > gen_max_file_lines )); then
      gen_max_file_lines=$file_lines
      gen_max_file_name="$file"
    fi
  else
    total_files=$((total_files + 1))
    total_lines=$((total_lines + file_lines))
    if (( file_lines > max_file_lines )); then
      max_file_lines=$file_lines
      max_file_name="$file"
    fi
  fi

  # Find classes and their inheritance relationships
  while read -r class parent; do
    classes+=("$class")
    parents+=("$parent")
    if [ "$is_generated" = true ]; then
      gen_total_classes=$((gen_total_classes + 1))
    else
      total_classes=$((total_classes + 1))
    fi
  done < <(find_inheritance "$file")
}

# Find and process all Dart files
for file in $(find "$1" -name '*.dart'); do
  if [[ "$file" =~ \.g\.dart$|\.freezed\.dart$|\.gr\.dart$|\.gen\.dart$ ]]; then
    process_file "$file" true
  else
    process_file "$file" false
  fi
done

# Generate and print the class diagram
if [ ${#classes[@]} -gt 0 ]; then
  echo -e "\nClass Diagram (Inheritance Relationships):\n"
  
  for i in "${!parents[@]}"; do
    parent="${parents[$i]}"
    
    if [[ ! $class_diagram =~ "$parent" ]]; then
      echo "$parent"
      
      for j in "${!parents[@]}"; do
        if [[ "${parents[$j]}" == "$parent" ]]; then
          echo -e "  └── ${classes[$j]}"
        fi
      done
      
      class_diagram="$class_diagram$parent\n"
    fi
  done
else
  echo -e "\nNo inheritance relationships found in the project."
fi

# Calculate average file line counts
if (( total_files > 0 )); then
  average_file_lines=$((total_lines / total_files))
else
  average_file_lines=0
fi

if (( gen_total_files > 0 )); then
  gen_average_file_lines=$((gen_total_lines / gen_total_files))
else
  gen_average_file_lines=0
fi

# Print the summary
echo -e "\nSummary:"
echo "Regular Dart Files:"
echo "  Total Files Checked: $total_files"
echo "  Total Lines of Code: $total_lines"
echo "  Total Classes Found: $total_classes"
echo "  Average Lines per File: $average_file_lines"
echo "  Max Lines in a Single File: $max_file_lines ($max_file_name)"

echo "Generated Dart Files:"
echo "  Total Files Checked: $gen_total_files"
echo "  Total Lines of Code: $gen_total_lines"
echo "  Total Classes Found: $gen_total_classes"
echo "  Average Lines per File: $gen_average_file_lines"
echo "  Max Lines in a Single File: $gen_max_file_lines ($gen_max_file_name)"
