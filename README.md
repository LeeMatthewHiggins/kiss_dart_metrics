# kiss_dart_metrics
Simple scripts for inspecting a dart codebase

Usage:
dart_metrics.sh /path/to/codebase


Output:

Class Diagram (Inheritance Relationships):

BaseClass
  └── Subclass1
  └── Subclass2

Summary:
Regular Dart Files:
  Total Files Checked: 594
  Total Lines of Code: 100000
  Total Classes Found: 425
  Average Lines per File: 82
  Max Lines in a Single File:     6169 (/path/to/fat.dart)
Generated Dart Files:
  Total Files Checked: 114
  Total Lines of Code: 25000
  Total Classes Found: 67
  Average Lines per File: 184
  Max Lines in a Single File:     1062 (/path/to/fat.dart)
