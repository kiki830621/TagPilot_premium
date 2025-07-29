# This is a reference to the function that has been functionalized
# Function has been moved to the proper location at:
# /update_scripts/global_scripts/00_functions/fn_get_r_files_recursive.R
# 
# This follows MP48 (Functionalizing) and R33 (Recursive Sourcing Rule)
#
# The function signature is:
# get_r_files_recursive(dir_path, include_pattern = "\\.R$", exclude_pattern = "test\\.R$", max_depth = Inf)
#
# Purpose: Enhanced recursive file finder that ensures all components in subdirectories are properly loaded