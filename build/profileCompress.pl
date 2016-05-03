BEGIN { $\ = undef; }
s/\r//g;                  # remove all CR characters
s/\t/    /g;              # replace all tabs with 4 spaces
if (/^\s/) {              # ignore the the xml root node
  s/\n//;                 # remove newlines
  s/^    (?=<(?!\/))/\n/; # insert newlines where appropriate
  s/^(    )+//;           # trim remaining whitespace
}
# ---- HOW TO USE IT ----
# In a Terminal or a Command Line Interface, run :
# perl -i.bak -p profileCompress.pl ../src/profiles/*.profile ../src/permissionsets/*.permissionset