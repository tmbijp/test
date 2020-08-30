#!/bin/bash
trace_branch="v1.0.0"
git_status="$(git status -s 2>&1 1> /dev/null )"
if [ "$git_status" ];then
  echo "$git_status"
  echo "git status取得に失敗したため処理を中止します"
  exit
fi

git_branch="$(git branch -a)"
current_branch=$(echo "$git_branch"|grep '^* '|awk '{ print $2 }')
echo "current_branch #=>$current_branch"

if [ "$(echo "$git_branch"|grep "remotes/origin/$trace_branch")" = "" ];then
  echo "cannot find local branch remotes/origin/$trace_branch"
  exit
fi
if [ "$(echo "$git_branch"|grep "remotes/upstream/$trace_branch")" = "" ];then
  echo "cannot find local branch remotes/upstream/$trace_branch"
  exit
fi
echo "OK"

