#!/bin/bash

st_unk=3
st_crit=2
st_warn=1
st_ok=0
number=0
tools=""
LANG=C

# Todavía puede fallar si no está alguna de estas dos herramientas instaladas
# pero es raro porque vienen en la instalación por defecto
rhev=$(dmidecode 2>/dev/null | grep -E 'oVirt|RHEV Hypervisor' || lspci 2>/dev/null | grep -E 'Virtio' )
vmware=$(ps auxf | grep vmtoolsd | grep -v grep)

if [ ! -z "$rhev" ]; then
	number=`mpstat 5 1 | tail -n 1 | awk '{ print $(NF-2) }'`
	tools="rhev"
elif [ ! -z "$vmware" ]; then
	number=`/usr/local/vmguestlib/vmguest-stats-stealXcpu -c | grep CPU | awk '{print $(NF-1)}'`;
	tools="vmware"
else
	tools="no"
fi

if [ $? -eq 0 ]; then
  if [ "$tools" == "rhev" ]; then
     msg="cpu_steal cpu_steal=$number;;;; CPU rhev stolen time: $number (%)"
     ret=$st_ok
  elif [ "$tools" == "vmware" ]; then
   msg="cpu_steal cpu_steal=$number;;;; CPU vmware stolen time: $number (%)"
   ret=$st_ok
  fi
elif [ "$tools" == "no" ]; then
   msg="cpu_steal cpu_steal=0;;;; No tiene instaladas las tools"
   ret=$st_unk
else
   msg="cpu_steal cpu_steal=0;;;; Algo no va bien"
   ret=$st_unk
fi

echo "$ret $msg"