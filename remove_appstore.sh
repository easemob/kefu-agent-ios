#!/bin/bash

gsed -i "\/\/=*appstore start/,/\/\/=*appstore end/d" ./AgentSDKDemo/Main/Appdelegate.m
gsed -i "\/\/=*appstore start/,/\/\/=*appstore end/d" ./AgentSDKDemo/Main/HomeViewController.m
 
gsed -i "\/\/=*appstore start/,/\/\/=*appstore end/d" ./AgentSDKDemo/Main/KFLeftViewController.m
 
gsed -i "\/\/=*appstore start/,/\/\/=*appstore end/d" ./AgentSDKDemo/Main/view/DXUpdateView.m
