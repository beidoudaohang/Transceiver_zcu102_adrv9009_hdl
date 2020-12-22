#!/bin/bash -f
#*********************************************************************************************************
# Vivado (TM) v2018.3 (64-bit)
#
# Filename    : xvr_refclk_out.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Simulation script for compiling, elaborating and verifying the project source files.
#               The script will automatically create the design libraries sub-directories in the run
#               directory, add the library logical mappings in the simulator setup file, create default
#               'do/prj' file, execute compilation, elaboration and simulation steps.
#
# Generated by Vivado on Fri Dec 18 11:11:27 -0800 2020
# SW Build 2405991 on Thu Dec  6 23:38:27 MST 2018
#
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved. 
#
# usage: xvr_refclk_out.sh [-help]
# usage: xvr_refclk_out.sh [-lib_map_path]
# usage: xvr_refclk_out.sh [-noclean_files]
# usage: xvr_refclk_out.sh [-reset_run]
#
#*********************************************************************************************************

# Command line options
xvlog_opts="--relax -L axi_vip_v1_1_4 -L zynq_ultra_ps_e_vip_v1_0_4 -L smartconnect_v1_0 -L xilinx_vip"


# Script info
echo -e "xvr_refclk_out.sh - Script generated by export_simulation (Vivado v2018.3 (64-bit)-id)\n"

# Main steps
run()
{
  check_args $# $1
  setup $1 $2
  compile
  elaborate
  simulate
}

# RUN_STEP: <compile>
compile()
{
  # Compile design files
  xvlog $xvlog_opts -prj vlog.prj 2>&1 | tee compile.log

}

# RUN_STEP: <elaborate>
elaborate()
{
  xelab --relax --debug typical --mt auto -L gtwizard_ultrascale_v1_7_5 -L xil_defaultlib -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot xvr_refclk_out xil_defaultlib.xvr_refclk_out xil_defaultlib.glbl -log elaborate.log
}

# RUN_STEP: <simulate>
simulate()
{
  xsim xvr_refclk_out -key {Behavioral:sim_1:Functional:xvr_refclk_out} -tclbatch cmd.tcl -protoinst "protoinst_files/bd_a17c.protoinst" -protoinst "protoinst_files/bd_31bd.protoinst" -protoinst "protoinst_files/bd_c0fd.protoinst" -protoinst "protoinst_files/bd_503c.protoinst" -protoinst "protoinst_files/system.protoinst" -log simulate.log
}

# STEP: setup
setup()
{
  case $1 in
    "-lib_map_path" )
      if [[ ($2 == "") ]]; then
        echo -e "ERROR: Simulation library directory path not specified (type \"./xvr_refclk_out.sh -help\" for more information)\n"
        exit 1
      fi
     copy_setup_file $2
    ;;
    "-reset_run" )
      reset_run
      echo -e "INFO: Simulation run files deleted.\n"
      exit 0
    ;;
    "-noclean_files" )
      # do not remove previous data
    ;;
    * )
     copy_setup_file $2
  esac

  # Add any setup/initialization commands here:-

  # <user specific commands>

}

# Copy xsim.ini file
copy_setup_file()
{
  file="xsim.ini"
  lib_map_path="C:/software/Xilinx/Vivado/2018.3/data/xsim"
  if [[ ($1 != "") ]]; then
    lib_map_path="$1"
  fi
  if [[ ($lib_map_path != "") ]]; then
    src_file="$lib_map_path/$file"
    if [[ -e $src_file ]]; then
      cp $src_file .
    fi

    # Map local design libraries to xsim.ini
    map_local_libs

  fi
}

# Map local design libraries
map_local_libs()
{
  updated_mappings=()
  local_mappings=()

  # Local design libraries
  local_libs=()

  if [[ 0 == ${#local_libs[@]} ]]; then
    return
  fi

  file="xsim.ini"
  file_backup="xsim.ini.bak"

  if [[ -e $file ]]; then
    rm -f $file_backup
    # Create a backup copy of the xsim.ini file
    cp $file $file_backup
    # Read libraries from backup file and search in local library collection
    while read -r line
    do
      IN=$line
      # Split mapping entry with '=' delimiter to fetch library name and mapping
      read lib_name mapping <<<$(IFS="="; echo $IN)
      # If local library found, then construct the local mapping and add to local mapping collection
      if `echo ${local_libs[@]} | grep -wq $lib_name` ; then
        line="$lib_name=xsim.dir/$lib_name"
        local_mappings+=("$lib_name")
      fi
      # Add to updated library mapping collection
      updated_mappings+=("$line")
    done < "$file_backup"
    # Append local libraries not found originally from xsim.ini
    for (( i=0; i<${#local_libs[*]}; i++ )); do
      lib_name="${local_libs[i]}"
      if `echo ${local_mappings[@]} | grep -wvq $lib_name` ; then
        line="$lib_name=xsim.dir/$lib_name"
        updated_mappings+=("$line")
      fi
    done
    # Write updated mappings in xsim.ini
    rm -f $file
    for (( i=0; i<${#updated_mappings[*]}; i++ )); do
      lib_name="${updated_mappings[i]}"
      echo $lib_name >> $file
    done
  else
    for (( i=0; i<${#local_libs[*]}; i++ )); do
      lib_name="${local_libs[i]}"
      mapping="$lib_name=xsim.dir/$lib_name"
      echo $mapping >> $file
    done
  fi
}

# Delete generated data from the previous run
reset_run()
{
  files_to_remove=(xelab.pb xsim.jou xvhdl.log xvlog.log compile.log elaborate.log simulate.log xelab.log xsim.log run.log xvhdl.pb xvlog.pb xvr_refclk_out.wdb xsim.dir)
  for (( i=0; i<${#files_to_remove[*]}; i++ )); do
    file="${files_to_remove[i]}"
    if [[ -e $file ]]; then
      rm -rf $file
    fi
  done
}

# Check command line arguments
check_args()
{
  if [[ ($1 == 1 ) && ($2 != "-lib_map_path" && $2 != "-noclean_files" && $2 != "-reset_run" && $2 != "-help" && $2 != "-h") ]]; then
    echo -e "ERROR: Unknown option specified '$2' (type \"./xvr_refclk_out.sh -help\" for more information)\n"
    exit 1
  fi

  if [[ ($2 == "-help" || $2 == "-h") ]]; then
    usage
  fi
}

# Script usage
usage()
{
  msg="Usage: xvr_refclk_out.sh [-help]\n\
Usage: xvr_refclk_out.sh [-lib_map_path]\n\
Usage: xvr_refclk_out.sh [-reset_run]\n\
Usage: xvr_refclk_out.sh [-noclean_files]\n\n\
[-help] -- Print help information for this script\n\n\
[-lib_map_path <path>] -- Compiled simulation library directory path. The simulation library is compiled\n\
using the compile_simlib tcl command. Please see 'compile_simlib -help' for more information.\n\n\
[-reset_run] -- Recreate simulator setup files and library mappings for a clean run. The generated files\n\
from the previous run will be removed. If you don't want to remove the simulator generated files, use the\n\
-noclean_files switch.\n\n\
[-noclean_files] -- Reset previous run, but do not remove simulator generated files from the previous run.\n\n"
  echo -e $msg
  exit 1
}

# Launch script
run $1 $2
