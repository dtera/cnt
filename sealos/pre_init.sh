#!/usr/bin/env bash

data_dir="/data"

yum remove -y containerd
rm -rf /var/lib/docker && rm -rf /var/lib/sealos
[ -d "$data_dir"/docker ] || mkdir -p "$data_dir"/docker
[ -d "$data_dir"/sealos ] || mkdir -p "$data_dir"/sealos
rm -rf "$data_dir"/docker/* "$data_dir"/sealos/*
ln -s "$data_dir"/docker /var/lib/docker
ln -s "$data_dir"/sealos /var/lib/sealos
